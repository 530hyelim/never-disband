package com.neverdisband.controller;

import com.neverdisband.dao.BankDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildMember;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/{subdomain}/bank")
public class BankController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final UserDao userDao;
    private final BankDao bankDao;
    private final SimpMessagingTemplate messagingTemplate;

    public BankController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                          UserDao userDao, BankDao bankDao,
                          SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.bankDao = bankDao;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 은행 fragment 반환
     */
    @GetMapping
    public String bankPage(@PathVariable String subdomain) {
        return "fragments/bank";
    }

    /**
     * 내 잔액 + 거래 내역 조회
     */
    @GetMapping("/info")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getInfo(
            @PathVariable String subdomain, HttpSession session) {

        var member = validateMember(subdomain, session);
        if (member == null) return ResponseEntity.status(403).build();

        List<Map<String, Object>> transactions = bankDao.findByMember(
                member.getGuildId(), member.getId(), 50);
        boolean hasPending = bankDao.hasPendingWithdrawal(member.getGuildId(), member.getId());

        return ResponseEntity.ok(Map.of(
                "balance", member.getBalance(),
                "transactions", transactions,
                "hasPending", hasPending
        ));
    }

    /**
     * 출금 신청
     */
    @PostMapping("/withdraw")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> withdraw(
            @PathVariable String subdomain,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var member = validateMember(subdomain, session);
        if (member == null) return ResponseEntity.status(403).build();

        long amount;
        try {
            amount = Long.parseLong(body.get("amount").toString());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "유효하지 않은 금액입니다."));
        }

        if (amount <= 0) {
            return ResponseEntity.badRequest().body(Map.of("error", "0보다 큰 금액을 입력해주세요."));
        }

        if (amount > member.getBalance()) {
            return ResponseEntity.badRequest().body(Map.of("error", "잔액이 부족합니다."));
        }

        if (bankDao.hasPendingWithdrawal(member.getGuildId(), member.getId())) {
            return ResponseEntity.badRequest().body(Map.of("error", "이미 대기 중인 출금 신청이 있습니다."));
        }

        bankDao.createWithdrawal(member.getGuildId(), member.getId(), amount);

        // 은행 관리 페이지에 실시간 알림
        var guild = guildDao.findById(member.getGuildId());
        if (guild.isPresent()) {
            messagingTemplate.convertAndSend("/topic/guild/" + guild.get().getSubdomain() + "/bank", "update");
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    private GuildMember validateMember(String subdomain, HttpSession session) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) return null;

        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) return null;

        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) return null;

        var member = guildMemberDao.findByGuildIdAndUserId(guildOpt.get().getId(), userOpt.get().getId());
        return member;
    }
}
