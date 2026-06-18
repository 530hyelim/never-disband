<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
.ba-page { max-width: 700px; margin: 0 auto; }
.ba-section { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px 24px; margin-bottom: 20px; }
.ba-section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.ba-section-title { font-size: 0.88rem; font-weight: 600; color: #e6edf3; display: flex; align-items: center; gap: 8px; }
.ba-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.ba-badge.withdraw { background: rgba(88,101,242,0.1); color: #5865F2; }
.ba-badge.deposit { background: rgba(237,66,69,0.1); color: #ed4245; }
.ba-actions { display: flex; gap: 6px; justify-content: flex-end; margin-bottom: 12px; }
.ba-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
.ba-table th { font-size: 0.72rem; color: #949ba4; font-weight: 500; text-align: center; padding: 6px 8px; border-bottom: 1px solid #3f4147; }
.ba-table td { font-size: 0.82rem; color: #e6edf3; padding: 10px 8px; border-bottom: 1px solid #3f4147; vertical-align: middle; text-align: center; }
.ba-table tr:last-child td { border-bottom: none; }
.ba-table input[type="checkbox"] { width: 14px; height: 14px; accent-color: #5865F2; cursor: pointer; }
.ba-amount-input { width: 100%; padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; text-align: center; box-sizing: border-box; }
.ba-amount-input:focus { border-color: #5865F2; }
.ba-amount-input::-webkit-outer-spin-button,
.ba-amount-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.ba-amount-input[type=number] { -moz-appearance: textfield; }
.ba-name-input { padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; width: 100%; box-sizing: border-box; }
.ba-name-input:focus { border-color: #5865F2; }
.ba-btn { padding: 5px 12px; border: none; border-radius: 6px; font-size: 0.72rem; font-weight: 600; cursor: pointer; font-family: inherit; transition: all 0.15s; background: #3f4147; color: #e6edf3; }
.ba-btn:hover { background: #4f545c; }
.ba-btn.hover-red:hover { background: rgba(237,66,69,0.15); color: #ed4245; }
.ba-btn.hover-green:hover { background: rgba(87,242,135,0.15); color: #57F287; }
.ba-btn.hover-blue:hover { background: rgba(88,101,242,0.15); color: #a5b4fc; }
.ba-btn.green { background: rgba(87,242,135,0.1); color: #57F287; }
.ba-btn.green:hover { background: rgba(87,242,135,0.2); }
.ba-btn.red { background: rgba(237,66,69,0.1); color: #ed4245; }
.ba-btn.red:hover { background: rgba(237,66,69,0.2); }
.ba-table-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; }
.ba-page-select { padding: 4px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.72rem; font-family: inherit; outline: none; }
.ba-empty { color: #6e7681; font-size: 0.82rem; padding: 16px 0; text-align: center; }
.ba-log-item { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid #3f4147; font-size: 0.78rem; }
.ba-log-item:last-child { border-bottom: none; }
.ba-log-badge { padding: 2px 6px; border-radius: 3px; font-size: 0.68rem; font-weight: 600; }
.ba-log-badge.approved { background: rgba(87,242,135,0.1); color: #57F287; }
.ba-log-badge.rejected { background: rgba(237,66,69,0.1); color: #ed4245; }
.ba-log-badge.direct { background: rgba(88,101,242,0.1); color: #a5b4fc; }
.ba-log-text { color: #c9d1d9; flex: 1; }
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
.ba-member-opt { padding: 7px 10px; font-size: 0.82rem; color: #e6edf3; cursor: pointer; }
.ba-member-opt:hover { background: #2b2d31; }
.ba-member-opt.selected { color: #5865F2; }
.ba-member-opt.hidden { display: none; }
/* 금액 표시 input (text type, 콤마 표시용) */
.ba-amount-display { width: 100%; padding: 5px 8px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; text-align: center; box-sizing: border-box; }
.ba-amount-display:focus { border-color: #5865F2; }
</style>

<div class="ba-page">
    <h2 style="margin-bottom:28px;">은행 관리</h2>
    <!-- 출금 신청서 -->
    <div class="ba-section">
        <div class="ba-section-header">
            <div class="ba-section-title">출금 신청서 <span class="ba-badge withdraw" id="baWithdrawCount">0건</span></div>
        </div>
        <div class="ba-actions">
            <button class="ba-btn hover-red" onclick="approveAll('withdrawal')">전체 승인</button>
            <button class="ba-btn hover-green" onclick="approveSelected('withdrawal')">선택 승인</button>
            <button class="ba-btn hover-blue" onclick="rejectSelected('withdrawal')">선택 반려</button>
        </div>
        <table class="ba-table">
            <thead><tr><th style="width:36px;"><input type="checkbox" onchange="toggleAll(this, 'withdrawal')"></th><th style="width:auto;">멤버</th><th style="width:120px;">금액</th><th style="width:100px;">신청일</th><th style="width:120px;"></th></tr></thead>
            <tbody id="baWithdrawBody"></tbody>
        </table>
        <p class="ba-empty" id="baWithdrawEmpty" style="display:none;">대기 중인 신청이 없습니다.</p>
        <div class="ba-table-footer">
            <select class="ba-page-select" onchange="setPageSize('withdrawal', this.value)">
                <option value="5">5개씩 표시</option>
                <option value="10">10개씩 표시</option>
            </select>
            <button class="ba-btn" onclick="addDirectRow('withdrawal')">+ 직접출금</button>
        </div>
    </div>

    <!-- 입금 신청서 -->
    <div class="ba-section">
        <div class="ba-section-header">
            <div class="ba-section-title">입금 신청서 <span class="ba-badge deposit" id="baDepositCount">0건</span></div>
        </div>
        <div class="ba-actions">
            <button class="ba-btn hover-red" onclick="approveAll('deposit')">전체 승인</button>
            <button class="ba-btn hover-green" onclick="approveSelected('deposit')">선택 승인</button>
            <button class="ba-btn hover-blue" onclick="rejectSelected('deposit')">선택 반려</button>
        </div>
        <table class="ba-table">
            <thead><tr><th style="width:36px;"><input type="checkbox" onchange="toggleAll(this, 'deposit')"></th><th style="width:auto;">멤버</th><th style="width:120px;">금액</th><th style="width:100px;">신청일</th><th style="width:120px;"></th></tr></thead>
            <tbody id="baDepositBody"></tbody>
        </table>
        <p class="ba-empty" id="baDepositEmpty" style="display:none;">대기 중인 신청이 없습니다.</p>
        <div class="ba-table-footer">
            <select class="ba-page-select" onchange="setPageSize('deposit', this.value)">
                <option value="5">5개씩 표시</option>
                <option value="10">10개씩 표시</option>
            </select>
            <button class="ba-btn" onclick="addDirectRow('deposit')">+ 직접입금</button>
        </div>
    </div>

    <!-- 처리 로그 -->
    <div class="ba-section">
        <div class="ba-section-header">
            <div class="ba-section-title">처리 로그</div>
        </div>
        <div id="baLogList">
            <p class="ba-empty">불러오는 중...</p>
        </div>
    </div>
</div>

<script>
(function() {
    var allMembers = [];
    var allWithdrawals = [];
    var allDeposits = [];
    var pageSize = { withdrawal: 5, deposit: 5 };

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
            html += '<tr data-id="' + item.id + '">'
                + '<td><input type="checkbox" class="ba-check" data-id="' + item.id + '" data-type="' + type + '"></td>'
                + '<td>' + escapeHtml(item.character_name || '???') + '</td>'
                + '<td><input type="text" class="ba-amount-display" value="' + Number(item.amount).toLocaleString() + '" data-raw="' + item.amount + '" data-id="' + item.id + '" oninput="formatAmountInput(this)"></td>'
                + '<td style="color:#6e7681;font-size:0.75rem;">' + formatDate(item.created_at) + '</td>'
                + '<td><button class="ba-btn green" onclick="approveSingle(' + item.id + ', this)" style="margin-right:4px;">승인</button><button class="ba-btn red" onclick="rejectSingle(' + item.id + ')">반려</button></td>'
                + '</tr>';
        });
        tbody.innerHTML = html;
    }

    function renderLogs(logs) {
        var el = document.getElementById('baLogList');
        if (!logs || logs.length === 0) {
            el.innerHTML = '<p class="ba-empty">처리 내역이 없습니다.</p>';
            return;
        }
        var html = '';
        logs.forEach(function(log) {
            var badgeClass = log.status === 'approved' ? 'approved' : log.status === 'rejected' ? 'rejected' : 'direct';
            var badgeText = log.status === 'approved' ? '승인' : log.status === 'rejected' ? '반려' : '-';
            var actionText = log.type === 'deposit' ? '입금' : '출금';
            html += '<div class="ba-log-item">'
                + '<span class="ba-log-badge ' + badgeClass + '">' + badgeText + '</span>'
                + '<span class="ba-log-text">' + escapeHtml(log.target_name || '') + ' · ' + actionText + ' ' + formatSilver(log.amount) + ' · ' + escapeHtml(log.approved_by_name || '') + '</span>'
                + '<span class="ba-log-time">' + formatDate(log.approved_at || log.created_at) + '</span>'
                + '</div>';
        });
        el.innerHTML = html;
    }

    function formatSilver(num) { if (!num) return '0'; return Number(num).toLocaleString(); }
    function formatDate(str) { if (!str) return ''; var d = new Date(str); return (d.getMonth()+1) + '/' + d.getDate() + ' ' + ('0'+d.getHours()).slice(-2) + ':' + ('0'+d.getMinutes()).slice(-2); }
    function escapeHtml(str) { if (!str) return ''; return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

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
            + '<td style="color:#6e7681;font-size:0.75rem;">직접</td>'
            + '<td><button class="ba-btn green" onclick="submitDirect(this,\'' + type + '\')" style="margin-right:4px;">승인</button><button class="ba-btn red" onclick="cancelDirectRow(this,\'' + type + '\')">취소</button></td>';
        tbody.appendChild(row);
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
        var input = btn.closest('tr').querySelector('.ba-amount-display');
        var amount = input ? parseInt(input.value.replace(/,/g, '')) : null;
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
        checks.forEach(function(c) { ids.push(parseInt(c.getAttribute('data-id'))); });
        if (ids.length === 0) return;
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
})();
</script>
