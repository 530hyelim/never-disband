package com.neverdisband.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.neverdisband.dao.RecruitSettlementDao;
import com.neverdisband.dao.SplitParticipantDao;
import com.neverdisband.model.RecruitSettlement;
import com.neverdisband.model.SplitParticipant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;
import java.util.concurrent.*;

@Service
public class SplitGameService {

    private static final Logger log = LoggerFactory.getLogger(SplitGameService.class);
    private static final long ANIMATION_DURATION_MS = 120_000; // 2분

    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    private final RecruitSettlementDao settlementDao;
    private final SplitParticipantDao splitParticipantDao;
    private final SimpMessagingTemplate messagingTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public SplitGameService(RecruitSettlementDao settlementDao,
                            SplitParticipantDao splitParticipantDao,
                            SimpMessagingTemplate messagingTemplate) {
        this.settlementDao = settlementDao;
        this.splitParticipantDao = splitParticipantDao;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 앱 시작 시: 시작 시간이 지났는데 결과가 없는 건을 복구
     */
    @PostConstruct
    public void recoverPendingSplits() {
        List<RecruitSettlement> pending = settlementDao.findPendingSplits();
        for (RecruitSettlement s : pending) {
            log.info("Recovering pending split for settlement {}", s.getId());
            resolveGame(s.getId());
        }
    }

    /**
     * 정산 생성 시 호출: 시작 시간에 결과를 확정하도록 예약
     */
    public void scheduleGame(Long settlementId, LocalDateTime startedAt) {
        long delayMs = Duration.between(LocalDateTime.now(ZoneOffset.UTC), startedAt).toMillis();
        if (delayMs <= 0) {
            // 이미 시작 시간 지남 → 즉시 실행
            scheduler.submit(() -> resolveGame(settlementId));
        } else {
            scheduler.schedule(() -> resolveGame(settlementId), delayMs, TimeUnit.MILLISECONDS);
        }
    }

    /**
     * 게임 결과 확정 (경마/사다리 전용)
     * 주사위는 개별 굴리기이므로 여기서 처리 안 함
     */
    public void resolveGame(Long settlementId) {
        try {
            Optional<RecruitSettlement> opt = settlementDao.findById(settlementId);
            if (opt.isEmpty()) return;
            RecruitSettlement settlement = opt.get();

            // 이미 결과가 있으면 스킵
            if (settlement.getSplitResult() != null) return;

            String method = settlement.getSplitMethod();

            // 주사위: 마감 시간이 지나면 순위 확정 (안 굴린 사람은 rank=0)
            if ("dice".equals(method)) {
                resolveDiceFinalize(settlement);
                return;
            }

            List<SplitParticipant> participants = splitParticipantDao.findBySettlementId(settlementId);

            // 포기하지 않은 참여자만 대상 (rank가 null인 사람)
            List<SplitParticipant> active = participants.stream()
                    .filter(p -> p.getRank() == null)
                    .toList();

            if (active.isEmpty()) {
                // 전원 포기 → 결과 없이 완료
                settlementDao.updateSplitResult(settlementId, "[]", 0L);
                return;
            }

            // 시드 생성
            long seed = System.nanoTime();
            Random rng = new Random(seed);

            List<Map<String, Object>> results;

            if ("horse".equals(method)) {
                results = resolveHorse(active, rng);
            } else if ("ladder".equals(method)) {
                results = resolveLadder(active, rng);
            } else {
                results = resolveHorse(active, rng); // fallback
            }

            // DB에 각 참여자 rank 업데이트
            for (Map<String, Object> r : results) {
                Long memberId = ((Number) r.get("memberId")).longValue();
                int rank = ((Number) r.get("rank")).intValue();
                splitParticipantDao.updateRank(settlementId, memberId, rank);
            }

            // 결과 JSON 저장
            String resultJson = objectMapper.writeValueAsString(results);
            settlementDao.updateSplitResult(settlementId, resultJson, seed);

            // WebSocket 알림
            messagingTemplate.convertAndSend(
                    "/topic/split/" + settlementId,
                    Map.of("action", "resolved", "settlementId", settlementId)
            );

            log.info("Split game resolved for settlement {} with seed {}", settlementId, seed);

        } catch (Exception e) {
            log.error("Failed to resolve split game for settlement {}", settlementId, e);
        }
    }

    /**
     * 주사위: 개별 굴리기. 서버에서 즉시 결과 생성, DB 저장 후 반환.
     * @return 주사위 값 (1~100), 이미 굴렸으면 null
     */
    public Integer rollDice(Long settlementId, Long memberId) {
        Optional<RecruitSettlement> opt = settlementDao.findById(settlementId);
        if (opt.isEmpty()) return null;
        RecruitSettlement settlement = opt.get();

        // 마감 시간 확인
        if (settlement.getSplitStartedAt() != null) {
            var now = LocalDateTime.now(ZoneOffset.UTC);
            if (!now.isBefore(settlement.getSplitStartedAt())) return null; // 마감됨
        }

        // 이미 굴렸는지 확인 (rank가 null이 아니고 0도 아니면 이미 굴린 것)
        List<SplitParticipant> participants = splitParticipantDao.findBySettlementId(settlementId);
        SplitParticipant me = participants.stream()
                .filter(p -> p.getMemberId().equals(memberId))
                .findFirst().orElse(null);
        if (me == null) return null;
        if (me.getRank() != null && me.getRank() > 0) return null; // 이미 굴림
        if (me.getRank() != null && me.getRank() == 0) return null; // 포기

        // 주사위 굴리기
        int diceValue = ThreadLocalRandom.current().nextInt(1, 101);

        // choice에 주사위 값 저장 (나중에 순위 계산용)
        splitParticipantDao.updateChoice(settlementId, memberId, diceValue);

        // 전원 다 굴렸는지 확인: 나를 제외하고 아직 안 굴린 사람(rank=null이고 choice=null)이 있는지
        // 나는 방금 굴렸으므로 제외
        boolean allDone = participants.stream()
                .filter(p -> !p.getMemberId().equals(memberId))
                .filter(p -> p.getRank() == null) // 포기(rank=0)가 아닌 사람만
                .noneMatch(p -> p.getChoice() == null); // 전부 choice가 있으면 allDone
        if (allDone) {
            // 마지막 사람의 reveal + 애니메이션 시간 후에 결과 확정 (3초 딜레이)
            scheduler.schedule(() -> resolveDiceFinalize(settlement), 3, java.util.concurrent.TimeUnit.SECONDS);
        }

        return diceValue;
    }

    /**
     * 주사위 마감: 모든 참여자의 주사위 값으로 순위 확정
     * 안 굴린 사람은 rank=0 (포기와 동일)
     */
    private void resolveDiceFinalize(RecruitSettlement settlement) {
        Long settlementId = settlement.getId();
        try {
            List<SplitParticipant> participants = splitParticipantDao.findBySettlementId(settlementId);

            // 안 굴린 사람 (rank=null, choice=null) → rank=0 처리
            for (SplitParticipant p : participants) {
                if (p.getRank() == null && p.getChoice() == null) {
                    splitParticipantDao.updateRank(settlementId, p.getMemberId(), 0);
                }
            }

            // 굴린 사람만 (choice != null && rank == null) 순위 결정
            List<SplitParticipant> rolled = participants.stream()
                    .filter(p -> p.getChoice() != null && (p.getRank() == null || p.getRank() > 0))
                    .sorted((a, b) -> Integer.compare(b.getChoice(), a.getChoice())) // 높은 순
                    .toList();

            List<Map<String, Object>> results = new ArrayList<>();
            for (int i = 0; i < rolled.size(); i++) {
                SplitParticipant p = rolled.get(i);
                int rank = i + 1;
                splitParticipantDao.updateRank(settlementId, p.getMemberId(), rank);
                results.add(Map.of(
                        "memberId", p.getMemberId(),
                        "characterName", p.getCharacterName(),
                        "diceValue", p.getChoice(),
                        "rank", rank
                ));
            }

            String resultJson = objectMapper.writeValueAsString(results);
            settlementDao.updateSplitResult(settlementId, resultJson, 0L);

            messagingTemplate.convertAndSend(
                    "/topic/split/" + settlementId,
                    Map.of("action", "resolved", "settlementId", settlementId)
            );

            log.info("Dice game finalized for settlement {}", settlementId);

        } catch (Exception e) {
            log.error("Failed to finalize dice game for settlement {}", settlementId, e);
        }
    }

    /**
     * 경마: 각 말에 랜덤 속도, 빠른 순으로 순위
     */
    private List<Map<String, Object>> resolveHorse(List<SplitParticipant> active, Random rng) {
        // 선택 안 한 사람은 포기 처리 (rank=0)
        List<SplitParticipant> chosen = new ArrayList<>();
        for (SplitParticipant p : active) {
            if (p.getChoice() == null || p.getChoice() < 1) {
                splitParticipantDao.updateRank(p.getSettlementId(), p.getMemberId(), 0);
            } else {
                chosen.add(p);
            }
        }

        if (chosen.isEmpty()) return new ArrayList<>();

        // 말 번호들 수집 (참여자들이 선택한 말 번호)
        List<Integer> horseNumbers = chosen.stream().map(SplitParticipant::getChoice).toList();

        // 말 순위 랜덤 결정: horseNumbers를 셔플해서 앞에 있을수록 높은 순위
        List<Integer> shuffled = new ArrayList<>(horseNumbers);
        Collections.shuffle(shuffled, rng);

        // 말 번호 → 순위 매핑
        Map<Integer, Integer> horseToRank = new HashMap<>();
        for (int i = 0; i < shuffled.size(); i++) {
            horseToRank.put(shuffled.get(i), i + 1);
        }

        List<Map<String, Object>> results = new ArrayList<>();
        for (SplitParticipant p : chosen) {
            int rank = horseToRank.get(p.getChoice());
            results.add(Map.of(
                    "memberId", p.getMemberId(),
                    "characterName", p.getCharacterName(),
                    "choice", p.getChoice(),
                    "rank", rank
            ));
        }
        results.sort(Comparator.comparingInt(a -> (int) a.get("rank")));
        return results;
    }

    /**
     * 사다리: 라인 셔플 → 결과 라인 순서대로 순위
     * 선택 안 한 사람은 남은 라인 중 랜덤 배정
     */
    private List<Map<String, Object>> resolveLadder(List<SplitParticipant> active, Random rng) {
        // 사다리는 경마와 동일한 로직 (라인 = 말)
        return resolveHorse(active, rng);
    }

    public long getAnimationDurationMs() {
        return ANIMATION_DURATION_MS;
    }
}
