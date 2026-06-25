package com.neverdisband.controller;

import com.neverdisband.dao.BankDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.RecruitSettlementDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildMember;
import com.neverdisband.model.GuildRole;
import com.neverdisband.model.RecruitSettlement;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/{subdomain}/admin")
public class AdminController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final UserDao userDao;
    private final BankDao bankDao;
    private final RecruitSettlementDao settlementDao;
    private final SimpMessagingTemplate messagingTemplate;

    public AdminController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                           UserDao userDao, BankDao bankDao,
                           RecruitSettlementDao settlementDao,
                           SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.bankDao = bankDao;
        this.settlementDao = settlementDao;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 은행 관리 페이지 fragment
     */
    @GetMapping("/bank")
    public String bankAdminPage(@PathVariable String subdomain, HttpSession session) {
        if (validateOfficer(subdomain, session) == null) return "fragments/bank-admin";
        return "fragments/bank-admin";
    }

    /**
     * 은행 관리 정보 조회 — pending 목록 + 처리 로그 + 멤버 목록
     */
    @GetMapping("/bank/info")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bankInfo(
            @PathVariable String subdomain, HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        Long guildId = officer.getGuildId();

        List<Map<String, Object>> withdrawals = bankDao.findPendingByType(guildId, "withdrawal");
        List<Map<String, Object>> deposits = bankDao.findPendingByType(guildId, "deposit");
        List<Map<String, Object>> logs = bankDao.findProcessedLogs(guildId, 50);
        List<Map<String, Object>> members = guildMemberDao.findAllWithBalance(guildId);

        return ResponseEntity.ok(Map.of(
                "withdrawals", withdrawals,
                "deposits", deposits,
                "logs", logs,
                "members", members
        ));
    }

    /**
     * 신청서 승인 (복수 건, 금액 수정 가능)
     */
    @PostMapping("/bank/approve")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> approve(
            @PathVariable String subdomain,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        List<Integer> ids = ((List<?>) body.get("ids")).stream()
                .map(o -> ((Number) o).intValue()).toList();
        Long overrideAmount = body.containsKey("amount") && body.get("amount") != null
                ? ((Number) body.get("amount")).longValue() : null;

        for (int id : ids) {
            bankDao.approve((long) id, overrideAmount, officer.getId());
            // balance 반영
            var tx = bankDao.findById((long) id);
            if (tx != null) {
                long amount = overrideAmount != null && ids.size() == 1 ? overrideAmount : (long) tx.get("amount");
                long memberId = ((Number) tx.get("member_id")).longValue();
                String type = (String) tx.get("type");
                if ("withdrawal".equals(type)) {
                    // 잔액 부족 검사
                    var member = guildMemberDao.findById(memberId);
                    if (member == null || member.getBalance() < amount) {
                        bankDao.reject((long) id, officer.getId()); // 잔액 부족으로 자동 반려
                        continue;
                    }
                    guildMemberDao.updateBalance(memberId, -amount);
                } else {
                    guildMemberDao.updateBalance(memberId, amount);
                }
                notifyBalanceChange(memberId);

                // 정산 참여비 자동 완료 체크
                Object settlementIdObj = tx.get("settlement_id");
                if (settlementIdObj != null) {
                    Long settlementId = ((Number) settlementIdObj).longValue();
                    if (bankDao.allApprovedBySettlementId(settlementId)) {
                        settlementDao.updateFeeStatus(settlementId, RecruitSettlement.SettleStatus.DONE);
                    }
                }
            }
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 신청서 반려 (복수 건)
     */
    @PostMapping("/bank/reject")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> reject(
            @PathVariable String subdomain,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        List<Integer> ids = ((List<?>) body.get("ids")).stream()
                .map(o -> ((Number) o).intValue()).toList();

        for (int id : ids) {
            var tx = bankDao.findById((long) id);
            bankDao.reject((long) id, officer.getId());
            // 멤버에게 상태 변경 알림
            if (tx != null) {
                long memberId = ((Number) tx.get("member_id")).longValue();
                notifyBalanceChange(memberId);
            }
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 직접 입출금 (신청서 없이 바로 처리)
     */
    @PostMapping("/bank/direct")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> direct(
            @PathVariable String subdomain,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        long memberId = ((Number) body.get("memberId")).longValue();
        long amount = ((Number) body.get("amount")).longValue();
        String type = (String) body.get("type");

        if (amount <= 0) return ResponseEntity.badRequest().body(Map.of("error", "유효하지 않은 금액"));

        // 출금 시 잔액 확인
        if ("withdrawal".equals(type)) {
            var member = guildMemberDao.findById(memberId);
            if (member == null || member.getBalance() < amount) {
                return ResponseEntity.badRequest().body(Map.of("error", "잔액 부족"));
            }
        }

        bankDao.createDirect(officer.getGuildId(), memberId, type, amount, officer.getId());

        if ("withdrawal".equals(type)) {
            guildMemberDao.updateBalance(memberId, -amount);
        } else {
            guildMemberDao.updateBalance(memberId, amount);
        }

        notifyBalanceChange(memberId);

        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 일별 순이익 그래프 데이터
     */
    @GetMapping("/bank/profit")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> profit(
            @PathVariable String subdomain,
            @RequestParam(defaultValue = "month") String period,
            HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        java.time.LocalDate from = switch (period) {
            case "week" -> java.time.LocalDate.now().minusWeeks(1);
            case "6month" -> java.time.LocalDate.now().minusMonths(6);
            case "year" -> java.time.LocalDate.now().minusYears(1);
            default -> java.time.LocalDate.now().minusMonths(1);
        };

        List<Map<String, Object>> daily = bankDao.getDailyProfit(officer.getGuildId(), from.toString());
        return ResponseEntity.ok(Map.of("daily", daily));
    }

    /**
     * 보유 현황 (총 자금 + 멤버 balance 순위)
     */
    @GetMapping("/bank/holdings")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> holdings(
            @PathVariable String subdomain, HttpSession session) {

        var officer = validateOfficer(subdomain, session);
        if (officer == null) return ResponseEntity.status(403).build();

        List<Map<String, Object>> members = guildMemberDao.findAllWithBalance(officer.getGuildId());
        long total = members.stream().mapToLong(m -> ((Number) m.get("balance")).longValue()).sum();

        return ResponseEntity.ok(Map.of("total", total, "members", members));
    }

    /**
     * silver_master 또는 guild_master 역할 체크
     */
    private GuildMember validateOfficer(String subdomain, HttpSession session) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) return null;

        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) return null;

        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) return null;

        var member = guildMemberDao.findByGuildIdAndUserId(guildOpt.get().getId(), userOpt.get().getId());
        if (member == null) return null;

        var roles = guildMemberDao.findRolesByMemberId(member.getId());
        boolean hasAccess = roles.stream().anyMatch(r ->
                r.getRole() == GuildRole.GUILD_MASTER || r.getRole() == GuildRole.SILVER_MASTER);

        if (!hasAccess) return null;
        return member;
    }

    /**
     * 멤버 balance 변경 후 WebSocket 알림
     */
    private void notifyBalanceChange(Long memberId) {
        var member = guildMemberDao.findById(memberId);
        if (member == null) return;
        var user = userDao.findById(member.getUserId());
        if (user.isEmpty()) return;
        messagingTemplate.convertAndSend(
                "/topic/user/" + user.get().getDiscordId() + "/balance",
                Map.of("balance", member.getBalance()));
    }
}
