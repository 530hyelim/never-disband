<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
#splitModal { display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.85);z-index:2000;align-items:center;justify-content:center;backdrop-filter:blur(6px); }
#splitModal.active { display:flex; }
.split-container { background:#1e1f22;border:1px solid #3f4147;border-radius:16px;padding:32px;max-width:600px;width:92%;max-height:80vh;overflow-y:auto;position:relative; }
.split-close { position:absolute;top:14px;right:14px;width:28px;height:28px;border-radius:6px;border:none;background:transparent;color:#8b949e;cursor:pointer;font-size:1.2rem;display:flex;align-items:center;justify-content:center; }
.split-close:hover { background:#3f4147;color:#e6edf3; }
.split-title { font-size:1rem;font-weight:700;color:#e6edf3;margin-bottom:4px; }
.split-subtitle { font-size:0.82rem;color:#8b949e;margin-bottom:20px; }
.split-countdown { font-size:2.5rem;font-weight:700;color:#FEE75C;text-align:center;margin:24px 0; min-height:4rem;display:flex;align-items:center;justify-content:center; }
.split-btn { padding:8px 20px;border-radius:8px;border:1px solid #3f4147;background:transparent;color:#e6edf3;font-size:0.84rem;cursor:pointer;font-family:inherit;transition:all 0.15s; }
.split-btn:hover { border-color:#e6edf3; }
.split-btn.primary { background:#5865F2;border-color:#5865F2;color:#fff; }
.split-btn.primary:hover { background:#4752c4; }
.split-btn.danger { border-color:#ed4245;color:#ed4245; }
.split-btn.danger:hover { background:#ed4245;color:#fff; }
.split-btn:disabled { opacity:0.4;cursor:not-allowed; }
.split-actions { display:flex;gap:8px;justify-content:center;margin-top:16px; }
.split-result-row { display:flex;align-items:center;gap:10px;padding:10px 14px;background:#2b2d31;border:1px solid #3f4147;border-radius:8px;margin-bottom:6px; }
.split-rank { width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:0.78rem;font-weight:700;flex-shrink:0; }
.split-rank.r1 { background:rgba(254,231,92,0.2);color:#FEE75C;border:1px solid rgba(254,231,92,0.4); }
.split-rank.r2 { background:rgba(192,192,192,0.15);color:#c0c0c0;border:1px solid rgba(192,192,192,0.3); }
.split-rank.r3 { background:rgba(205,127,50,0.15);color:#cd7f32;border:1px solid rgba(205,127,50,0.3); }
.split-rank.rn { background:rgba(139,148,158,0.1);color:#8b949e;border:1px solid #3f4147; }
.split-per-person { font-size:0.82rem;color:#57F287;text-align:center;margin:12px 0;font-weight:600; }
.dice-rolling { animation:diceShake 0.6s ease-in-out infinite;display:inline-block; }
@keyframes diceShake { 0%{transform:translate(0,0) rotate(0)} 20%{transform:translate(-6px,-10px) rotate(-15deg)} 40%{transform:translate(8px,4px) rotate(12deg)} 60%{transform:translate(-4px,6px) rotate(-8deg)} 80%{transform:translate(6px,-4px) rotate(10deg)} 100%{transform:translate(0,0) rotate(0)} }
@keyframes diceReveal { 0%{transform:scale(0.3) rotate(-180deg);opacity:0} 60%{transform:scale(1.3) rotate(10deg);opacity:1} 100%{transform:scale(1) rotate(0);opacity:1} }
.lane-select { display:flex;flex-direction:column;gap:6px;margin:16px 0; }
.lane-btn { display:flex;align-items:center;gap:10px;padding:10px 14px;background:#2b2d31;border:1px solid #3f4147;border-radius:8px;cursor:pointer;transition:all 0.15s; }
.lane-btn:hover { border-color:#5865F2; }
.lane-btn.selected { border-color:#5865F2;background:rgba(88,101,242,0.15); }
.lane-btn.taken { opacity:0.5;cursor:not-allowed; }
.lane-btn-num { width:24px;height:24px;border-radius:50%;background:#3f4147;display:flex;align-items:center;justify-content:center;font-size:0.78rem;font-weight:600;color:#e6edf3; }
.lane-btn.selected .lane-btn-num { background:#5865F2; }
.lane-btn-label { font-size:0.82rem;color:#e6edf3;flex:1; }
.lane-btn-owner { font-size:0.75rem;color:#8b949e; }
.horse-track { display:flex;flex-direction:column;gap:4px;margin:16px 0; }
.horse-lane { display:flex;align-items:center;height:36px;background:#2b2d31;border:1px solid #3f4147;border-radius:6px;position:relative;overflow:hidden;padding:0 8px; }
.horse-lane-num { font-size:0.72rem;color:#8b949e;width:20px;flex-shrink:0;z-index:1; }
.horse-icon { position:absolute;font-size:1.2rem; }
.horse-lane-rank { position:absolute;right:8px;font-size:0.72rem;font-weight:600;opacity:0;transition:opacity 0.3s; }
.horse-lane-rank.r1 { color:#FEE75C; }
.horse-lane-rank.r2 { color:#c0c0c0; }
.horse-lane-rank.r3 { color:#cd7f32; }
.horse-lane-rank.rn { color:#8b949e; }
/* 사다리 슬롯 툴팁 */
.ladder-slot { position:relative; }
.ladder-slot .ladder-tooltip { position:absolute;bottom:calc(100% + 6px);left:50%;transform:translateX(-50%);background:#111214;color:#e6edf3;font-size:0.72rem;padding:3px 8px;border-radius:5px;white-space:nowrap;pointer-events:none;opacity:0;transition:opacity 0.15s;z-index:10; }
.ladder-slot:hover .ladder-tooltip { opacity:1; }
</style>

<div id="splitModal" onmousedown="if(event.target===this)closeSplitModal()" style="flex-direction:column;">
    <div id="splitCountdownArea" style="display:none;flex-shrink:0;padding-bottom:20px;justify-content:center;font-size:1.2rem;font-weight:600;color:#FEE75C;transition:all 0.2s;z-index:1;"></div>
    <div class="split-container" style="border-radius:16px;">
        <button class="split-close" onclick="closeSplitModal()">&times;</button>
        <div id="splitBody">불러오는 중...</div>
    </div>
</div>

<script>
var splitPostId = null;
var splitSettlementId = null;
var splitSub = null;
var splitPhase = 'idle'; // idle, waiting, countdown, done
var splitCdInterval = null;

function openSplitModal(postId, skipAnimation) {
    // 같은 게임이면 그냥 보이기만 (DOM 유지)
    if (splitPostId === postId && splitPhase !== 'idle') {
        document.getElementById('splitModal').classList.add('active');
        return;
    }
    // 다른 게임이거나 첫 진입 → 초기화
    if (splitSub) { try { splitSub.unsubscribe(); } catch(e) {} splitSub = null; }
    if (splitCdInterval) { clearInterval(splitCdInterval); splitCdInterval = null; }
    splitPostId = postId;
    splitPhase = 'idle';
    raceAnimShown = skipAnimation ? true : false;
    raceWasPlayed = false;
    document.getElementById('splitBody').innerHTML = '불러오는 중...';
    var ca = document.getElementById('splitCountdownArea');
    if (ca) { ca.style.display = 'none'; ca.textContent = ''; }
    document.getElementById('splitModal').classList.add('active');
    loadSplitState();
}

function closeSplitModal() {
    document.getElementById('splitModal').classList.remove('active');
    var ca = document.getElementById('splitCountdownArea');
    if (ca) { ca.style.display = 'none'; ca.textContent = ''; }
}

function loadSplitState() {
    if (!splitPostId) return;
    fetch('/' + guildSubdomain + '/recruit/posts/' + splitPostId + '/split')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.error) { document.getElementById('splitBody').innerHTML = '<div style="text-align:center;color:#ed4245;">' + data.error + '</div>'; return; }
            splitSettlementId = data.settlementId;
            if (!splitSub) subscribeSplit();
            renderByStatus(data);
        });
}

function subscribeSplit() {
    if (!splitSettlementId || !window.stompClient || !window.stompClient.connected) return;
    if (splitSub) { try { splitSub.unsubscribe(); } catch(e) {} }
    splitSub = stompClient.subscribe('/topic/split/' + splitSettlementId, function(msg) {
        var data = JSON.parse(msg.body);
        // 카운트다운/레이스 중에는 resolved만 받고 나머진 무시
        if (splitPhase === 'countdown' || splitPhase === 'racing') {
            if (data.action === 'resolved') { /* 레이스 끝나면 자연스럽게 전환됨, 무시 */ }
            return;
        }
        if (splitPhase === 'done') return;
        if (data.action === 'allReady') {
            loadSplitState();
        } else {
            loadSplitState();
            loadPostsDebounced();
        }
    });
}

function renderByStatus(data) {
    // 이미 카운트다운/레이스 중이면 덮어쓰지 않음
    if (splitPhase === 'countdown' || splitPhase === 'racing') return;

    if (data.status === 'DONE') {
        splitPhase = 'done';
        renderDone(data);
    } else if (data.status === 'COUNTDOWN') {
        // 먼저 대기화면 렌더 (선택 상태 반영) 후 카운트다운 시작
        splitPhase = 'waiting';
        renderWaiting(data);
        startCountdown(5);
    } else {
        splitPhase = 'waiting';
        renderWaiting(data);
    }
}

// === 대기 화면 ===
function renderWaiting(data) {
    var body = document.getElementById('splitBody');
    var method = data.splitMethod;
    var methodLabel = method === 'dice' ? '주사위' : method === 'horse' ? '경마' : '사다리';
    var amount = data.splitAmount;
    var participants = data.participants || [];
    var activeCount = participants.filter(function(p) { return p.rank !== 0; }).length;
    var perPerson = activeCount > 0 ? Math.floor(amount / activeCount) : 0;
    var startedAt = data.startedAt ? new Date(data.startedAt + 'Z') : null;
    var isCountdown = (data.status === 'COUNTDOWN');

    var html = '<div class="split-title">' + methodLabel + ' 분배</div>';
    html += '<div class="split-subtitle">' + amount.toLocaleString() + ' 실버 · 1인당 ' + perPerson.toLocaleString() + ' 실버</div>';
    var caEl = document.getElementById('splitCountdownArea');
    if (startedAt && caEl) { caEl.textContent = '--:--'; caEl.style.display = 'flex'; }

    var me = participants.find(function(p) { return p.memberId === currentMemberId; });

    if (method === 'dice') {
        // 주사위: 순위 리스트
        var sorted = participants.slice().sort(function(a, b) {
            var av = (a.choice > 0 && a.rank !== 0) ? a.choice : -1;
            var bv = (b.choice > 0 && b.rank !== 0) ? b.choice : -1;
            return bv - av;
        });
        html += '<div style="display:flex;flex-direction:column;gap:6px;margin:16px 0;">';
        var rank = 0;
        for (var i = 0; i < sorted.length; i++) {
            var p = sorted[i];
            if (p.rank === 0) {
                html += '<div class="split-result-row" style="opacity:0.4;"><span class="split-rank rn">-</span><span style="flex:1;color:#8b949e;font-size:0.84rem;text-decoration:line-through;">' + escapeHtml(p.characterName) + '</span><span style="font-size:0.78rem;color:#8b949e;">포기</span></div>';
            } else if (p.choice > 0) {
                rank++;
                var rc = rank === 1 ? 'r1' : rank === 2 ? 'r2' : rank === 3 ? 'r3' : 'rn';
                html += '<div class="split-result-row"><span class="split-rank ' + rc + '">' + rank + '</span><span style="flex:1;color:#e6edf3;font-size:0.84rem;">' + escapeHtml(p.characterName) + '</span><span style="color:#5865F2;font-weight:600;">' + p.choice + '</span></div>';
            } else {
                html += '<div class="split-result-row" style="opacity:0.6;"><span class="split-rank rn">?</span><span style="flex:1;color:#8b949e;font-size:0.84rem;">' + escapeHtml(p.characterName) + '</span><span style="font-size:0.78rem;color:#8b949e;">대기중</span></div>';
            }
        }
        html += '</div>';
        // 버튼 (카운트다운 중에는 숨김)
        if (!isCountdown && me && me.rank !== 0) {
            html += '<div class="split-actions">';
            if (me.choice > 0) html += '<button class="split-btn" disabled>굴림 완료 (' + me.choice + ')</button>';
            else html += '<button class="split-btn primary" onclick="doRoll()">🎲 주사위 굴리기</button><button class="split-btn danger" onclick="doOptOut()">포기</button>';
            html += '</div>';
        } else if (!isCountdown && me && me.rank === 0) {
            html += '<div class="split-actions"><button class="split-btn" onclick="doOptOut()">복귀</button></div>';
        }
        // 미참여 목록
        var opted = participants.filter(function(p) { return p.rank === 0; });
        if (opted.length > 0) {
            html += '<div style="margin-top:12px;font-size:0.75rem;color:#8b949e;">미참여</div><div style="font-size:0.78rem;color:#5a6173;margin-top:4px;">' + opted.map(function(p) { return escapeHtml(p.characterName); }).join(', ') + '</div>';
        }
    } else if (method === 'horse') {
        // 경마: 레인 선택
        if (me && me.rank !== 0) {
            var active = participants.filter(function(p) { return p.rank !== 0; });
            var totalLanes = active.length;
            var taken = {};
            active.forEach(function(p) { if (p.choice) taken[p.choice] = p.characterName; });
            html += '<div style="font-size:0.78rem;color:#8b949e;margin-bottom:8px;">레인을 선택하세요:</div><div class="lane-select">';
            for (var n = 1; n <= totalLanes; n++) {
                var mine = me.choice === n;
                var isTaken = taken[n] && !mine;
                var cls = 'lane-btn' + (mine ? ' selected' : '') + (isTaken ? ' taken' : '');
                var oc = isTaken ? '' : ' onclick="doChoose(' + n + ')"';
                var ow = taken[n] ? '<span class="lane-btn-owner">' + escapeHtml(taken[n]) + '</span>' : '<span class="lane-btn-owner" style="color:#3f4147;">비어있음</span>';
                html += '<div class="' + cls + '"' + oc + '><span class="lane-btn-num">' + n + '</span><span class="lane-btn-label">🐴 ' + n + '번 레인</span>' + ow + '</div>';
            }
            html += '</div>';
            if (!isCountdown) html += '<div class="split-actions"><button class="split-btn danger" onclick="doOptOut()">포기</button></div>';
        } else if (!isCountdown && me && me.rank === 0) {
            html += '<div class="split-actions"><button class="split-btn" onclick="doOptOut()">복귀</button></div>';
        }
        var opted = participants.filter(function(p) { return p.rank === 0; });
        if (opted.length > 0) {
            html += '<div style="margin-top:12px;font-size:0.75rem;color:#8b949e;">미참여</div><div style="font-size:0.78rem;color:#5a6173;margin-top:4px;">' + opted.map(function(p) { return escapeHtml(p.characterName); }).join(', ') + '</div>';
        }
    } else {
        // 사다리: 상단 프로필 슬롯 + 세로선 + 하단 등수
        var active = participants.filter(function(p) { return p.rank !== 0; });
        var totalSlots = active.length;
        var takenMap = {}; // choice → participant object
        active.forEach(function(p) { if (p.choice) takenMap[p.choice] = p; });

        // 상단 슬롯 (프로필 사진 + 호버 툴팁)
        html += '<div style="display:flex;justify-content:space-around;margin:16px 0 0;">';
        for (var n = 1; n <= totalSlots; n++) {
            var ownerP = takenMap[n];
            var mine = me && me.choice === n;
            var isTaken = ownerP && !mine;
            var borderCol = mine ? '#5865F2' : '#3f4147';
            var opacity = isTaken ? 'opacity:0.5;cursor:not-allowed;' : '';
            var oc = (me && me.rank !== 0 && !isTaken) ? ' onclick="doChoose(' + n + ')"' : '';
            var inner = '';
            if (ownerP) {
                var av = ownerP.avatarUrl;
                var name = escapeHtml(ownerP.characterName);
                if (av) {
                    inner = '<img src="' + av + '?size=64" style="width:32px;height:32px;border-radius:50%;object-fit:cover;display:block;">';
                } else {
                    inner = '<span style="width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#5865F2,#57F287);display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700;color:#fff;">' + name.charAt(0).toUpperCase() + '</span>';
                }
                inner += '<span class="ladder-tooltip">' + name + '</span>';
            } else {
                inner = '<span style="color:#3f4147;font-size:1rem;">+</span>';
            }
            html += '<div class="ladder-slot" style="width:36px;height:36px;border-radius:50%;border:2px solid ' + borderCol + ';background:#2b2d31;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.15s;position:relative;' + opacity + '"' + oc + '>' + inner + '</div>';
        }
        html += '</div>';

        // 세로선 (사다리 미리보기)
        html += '<div style="display:flex;justify-content:space-around;height:120px;margin:0;position:relative;">';
        for (var n = 1; n <= totalSlots; n++) {
            html += '<div style="width:2px;background:#3f4147;height:100%;"></div>';
        }
        html += '</div>';

        // 하단 등수 (원형 뱃지 - 프로필과 동일 크기)
        html += '<div style="display:flex;justify-content:space-around;margin:0 0 16px;">';
        for (var n = 1; n <= totalSlots; n++) {
            var bgColor = n===1?'rgba(254,231,92,0.2)':n===2?'rgba(192,192,192,0.15)':n===3?'rgba(205,127,50,0.15)':'rgba(139,148,158,0.1)';
            var borderColor = n===1?'rgba(254,231,92,0.4)':n===2?'rgba(192,192,192,0.3)':n===3?'rgba(205,127,50,0.3)':'#3f4147';
            var textColor = n===1?'#FEE75C':n===2?'#c0c0c0':n===3?'#cd7f32':'#8b949e';
            html += '<div style="width:36px;height:36px;border-radius:50%;background:' + bgColor + ';border:2px solid ' + borderColor + ';display:flex;align-items:center;justify-content:center;font-size:0.78rem;font-weight:700;color:' + textColor + ';">' + n + '</div>';
        }
        html += '</div>';

        // 포기/복귀 버튼 (카운트다운 중 숨김)
        if (!isCountdown && me && me.rank !== 0) {
            html += '<div class="split-actions"><button class="split-btn danger" onclick="doOptOut()">포기</button></div>';
        } else if (!isCountdown && me && me.rank === 0) {
            html += '<div class="split-actions"><button class="split-btn" onclick="doOptOut()">복귀</button></div>';
        }
        // 미참여 인원
        var opted = participants.filter(function(p) { return p.rank === 0; });
        if (opted.length > 0) {
            html += '<div style="margin-top:12px;font-size:0.75rem;color:#8b949e;">미참여</div><div style="font-size:0.78rem;color:#5a6173;margin-top:4px;">' + opted.map(function(p) { return escapeHtml(p.characterName); }).join(', ') + '</div>';
        }
    }

    body.innerHTML = html;
    if (startedAt) startTimerCountdown(startedAt);
}

function startTimerCountdown(endTime) {
    var tick = function() {
        var el = document.getElementById('splitCountdownArea');
        if (!el || splitPhase !== 'waiting') return;
        el.style.display = 'flex';
        var diff = endTime.getTime() - Date.now();
        if (diff <= 0) { el.textContent = '마감!'; setTimeout(loadSplitState, 1500); return; }
        var m = Math.floor(diff/60000), s = Math.floor((diff%60000)/1000);
        el.textContent = (m<10?'0':'')+m+':'+(s<10?'0':'')+s;
        setTimeout(tick, 1000);
    };
    tick();
}

// === 카운트다운 ===
function startCountdown(seconds) {
    // 기존 카운트다운 정리
    if (splitCdInterval) { clearInterval(splitCdInterval); splitCdInterval = null; }
    splitPhase = 'countdown';
    var el = document.getElementById('splitCountdownArea');
    if (!el) return;
    var count = seconds;
    el.textContent = '✓ 모든 참여자 선택 완료';
    // 1초 후 숫자 카운트다운 시작
    splitCdInterval = setTimeout(function() {
        if (splitPhase !== 'countdown') return;
        el.textContent = count;
        splitCdInterval = setInterval(function() {
            count--;
            if (!el || splitPhase !== 'countdown') { clearInterval(splitCdInterval); splitCdInterval = null; return; }
            if (count <= 0) { clearInterval(splitCdInterval); splitCdInterval = null; el.textContent = '출발!'; splitPhase = 'idle'; setTimeout(function(){ loadSplitState(); }, 1000); }
            else el.textContent = count;
        }, 1000);
    }, 1000);
}

// === 결과 화면 ===
var raceAnimShown = false;  // true면 애니메이션 스킵 (결과보기 or 이미 봄)
var raceWasPlayed = false;  // 실제로 애니메이션이 재생됐으면 true (화면 유지용)

function renderDone(data) {
    var body = document.getElementById('splitBody');
    var method = data.splitMethod;
    var methodLabel = method === 'dice' ? '주사위' : method === 'horse' ? '경마' : '사다리';
    var amount = data.splitAmount;
    var results = []; try { results = JSON.parse(data.result); } catch(e) {}
    var participants = data.participants || [];
    var activeCount = results.length;
    var perPerson = activeCount > 0 ? Math.floor(amount / activeCount) : 0;

    var caClear = document.getElementById('splitCountdownArea');
    if (caClear) { caClear.style.display = 'none'; caClear.textContent = ''; }

    // 경마/사다리: 처음 한 번만 애니메이션
    if (method === 'horse' && results.length > 0 && !raceAnimShown) {
        raceAnimShown = true;
        raceWasPlayed = true;
        renderRaceAnimation(body, data, results, methodLabel, amount, perPerson, participants);
        return;
    }
    if (method === 'ladder' && results.length > 0 && !raceAnimShown) {
        raceAnimShown = true;
        raceWasPlayed = true;
        renderLadderAnimation(body, data, results, methodLabel, amount, perPerson, participants);
        return;
    }

    // 경마/사다리: 애니메이션 재생 후엔 화면 유지 (덮어쓰지 않음)
    if ((method === 'horse' || method === 'ladder') && raceWasPlayed) return;

    renderFinalResult(body, data, results, methodLabel, amount, perPerson, participants);
}

function renderFinalResult(body, data, results, methodLabel, amount, perPerson, participants) {
    var method = data.splitMethod;
    var html = '<div class="split-title">' + methodLabel + ' 결과</div>';
    html += '<div class="split-subtitle">' + amount.toLocaleString() + ' 실버 · 1인당 ' + perPerson.toLocaleString() + ' 실버</div>';

    if (method === 'horse') {
        var lanes = results.slice().sort(function(a,b){ return a.choice - b.choice; });
        var total = results.length;
        html += '<div class="horse-track">';
        for (var i = 0; i < lanes.length; i++) {
            var r = lanes[i];
            var pct = 95 - ((r.rank-1)*(50/total));
            var rc = r.rank===1?'r1':r.rank===2?'r2':r.rank===3?'r3':'rn';
            html += '<div class="horse-lane"><span class="horse-lane-rank ' + rc + '" style="opacity:1;position:relative;left:0;right:auto;flex-shrink:0;margin-right:6px;">' + r.rank + '등 · ' + escapeHtml(r.characterName) + '</span><span class="horse-icon" style="left:' + pct + '%;">🐴</span></div>';
        }
        html += '</div>';
    } else if (method === 'ladder') {
        // 사다리 결과: 대기화면과 동일 구조 (프로필 슬롯 + 세로선 + 가로선 + 등수 뱃지)
        var total = results.length;
        var seed = data.seed || 12345;
        var rungs = generateLadderRungs(total, seed);
        var sorted = results.slice().sort(function(a,b){ return a.choice - b.choice; });

        // 상단: 프로필 슬롯
        html += '<div style="display:flex;justify-content:space-around;margin:16px 0 0;">';
        for (var i = 0; i < sorted.length; i++) {
            var r = sorted[i];
            var p = participants.find(function(pp){ return pp.memberId === r.memberId; });
            var av = p ? p.avatarUrl : null;
            var name = escapeHtml(r.characterName);
            var inner = '';
            if (av) {
                inner = '<img src="' + av + '?size=64" style="width:32px;height:32px;border-radius:50%;object-fit:cover;display:block;">';
            } else {
                inner = '<span style="width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#5865F2,#57F287);display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700;color:#fff;">' + name.charAt(0).toUpperCase() + '</span>';
            }
            inner += '<span class="ladder-tooltip">' + name + '</span>';
            html += '<div class="ladder-slot" style="width:36px;height:36px;border-radius:50%;border:2px solid #3f4147;background:#2b2d31;display:flex;align-items:center;justify-content:center;position:relative;">' + inner + '</div>';
        }
        html += '</div>';

        // SVG 사다리 (가로선 포함)
        var svgW = 500, svgH = 200, ROWS = 8;
        var gap = svgW / (total + 1);
        var rowH = svgH / (ROWS + 1);
        html += '<svg width="100%" viewBox="0 0 ' + svgW + ' ' + svgH + '" style="display:block;margin:0;">';
        for (var c = 0; c < total; c++) {
            html += '<line x1="' + (gap*(c+1)) + '" y1="0" x2="' + (gap*(c+1)) + '" y2="' + svgH + '" stroke="#3f4147" stroke-width="2"/>';
        }
        for (var ri = 0; ri < rungs.length; ri++) {
            var rung = rungs[ri];
            html += '<line x1="' + (gap*(rung.col+1)) + '" y1="' + (rowH*(rung.row+1)) + '" x2="' + (gap*(rung.col+2)) + '" y2="' + (rowH*(rung.row+1)) + '" stroke="#5865F2" stroke-width="3" stroke-linecap="round"/>';
        }
        html += '</svg>';

        // 하단: 등수 뱃지
        html += '<div style="display:flex;justify-content:space-around;margin:0 0 16px;">';
        for (var n = 1; n <= total; n++) {
            var bgColor = n===1?'rgba(254,231,92,0.2)':n===2?'rgba(192,192,192,0.15)':n===3?'rgba(205,127,50,0.15)':'rgba(139,148,158,0.1)';
            var borderColor = n===1?'rgba(254,231,92,0.4)':n===2?'rgba(192,192,192,0.3)':n===3?'rgba(205,127,50,0.3)':'#3f4147';
            var textColor = n===1?'#FEE75C':n===2?'#c0c0c0':n===3?'#cd7f32':'#8b949e';
            html += '<div style="width:36px;height:36px;border-radius:50%;background:' + bgColor + ';border:2px solid ' + borderColor + ';display:flex;align-items:center;justify-content:center;font-size:0.78rem;font-weight:700;color:' + textColor + ';">' + n + '</div>';
        }
        html += '</div>';
    } else {
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            var rc = r.rank===1?'r1':r.rank===2?'r2':r.rank===3?'r3':'rn';
            html += '<div class="split-result-row"><span class="split-rank ' + rc + '">' + r.rank + '</span><span style="flex:1;color:#e6edf3;font-size:0.84rem;">' + escapeHtml(r.characterName) + '</span><span style="color:#5865F2;font-weight:600;">' + r.diceValue + '</span></div>';
        }
    }

    var opted = participants.filter(function(p){ return p.rank===0; });
    if (opted.length > 0) html += '<div style="margin-top:12px;font-size:0.75rem;color:#8b949e;">미참여: ' + opted.map(function(p){ return escapeHtml(p.characterName); }).join(', ') + '</div>';

    body.innerHTML = html;
}

function renderRaceAnimation(body, data, results, methodLabel, amount, perPerson, participants) {
    splitPhase = 'racing';
    var total = results.length;
    var lanes = results.slice().sort(function(a,b){ return a.choice - b.choice; });

    var html = '<div class="split-title">' + methodLabel + ' 레이스</div>';
    html += '<div class="split-subtitle">' + amount.toLocaleString() + ' 실버 · 1인당 ' + perPerson.toLocaleString() + ' 실버</div>';
    html += '<div class="horse-track" style="margin:24px 0;">';
    for (var i = 0; i < lanes.length; i++) {
        var r = lanes[i];
        var rc = r.rank===1?'r1':r.rank===2?'r2':r.rank===3?'r3':'rn';
        html += '<div class="horse-lane"><span class="horse-lane-num" id="rn-' + r.choice + '">' + r.choice + '</span><span class="horse-lane-rank ' + rc + '" id="rl-' + r.choice + '" style="opacity:0;position:relative;left:0;right:auto;flex-shrink:0;margin-right:6px;">' + r.rank + '등 · ' + escapeHtml(r.characterName) + '</span><span class="horse-icon" id="rh-' + r.choice + '" style="left:5%;">🐴</span></div>';
    }
    html += '</div>';
    body.innerHTML = html;

    // 애니메이션: 시작 5%에서 목표까지 전진만
    var seed = data.seed || 12345;
    var rng = (function(s) { return function() { s=(s*1664525+1013904223)&0xFFFFFFFF; return (s>>>0)/0xFFFFFFFF; }; })(seed);
    var START_PCT = 5;
    var TARGET_PCT = 95;
    var TOTAL_TICKS = 40;

    var finishedCount = 0;
    lanes.forEach(function(r) {
        var tickStep = (TARGET_PCT - START_PCT) / TOTAL_TICKS;
        var cumDelay = 0;

        for (var t = 0; t < TOTAL_TICKS; t++) {
            var delay = 10 + Math.floor(rng() * 1000);
            cumDelay += delay;
            var pos = START_PCT + tickStep * (t + 1);
            if (pos > TARGET_PCT) pos = TARGET_PCT;
            (function(currentPos, cd, isLast, choice) {
                setTimeout(function() {
                    var el = document.getElementById('rh-' + choice);
                    if (el) el.style.left = currentPos + '%';
                    if (isLast) {
                        var numEl = document.getElementById('rn-' + choice);
                        if (numEl) numEl.style.display = 'none';
                        var lbl = document.getElementById('rl-' + choice);
                        if (lbl) lbl.style.opacity = '1';
                        finishedCount++;
                        if (finishedCount >= total) {
                            setTimeout(function() {
                                splitPhase = 'done';
                                var caDone = document.getElementById('splitCountdownArea');
                                if (caDone) { caDone.style.display = 'none'; caDone.textContent = ''; }
                                loadPostsDebounced();
                                if (openDetailTab === 'settle' && openDetailPostId === splitPostId) loadSettleContent(splitPostId);
                            }, 800);
                        }
                    }
                }, cd);
            })(pos, cumDelay, t === TOTAL_TICKS - 1, r.choice);
        }
    });
}

// === 액션 ===
function doRoll() {
    fetch('/' + guildSubdomain + '/recruit/posts/' + splitPostId + '/split/roll', {
        method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':csrfToken}, body:'{}'
    }).then(function(r){return r.json();}).then(function(d) {
        if (!d.success) { alert(d.message||'실패'); return; }
        splitPhase = 'countdown'; // 애니메이션 중 이벤트 무시용
        var actions = document.querySelector('.split-actions');
        if (actions) {
            actions.innerHTML = '<div style="font-size:4rem;text-align:center;margin:20px 0;" class="dice-rolling">🎲</div>';
            setTimeout(function() {
                actions.innerHTML = '<div style="font-size:3.5rem;text-align:center;margin:20px 0;animation:diceReveal 0.5s ease;">' + d.diceValue + '</div>';
                fetch('/' + guildSubdomain + '/recruit/posts/' + splitPostId + '/split/reveal', {
                    method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':csrfToken}, body:'{}'
                }).then(function() {
                    setTimeout(function() {
                        splitPhase = 'idle';
                        loadSplitState();
                        loadPostsDebounced();
                        if (openDetailTab === 'settle' && openDetailPostId === splitPostId) loadSettleContent(splitPostId);
                    }, 1000);
                });
            }, 1000);
        }
    });
}

function doOptOut() {
    if (splitPhase === 'countdown' || splitPhase === 'racing') return;
    fetch('/' + guildSubdomain + '/recruit/posts/' + splitPostId + '/split/opt-out', {
        method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':csrfToken}, body:'{}'
    }).then(function(r){return r.json();}).then(function(d) { if(d.success) loadSplitState(); else alert(d.message||'실패'); });
}

function doChoose(n) {
    if (splitPhase === 'countdown' || splitPhase === 'racing') return;
    fetch('/' + guildSubdomain + '/recruit/posts/' + splitPostId + '/split/choose', {
        method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':csrfToken}, body:JSON.stringify({choice:n})
    }).then(function(r){return r.json();}).then(function(d) {
        if (!d.success) { alert(d.message||'실패'); return; }
        loadSplitState();
    });
}

// === 사다리 헬퍼 ===

function generateLadderRungs(total, seed) {
    // seed 기반으로 가로선(rung) 생성: 어떤 세로선 사이에 가로선이 있는지
    var rng = (function(s) { return function() { s=(s*1664525+1013904223)&0xFFFFFFFF; return (s>>>0)/0xFFFFFFFF; }; })(seed);
    var ROWS = 8; // 가로선이 들어갈 수 있는 행 수
    var rungs = []; // [{row, col}] col은 col과 col+1 사이의 가로선
    for (var row = 0; row < ROWS; row++) {
        for (var col = 0; col < total - 1; col++) {
            if (rng() < 0.45) { // 45% 확률로 가로선
                // 같은 row에서 인접 가로선이 없어야 함
                var conflict = rungs.some(function(r) { return r.row === row && Math.abs(r.col - col) <= 1; });
                if (!conflict) rungs.push({row: row, col: col});
            }
        }
    }
    return rungs;
}

function renderLadderBoard(results, rungs, showRungs) {
    var total = results.length;
    var ROWS = 8;
    var colWidth = Math.floor(100 / total);

    var html = '<div style="position:relative;margin:16px 0;">';
    // 상단: 참여자 이름
    html += '<div style="display:flex;justify-content:space-around;margin-bottom:8px;">';
    var sorted = results.slice().sort(function(a,b){ return a.choice - b.choice; });
    for (var i = 0; i < sorted.length; i++) {
        var r = sorted[i];
        html += '<div style="width:' + colWidth + '%;text-align:center;font-size:0.72rem;color:#e6edf3;">' + escapeHtml(r.characterName).substring(0,6) + '</div>';
    }
    html += '</div>';

    // SVG 사다리
    var svgW = 500, svgH = 200;
    var gap = svgW / (total + 1);
    var rowH = svgH / (ROWS + 1);
    html += '<svg width="100%" viewBox="0 0 ' + svgW + ' ' + svgH + '" style="display:block;">';
    // 세로선
    for (var c = 0; c < total; c++) {
        var x = gap * (c + 1);
        html += '<line x1="' + x + '" y1="0" x2="' + x + '" y2="' + svgH + '" stroke="#3f4147" stroke-width="2"/>';
    }
    // 가로선
    if (showRungs) {
        for (var i = 0; i < rungs.length; i++) {
            var rung = rungs[i];
            var x1 = gap * (rung.col + 1);
            var x2 = gap * (rung.col + 2);
            var y = rowH * (rung.row + 1);
            html += '<line x1="' + x1 + '" y1="' + y + '" x2="' + x2 + '" y2="' + y + '" stroke="#5865F2" stroke-width="3" stroke-linecap="round"/>';
        }
    }
    html += '</svg>';

    // 하단: 등수
    html += '<div style="display:flex;justify-content:space-around;margin-top:8px;">';
    // 각 슬롯에서 사다리 타고 내려간 결과 등수 계산
    for (var startCol = 0; startCol < total; startCol++) {
        var col = startCol;
        for (var row = 0; row < ROWS; row++) {
            for (var ri = 0; ri < rungs.length; ri++) {
                if (rungs[ri].row === row) {
                    if (rungs[ri].col === col) col++;
                    else if (rungs[ri].col === col - 1) col--;
                }
            }
        }
        // col이 도착 위치 → 이 슬롯의 등수
        var rank = col + 1;
        var rc = rank===1?'#FEE75C':rank===2?'#c0c0c0':rank===3?'#cd7f32':'#8b949e';
        html += '<div style="width:' + colWidth + '%;text-align:center;font-size:0.78rem;font-weight:600;color:' + rc + ';">' + rank + '등</div>';
    }
    html += '</div></div>';
    return html;
}

function renderLadderAnimation(body, data, results, methodLabel, amount, perPerson, participants) {
    splitPhase = 'racing';
    var total = results.length;
    var seed = data.seed || 12345;
    var rungs = generateLadderRungs(total, seed);

    // 대기화면과 동일한 레이아웃으로 그림 (프로필 슬롯 + 세로선 + 뱃지)
    // 상단: 프로필 슬롯
    var sorted = results.slice().sort(function(a,b){ return a.choice - b.choice; });
    var html = '<div class="split-title">' + methodLabel + ' 결과</div>';
    html += '<div class="split-subtitle">' + amount.toLocaleString() + ' 실버 · 1인당 ' + perPerson.toLocaleString() + ' 실버</div>';
    html += '<div style="display:flex;justify-content:space-around;margin:16px 0 0;">';
    for (var i = 0; i < sorted.length; i++) {
        var r = sorted[i];
        var p = participants.find(function(pp){ return pp.memberId === r.memberId; });
        var av = p ? p.avatarUrl : null;
        var name = escapeHtml(r.characterName);
        var inner = '';
        if (av) {
            inner = '<img src="' + av + '?size=64" style="width:32px;height:32px;border-radius:50%;object-fit:cover;display:block;">';
        } else {
            inner = '<span style="width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#5865F2,#57F287);display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700;color:#fff;">' + name.charAt(0).toUpperCase() + '</span>';
        }
        inner += '<span class="ladder-tooltip">' + name + '</span>';
        html += '<div class="ladder-slot" style="width:36px;height:36px;border-radius:50%;border:2px solid #3f4147;background:#2b2d31;display:flex;align-items:center;justify-content:center;position:relative;">' + inner + '</div>';
    }
    html += '</div>';

    // SVG (세로선만, 가로선 아직 없음)
    var svgW = 500, svgH = 200, ROWS = 8;
    var gap = svgW / (total + 1);
    var rowH = svgH / (ROWS + 1);
    html += '<svg id="ladderSvg" width="100%" viewBox="0 0 ' + svgW + ' ' + svgH + '" style="display:block;margin:0;">';
    for (var c = 0; c < total; c++) {
        html += '<line x1="' + (gap*(c+1)) + '" y1="0" x2="' + (gap*(c+1)) + '" y2="' + svgH + '" stroke="#3f4147" stroke-width="2"/>';
    }
    html += '</svg>';

    // 하단: 등수 뱃지
    html += '<div style="display:flex;justify-content:space-around;margin:0 0 16px;">';
    for (var n = 1; n <= total; n++) {
        var bgColor = n===1?'rgba(254,231,92,0.2)':n===2?'rgba(192,192,192,0.15)':n===3?'rgba(205,127,50,0.15)':'rgba(139,148,158,0.1)';
        var borderColor = n===1?'rgba(254,231,92,0.4)':n===2?'rgba(192,192,192,0.3)':n===3?'rgba(205,127,50,0.3)':'#3f4147';
        var textColor = n===1?'#FEE75C':n===2?'#c0c0c0':n===3?'#cd7f32':'#8b949e';
        html += '<div style="width:36px;height:36px;border-radius:50%;background:' + bgColor + ';border:2px solid ' + borderColor + ';display:flex;align-items:center;justify-content:center;font-size:0.78rem;font-weight:700;color:' + textColor + ';">' + n + '</div>';
    }
    html += '</div>';

    body.innerHTML = html;

    // 가로선 바로 그리기
    var svg = document.getElementById('ladderSvg');
    if (svg) {
        for (var i = 0; i < rungs.length; i++) {
            var rung = rungs[i];
            var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', gap*(rung.col+1));
            line.setAttribute('y1', rowH*(rung.row+1));
            line.setAttribute('x2', gap*(rung.col+2));
            line.setAttribute('y2', rowH*(rung.row+1));
            line.setAttribute('stroke', '#5865F2');
            line.setAttribute('stroke-width', '3');
            line.setAttribute('stroke-linecap', 'round');
            svg.appendChild(line);
        }
    }
    // 바로 전환
    splitPhase = 'done';
    var caDone = document.getElementById('splitCountdownArea');
    if (caDone) { caDone.style.display = 'none'; caDone.textContent = ''; }
    refreshSinglePost(splitPostId);
    if (openDetailTab === 'settle' && openDetailPostId === splitPostId) loadSettleContent(splitPostId);
}
</script>
