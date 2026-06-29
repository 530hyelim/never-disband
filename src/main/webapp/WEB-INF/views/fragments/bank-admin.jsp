<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
.ba-page { max-width: 900px; margin: 0 auto; }
.ba-grid { display: grid; grid-template-columns: 6fr 4fr; grid-template-rows: 360px 360px; gap: 20px; margin-bottom: 20px; }
.ba-grid-withdraw { grid-column: 1; grid-row: 1; display: flex; flex-direction: column; overflow: hidden; }
.ba-grid-deposit { grid-column: 1; grid-row: 2; display: flex; flex-direction: column; overflow: hidden; }
.ba-grid-log { grid-column: 2; grid-row: 1 / 3; }
.ba-bottom { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.ba-section { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px 24px; }
.ba-section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.ba-section-title { font-size: 0.88rem; font-weight: 600; color: #e6edf3; display: flex; align-items: center; gap: 8px; }
.ba-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.ba-badge.withdraw { background: rgba(254,231,92,0.1); color: #FEE75C; }
.ba-badge.deposit { background: rgba(254,231,92,0.1); color: #FEE75C; }
.ba-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
.ba-table th { font-size: 0.72rem; color: #949ba4; font-weight: 500; text-align: center; padding: 6px 8px; border-bottom: 1px solid #3f4147; }
.ba-table td { font-size: 0.82rem; color: #e6edf3; padding: 10px 3px; border-bottom: 1px solid #3f4147; vertical-align: middle; text-align: center; }
.ba-table tr:last-child td { border-bottom: none; }
.ba-table input[type="checkbox"] { width: 14px; height: 14px; accent-color: #5865F2; cursor: pointer; }
.ba-amount-input { width: 100%; padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; text-align: center; box-sizing: border-box; }
.ba-amount-input:focus { border-color: #5865F2; }
.ba-amount-input::-webkit-outer-spin-button,
.ba-amount-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.ba-amount-input[type=number] { -moz-appearance: textfield; }
.ba-name-input { padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; width: 100%; box-sizing: border-box; }
.ba-name-input:focus { border-color: #5865F2; }
.ba-btn { padding: 5px 9px; border: none; border-radius: 12px; font-size: 0.72rem; font-weight: 600; cursor: pointer; font-family: inherit; transition: all 0.15s; background: #3f4147; color: #e6edf3; }
.ba-btn:hover { background: #4f545c; }
.ba-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.ba-btn.green { background: rgba(87,242,135,0.1); color: #57F287; }
.ba-btn.green:hover { background: rgba(87,242,135,0.2); }
.ba-btn.red { background: rgba(237,66,69,0.1); color: #ed4245; }
.ba-btn.red:hover { background: rgba(237,66,69,0.2); }
.ba-empty { color: #6e7681; font-size: 0.82rem; text-align: center; margin: auto; }
.ba-log-item { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid #3f4147; font-size: 0.78rem; }
.ba-log-item:last-child { border-bottom: none; }
.ba-log-badge { padding: 2px 6px; border-radius: 3px; font-size: 0.68rem; font-weight: 600; }
.ba-log-badge { padding: 2px 6px; border-radius: 3px; font-size: 0.68rem; font-weight: 600; }
.ba-log-badge.approved { background: rgba(87,242,135,0.1); color: #57F287; }
.ba-log-badge.rejected { background: rgba(237,66,69,0.1); color: #ed4245; }
.ba-log-badge.direct { background: rgba(88,101,242,0.1); color: #a5b4fc; }
.ba-log-text { color: #c9d1d9; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ba-log-time { color: #6e7681; font-size: 0.7rem; white-space: nowrap; }
/* 커스텀 멤버 드롭다운 */
.ba-member-dd { position: relative; width: 100%; }
.ba-member-trigger { display: flex; align-items: center; justify-content: space-between; padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; cursor: pointer; user-select: none; }
.ba-member-trigger:hover { border-color: #5865F2; }
.ba-member-trigger.open { border-color: #5865F2; }
.ba-member-trigger svg { width: 10px; height: 10px; fill: #949ba4; flex-shrink: 0; }
.ba-member-panel { display: none; position: absolute; top: calc(100% + 4px); left: 0; right: 0; background: #1e1f22; border: 1px solid #3f4147; border-radius: 8px; z-index: 200; box-shadow: 0 4px 16px rgba(0,0,0,0.4); }
.ba-member-panel.open { display: block; }
.ba-member-search { width: 100%; padding: 8px 10px; background: transparent; border: none; border-bottom: 1px solid #3f4147; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; box-sizing: border-box; }
.ba-member-list { max-height: 160px; overflow-y: auto; }
.ba-member-opt { text-align:left; padding: 7px 10px; font-size: 0.82rem; color: #e6edf3; cursor: pointer; }
.ba-member-opt:hover { background: #2b2d31; }
.ba-member-opt.selected { color: #5865F2; }
.ba-member-opt.hidden { display: none; }
/* 금액 표시 input (text type, 콤마 표시용) */
.ba-amount-display { width: 100%; padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; text-align: center; box-sizing: border-box; }
.ba-amount-display:focus { border-color: #5865F2; }
</style>

<div class="ba-page">
    <h2 style="margin-bottom:28px;">은행 관리</h2>
    <div class="ba-grid">
        <!-- 출금 신청서 (좌상) -->
        <div class="ba-section ba-grid-withdraw">
            <div class="ba-section-header">
                <div class="ba-section-title">출금 신청서 <span class="ba-badge withdraw" id="baWithdrawCount">0건</span></div>
                <div style="display:flex;gap:6px;">
                    <button class="ba-btn" onclick="approveAll('withdrawal')">전체 승인</button>
                </div>
            </div>
            <table class="ba-table">
                <thead><tr><th style="width:30px;"><input type="checkbox" onchange="toggleAll(this, 'withdrawal')"></th><th style="width:auto;">멤버</th><th style="width:100px;">금액</th><th style="width:80px;">신청일</th><th style="width:90px;"></th></tr></thead>
            </table>
            <div style="flex:1;overflow-y:auto;display:flex;flex-direction:column;">
                <table class="ba-table">
                    <colgroup><col style="width:30px;"><col><col style="width:100px;"><col style="width:80px;"><col style="width:90px;"></colgroup>
                    <tbody id="baWithdrawBody"></tbody>
                </table>
                <p class="ba-empty" id="baWithdrawEmpty" style="display:none;">대기 중인 신청이 없습니다.</p>
            </div>
            <div style="display:flex;justify-content:space-between;padding-top:3px;">
                <div style="display:flex;gap:6px;">
                    <button class="ba-btn green" onclick="approveSelected('withdrawal')">선택 승인</button>
                    <button class="ba-btn red" onclick="rejectSelected('withdrawal')">선택 반려</button>
                </div>
                <button class="ba-btn" onclick="addDirectRow('withdrawal')">+ 직접출금</button>
            </div>
        </div>

        <!-- 입금 신청서 (좌하) -->
        <div class="ba-section ba-grid-deposit">
            <div class="ba-section-header">
                <div class="ba-section-title">입금 신청서 <span class="ba-badge deposit" id="baDepositCount">0건</span></div>
                <div style="display:flex;gap:6px;">
                    <button class="ba-btn" onclick="approveAll('deposit')">전체 승인</button>
                </div>
            </div>
            <table class="ba-table">
                <thead><tr><th style="width:30px;"><input type="checkbox" onchange="toggleAll(this, 'deposit')"></th><th style="width:auto;">멤버</th><th style="width:100px;">금액</th><th style="width:80px;">신청일</th><th style="width:90px;"></th></tr></thead>
            </table>
            <div style="flex:1;overflow-y:auto;display:flex;flex-direction:column;">
                <table class="ba-table">
                    <colgroup><col style="width:30px;"><col><col style="width:100px;"><col style="width:80px;"><col style="width:90px;"></colgroup>
                    <tbody id="baDepositBody"></tbody>
                </table>
                <p class="ba-empty" id="baDepositEmpty" style="display:none;">대기 중인 신청이 없습니다.</p>
            </div>
            <div style="display:flex;justify-content:space-between;padding-top:3px;">
                <div style="display:flex;gap:6px;">
                    <button class="ba-btn green" onclick="approveSelected('deposit')">선택 승인</button>
                    <button class="ba-btn red" onclick="rejectSelected('deposit')">선택 반려</button>
                </div>
                <button class="ba-btn" onclick="addDirectRow('deposit')">+ 직접입금</button>
            </div>
        </div>

        <!-- 보유 현황 (우, 2행 차지) -->
        <div class="ba-section ba-grid-log" style="display:flex;flex-direction:column;overflow:hidden;">
            <div class="ba-section-header">
                <div class="ba-section-title">보유 현황</div>
                <div id="holdingsTotal" style="font-size:0.88rem;font-weight:700;color:#FEE75C;">-</div>
            </div>
            <table class="ba-table">
                <thead><tr><th style="width:30px;">#</th><th>멤버</th><th style="width:80px;">잔액</th></tr></thead>
            </table>
            <div id="holdingsList" style="flex:1;overflow-y:auto;"></div>
        </div>
    </div>

    <!-- 하단: 처리로그 5 : 그래프 5 -->
    <div class="ba-bottom">
        <div class="ba-section" style="display:flex;flex-direction:column;">
            <div class="ba-section-header">
                <div class="ba-section-title">처리 로그</div>
                <div id="baLogPaging" style="display:flex;align-items:center;gap:6px;"></div>
            </div>
            <div id="baLogList" style="flex:1;display:flex;flex-direction:column;">
            </div>
        </div>

        <div class="ba-section" style="display:flex;flex-direction:column;">
            <div class="ba-section-header">
                <div class="ba-section-title">입/출금 흐름</div>
                <div style="display:flex;gap:6px;">
                    <button class="ba-btn" data-profit="week" onclick="loadProfit('week', this)">1주</button>
                    <button class="ba-btn" data-profit="month" onclick="loadProfit('month', this)" style="background:#5865F2;">1달</button>
                    <button class="ba-btn" data-profit="6month" onclick="loadProfit('6month', this)">6개월</button>
                    <button class="ba-btn" data-profit="year" onclick="loadProfit('year', this)">1년</button>
                </div>
            </div>
            <div id="profitGraph" style="width:100%;height:175px;position:relative;">
                <canvas id="profitCanvas" style="width:100%;height:100%;"></canvas>
                <div id="profitTooltip" style="display:none;position:absolute;background:#1e1f22;border:1px solid #3f4147;border-radius:6px;padding:6px 10px;font-size:0.72rem;color:#e6edf3;pointer-events:none;white-space:nowrap;z-index:100;"></div>
                <p class="ba-empty" id="profitEmpty" style="display:none;position:absolute;top:0;left:0;right:0;bottom:0;margin:auto;height:fit-content;">데이터가 없습니다.</p>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    var allMembers = [];
    var allWithdrawals = [];
    var allDeposits = [];
    var pageSize = { withdrawal: 999, deposit: 999 };

    loadBankAdmin();

    function loadBankAdmin() {
        fetch('/' + guildSubdomain + '/admin/bank/info')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                allMembers = data.members || [];
                allWithdrawals = data.withdrawals || [];
                allDeposits = data.deposits || [];
                document.getElementById('baWithdrawCount').textContent = allWithdrawals.length + '건';
                document.getElementById('baDepositCount').textContent = allDeposits.length + '건';
                renderTable('withdrawal');
                renderTable('deposit');
                renderLogs(data.logs || []);
                loadHoldings();
            })
            .catch(function() {});
    }

    function renderTable(type) {
        var items = type === 'withdrawal' ? allWithdrawals : allDeposits;
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        var emptyId = type === 'withdrawal' ? 'baWithdrawEmpty' : 'baDepositEmpty';
        var tbody = document.getElementById(bodyId);
        var emptyEl = document.getElementById(emptyId);
        var size = pageSize[type];
        var visible = items.slice(0, size);

        if (!items || items.length === 0) {
            tbody.innerHTML = '';
            emptyEl.style.display = 'block';
            return;
        }
        emptyEl.style.display = 'none';
        var html = '';
        visible.forEach(function(item) {
            var amountCell = type === 'withdrawal'
                ? '<span style="font-weight:600;">' + Number(item.amount).toLocaleString() + '</span>'
                : '<input type="text" class="ba-amount-display" value="' + Number(item.amount).toLocaleString() + '" data-raw="' + item.amount + '" data-id="' + item.id + '" oninput="formatAmountInput(this)">';
            html += '<tr data-id="' + item.id + '" data-amount="' + item.amount + '">'
                + '<td><input type="checkbox" class="ba-check" data-id="' + item.id + '" data-type="' + type + '"></td>'
                + '<td>' + escapeHtml(item.character_name || '???') + '</td>'
                + '<td>' + amountCell + '</td>'
                + '<td style="color:#6e7681;font-size:0.75rem;">' + formatDate(item.created_at) + '</td>'
                + '<td><button class="ba-btn green" onclick="approveSingle(' + item.id + ', this)" style="margin-right:4px;">승인</button><button class="ba-btn red" onclick="rejectSingle(' + item.id + ')">반려</button></td>'
                + '</tr>';
        });
        tbody.innerHTML = html;
    }

    var logPage = 0;
    var logPageSize = 5;
    var allLogs = [];

    function renderLogs(logs) {
        allLogs = logs || [];
        logPage = 0;
        renderLogPage();
    }

    function renderLogPage() {
        var el = document.getElementById('baLogList');
        var pagingEl = document.getElementById('baLogPaging');
        if (!allLogs || allLogs.length === 0) {
            el.innerHTML = '<p class="ba-empty">처리 내역이 없습니다.</p>';
            pagingEl.innerHTML = '';
            return;
        }
        var start = logPage * logPageSize;
        var page = allLogs.slice(start, start + logPageSize);
        var html = '';
        page.forEach(function(log) {
            var badgeClass = log.status === 'approved' ? 'approved' : log.status === 'rejected' ? 'rejected' : 'direct';
            var badgeText = log.status === 'approved' ? '승인' : log.status === 'rejected' ? '반려' : '-';
            var actionText = log.type === 'deposit' ? '입금' : '출금';
            html += '<div class="ba-log-item">'
                + '<span class="ba-log-badge ' + badgeClass + '">' + badgeText + '</span>'
                + '<span class="ba-log-text">' + escapeHtml(log.target_name || '') + ' · ' + actionText + ' ' + formatSilver(log.amount) + ' · 처리자 ' + escapeHtml(log.approved_by_name || '') + '</span>'
                + '<span class="ba-log-time">' + formatDate(log.approved_at || log.created_at) + '</span>'
                + '</div>';
        });
        el.innerHTML = html;
        // 페이징 컨트롤 (header 우측)
        var totalPages = Math.ceil(allLogs.length / logPageSize);
        if (totalPages > 1) {
            pagingEl.innerHTML = '<button class="ba-btn" style="padding:3px 8px;font-size:0.68rem;" onclick="logPrev()" ' + (logPage === 0 ? 'disabled' : '') + '>←</button>'
                + '<span style="font-size:0.68rem;color:#949ba4;">' + (logPage + 1) + ' / ' + totalPages + '</span>'
                + '<button class="ba-btn" style="padding:3px 8px;font-size:0.68rem;" onclick="logNext()" ' + (logPage >= totalPages - 1 ? 'disabled' : '') + '>→</button>';
        } else {
            pagingEl.innerHTML = '';
        }
    }

    window.logPrev = function() { if (logPage > 0) { logPage--; renderLogPage(); } };
    window.logNext = function() { if ((logPage + 1) * logPageSize < allLogs.length) { logPage++; renderLogPage(); } };

    // ===== 순이익 그래프 =====
    function loadProfit(period, btn) {
        if (btn) {
            document.querySelectorAll('[data-profit]').forEach(function(b) { b.style.background = '#3f4147'; });
            btn.style.background = '#5865F2';
        }
        fetch('/' + guildSubdomain + '/admin/bank/profit?period=' + period)
            .then(function(r) { return r.json(); })
            .then(function(data) { drawProfitGraph(data.daily || []); })
            .catch(function() {});
    };

    function drawProfitGraph(daily) {
        var canvas = document.getElementById('profitCanvas');
        var emptyEl = document.getElementById('profitEmpty');
        var tooltip = document.getElementById('profitTooltip');
        var container = document.getElementById('profitGraph');

        if (!daily || daily.length === 0) {
            canvas.style.display = 'none';
            emptyEl.style.display = 'block';
            return;
        }
        canvas.style.display = 'block';
        emptyEl.style.display = 'none';

        var points = daily.map(function(d) {
            var dep = Number(d.total_deposit || 0);
            var wit = Number(d.total_withdrawal || 0);
            return { day: d.day, profit: dep - wit };
        });

        var dpr = window.devicePixelRatio || 1;
        var rect = container.getBoundingClientRect();
        canvas.width = rect.width * dpr;
        canvas.height = rect.height * dpr;
        canvas.style.width = rect.width + 'px';
        canvas.style.height = rect.height + 'px';
        var ctx = canvas.getContext('2d');
        ctx.scale(dpr, dpr);
        var w = rect.width, h = rect.height;
        ctx.clearRect(0, 0, w, h);

        var padding = { top: 12, right: 12, bottom: 12, left: 30 };
        var gw = w - padding.left - padding.right;
        var gh = h - padding.top - padding.bottom;

        var maxAbs = Math.max.apply(null, points.map(function(p) { return Math.abs(p.profit); })) || 1;
        var midY = padding.top + gh / 2;

        // 0 기준선
        ctx.strokeStyle = '#5a6173';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.moveTo(padding.left, midY);
        ctx.lineTo(w - padding.right, midY);
        ctx.stroke();

        // Y축 라벨
        ctx.fillStyle = '#6e7681';
        ctx.font = '9px sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText('+' + formatShort(maxAbs), padding.left - 4, padding.top + 8);
        ctx.fillText('-' + formatShort(maxAbs), padding.left - 4, h - padding.bottom - 2);
        ctx.fillText('0', padding.left - 4, midY + 3);

        // 선 그래프
        var pointCoords = [];
        ctx.beginPath();
        ctx.strokeStyle = '#5865F2';
        ctx.lineWidth = 2;
        points.forEach(function(p, i) {
            var x = padding.left + (i / (points.length - 1 || 1)) * gw;
            var y = midY - (p.profit / maxAbs) * (gh / 2);
            pointCoords.push({ x: x, y: y, point: p });
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        });
        ctx.stroke();

        // 점
        pointCoords.forEach(function(pc) {
            ctx.beginPath();
            ctx.fillStyle = pc.point.profit >= 0 ? '#57F287' : '#ed4245';
            ctx.arc(pc.x, pc.y, 3, 0, Math.PI * 2);
            ctx.fill();
        });

        // X축 라벨
        ctx.fillStyle = '#6e7681';
        ctx.font = '9px sans-serif';
        ctx.textAlign = 'center';
        if (points.length >= 2) {
            ctx.fillText(points[0].day, padding.left, h - 6);
            ctx.fillText(points[points.length - 1].day, w - padding.right, h - 6);
        }
        if (points.length >= 5) {
            var mi = Math.floor(points.length / 2);
            var mx = padding.left + (mi / (points.length - 1)) * gw;
            ctx.fillText(points[mi].day, mx, h - 6);
        }

        // Hover
        canvas.onmousemove = function(e) {
            var cr = canvas.getBoundingClientRect();
            var mx = e.clientX - cr.left;
            var closest = null, minDist = 999;
            pointCoords.forEach(function(pc) {
                var dist = Math.abs(pc.x - mx);
                if (dist < minDist) { minDist = dist; closest = pc; }
            });
            if (closest && minDist < 20) {
                var sign = closest.point.profit >= 0 ? '+' : '';
                tooltip.innerHTML = '<div>' + closest.point.day + '</div><div style="font-weight:600;color:' + (closest.point.profit >= 0 ? '#57F287' : '#ed4245') + ';">' + sign + formatSilver(closest.point.profit) + '</div>';
                tooltip.style.display = 'block';
                tooltip.style.left = Math.min(closest.x + 8, w - 120) + 'px';
                tooltip.style.top = (closest.y - 40) + 'px';
            } else {
                tooltip.style.display = 'none';
            }
        };
        canvas.onmouseleave = function() { tooltip.style.display = 'none'; };
    }

    // ===== 보유 현황 =====
    function loadHoldings() {
        fetch('/' + guildSubdomain + '/admin/bank/holdings')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var members = data.members || [];
                document.getElementById('holdingsTotal').textContent = '총 ' + formatSilver(data.total || 0);
                members.sort(function(a, b) { return (b.balance || 0) - (a.balance || 0); });
                var html = '<table class="ba-table"><colgroup><col style="width:30px;"><col><col style="width:80px;"></colgroup><tbody>';
                members.forEach(function(m, i) {
                    html += '<tr><td style="color:#949ba4;">' + (i + 1) + '</td><td>' + escapeHtml(m.character_name) + '</td><td style="font-weight:600;">' + formatShort(m.balance || 0) + '</td></tr>';
                });
                html += '</tbody></table>';
                document.getElementById('holdingsList').innerHTML = html;
            })
            .catch(function() {});
    }

    function formatSilver(num) { if (!num) return '0'; return Number(num).toLocaleString(); }
    function formatShort(num) {
        if (!num) return '0';
        var v = Number(num);
        if (v >= 1000000000) return (v / 1000000000).toFixed(1).replace(/\.0$/, '') + 'B';
        if (v >= 1000000) return (v / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
        if (v >= 100000) return (v / 1000).toFixed(0) + 'K';
        return v.toLocaleString();
    }
    function formatDate(str) { if (!str) return ''; var d = new Date(str); return (d.getMonth()+1) + '/' + d.getDate() + ' ' + ('0'+d.getHours()).slice(-2) + ':' + ('0'+d.getMinutes()).slice(-2); }
    function escapeHtml(str) { if (!str) return ''; return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

    // 초기 로드
    loadProfit('month');
    loadHoldings();

    window.loadProfit = loadProfit;

    // 커스텀 드롭다운 생성
    function createMemberDropdown(uid) {
        var html = '<div class="ba-member-dd" id="dd-' + uid + '">'
            + '<div class="ba-member-trigger" onclick="toggleMemberDD(\'' + uid + '\')">'
            + '<span class="ba-member-label">멤버 선택</span>'
            + '<svg viewBox="0 0 10 6"><path d="M0 0l5 6 5-6z"/></svg>'
            + '</div>'
            + '<div class="ba-member-panel" id="ddp-' + uid + '">'
            + '<input class="ba-member-search" placeholder="검색..." oninput="filterMemberDD(\'' + uid + '\', this.value)">'
            + '<div class="ba-member-list" id="ddl-' + uid + '">';
        allMembers.forEach(function(m) {
            html += '<div class="ba-member-opt" data-id="' + m.id + '" data-name="' + escapeHtml(m.character_name) + '" onclick="selectMemberDD(\'' + uid + '\',' + m.id + ',\'' + escapeHtml(m.character_name) + '\')">'
                + escapeHtml(m.character_name)
                + '</div>';
        });
        html += '</div></div></div>';
        return html;
    }

    window.toggleMemberDD = function(uid) {
        var trigger = document.querySelector('#dd-' + uid + ' .ba-member-trigger');
        var panel = document.getElementById('ddp-' + uid);
        var isOpen = panel.classList.contains('open');
        // 다른 열린 드롭다운 닫기
        document.querySelectorAll('.ba-member-panel.open').forEach(function(p) { p.classList.remove('open'); p.previousElementSibling.classList.remove('open'); });
        if (!isOpen) {
            panel.classList.add('open');
            trigger.classList.add('open');
            panel.querySelector('.ba-member-search').focus();
        }
    };

    window.filterMemberDD = function(uid, q) {
        var list = document.getElementById('ddl-' + uid);
        list.querySelectorAll('.ba-member-opt').forEach(function(opt) {
            opt.classList.toggle('hidden', !opt.getAttribute('data-name').toLowerCase().includes(q.toLowerCase()));
        });
    };

    window.selectMemberDD = function(uid, id, name) {
        var dd = document.getElementById('dd-' + uid);
        dd.querySelector('.ba-member-label').textContent = name;
        dd.setAttribute('data-selected', id);
        document.getElementById('ddp-' + uid).classList.remove('open');
        dd.querySelector('.ba-member-trigger').classList.remove('open');
    };

    // 외부 클릭 시 드롭다운 닫기
    document.addEventListener('click', function(e) {
        if (!e.target || !e.target.closest) return;
        if (!e.target.closest('.ba-member-dd')) {
            document.querySelectorAll('.ba-member-panel.open').forEach(function(p) { p.classList.remove('open'); p.previousElementSibling.classList.remove('open'); });
        }
    });

    // 금액 입력 시 콤마 포맷팅
    window.formatAmountInput = function(input) {
        var raw = input.value.replace(/,/g, '').replace(/[^0-9]/g, '');
        if (raw === '') { input.value = ''; return; }
        input.value = Number(raw).toLocaleString();
    };

    window.setPageSize = function(type, size) {
        pageSize[type] = parseInt(size);
        renderTable(type);
    };

    window.addDirectRow = function(type) {
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        var emptyId = type === 'withdrawal' ? 'baWithdrawEmpty' : 'baDepositEmpty';
        var tbody = document.getElementById(bodyId);
        document.getElementById(emptyId).style.display = 'none';

        var uid = 'u' + Date.now();
        var row = document.createElement('tr');
        row.setAttribute('data-direct', 'true');
        row.innerHTML = '<td><input type="checkbox" class="ba-check" data-direct="true" data-type="' + type + '"></td>'
            + '<td>' + createMemberDropdown(uid) + '</td>'
            + '<td><input type="text" class="ba-amount-display" placeholder="0" oninput="formatAmountInput(this)"></td>'
            + '<td style="color:#6e7681;font-size:0.75rem;">-</td>'
            + '<td><button class="ba-btn green" onclick="submitDirect(this,\'' + type + '\')" style="margin-right:4px;">승인</button><button class="ba-btn red" onclick="cancelDirectRow(this,\'' + type + '\')">취소</button></td>';
        tbody.appendChild(row);
        // 스크롤 맨 아래로
        var scrollDiv = tbody.closest('[style*="overflow-y"]');
        if (scrollDiv) scrollDiv.scrollTop = scrollDiv.scrollHeight;
    };

    window.cancelDirectRow = function(btn, type) {
        var row = btn.closest('tr');
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        var emptyId = type === 'withdrawal' ? 'baWithdrawEmpty' : 'baDepositEmpty';
        row.remove();
        var tbody = document.getElementById(bodyId);
        if (tbody.querySelectorAll('tr').length === 0) {
            document.getElementById(emptyId).style.display = 'block';
        }
    };

    window.submitDirect = function(btn, type) {
        var row = btn.closest('tr');
        var dd = row.querySelector('.ba-member-dd');
        var memberId = dd ? dd.getAttribute('data-selected') : null;
        var amountInput = row.querySelector('.ba-amount-display');
        var amount = amountInput ? parseInt(amountInput.value.replace(/,/g, '')) : 0;
        if (!memberId || !amount || amount <= 0) return;
        fetch('/' + guildSubdomain + '/admin/bank/direct', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ memberId: parseInt(memberId), amount: amount, type: type })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.approveSingle = function(id, btn) {
        var row = btn.closest('tr');
        var input = row.querySelector('.ba-amount-display');
        var amount = input ? parseInt(input.value.replace(/,/g, '')) : (row.getAttribute('data-amount') ? parseInt(row.getAttribute('data-amount')) : null);
        fetch('/' + guildSubdomain + '/admin/bank/approve', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ ids: [id], amount: amount })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.rejectSingle = function(id) {
        fetch('/' + guildSubdomain + '/admin/bank/reject', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ ids: [id] })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.approveSelected = function(type) {
        var ids = getCheckedIds(type);
        if (ids.length === 0) return;
        fetch('/' + guildSubdomain + '/admin/bank/approve', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ ids: ids })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.rejectSelected = function(type) {
        var ids = getCheckedIds(type);
        if (ids.length === 0) return;
        fetch('/' + guildSubdomain + '/admin/bank/reject', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ ids: ids })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.approveAll = function(type) {
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        var checks = document.querySelectorAll('#' + bodyId + ' .ba-check');
        var ids = [];
        checks.forEach(function(c) { var id = c.getAttribute('data-id'); if (id) ids.push(parseInt(id)); });
        if (ids.length === 0) return;
        if (!confirm(ids.length + '건을 전체 승인하시겠습니까?')) return;
        fetch('/' + guildSubdomain + '/admin/bank/approve', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ ids: ids })
        }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadBankAdmin(); });
    };

    window.toggleAll = function(cb, type) {
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        document.querySelectorAll('#' + bodyId + ' .ba-check').forEach(function(c) { c.checked = cb.checked; });
    };

    function getCheckedIds(type) {
        var bodyId = type === 'withdrawal' ? 'baWithdrawBody' : 'baDepositBody';
        var ids = [];
        document.querySelectorAll('#' + bodyId + ' .ba-check:checked').forEach(function(c) { ids.push(parseInt(c.getAttribute('data-id'))); });
        return ids;
    }

    // 소켓으로 은행 변경 수신 시 갱신
    (function waitWsForBank() {
        if (!window.stompClient || !window.stompClient.connected) { setTimeout(waitWsForBank, 500); return; }
        stompClient.subscribe('/topic/guild/' + guildSubdomain + '/bank', function() {
            loadBankAdmin();
        });
    })();
})();
</script>
