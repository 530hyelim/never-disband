<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
.dashboard { max-width: 900px; margin: 0 auto; }
.dash-header { margin-bottom: 28px; }
.dash-header h2 { font-size: 1.2rem; font-weight: 700; margin-bottom: 4px; }
.dash-period { font-size: 0.82rem; color: #949ba4; }
.dash-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 24px; }
.dash-card { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px; }
.dash-card-title { font-size: 0.85rem; font-weight: 600; color: #949ba4; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; }
.dash-card-title svg { width: 16px; height: 16px; fill: currentColor; }
.rank-list { list-style: none; padding: 0; margin: 0; }
.rank-item { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid #3f4147; }
.rank-item:last-child { border-bottom: none; }
.rank-num { width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.72rem; font-weight: 700; flex-shrink: 0; }
.rank-num.gold { background: rgba(254, 231, 92, 0.15); color: #FEE75C; }
.rank-num.silver { background: rgba(192, 192, 192, 0.15); color: #c0c0c0; }
.rank-num.bronze { background: rgba(205, 127, 50, 0.15); color: #cd7f32; }
.rank-num.normal { background: #3f4147; color: #949ba4; }
.rank-name { flex: 1; font-size: 0.85rem; font-weight: 500; color: #e6edf3; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rank-fame { font-size: 0.78rem; color: #57F287; font-weight: 600; }
.dash-empty { color: #6e7681; font-size: 0.82rem; padding: 12px 0; }
/* 최근 전투 섹션 */
.battle-section { margin-top: 8px; }
.battle-card { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px; }
.battle-list { display: flex; flex-direction: column; gap: 8px; max-height: 320px; overflow-y: auto; }
.battle-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; background: #1e1f22; border-radius: 8px; cursor: pointer; transition: background 0.15s; }
.battle-item:hover { background: #2a2d32; }
.battle-item.kill { border-left: 3px solid #57F287; }
.battle-item.death { border-left: 3px solid #ed4245; }
.battle-killer { font-size: 0.82rem; font-weight: 600; color: #e6edf3; }
.battle-victim { font-size: 0.82rem; color: #949ba4; }
.battle-fame { font-size: 0.72rem; color: #FEE75C; margin-left: auto; white-space: nowrap; }
.battle-time { font-size: 0.68rem; color: #6e7681; margin-left: 8px; white-space: nowrap; }
/* 채집 탭 */
.gather-tabs { display: flex; gap: 6px; margin-bottom: 14px; flex-wrap: wrap; }
.gather-tab { padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 500; background: #3f4147; color: #949ba4; cursor: pointer; border: none; font-family: inherit; transition: all 0.15s; }
.gather-tab.active { background: #5865F2; color: #fff; }
.gather-tab:hover { color: #e6edf3; }
/* 로딩 */
.dash-loading { display: flex; align-items: center; justify-content: center; padding: 60px; color: #949ba4; font-size: 0.88rem; }
</style>

<div class="dashboard">
    <div class="dash-header">
        <h2>주간 통계</h2>
        <p class="dash-period" id="dashPeriod">불러오는 중...</p>
    </div>

    <div class="dash-grid">
        <!-- PvP 랭킹 (스냅샷 diff) -->
        <div class="dash-card">
            <div class="dash-card-title">
                ⚔️ PvP Kill Fame
            </div>
            <ul class="rank-list" id="pvpRankList">
                <li class="dash-empty">불러오는 중...</li>
            </ul>
        </div>

        <!-- PvE 랭킹 -->
        <div class="dash-card">
            <div class="dash-card-title">
                🐉 PvE Fame
            </div>
            <ul class="rank-list" id="pveRankList">
                <li class="dash-empty">불러오는 중...</li>
            </ul>
        </div>

        <!-- 채집 랭킹 -->
        <div class="dash-card">
            <div class="dash-card-title">
                ⛏️ 채집 Fame
            </div>
            <div class="gather-tabs" id="gatherTabs">
                <button class="gather-tab active" data-subtype="All">전체</button>
                <button class="gather-tab" data-subtype="Fiber">섬유</button>
                <button class="gather-tab" data-subtype="Hide">가죽</button>
                <button class="gather-tab" data-subtype="Ore">광석</button>
                <button class="gather-tab" data-subtype="Rock">석재</button>
                <button class="gather-tab" data-subtype="Wood">목재</button>
            </div>
            <ul class="rank-list" id="gatherRankList">
                <li class="dash-empty">불러오는 중...</li>
            </ul>
        </div>
    </div>

    <!-- K/D 그래프 -->
    <div class="battle-section" style="margin-bottom:24px;">
        <div class="battle-card">
            <div class="dash-card-title" style="justify-content:space-between;flex-wrap:wrap;gap:8px;">
                <span>📊 전투 K/D 추이</span>
                <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
                    <div class="gather-tabs" id="graphScaleTabs" style="margin-bottom:0;">
                        <button class="gather-tab active" data-scale="all">전체</button>
                        <button class="gather-tab" data-scale="small">소(2-9)</button>
                        <button class="gather-tab" data-scale="medium">중(10-22)</button>
                        <button class="gather-tab" data-scale="large">대(23+)</button>
                    </div>
                </div>
            </div>
            <div id="battleGraph" style="width:100%;height:200px;position:relative;overflow:visible;cursor:grab;user-select:none;">
                <canvas id="battleCanvas" style="width:100%;height:100%;"></canvas>
                <div id="graphTooltip" style="display:none;position:absolute;background:#1e1f22;border:1px solid #3f4147;border-radius:6px;padding:8px 12px;font-size:0.72rem;color:#e6edf3;pointer-events:none;white-space:nowrap;z-index:100;box-shadow:0 4px 12px rgba(0,0,0,0.5);"></div>
                <button id="graphGoLatest" onclick="goLatestGraph()" style="display:none;position:absolute;bottom:6px;right:8px;padding:3px 10px;background:#5865F2;color:#fff;border:none;border-radius:4px;font-size:0.68rem;cursor:pointer;font-family:inherit;opacity:0.9;">최근으로 →</button>
            </div>
            <div id="battleGraphEmpty" style="display:none;text-align:center;padding:40px 0;color:#6e7681;font-size:0.82rem;">전투 데이터가 없습니다.</div>
        </div>
    </div>

    <!-- 최근 전투 -->
    <div class="battle-section">
        <div class="battle-card">
            <div class="dash-card-title" style="justify-content:space-between;">
                <span>🗡️ 최근 전투</span>
                <div style="display:flex;align-items:center;gap:10px;">
                    <span id="battleCountdown" style="font-size:0.68rem;color:#6e7681;font-weight:400;"></span>
                    <button id="battleRefreshBtn" onclick="refreshBattles()" style="display:inline-flex;align-items:center;gap:4px;padding:4px 10px;background:transparent;color:#949ba4;border:1px solid #3f4147;border-radius:6px;font-size:0.72rem;cursor:pointer;font-family:inherit;transition:all 0.15s;">
                        <svg viewBox="0 0 24 24" style="width:12px;height:12px;fill:currentColor;"><path d="M17.65 6.35A7.958 7.958 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg>
                        새로고침
                    </button>
                </div>
            </div>
            <div class="battle-list" id="battleList">
                <p class="dash-empty">불러오는 중...</p>
            </div>
        </div>
    </div>
</div>

<!-- 전투 상세 모달 -->
<div id="battleDetailModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;backdrop-filter:blur(4px);">
    <div style="background:#21262d;border:1px solid #3f4147;border-radius:16px;padding:28px;max-width:500px;width:90%;max-height:80vh;overflow-y:auto;position:relative;">
        <button onclick="closeBattleDetail()" style="position:absolute;top:12px;right:12px;background:none;border:none;color:#8b949e;cursor:pointer;font-size:1.2rem;">✕</button>
        <div id="battleDetailContent"></div>
    </div>
</div>

<script>
(function() {
    var statsData = null;

    fetch('/' + guildSubdomain + '/home/stats')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.error) {
                document.getElementById('dashPeriod').textContent = data.error;
                return;
            }
            statsData = data;

            if (data.noSnapshot) {
                document.getElementById('dashPeriod').textContent = '';
                var mainContent = document.querySelector('.dashboard');
                mainContent.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;min-height:300px;"><p style="color:#6e7681;font-size:0.92rem;text-align:center;">아직 주간 통계가 없습니다.<br><span style="font-size:0.82rem;">다음 스냅샷 이후 표시됩니다.</span></p></div>';
                return;
            }

            // 기간 표시
            document.getElementById('dashPeriod').textContent =
                data.periodStart + ' ~ ' + data.periodEnd + ' 주간 통계';

            // PvE 랭킹 (스냅샷 diff)
            renderDiffRanking('pveRankList', data.pveRanking);
            // 채집 랭킹
            renderDiffRanking('gatherRankList', data.gatheringRanking);
            // PvP 랭킹 (스냅샷 diff)
            renderDiffRanking('pvpRankList', data.pvpRanking);
            // 최근 전투
            renderBattleList(parseJson(data.recentEvents));
        })
        .catch(function() {
            document.getElementById('dashPeriod').textContent = '통계를 불러올 수 없습니다.';
        });

    function parseJson(str) {
        if (!str) return [];
        if (typeof str === 'object') return str;
        try { return JSON.parse(str); } catch(e) { return []; }
    }

    function formatFame(num) {
        if (!num) return '0';
        if (num >= 1000000000) return (num / 1000000000).toFixed(1) + 'B';
        if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
        if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
        return num.toString();
    }

    function getRankClass(i) {
        if (i === 0) return 'gold';
        if (i === 1) return 'silver';
        if (i === 2) return 'bronze';
        return 'normal';
    }

    function renderRankList(listId, data, fameKey) {
        var list = document.getElementById(listId);
        if (!data || data.length === 0) {
            list.innerHTML = '<li class="dash-empty">데이터가 없습니다.</li>';
            return;
        }
        var html = '';
        data.forEach(function(item, i) {
            var name = item.Name || item.name || '알 수 없음';
            var fame = item[fameKey] || item.fame || item.Fame || 0;
            html += '<li class="rank-item">'
                + '<span class="rank-num ' + getRankClass(i) + '">' + (i + 1) + '</span>'
                + '<span class="rank-name">' + escapeHtml(name) + '</span>'
                + '<span class="rank-fame">' + formatFame(fame) + '</span>'
                + '</li>';
        });
        list.innerHTML = html;
    }

    function renderDiffRanking(listId, data) {
        var list = document.getElementById(listId);
        if (!data || data.length === 0) {
            list.innerHTML = '<li class="dash-empty">데이터가 없습니다.</li>';
            return;
        }
        var html = '';
        data.forEach(function(item, i) {
            var name = item.player_name || item.Name || '알 수 없음';
            var fame = item.fame_diff || item.Fame || 0;
            html += '<li class="rank-item">'
                + '<span class="rank-num ' + getRankClass(i) + '">' + (i + 1) + '</span>'
                + '<span class="rank-name">' + escapeHtml(name) + '</span>'
                + '<span class="rank-fame">+' + formatFame(fame) + '</span>'
                + '</li>';
        });
        list.innerHTML = html;
    }

    function renderPvpSummary(guildData) {
        var summary = document.getElementById('pvpSummary');
        if (!guildData || !guildData.overall) return;
        var o = guildData.overall;
        summary.innerHTML = '<span style="margin-right:16px;">킬 <strong style="color:#57F287;">' + (o.kills || 0) + '</strong></span>'
            + '<span style="margin-right:16px;">데스 <strong style="color:#ed4245;">' + (o.deaths || 0) + '</strong></span>'
            + '<span>K/D <strong style="color:#FEE75C;">' + (o.ratio || '-') + '</strong></span>';
    }

    function renderPvpFromGuildData(guildData) {
        var list = document.getElementById('pvpRankList');
        var summary = document.getElementById('pvpSummary');

        if (!guildData || !guildData.topPlayers || guildData.topPlayers.length === 0) {
            list.innerHTML = '<li class="dash-empty">데이터가 없습니다.</li>';
            return;
        }

        // Top Players (KillFame 기준 정렬)
        var players = guildData.topPlayers.slice(0, 5);
        var html = '';
        players.forEach(function(p, i) {
            var name = p.Name || p.name || '???';
            var fame = p.KillFame || p.killFame || 0;
            html += '<li class="rank-item">'
                + '<span class="rank-num ' + getRankClass(i) + '">' + (i + 1) + '</span>'
                + '<span class="rank-name">' + escapeHtml(name) + '</span>'
                + '<span class="rank-fame">' + formatFame(fame) + '</span>'
                + '</li>';
        });
        list.innerHTML = html;

        // 길드 PvP 요약
        if (guildData.overall) {
            var o = guildData.overall;
            summary.innerHTML = '<span style="margin-right:16px;">킬 <strong style="color:#57F287;">' + (o.kills || 0) + '</strong></span>'
                + '<span style="margin-right:16px;">데스 <strong style="color:#ed4245;">' + (o.deaths || 0) + '</strong></span>'
                + '<span>K/D <strong style="color:#FEE75C;">' + (o.ratio || '-') + '</strong></span>';
        }
    }

    function renderBattleList(events) {
        var container = document.getElementById('battleList');
        if (!events || events.length === 0) {
            container.innerHTML = '<p class="dash-empty">최근 전투 기록이 없습니다.</p>';
            return;
        }

        var html = '';
        events.slice(0, 20).forEach(function(ev) {
            var killer = ev.Killer || ev.killer || {};
            var victim = ev.Victim || ev.victim || {};
            var killerName = killer.Name || killer.name || '???';
            var victimName = victim.Name || victim.name || '???';
            var fame = ev.TotalVictimKillFame || ev.totalVictimKillFame || 0;
            var time = ev.TimeStamp || ev.timestamp || '';
            var evId = ev.EventId || ev.eventId || 0;
            var timeStr = '';
            if (time) {
                var d = new Date(time);
                var now = new Date();
                var diffH = Math.floor((now - d) / 3600000);
                if (diffH < 1) timeStr = Math.floor((now - d) / 60000) + '분 전';
                else if (diffH < 24) timeStr = diffH + '시간 전';
                else timeStr = Math.floor(diffH / 24) + '일 전';
            }

            html += '<div class="battle-item kill" onclick="showBattleDetail(' + evId + ')">'
                + '<span class="battle-killer">' + escapeHtml(killerName) + '</span>'
                + '<span style="color:#6e7681;font-size:0.75rem;">→</span>'
                + '<span class="battle-victim">' + escapeHtml(victimName) + '</span>'
                + '<span class="battle-fame">' + formatFame(fame) + '</span>'
                + '<span class="battle-time">' + timeStr + '</span>'
                + '</div>';
        });
        container.innerHTML = html;
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    // 채집 탭 클릭
    document.getElementById('gatherTabs').addEventListener('click', function(e) {
        var btn = e.target.closest('.gather-tab');
        if (!btn) return;
        var subtype = btn.getAttribute('data-subtype');

        document.querySelectorAll('#gatherTabs .gather-tab').forEach(function(t) { t.classList.remove('active'); });
        btn.classList.add('active');

        document.getElementById('gatherRankList').innerHTML = '<li class="dash-empty">불러오는 중...</li>';

        fetch('/' + guildSubdomain + '/home/stats/gathering?subtype=' + subtype)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                renderDiffRanking('gatherRankList', data.ranking);
            })
            .catch(function() {
                document.getElementById('gatherRankList').innerHTML = '<li class="dash-empty">불러올 수 없습니다.</li>';
            });
    });

    // ===== 최근 전투 2분 폴링 =====
    // ===== 최근 전투 2분 폴링 =====
    // 이미 interval이 돌고 있으면 새로 만들지 않음
    if (!window._battlePollingInterval) {
        window._battleSecondsLeft = 120;

        function fetchBattles() {
            fetch('/' + guildSubdomain + '/home/stats/battles')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.events) {
                        var events = parseJson(data.events);
                        renderBattleList(events);
                    }
                })
                .catch(function() {});
            window._battleSecondsLeft = 120;
        }

        function updateCountdown() {
            window._battleSecondsLeft--;
            if (window._battleSecondsLeft <= 0) window._battleSecondsLeft = 0;
            var min = Math.floor(window._battleSecondsLeft / 60);
            var sec = window._battleSecondsLeft % 60;
            var el = document.getElementById('battleCountdown');
            if (el) el.textContent = min + ':' + (sec < 10 ? '0' : '') + sec;
        }

        // 2분마다 폴링
        window._battlePollingInterval = setInterval(fetchBattles, 120000);
        // 1초마다 카운트다운
        window._battleCountdownInterval = setInterval(updateCountdown, 1000);
        updateCountdown();
    }

})();

function refreshBattles() {
    var btn = document.getElementById('battleRefreshBtn');
    btn.disabled = true;
    btn.style.opacity = '0.5';

    fetch('/' + guildSubdomain + '/home/stats/battles')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.events) {
                var events = (typeof data.events === 'string') ? JSON.parse(data.events) : data.events;
                // renderBattleList 재사용 — IIFE 내부 함수라서 직접 렌더
                var container = document.getElementById('battleList');
                if (!events || events.length === 0) {
                    container.innerHTML = '<p class="dash-empty">최근 전투 기록이 없습니다.</p>';
                } else {
                    renderBattleListGlobal(events);
                }
            }
        })
        .catch(function() {})
        .finally(function() {
            btn.disabled = false;
            btn.style.opacity = '1';
            // 카운트다운 리셋
            window._battleSecondsLeft = 120;
        });
}

// ===== K/D 그래프 (드래그 뷰포트) =====
var currentGraphScale = 'all';
var allBattlePoints = [];
var graphViewport = { start: 0, size: 40 };
var graphDrag = { active: false, startX: 0, startOffset: 0 };

function loadBattleGraph() {
    fetch('/' + guildSubdomain + '/home/stats/battles/graph?scale=' + currentGraphScale)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var battles = data.battles || [];
            allBattlePoints = battles.map(function(b) {
                var kills = b.our_kills || 0;
                var deaths = b.our_deaths || 0;
                var t = b.battle_time;
                if (t && t.indexOf('Z') === -1 && t.indexOf('+') === -1) t += 'Z';
                return { time: new Date(t), kills: kills, deaths: deaths, players: b.total_players, ourPlayers: b.our_player_count };
            });
            graphViewport.size = 40;
            graphViewport.start = Math.max(0, allBattlePoints.length - graphViewport.size);
            drawBattleGraph();
            updateGoLatestBtn();
        })
        .catch(function() {
            document.getElementById('battleGraphEmpty').style.display = 'block';
            document.getElementById('battleCanvas').style.display = 'none';
        });
}

function goLatestGraph() {
    graphViewport.start = Math.max(0, allBattlePoints.length - graphViewport.size);
    drawBattleGraph();
    updateGoLatestBtn();
}

function updateGoLatestBtn() {
    var btn = document.getElementById('graphGoLatest');
    if (!btn) return;
    var isAtEnd = graphViewport.start >= allBattlePoints.length - graphViewport.size;
    btn.style.display = (!isAtEnd && allBattlePoints.length > graphViewport.size) ? 'block' : 'none';
}

function drawBattleGraph() {
    var canvas = document.getElementById('battleCanvas');
    var emptyEl = document.getElementById('battleGraphEmpty');
    var tooltip = document.getElementById('graphTooltip');
    var graphContainer = document.getElementById('battleGraph');

    if (!allBattlePoints || allBattlePoints.length === 0) {
        canvas.style.display = 'none';
        emptyEl.style.display = 'block';
        return;
    }
    canvas.style.display = 'block';
    emptyEl.style.display = 'none';

    // 현재 뷰포트 범위의 데이터
    var end = Math.min(graphViewport.start + graphViewport.size, allBattlePoints.length);
    var points = allBattlePoints.slice(graphViewport.start, end);

    if (points.length === 0) {
        canvas.style.display = 'none';
        emptyEl.style.display = 'block';
        return;
    }

    var dpr = window.devicePixelRatio || 1;
    var rect = graphContainer.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    canvas.style.width = rect.width + 'px';
    canvas.style.height = rect.height + 'px';
    var ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    var w = rect.width;
    var h = rect.height;

    ctx.clearRect(0, 0, w, h);

    var maxKills = Math.max.apply(null, points.map(function(p) { return p.kills; })) || 1;
    var maxDeaths = Math.max.apply(null, points.map(function(p) { return p.deaths; })) || 1;
    var maxVal = Math.max(maxKills, maxDeaths);

    var padding = { top: 16, right: 16, bottom: 28, left: 36 };
    var graphW = w - padding.left - padding.right;
    var graphH = h - padding.top - padding.bottom;
    var midY = padding.top + graphH / 2;

    var barWidth = Math.max(4, Math.min(24, (graphW / points.length) * 0.65));
    var gap = (graphW - barWidth * points.length) / (points.length + 1);

    // 0 기준선
    ctx.strokeStyle = '#5a6173';
    ctx.lineWidth = 0.8;
    ctx.beginPath();
    ctx.moveTo(padding.left, midY);
    ctx.lineTo(w - padding.right, midY);
    ctx.stroke();

    // Y축 라벨
    ctx.fillStyle = '#6e7681';
    ctx.font = '9px sans-serif';
    ctx.textAlign = 'right';
    ctx.fillText(maxVal, padding.left - 4, padding.top + 10);
    ctx.fillText('-' + maxVal, padding.left - 4, h - padding.bottom - 2);
    ctx.fillText('0', padding.left - 4, midY + 3);

    // 바 위치 기록 (hover 용)
    var barRects = [];

    points.forEach(function(p, idx) {
        var x = padding.left + gap + idx * (barWidth + gap);

        // Kill 바 (위로)
        var killH = (p.kills / maxVal) * (graphH / 2);
        ctx.fillStyle = '#ed4245';
        ctx.fillRect(x, midY - killH, barWidth, killH);

        // Death 바 (아래로)
        var deathH = (p.deaths / maxVal) * (graphH / 2);
        ctx.fillStyle = '#5865F2';
        ctx.fillRect(x, midY, barWidth, deathH);

        barRects.push({ x: x, w: barWidth, point: p });
    });

    // X축 날짜 라벨 — 날짜가 바뀌는 지점의 첫 바 아래에 표시 (UTC 기준)
    ctx.fillStyle = '#6e7681';
    ctx.font = '9px sans-serif';
    ctx.textAlign = 'center';
    var prevDate = '';
    points.forEach(function(p, idx) {
        var dateStr = (p.time.getUTCMonth() + 1) + '/' + p.time.getUTCDate();
        if (dateStr !== prevDate) {
            var lx = padding.left + gap + idx * (barWidth + gap) + barWidth / 2;
            ctx.fillText(dateStr, lx, h - 8);
            prevDate = dateStr;
        }
    });

    // 스크롤 인디케이터
    if (allBattlePoints.length > graphViewport.size) {
        var indicatorW = 60;
        var indicatorH = 3;
        var indicatorX = w - padding.right - indicatorW;
        var indicatorY = padding.top - 10;
        var ratio = graphViewport.start / (allBattlePoints.length - graphViewport.size);
        var thumbW = Math.max(10, indicatorW * (graphViewport.size / allBattlePoints.length));

        ctx.fillStyle = '#3f4147';
        ctx.fillRect(indicatorX, indicatorY, indicatorW, indicatorH);
        ctx.fillStyle = '#5865F2';
        ctx.fillRect(indicatorX + ratio * (indicatorW - thumbW), indicatorY, thumbW, indicatorH);
    }

    // Hover 이벤트
    canvas.onmousemove = function(e) {
        if (graphDrag.active) return;
        var canvasRect = canvas.getBoundingClientRect();
        var mx = e.clientX - canvasRect.left;
        var my = e.clientY - canvasRect.top;
        var found = null;
        for (var i = 0; i < barRects.length; i++) {
            var br = barRects[i];
            if (mx >= br.x && mx <= br.x + br.w) {
                found = br;
                break;
            }
        }
        if (found) {
            var p = found.point;
            var total = p.kills + p.deaths;
            var kdPercent = total === 0 ? '0%' : Math.round((p.kills / total) * 100) + '%';
            var timeStr = (p.time.getUTCMonth() + 1) + '월 ' + p.time.getUTCDate() + '일 ' + ('0' + p.time.getUTCHours()).slice(-2) + ':' + ('0' + p.time.getUTCMinutes()).slice(-2) + ' UTC';
            tooltip.innerHTML = '<div style="margin-bottom:4px;font-weight:600;">K/D: ' + kdPercent + '</div>'
                + '<div><span style="color:#ed4245;">Kill: ' + p.kills + '</span> / <span style="color:#5865F2;">Death: ' + p.deaths + '</span></div>'
                + '<div style="margin-top:4px;color:#949ba4;">참여자: ' + p.players + '명 (아군 ' + p.ourPlayers + '명)</div>'
                + '<div style="color:#6e7681;">' + timeStr + '</div>';
            tooltip.style.display = 'block';
            // 위치 계산 — 위로 넘어가면 아래로 표시
            var tooltipLeft = Math.min(mx + 10, w - 180);
            var tooltipTop = my - 70;
            if (tooltipTop < 0) tooltipTop = my + 16;
            tooltip.style.left = tooltipLeft + 'px';
            tooltip.style.top = tooltipTop + 'px';
        } else {
            tooltip.style.display = 'none';
        }
    };
    canvas.onmouseleave = function() {
        if (!graphDrag.active) tooltip.style.display = 'none';
    };
}

// 드래그로 타임라인 이동
(function setupGraphDrag() {
    var canvas = document.getElementById('battleCanvas');
    var graphContainer = document.getElementById('battleGraph');

    canvas.addEventListener('mousedown', function(e) {
        if (allBattlePoints.length <= graphViewport.size) return;
        graphDrag.active = true;
        graphDrag.startX = e.clientX;
        graphDrag.startOffset = graphViewport.start;
        graphContainer.style.cursor = 'grabbing';
        canvas.style.cursor = 'grabbing';
        document.getElementById('graphTooltip').style.display = 'none';
        e.preventDefault();
    });

    document.addEventListener('mousemove', function(e) {
        if (!graphDrag.active) return;
        var dx = e.clientX - graphDrag.startX;
        var rect = graphContainer.getBoundingClientRect();
        var barStep = rect.width / graphViewport.size;
        var indexShift = Math.round(-dx / barStep);
        var newStart = graphDrag.startOffset + indexShift;
        newStart = Math.max(0, Math.min(allBattlePoints.length - graphViewport.size, newStart));
        if (newStart !== graphViewport.start) {
            graphViewport.start = newStart;
            drawBattleGraph();
            updateGoLatestBtn();
        }
    });

    document.addEventListener('mouseup', function() {
        if (graphDrag.active) {
            graphDrag.active = false;
            graphContainer.style.cursor = 'grab';
            canvas.style.cursor = 'grab';
        }
    });

    // 터치 지원
    canvas.addEventListener('touchstart', function(e) {
        if (allBattlePoints.length <= graphViewport.size) return;
        graphDrag.active = true;
        graphDrag.startX = e.touches[0].clientX;
        graphDrag.startOffset = graphViewport.start;
        document.getElementById('graphTooltip').style.display = 'none';
    }, { passive: true });

    document.addEventListener('touchmove', function(e) {
        if (!graphDrag.active) return;
        var dx = e.touches[0].clientX - graphDrag.startX;
        var rect = graphContainer.getBoundingClientRect();
        var barStep = rect.width / graphViewport.size;
        var indexShift = Math.round(-dx / barStep);
        var newStart = graphDrag.startOffset + indexShift;
        newStart = Math.max(0, Math.min(allBattlePoints.length - graphViewport.size, newStart));
        if (newStart !== graphViewport.start) {
            graphViewport.start = newStart;
            drawBattleGraph();
            updateGoLatestBtn();
        }
    }, { passive: true });

    document.addEventListener('touchend', function() {
        graphDrag.active = false;
    });

    // 마우스 휠로도 이동 가능
    canvas.addEventListener('wheel', function(e) {
        if (allBattlePoints.length <= graphViewport.size) return;
        e.preventDefault();
        var shift = e.deltaY > 0 ? 3 : -3;
        var newStart = graphViewport.start + shift;
        newStart = Math.max(0, Math.min(allBattlePoints.length - graphViewport.size, newStart));
        if (newStart !== graphViewport.start) {
            graphViewport.start = newStart;
            drawBattleGraph();
            updateGoLatestBtn();
        }
    });

    canvas.style.cursor = 'grab';
})();

// 규모 필터 이벤트
document.getElementById('graphScaleTabs').addEventListener('click', function(e) {
    var btn = e.target.closest('.gather-tab');
    if (!btn) return;
    currentGraphScale = btn.getAttribute('data-scale');
    this.querySelectorAll('.gather-tab').forEach(function(t) { t.classList.remove('active'); });
    btn.classList.add('active');
    loadBattleGraph();
});

// 초기 로드
loadBattleGraph();

function renderBattleListGlobal(events) {
    var container = document.getElementById('battleList');
    if (!events || events.length === 0) {
        container.innerHTML = '<p class="dash-empty">최근 전투 기록이 없습니다.</p>';
        return;
    }
    var RENDER_URL = 'https://render.albiononline.com/v1/item/';
    var html = '';
    events.slice(0, 20).forEach(function(ev, idx) {
        var killer = ev.Killer || ev.killer || {};
        var victim = ev.Victim || ev.victim || {};
        var killerName = killer.Name || killer.name || '???';
        var victimName = victim.Name || victim.name || '???';
        var fame = ev.TotalVictimKillFame || ev.totalVictimKillFame || 0;
        var time = ev.TimeStamp || ev.timestamp || '';
        var timeStr = '';
        if (time) {
            var d = new Date(time);
            var now = new Date();
            var diffH = Math.floor((now - d) / 3600000);
            if (diffH < 1) timeStr = Math.floor((now - d) / 60000) + '분 전';
            else if (diffH < 24) timeStr = diffH + '시간 전';
            else timeStr = Math.floor(diffH / 24) + '일 전';
        }
        var evId = ev.EventId || ev.eventId || idx;
        html += '<div class="battle-item kill" onclick="showBattleDetail(' + evId + ')">'
            + '<span class="battle-killer">' + escapeHtmlG(killerName) + '</span>'
            + '<span style="color:#6e7681;font-size:0.75rem;">→</span>'
            + '<span class="battle-victim">' + escapeHtmlG(victimName) + '</span>'
            + '<span class="battle-fame">' + formatFameG(fame) + '</span>'
            + '<span class="battle-time">' + timeStr + '</span>'
            + '</div>';
    });
    container.innerHTML = html;
}

function formatFameG(num) {
    if (!num) return '0';
    if (num >= 1000000000) return (num / 1000000000).toFixed(1) + 'B';
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toString();
}
function escapeHtmlG(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function showBattleDetail(eventId) {
    var modal = document.getElementById('battleDetailModal');
    var content = document.getElementById('battleDetailContent');
    content.innerHTML = '<p style="color:#949ba4;font-size:0.85rem;">불러오는 중...</p>';
    modal.style.display = 'flex';

    fetch('/' + guildSubdomain + '/home/stats/battle/' + eventId)
        .then(function(r) { return r.json(); })
        .then(function(ev) {
            if (ev.error) { content.innerHTML = '<p style="color:#ed4245;">' + ev.error + '</p>'; return; }

            var RENDER_URL = 'https://render.albiononline.com/v1/item/';
            var killer = ev.Killer || ev.killer || {};
            var victim = ev.Victim || ev.victim || {};
            var killerEquip = killer.Equipment || {};
            var victimEquip = victim.Equipment || {};
            var fame = ev.TotalVictimKillFame || 0;
            var participants = ev.Participants || ev.participants || [];
            var time = ev.TimeStamp || ev.timestamp || '';
            var timeStr = '';
            if (time) {
                var td = new Date(time);
                timeStr = (td.getUTCMonth() + 1) + '월 ' + td.getUTCDate() + '일 ' + ('0' + td.getUTCHours()).slice(-2) + ':' + ('0' + td.getUTCMinutes()).slice(-2) + ' UTC';
            }

            var html = '<h3 style="font-size:1rem;font-weight:700;margin-bottom:16px;color:#e6edf3;">전투 상세</h3>';
            html += '<p style="font-size:0.75rem;color:#6e7681;margin-bottom:16px;">' + timeStr + '</p>';

            // 킬러
            html += '<div style="margin-bottom:16px;">';
            html += '<p style="font-size:0.78rem;color:#57F287;font-weight:600;margin-bottom:6px;">킬러: ' + escapeHtmlG(killer.Name || '???') + ' <span style="color:#949ba4;font-weight:400;">IP ' + Math.round(killer.AverageItemPower || 0) + '</span></p>';
            html += renderEquipRow(killerEquip, RENDER_URL);
            html += '</div>';

            // 피해자
            html += '<div style="margin-bottom:16px;">';
            html += '<p style="font-size:0.78rem;color:#ed4245;font-weight:600;margin-bottom:6px;">피해자: ' + escapeHtmlG(victim.Name || '???') + ' <span style="color:#949ba4;font-weight:400;">IP ' + Math.round(victim.AverageItemPower || 0) + '</span></p>';
            html += renderEquipRow(victimEquip, RENDER_URL);
            html += '</div>';

            // Fame
            html += '<p style="font-size:0.82rem;color:#FEE75C;font-weight:600;margin-bottom:12px;">Kill Fame: ' + formatFameG(fame) + '</p>';

            // 참여자
            if (participants.length > 1) {
                html += '<p style="font-size:0.78rem;color:#949ba4;margin-bottom:6px;">참여자 (' + participants.length + '명)</p>';
                html += '<div style="display:flex;flex-wrap:wrap;gap:4px;">';
                participants.forEach(function(p) {
                    var pName = p.Name || p.name || '???';
                    html += '<span style="font-size:0.72rem;background:#3f4147;color:#e6edf3;padding:2px 8px;border-radius:4px;">' + escapeHtmlG(pName) + '</span>';
                });
                html += '</div>';
            }

            content.innerHTML = html;
        })
        .catch(function() {
            content.innerHTML = '<p style="color:#ed4245;">상세 정보를 불러올 수 없습니다.</p>';
        });
}

function renderEquipRow(equip, renderUrl) {
    var slots = ['MainHand','OffHand','Head','Armor','Shoes','Cape','Mount'];
    var html = '<div style="display:flex;gap:4px;flex-wrap:wrap;">';
    slots.forEach(function(slot) {
        var item = equip[slot];
        if (item && item.Type) {
            html += '<div style="width:36px;height:36px;border-radius:4px;background:#161b22;border:1px solid #3f4147;overflow:hidden;">'
                + '<img src="' + renderUrl + encodeURIComponent(item.Type) + '.png?size=40" '
                + 'style="width:36px;height:36px;" loading="lazy" title="' + slot + '" '
                + 'onerror="this.style.display=\'none\'">'
                + '</div>';
        }
    });
    html += '</div>';
    return html;
}

function closeBattleDetail() {
    document.getElementById('battleDetailModal').style.display = 'none';
}
// 모달 외부 클릭 닫기
document.getElementById('battleDetailModal').addEventListener('click', function(e) {
    if (e.target === this) closeBattleDetail();
});
</script>
