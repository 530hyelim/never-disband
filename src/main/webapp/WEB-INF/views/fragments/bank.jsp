<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
.bank-page { max-width: 700px; margin: 0 auto; }
.bank-header { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 28px; }
.bank-card { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px 24px; }
.bank-card-label { font-size: 0.78rem; color: #949ba4; margin-bottom: 10px; }
.bank-balance-value { font-size: 1.5rem; font-weight: 700; color: #FEE75C; }
.bank-withdraw-row { display: flex; gap: 8px; }
.bank-input { flex: 1; min-width: 0; padding: 8px 12px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 8px; color: #e6edf3; font-size: 0.85rem; font-family: inherit; outline: none; transition: border-color 0.2s; }
.bank-input:focus { border-color: #5865F2; }
.bank-input::placeholder { color: #6e7681; }
.bank-input::-webkit-outer-spin-button,
.bank-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.bank-input[type=number] { -moz-appearance: textfield; }
.bank-btn { padding: 8px 0; width: 72px; background: #5865F2; color: #fff; border: none; border-radius: 8px; font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: inherit; transition: background 0.15s; text-align: center; flex-shrink: 0; }
.bank-btn:hover { background: #4752C4; }
.bank-btn:disabled { background: #3f4147; color: #6e7681; cursor: not-allowed; }
.bank-error { color: #ed4245; font-size: 0.72rem; min-height: 16px; margin-top: 6px; }
.bank-history { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 20px 24px; }
.bank-history-title { font-size: 0.85rem; font-weight: 600; color: #949ba4; margin-bottom: 14px; }
.bank-tx-list { list-style: none; padding: 0; margin: 0; }
.bank-tx-item { display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #3f4147; }
.bank-tx-item:last-child { border-bottom: none; }
.bank-tx-type { font-size: 0.78rem; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
.bank-tx-type.deposit { background: rgba(87,242,135,0.1); color: #57F287; }
.bank-tx-type.withdrawal { background: rgba(237,66,69,0.1); color: #ed4245; }
.bank-tx-amount { font-size: 0.88rem; font-weight: 600; color: #e6edf3; }
.bank-tx-meta { font-size: 0.72rem; color: #6e7681; }
.bank-tx-status { font-size: 0.68rem; padding: 1px 6px; border-radius: 3px; }
.bank-tx-status.pending { background: rgba(254,231,92,0.1); color: #FEE75C; }
.bank-tx-status.approved { background: rgba(87,242,135,0.1); color: #57F287; }
.bank-tx-status.rejected { background: rgba(237,66,69,0.1); color: #ed4245; }
.bank-empty { color: #6e7681; font-size: 0.82rem; padding: 12px 0; }
@media (max-width: 540px) { .bank-header { grid-template-columns: 1fr; } }
</style>

<div class="bank-page">
    <h2 style="margin-bottom:28px;">은행</h2>
    <div class="bank-header">
        <div class="bank-card">
            <div class="bank-card-label">내 잔액</div>
            <div class="bank-balance-value" id="bankBalance">-</div>
        </div>
        <div class="bank-card">
            <div class="bank-card-label">출금 신청</div>
            <div class="bank-withdraw-row">
                <input type="number" class="bank-input" id="withdrawAmount" placeholder="금액 입력" min="1">
                <button class="bank-btn" id="withdrawBtn" onclick="requestWithdraw()">출금</button>
            </div>
            <div class="bank-error" id="withdrawError"></div>
        </div>
    </div>

    <div class="bank-history">
        <div class="bank-history-title">입/출금 내역</div>
        <ul class="bank-tx-list" id="bankTxList">
            <li class="bank-empty">불러오는 중...</li>
        </ul>
    </div>
</div>

<script>
(function() {
    loadBankInfo();

    function loadBankInfo() {
        fetch('/' + guildSubdomain + '/bank/info')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                document.getElementById('bankBalance').textContent = formatSilver(data.balance || 0);
                renderTransactions(data.transactions || []);
                if (data.hasPending) {
                    document.getElementById('withdrawBtn').disabled = true;
                    document.getElementById('withdrawBtn').textContent = '대기중';
                }
            })
            .catch(function() {
                document.getElementById('bankBalance').textContent = '오류';
            });
    }

    function formatSilver(num) {
        if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
        if (num >= 1000) return num.toLocaleString();
        return num.toString();
    }

    function renderTransactions(txs) {
        var list = document.getElementById('bankTxList');
        if (!txs || txs.length === 0) {
            list.innerHTML = '<li class="bank-empty">거래 내역이 없습니다.</li>';
            return;
        }
        var html = '';
        txs.forEach(function(tx) {
            var typeLabel = tx.type === 'deposit' ? '입금' : '출금';
            var typeClass = tx.type === 'deposit' ? 'deposit' : 'withdrawal';
            var statusLabel = tx.status === 'pending' ? '대기' : tx.status === 'approved' ? '승인' : '거절';
            var statusClass = tx.status;
            var date = tx.created_at ? new Date(tx.created_at).toLocaleDateString('ko-KR') : '';
            var sign = tx.type === 'deposit' ? '+' : '-';

            html += '<li class="bank-tx-item">'
                + '<div style="display:flex;align-items:center;gap:10px;">'
                + '<span class="bank-tx-type ' + typeClass + '">' + typeLabel + '</span>'
                + '<span class="bank-tx-amount">' + sign + formatSilver(tx.amount) + '</span>'
                + '</div>'
                + '<div style="display:flex;align-items:center;gap:8px;">'
                + '<span class="bank-tx-status ' + statusClass + '">' + statusLabel + '</span>'
                + '<span class="bank-tx-meta">' + date + '</span>'
                + '</div>'
                + '</li>';
        });
        list.innerHTML = html;
    }

    window.requestWithdraw = function() {
        var input = document.getElementById('withdrawAmount');
        var btn = document.getElementById('withdrawBtn');
        var errorEl = document.getElementById('withdrawError');
        var amount = parseInt(input.value);

        errorEl.textContent = '';

        if (!amount || amount <= 0) {
            errorEl.textContent = '유효한 금액을 입력해주세요.';
            return;
        }

        btn.disabled = true;
        btn.textContent = '처리중...';

        fetch('/' + guildSubdomain + '/bank/withdraw', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ amount: amount })
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.error) {
                errorEl.textContent = data.error;
                btn.disabled = false;
                btn.textContent = '출금';
            } else {
                input.value = '';
                btn.textContent = '대기중';
                loadBankInfo();
            }
        })
        .catch(function() {
            errorEl.textContent = '요청에 실패했습니다.';
            btn.disabled = false;
            btn.textContent = '출금';
        });
    };
})();
</script>
