<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.filter-bar { display:flex; gap:8px; margin-bottom:16px; }
.filter-btn { font-size:0.8rem; padding:5px 14px; border-radius:14px; border:1px solid #3f4147; background:transparent; color:#949ba4; cursor:pointer; font-family:inherit; transition:all 0.1s; }
.filter-btn.active { background:#5865F2; border-color:#5865F2; color:#fff; }
.post-wrap { display:flex; flex-direction:column; }
.post-list { display:flex; flex-direction:column; gap:50px; }
.post-card { background:#2b2d31; border:1px solid #3f4147; border-radius:12px; padding:16px 20px; transition:opacity 0.2s, border-radius 0.2s; position:relative; }
.post-card.closed { opacity:0.45; }
.post-card.mandatory { animation: mandatoryPulse 1.5s ease-in-out infinite; }
.post-card.mandatory.closed { animation: none; }
@keyframes mandatoryPulse {
    0%, 100% { border-color: #3f4147; }
    50% { border-color: #ed4245; }
}
.post-layout { display:flex; gap:24px; align-items:stretch; }
.post-main { flex:1; min-width:0; display:flex; flex-direction:column; gap:10px; }
.post-top { display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding-right:100px; }
.post-content-box { flex:1; font-size:0.88rem; color:#c9d1d9; line-height:1.65; white-space:pre-wrap; word-break:break-word; background:#1e1f22; border:1px solid #3f4147; border-radius:8px; padding:12px 14px; }
.post-side { display:flex; flex-direction:column; align-items:flex-start; justify-content:flex-end; gap:6px; min-width:150px; flex-shrink:0; padding-top:24px; }
.status-badge { font-size:0.78rem; font-weight:600; border-radius:12px; padding:3px 10px; border:1px solid; }
.status-badge.open { color:#57F287; background:rgba(87,242,135,0.1); border-color:rgba(87,242,135,0.3); }
.status-badge.in-progress { color:#FEE75C; background:rgba(254,231,92,0.1); border-color:rgba(254,231,92,0.3); }
.status-badge.closed { color:#ed4245; background:rgba(237,66,69,0.1); border-color:rgba(237,66,69,0.3); }
.status-badge.clickable { cursor:pointer; transition:filter 0.15s; }
.status-badge.clickable:hover { filter:brightness(1.2); }
.post-avatars { display:flex; align-items:center; gap:6px; flex-wrap:wrap; padding-top:8px; }
.avatar-wrap { position:relative; display:inline-block; }
.avatar-crown { position:absolute; top:-10px; left:50%; transform:translateX(-50%); width:13px; height:13px; pointer-events:none; filter:drop-shadow(0 1px 2px rgba(0,0,0,0.7)); }
.avatar-wrap .avatar-tooltip { position:absolute; bottom:calc(100% + 6px); left:50%; transform:translateX(-50%); background:#111214; color:#e6edf3; font-size:0.72rem; padding:3px 8px; border-radius:5px; white-space:nowrap; pointer-events:none; opacity:0; transition:opacity 0.15s; z-index:10; }
.avatar-wrap:hover .avatar-tooltip { opacity:1; }
.avatar-img { width:28px; height:28px; border-radius:50%; object-fit:cover; border:2px solid #3f4147; display:block; }
.avatar-fallback { width:28px; height:28px; border-radius:50%; background:linear-gradient(135deg,#5865F2,#57F287); display:flex; align-items:center; justify-content:center; font-size:0.72rem; font-weight:700; color:#fff; border:2px solid #3f4147; }
.post-meta-row { display:flex; align-items:center; gap:6px; font-size:0.82rem; color:#c9d1d9; }
.post-meta-row svg { width:15px; height:15px; fill:#949ba4; flex-shrink:0; }
.btn-join { width:100%; padding:7px 20px; border-radius:8px; border:1px solid #3f4147; background:transparent; color:#949ba4; font-size:0.82rem; cursor:pointer; font-family:inherit; transition:all 0.15s; }
.btn-join:hover { border-color:#e6edf3; color:#e6edf3; }
.btn-join.joined { border-color:#ed4245; color:#ed4245; }
.btn-join.joined:hover { background:#ed4245; color:#fff; }
.btn-join:disabled { opacity:0.4; cursor:not-allowed; }
/* 카드 우상단 아이콘 버튼 */
.card-actions { position:absolute; top:12px; right:14px; display:flex; gap:4px; }
.card-icon-btn { width:28px; height:28px; border-radius:6px; border:none; background:transparent; color:#5a6173; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:background 0.15s, color 0.15s; padding:0; }
.card-icon-btn:hover { background:#3f4147; color:#e6edf3; }
.card-icon-btn svg { width:15px; height:15px; fill:currentColor; pointer-events:none; }
/* 핑 메뉴 */
.ping-menu { background:#1e1f22; border:1px solid #3f4147; border-radius:8px; padding:4px 0; z-index:1000; min-width:120px; box-shadow:0 4px 12px rgba(0,0,0,0.4); }
.ping-option { padding:7px 14px; font-size:0.82rem; color:#e6edf3; cursor:pointer; font-family:inherit; }
.ping-option:hover { background:#30363d; }
.empty-state { text-align:center; padding:60px 0; color:#949ba4; font-size:0.88rem; }
#editModal { display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;backdrop-filter:blur(4px); }
#editModal.active { display:flex; }
.edit-input { width:100%; padding:9px 10px; background:#161b22; border:1px solid #30363d; border-radius:6px; color:#e6edf3; font-size:0.84rem; font-family:inherit; box-sizing:border-box; height:36px; }
.edit-input:focus { border-color:#5865F2; outline:none; }
.edit-textarea { width:100%; padding:9px 10px; background:#161b22; border:1px solid #30363d; border-radius:6px; color:#e6edf3; font-size:0.84rem; font-family:inherit; box-sizing:border-box; min-height:100px; resize:vertical; line-height:1.65; }
.edit-textarea:focus { border-color:#5865F2; outline:none; }
.edit-textarea:read-only { color:#8b949e; cursor:not-allowed; }
#editModal input[type="number"] { -moz-appearance: textfield; }
#editModal input[type="number"]::-webkit-outer-spin-button,
#editModal input[type="number"]::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.comp-dd-group-header { padding:7px 12px; font-size:0.78rem; font-weight:600; color:#8b949e; background:#21262d; cursor:pointer; display:flex; align-items:center; gap:6px; }
.comp-dd-group-header:hover { color:#e6edf3; }
.comp-dd-arrow { font-size:0.6rem; }
.comp-dd-item { padding:7px 12px 7px 22px; font-size:0.82rem; color:#e6edf3; cursor:pointer; }
.comp-dd-item:hover { background:#30363d; }
/* 조합 슬롯 패널 */
.slot-panel { background:#1e1f22; border:1px solid #3f4147; border-top:none; border-radius:0 0 12px 12px; overflow:hidden; max-height:0; transition:max-height 0.25s ease, padding 0.25s ease, border-width 0s 0.25s; padding:0 14px; border-width:0; }
.slot-panel.open { max-height:800px; padding:12px 14px; border-width:0 1px 1px 1px; transition:max-height 0.25s ease, padding 0.25s ease, border-width 0s; }
.slot-panel-title { font-size:0.8rem; color:#8b949e; margin-bottom:10px; }
.slot-grid { display:flex; flex-direction:column; gap:6px; }
.slot-row { display:flex; align-items:center; gap:10px; padding:7px 10px; border-radius:7px; border:1px solid #3f4147; background:#2b2d31; font-size:0.82rem; }
.slot-row.taken { opacity:0.55; }
.slot-row.mine { border-color:#5865F2; background:rgba(88,101,242,0.08); }
.slot-role-badge { font-size:0.72rem; font-weight:600; padding:2px 8px; border-radius:10px; border:1px solid; flex-shrink:0; min-width:62px; text-align:center; }
.slot-weapon { flex:1; color:#c9d1d9; font-size:0.82rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.slot-occupant { font-size:0.78rem; color:#8b949e; flex-shrink:0; }
.slot-join-btn { padding:4px 0; width:64px; border-radius:6px; border:1px solid #3f4147; background:transparent; color:#949ba4; font-size:0.78rem; cursor:pointer; font-family:inherit; transition:all 0.15s; flex-shrink:0; text-align:center; }
.slot-join-btn:hover { border-color:#e6edf3; color:#e6edf3; }
.slot-join-btn.mine-btn { border-color:#ed4245; color:#ed4245; }
.slot-join-btn.mine-btn:hover { background:#ed4245; color:#fff; }
.slot-join-btn:disabled { opacity:0.35; cursor:not-allowed; }
/* 장비 이미지 팝오버 */
.equip-preview-btn { width:22px; height:22px; border:none; background:transparent; color:#5a6173; cursor:default; display:inline-flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; padding:0; transition:color 0.15s; position:relative; }
.equip-preview-btn:hover { color:#e6edf3; }
.equip-preview-btn svg { width:14px; height:14px; fill:currentColor; }
.equip-preview-btn .equip-popover { display:none; position:fixed; z-index:1100; background:#1e1f22; border:1px solid #3f4147; border-radius:10px; padding:10px; box-shadow:0 6px 20px rgba(0,0,0,0.5); grid-template-columns:repeat(3,52px); grid-template-rows:repeat(3,52px); gap:6px; pointer-events:none; }
.equip-preview-btn .equip-popover.visible { display:grid; }
.equip-popover img { width:52px; height:52px; border-radius:6px; background:#21262d; border:1px solid #30363d; display:block; }
.equip-popover .equip-empty { width:52px; height:52px; border-radius:6px; background:#21262d; border:1px solid #30363d; }
</style>

<div style="max-width:860px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:8px;">컨텐츠 모집</h2>
    <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">파티 모집, 참여, 조합, 정산을 한꺼번에 관리합니다.</p>

    <div class="filter-bar">
        <button class="filter-btn active" onclick="setFilter('all',this)">전체</button>
        <button class="filter-btn" onclick="setFilter('IN_PROGRESS',this)">진행중</button>
        <button class="filter-btn" onclick="setFilter('OPEN',this)">모집중</button>
        <button class="filter-btn" onclick="setFilter('CLOSED',this)">완료</button>
        <button class="filter-btn" style="margin-left:auto;background:#5865F2;border-color:#5865F2;color:#fff;" onclick="openCreateModal()">+ 모집글 작성</button>
    </div>
    <div class="post-list" id="postList">
        <div class="empty-state">불러오는 중...</div>
    </div>
</div>

<script>
var currentMemberId = parseInt('${currentMemberId}') || 0;
var currentFilter = 'all';
var allPosts = [];
var openSlotPanelPostId = null;

function setFilter(filter, btn) {
    currentFilter = filter;
    document.querySelectorAll('.filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    renderPosts();
}

function renderPosts() {
    var list = document.getElementById('postList');
    var filtered = allPosts.filter(function(p) {
        var ds = getDisplayStatus(p);
        if (currentFilter === 'all') return true;
        if (currentFilter === 'IN_PROGRESS') return ds === 'in-progress';
        if (currentFilter === 'OPEN') return ds === 'open';
        if (currentFilter === 'CLOSED') return ds === 'closed';
        return true;
    });
    // 정렬: mandatory 최우선, 그 안에서 진행중 > 모집중 > 완료
    var order = { 'in-progress': 0, 'open': 1, 'closed': 2 };
    filtered.sort(function(a, b) {
        var ma = a.mandatory === 'Y' ? 0 : 1;
        var mb = b.mandatory === 'Y' ? 0 : 1;
        if (ma !== mb) return ma - mb;
        var oa = order[getDisplayStatus(a)] !== undefined ? order[getDisplayStatus(a)] : 9;
        var ob = order[getDisplayStatus(b)] !== undefined ? order[getDisplayStatus(b)] : 9;
        return oa - ob;
    });
    if (!filtered.length) { list.innerHTML = '<div class="empty-state">게시글이 없습니다.</div>'; return; }
    list.innerHTML = filtered.map(buildCard).join('');
    // 슬롯 패널이 열려있던 포스트 복원
    if (openSlotPanelPostId) {
        var panel = document.getElementById('slot-panel-' + openSlotPanelPostId);
        var card = document.getElementById('post-card-' + openSlotPanelPostId);
        var joinBtn = card ? card.querySelector('.btn-panel-toggle') : null;
        if (panel) {
            if (card) card.style.borderRadius = '12px 12px 0 0';
            if (joinBtn) joinBtn.textContent = '닫기';
            panel.innerHTML = '<div style="color:#8b949e;font-size:0.82rem;padding:4px 0;">불러오는 중...</div>';
            panel.classList.add('open');
            loadSlotPanel(openSlotPanelPostId);
        }
    }
}

// DB status(OPEN/CLOSED) + scheduledAt으로 표시용 상태 계산
function getDisplayStatus(p) {
    if (p.status === 'CLOSED') return 'closed';
    if (p.scheduledAt) {
        var scheduled = new Date(p.scheduledAt + 'Z');
        var now = new Date();
        if (now >= scheduled) return 'in-progress';
    }
    return 'open';
}

function getStatusLabel(displayStatus) {
    if (displayStatus === 'closed') return '완료';
    if (displayStatus === 'in-progress') return '진행중';
    return '모집중';
}

function buildCard(p) {
    var isClosed = p.status === 'CLOSED';
    var isLeader = p.leaderMemberId === currentMemberId;
    var participants = p.participants || [];
    var displayStatus = getDisplayStatus(p);

    // 아바타
    var avatarHtml = participants.map(function(pt, i) {
        var isL = i === 0;
        var name = escapeHtml(pt.characterName || '?');
        var crown = isL ? '<svg class="avatar-crown" viewBox="0 0 24 24" fill="#FEE75C"><path d="M5 16L3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5zm0 2h14v2H5v-2z"/></svg>' : '';
        var img = pt.avatarUrl
            ? '<img class="avatar-img' + (isL ? ' leader' : '') + '" src="' + pt.avatarUrl + '?size=64" onerror="this.style.display=\'none\';this.nextSibling.style.display=\'flex\'" alt="' + name + '"><span class="avatar-fallback' + (isL ? ' leader' : '') + '" style="display:none">' + name.charAt(0).toUpperCase() + '</span>'
            : '<span class="avatar-fallback' + (isL ? ' leader' : '') + '">' + name.charAt(0).toUpperCase() + '</span>';
        return '<div class="avatar-wrap"><span class="avatar-tooltip">' + name + '</span>' + crown + img + '</div>';
    }).join('');

    // 상태 배지 - 파티장이면 클릭으로 토글
    var badgeClass = 'status-badge ' + displayStatus + (isLeader ? ' clickable' : '');
    var badgeOnclick = isLeader ? ' onclick="toggleStatus(' + p.id + ',\'' + p.status + '\')"' : '';
    var statusBadge = '<span class="' + badgeClass + '"' + badgeOnclick + '>' + getStatusLabel(displayStatus) + '</span>';

    // 우측 메타
    var scheduledText = p.scheduledAt ? formatDatetime(p.scheduledAt) + ' UTC' : '미정';
    var memberText = '미정';
    if (p.minMembers || p.maxMembers) {
        if (p.minMembers && p.maxMembers) memberText = p.minMembers + ' ~ ' + p.maxMembers + '명';
        else if (p.maxMembers) memberText = '최대 ' + p.maxMembers + '명';
        else memberText = '최소 ' + p.minMembers + '명';
    }

    var lockPath = p.isPublic
        ? '<path d="M12 1C9.24 1 7 3.24 7 6v1H5a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-2V6c0-2.76-2.24-5-5-5zm0 2c1.66 0 3 1.34 3 3v1H9V6c0-1.66 1.34-3 3-3zm1 11.73V17h-2v-2.27A2 2 0 0 1 10 13a2 2 0 0 1 4 0 2 2 0 0 1-1 1.73z"/>'
        : '<path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V10a2 2 0 0 0-2-2zm-6 9a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>';

    // 카드 우상단 아이콘 (파티장만)
    var cardActions = '';
    if (isLeader) {
        cardActions = '<div class="card-actions">'
            + '<button class="card-icon-btn" onclick="event.stopPropagation();togglePingMenu(' + p.id + ', this)" title="디스코드 알림"><svg viewBox="0 0 24 24"><path d="M12 22c1.1 0 2-.9 2-2h-4a2 2 0 0 0 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg></button>'
            + '<button class="card-icon-btn" onclick="editPost(' + p.id + ')" title="수정"><svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg></button>'
            + '<button class="card-icon-btn" onclick="deletePost(' + p.id + ')" title="삭제"><svg viewBox="0 0 24 24"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg></button>'
            + '</div>';
    }

    // 우측 하단 버튼
    var alreadyJoined = participants.some(function(pt) { return pt.memberId === currentMemberId; });
    var isFull = !alreadyJoined && p.maxMembers && participants.length >= p.maxMembers;
    var dis = (isClosed || isFull) ? ' disabled' : '';
    var actionBtn = '';
    if (p.compositionId) {
        // 조합 있음 → 인원 마감여도 현황은 볼 수 있게, closed일 때만 disabled
        var panelDis = isClosed ? ' disabled' : '';
        actionBtn = '<button class="btn-join btn-panel-toggle"' + panelDis + ' onclick="toggleSlotPanel(' + p.id + ', this)">참여 현황</button>';
    } else if (!isLeader) {
        if (alreadyJoined) {
            actionBtn = '<button class="btn-join joined"' + (isClosed ? ' disabled' : '') + ' onclick="toggleJoin(' + p.id + ')">참여 취소</button>';
        } else {
            actionBtn = '<button class="btn-join"' + dis + (isFull ? ' title="인원이 가득 찼습니다"' : '') + ' onclick="toggleJoin(' + p.id + ')">참여' + (isFull ? ' 마감' : '') + '</button>';
        }
    } else {
        // 파티 리더, 조합 없음
        actionBtn = '<button class="btn-join" disabled>참여 중</button>';
    }

    return '<div class="post-wrap">'
        + '<div class="post-card' + (isClosed ? ' closed' : '') + (p.mandatory === 'Y' ? ' mandatory' : '') + '" id="post-card-' + p.id + '">'
        + cardActions
        + '<div class="post-layout">'
        +   '<div class="post-main">'
        +     '<div class="post-top">' + statusBadge + '<div class="post-avatars">' + avatarHtml + '</div></div>'
        +     '<div class="post-content-box">' + escapeHtml(p.content) + '</div>'
        +   '</div>'
        +   '<div class="post-side">'
        +     '<div>'
        +       '<div class="post-meta-row" style="margin-bottom:4px"><svg viewBox="0 0 24 24" style="width:13px;height:13px;fill:#949ba4;flex-shrink:0">' + lockPath + '</svg><span>' + (p.isPublic ? '공개' : '비공개') + '</span></div>'
        +       '<div class="post-meta-row" style="margin-bottom:4px"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2zm1 11H7.5a1 1 0 0 1 0-2H11V7a1 1 0 0 1 2 0v5a1 1 0 0 1-1 1h1z"/></svg><span>' + scheduledText + '</span></div>'
        +       '<div class="post-meta-row"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg><span>' + memberText + '</span></div>'
        +     '</div>'
        +     actionBtn
        +   '</div>'
        + '</div>'
        + '</div>'
        + '<div class="slot-panel" id="slot-panel-' + p.id + '"></div>'
        + '</div>';
}

// 파티장: 상태 배지 클릭 토글
// 모집중 or 진행중 → CLOSED, 완료 → OPEN
function toggleStatus(postId, currentDbStatus) {
    var newStatus = currentDbStatus === 'CLOSED' ? 'OPEN' : 'CLOSED';
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/status', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'status=' + newStatus + '&' + csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadPosts(); });
}

function toggleJoin(postId) {
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/join', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) loadPosts(); });
}

var ROLE_STYLES = {
    OFF_TANK:    { label:'O TANK',  color:'#57a9f2', bg:'rgba(87,169,242,0.1)',  border:'rgba(87,169,242,0.3)' },
    DEF_TANK:    { label:'D TANK',  color:'#57a9f2', bg:'rgba(87,169,242,0.1)',  border:'rgba(87,169,242,0.3)' },
    MDPS:        { label:'MDPS',    color:'#ed4245', bg:'rgba(237,66,69,0.1)',   border:'rgba(237,66,69,0.3)' },
    RDPS:        { label:'RDPS',    color:'#f5813a', bg:'rgba(245,129,58,0.1)',  border:'rgba(245,129,58,0.3)' },
    HEALER:      { label:'HEAL',    color:'#57F287', bg:'rgba(87,242,135,0.1)',  border:'rgba(87,242,135,0.3)' },
    SUPPORT:     { label:'SUP',     color:'#FEE75C', bg:'rgba(254,231,92,0.1)', border:'rgba(254,231,92,0.3)' },
    BATTLEMOUNT: { label:'BM',      color:'#8b949e', bg:'rgba(139,148,158,0.1)', border:'rgba(139,148,158,0.3)' }
};

function toggleSlotPanel(postId, btn) {
    var panel = document.getElementById('slot-panel-' + postId);
    var card = document.getElementById('post-card-' + postId);
    if (!panel) return;
    var isOpen = panel.classList.contains('open');
    if (isOpen) {
        panel.classList.remove('open');
        openSlotPanelPostId = null;
        if (card) card.style.borderRadius = '';
        if (btn) btn.textContent = '참여 현황';
        return;
    }
    openSlotPanelPostId = postId;
    if (card) card.style.borderRadius = '12px 12px 0 0';
    if (btn) btn.textContent = '닫기';
    // 내용이 없으면 먼저 채우고 open
    if (!panel.dataset.loaded) {
        panel.innerHTML = '<div style="color:#8b949e;font-size:0.82rem;padding:4px 0;">불러오는 중...</div>';
    }
    panel.classList.add('open');
    loadSlotPanel(postId);
}

function loadSlotPanel(postId) {
    var panel = document.getElementById('slot-panel-' + postId);
    if (!panel) return;

    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/composition')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.error) { panel.classList.remove('open'); openSlotPanelPostId = null; return; }

            var slots = data.slots || [];
            var participants = data.participants || [];
            var maxMembers = data.maxMembers;
            var post = allPosts.find(function(p) { return p.id === postId; });
            var isLeader = post && post.leaderMemberId === currentMemberId;

            // 슬롯별 점유자 매핑
            var occupiedMap = {};
            participants.forEach(function(p) {
                if (p.slotId) occupiedMap[p.slotId] = p.characterName;
            });

            // 내 슬롯 / 내가 자유참여인지
            var mySlotId = null;
            var iAmFree = false;
            participants.forEach(function(p) {
                if (p.memberId === currentMemberId) {
                    if (p.slotId) mySlotId = p.slotId;
                    else iAmFree = true;
                }
            });

            // 전체 참여자 수 / 전체 정원
            var totalJoined = participants.length;
            var totalCapacity = maxMembers || slots.length;

            // 자유 참여 row (maxMembers > slots.length 일 때만)
            var freeSlots = (maxMembers && maxMembers > slots.length) ? (maxMembers - slots.length) : 0;
            var freeJoined = participants.filter(function(p) { return !p.slotId; }).length;
            var freeRemain = freeSlots - freeJoined;
            var panelFull = !mySlotId && !iAmFree && maxMembers && totalJoined >= maxMembers;

            // 전체 row 배열 생성
            var allRows = slots.map(function(s) {
                var style = ROLE_STYLES[s.role] || { label: s.role, color:'#949ba4', bg:'transparent', border:'#3f4147' };
                var badge = '<span class="slot-role-badge" style="color:' + style.color + ';background:' + style.bg + ';border-color:' + style.border + '">' + style.label + '</span>';
                // 장비 목록: null이 아닌 것만 표시
                var items = [s.weapon, s.offhand, s.head, s.chest, s.shoes, s.cape, s.food].filter(function(v) { return v; });
                var itemText = items.length ? items.map(function(v) { return escapeHtml(v); }).join(', ') : '-';
                // 이미지 ID 배열 (원본 unique name) → 3x3 그리드
                // row1: (빈), 머리, 망토 / row2: 무기, 갑바, 보조 / row3: (빈), 신발, 음식
                var gridIds = [null, s.headId, s.capeId, s.weaponId, s.chestId, s.offhandId, null, s.shoesId, s.foodId];
                var hasItems = gridIds.some(function(v) { return v; });
                var previewBtn = '';
                if (hasItems) {
                    var cells = gridIds.map(function(id) {
                        return id
                            ? '<img src="https://render.albiononline.com/v1/item/' + encodeURIComponent(id) + '.png" alt="">'
                            : '<div class="equip-empty"></div>';
                    });
                    previewBtn = '<span class="equip-preview-btn"><svg viewBox="0 0 24 24"><path d="M21 19V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/></svg><div class="equip-popover">' + cells.join('') + '</div></span>';
                }
                var weapon = '<span class="slot-weapon">' + itemText + '</span>';
                var rowContent = badge + previewBtn + weapon;
                var occupant = occupiedMap[s.id];
                var isMine = s.id === mySlotId;
                var isTaken = !!occupant && !isMine;
                var rowClass = 'slot-row' + (isMine ? ' mine' : (isTaken ? ' taken' : ''));
                var occupantHtml = occupant
                    ? '<span class="slot-occupant">' + escapeHtml(occupant) + '</span>'
                    : '<span class="slot-occupant" style="color:#3f4147">비어있음</span>';
                var joinBtn;
                if (isMine) {
                    joinBtn = '<button class="slot-join-btn mine-btn" onclick="joinSlot(' + postId + ', null)">취소</button>';
                } else if (isTaken) {
                    joinBtn = '<button class="slot-join-btn" disabled>참여 불가</button>';
                } else if (panelFull) {
                    joinBtn = '<button class="slot-join-btn" disabled>마감</button>';
                } else {
                    joinBtn = '<button class="slot-join-btn" onclick="joinSlot(' + postId + ', ' + s.id + ')">참여</button>';
                }
                return '<div class="' + rowClass + '">' + rowContent + occupantHtml + joinBtn + '</div>';
            });

            // 자유참여 row
            if (freeSlots > 0) {
                var freeBadgeColor = freeRemain <= 0 ? 'ed4245' : '57F287';
                var freeBadgeRgb = freeRemain <= 0 ? '237,66,69' : '87,242,135';
                var freeLabel = '<span class="slot-role-badge" style="color:#' + freeBadgeColor + ';background:rgba(' + freeBadgeRgb + ',0.1);border-color:rgba(' + freeBadgeRgb + ',0.3)">대기</span>';
                // 대기자 명단
                var freeParticipants = participants.filter(function(p) { return !p.slotId; });
                var freeNames = freeParticipants.map(function(p) { return escapeHtml(p.characterName || '?'); }).join(', ');
                var freeWeapon = '<span class="slot-weapon" style="color:#8b949e">' + (freeNames || '') + '</span>';
                var freeOccupant = '<span class="slot-occupant" style="color:#8b949e">' + freeRemain + '자리 남음</span>';
                var freeBtn;
                if (!isLeader) {
                    if (iAmFree) {
                        freeBtn = '<button class="slot-join-btn mine-btn" onclick="joinSlot(' + postId + ', null)">취소</button>';
                    } else if (freeRemain > 0 && !mySlotId) {
                        freeBtn = '<button class="slot-join-btn" onclick="joinSlot(' + postId + ', null)">참여대기</button>';
                    } else if (freeRemain <= 0) {
                        freeBtn = '<button class="slot-join-btn" disabled>대기 마감</button>';
                    } else {
                        freeBtn = '<button class="slot-join-btn" disabled style="opacity:0;border:none;"></button>';
                    }
                } else {
                    freeBtn = '<button class="slot-join-btn" disabled style="opacity:0;border:none;"></button>';
                }
                var freeRowClass = 'slot-row' + (iAmFree ? ' mine' : '');
                allRows.push('<div class="' + freeRowClass + '">' + freeLabel + freeWeapon + freeOccupant + freeBtn + '</div>');
            }

            // 타이틀 카운트 뱃지 (전체 통합)
            var countColor = totalJoined >= totalCapacity ? 'ed4245' : '57F287';
            var countRgb   = totalJoined >= totalCapacity ? '237,66,69' : '87,242,135';
            var countBadge = '<span style="font-size:0.78rem;color:#' + countColor + ';background:rgba(' + countRgb + ',0.1);border:1px solid rgba(' + countRgb + ',0.3);border-radius:10px;padding:1px 8px;">' + totalJoined + ' / ' + totalCapacity + '</span>';

            // 페이징
            var PAGE_SIZE = 10;
            var currentPage = parseInt(panel.dataset.page || '0');
            var totalPages = Math.ceil(allRows.length / PAGE_SIZE);
            if (currentPage >= totalPages) currentPage = totalPages - 1;
            if (currentPage < 0) currentPage = 0;
            panel.dataset.page = currentPage;

            var pageRows = allRows.slice(currentPage * PAGE_SIZE, (currentPage + 1) * PAGE_SIZE);

            var pager = '';
            if (totalPages > 1) {
                var prevDis = currentPage === 0 ? ' disabled' : '';
                var nextDis = currentPage >= totalPages - 1 ? ' disabled' : '';
                pager = '<div style="display:flex;align-items:center;justify-content:flex-end;gap:6px;margin-top:8px;">'
                    + '<button class="slot-join-btn"' + prevDis + ' style="width:28px;padding:0;" onclick="slotPanelPage(' + postId + ',-1)">‹</button>'
                    + '<span style="font-size:0.78rem;color:#8b949e;">' + (currentPage+1) + ' / ' + totalPages + '</span>'
                    + '<button class="slot-join-btn"' + nextDis + ' style="width:28px;padding:0;" onclick="slotPanelPage(' + postId + ',1)">›</button>'
                    + '</div>';
            }

            panel.innerHTML = '<div class="slot-panel-title" style="display:flex;align-items:center;justify-content:space-between;">포지션을 선택하세요' + countBadge + '</div>'
                + '<div class="slot-grid">' + pageRows.join('') + '</div>'
                + pager;
        })
        .catch(function() { panel.classList.remove('open'); openSlotPanelPostId = null; });
}

function slotPanelPage(postId, dir) {
    var panel = document.getElementById('slot-panel-' + postId);
    if (!panel) return;
    var current = parseInt(panel.dataset.page || '0');
    panel.dataset.page = current + dir;
    loadSlotPanel(postId);
}

function joinSlot(postId, slotId) {
    var body = slotId ? JSON.stringify({ slotId: slotId }) : JSON.stringify({});
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/join-slot', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: body
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.success) {
            // 패널 열려있으면 패널만 갱신, 아니면 전체 갱신
            if (openSlotPanelPostId === postId) {
                fetch('/' + guildSubdomain + '/recruit/posts')
                    .then(function(r) { return r.json(); })
                    .then(function(posts) {
                        allPosts = posts;
                        var card = document.getElementById('post-card-' + postId);
                        if (card) {
                            var post = posts.find(function(p) { return p.id === postId; });
                            if (post) {
                                var tmp = document.createElement('div');
                                tmp.innerHTML = buildCard(post);
                                var oldAvatars = card.querySelector('.post-avatars');
                                var newAvatars = tmp.querySelector('.post-avatars');
                                if (oldAvatars && newAvatars) oldAvatars.innerHTML = newAvatars.innerHTML;
                            }
                        }
                        loadSlotPanel(postId);
                    });
            } else {
                openSlotPanelPostId = null;
                loadPosts();
            }
        }
    });
}

function pingPost(postId, mentionType) {
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/ping', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: JSON.stringify({ mention: mentionType })
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (!d.success) alert(d.message || '알림 전송에 실패했습니다.');
    }).catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
    closePingMenu();
}

var activePingMenu = null;
function togglePingMenu(postId, btn) {
    closePingMenu();
    var rect = btn.getBoundingClientRect();
    var menu = document.createElement('div');
    menu.className = 'ping-menu';
    menu.innerHTML = '<div class="ping-option" onclick="pingPost(' + postId + ', \'everyone\')">@everyone</div>'
        + '<div class="ping-option" onclick="pingPost(' + postId + ', \'here\')">@here</div>'
        + '<div class="ping-option" onclick="pingPost(' + postId + ', \'participants\')">참여인원</div>';
    menu.style.position = 'fixed';
    menu.style.top = (rect.bottom + 4) + 'px';
    menu.style.left = rect.left + 'px';
    document.body.appendChild(menu);
    activePingMenu = menu;
    setTimeout(function() { document.addEventListener('click', closePingMenu, { once: true }); }, 0);
}

function closePingMenu() {
    if (activePingMenu) { activePingMenu.remove(); activePingMenu = null; }
}


// 장비 팝오버 hover 위치 지정
document.addEventListener('mouseenter', function(e) {
    var btn = e.target.closest('.equip-preview-btn');
    if (!btn) return;
    var popover = btn.querySelector('.equip-popover');
    if (!popover) return;
    // 먼저 보이게 해서 크기 측정
    popover.classList.add('visible');
    var rect = btn.getBoundingClientRect();
    var ph = popover.offsetHeight;
    popover.style.top = (rect.top - ph - 8) + 'px';
    popover.style.left = Math.max(4, rect.left - 70) + 'px';
}, true);

document.addEventListener('mouseleave', function(e) {
    var btn = e.target.closest('.equip-preview-btn');
    if (!btn) return;
    var popover = btn.querySelector('.equip-popover');
    if (popover) popover.classList.remove('visible');
}, true);

function deletePost(postId) {
    if (!confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) return;
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/delete', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.success) { openSlotPanelPostId = null; loadPosts(); }
        else alert(d.message || '삭제에 실패했습니다.');
    }).catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
}

function openCreateModal() {
    document.getElementById('editPostId').value = '';
    document.getElementById('editModalTitle').textContent = '모집글 작성';
    var contentEl = document.getElementById('editContent');
    contentEl.readOnly = false;
    contentEl.value = '';
    contentEl.placeholder = '모집 내용을 입력하세요';
    document.getElementById('editIsPublic').checked = false;
    document.getElementById('editMandatory').checked = false;
    document.getElementById('editMinMembers').value = '';
    document.getElementById('editMaxMembers').value = '';
    document.getElementById('editDate').value = '';
    document.getElementById('editHour').value = '';
    document.getElementById('editMinute').value = '';
    pickComp('', '미지정');
    document.getElementById('editModal').classList.add('active');
    loadEditCompositions(null);
    startEditClock();
}

function editPost(postId) {
    var post = allPosts.find(function(p) { return p.id === postId; });
    if (!post) return;

    document.getElementById('editPostId').value = postId;
    document.getElementById('editModalTitle').textContent = '모집글 수정';
    var isDiscord = post.source === 'DISCORD';
    var contentEl = document.getElementById('editContent');
    contentEl.readOnly = isDiscord;
    contentEl.value = isDiscord ? '' : (post.content || '');
    contentEl.placeholder = isDiscord
        ? '디스코드에서 작성한 내용은 해당 채널에서 관리됩니다. \n웹에서는 시간·인원·빌드 등만 수정할 수 있습니다.'
        : '모집 내용을 입력하세요';
    document.getElementById('editIsPublic').checked = post.isPublic;
    document.getElementById('editMandatory').checked = (post.mandatory === 'Y');
    document.getElementById('editMinMembers').value = post.minMembers || '';
    document.getElementById('editMaxMembers').value = post.maxMembers || '';
    if (!post.compositionId) {
        pickComp('', '미지정');
    } else {
        document.getElementById('editCompositionId').value = post.compositionId;
    }

    // 시간 세팅 — DB에서 온 문자열 그대로 파싱 (타임존 변환 없음)
    if (post.scheduledAt) {
        var parts = post.scheduledAt.replace('T', '-').replace(':', '-').split('-');
        document.getElementById('editDate').value = parts[0] + '-' + parts[1] + '-' + parts[2];
        document.getElementById('editHour').value = pad(parseInt(parts[3]));
        document.getElementById('editMinute').value = pad(parseInt(parts[4]));
    } else {
        document.getElementById('editDate').value = '';
        document.getElementById('editHour').value = '';
        document.getElementById('editMinute').value = '';
    }

    document.getElementById('editModal').classList.add('active');
    loadEditCompositions(post.compositionId);
    startEditClock();
}

// 날짜 min을 오늘(UTC)로 설정
(function() {
    var now = new Date();
    var today = now.getUTCFullYear() + '-' + pad(now.getUTCMonth()+1) + '-' + pad(now.getUTCDate());
    document.getElementById('editDate').setAttribute('min', today);
})();

function closeEditModal() {
    document.getElementById('editModal').classList.remove('active');
    stopEditClock();
    document.getElementById('editCompDD').style.display = 'none';
}

function loadEditCompositions(selectedId) {
    var myGroup = document.getElementById('compGroupMy');
    var guildGroup = document.getElementById('compGroupGuild');
    myGroup.innerHTML = '';
    guildGroup.innerHTML = '';

    var display = document.getElementById('editCompDisplay');

    fetch('/api/compositions')
        .then(function(r) { return r.json(); })
        .then(function(comps) {
            comps.forEach(function(c) {
                var slotCount = c.slots ? c.slots.length : 0;
                var label = escapeHtml(c.name) + ' (' + slotCount + '명)';
                myGroup.innerHTML += '<div class="comp-dd-item" onclick="pickComp(' + c.id + ',\'' + escapeHtml(c.name) + ' (' + slotCount + '명)\')">' + label + '</div>';
                if (selectedId && c.id === selectedId) {
                    display.textContent = c.name + ' (' + slotCount + '명)';
                    display.style.color = '#e6edf3';
                }
            });
        });

    fetch('/' + guildSubdomain + '/recruit/compositions/public')
        .then(function(r) { return r.json(); })
        .then(function(comps) {
            comps.forEach(function(c) {
                var slotCount = c.slots ? c.slots.length : 0;
                var label = escapeHtml(c.name) + ' (' + slotCount + '명)';
                guildGroup.innerHTML += '<div class="comp-dd-item" onclick="pickComp(' + c.id + ',\'' + escapeHtml(c.name) + ' (' + slotCount + '명)\')">' + label + '</div>';
                if (selectedId && c.id === selectedId && display.style.color !== 'rgb(230, 237, 243)') {
                    display.textContent = c.name + ' (' + slotCount + '명)';
                    display.style.color = '#e6edf3';
                }
            });
        });
}

function toggleCompDD() {
    var dd = document.getElementById('editCompDD');
    var trigger = document.getElementById('editCompTrigger');
    if (dd.style.display === 'none') {
        dd.style.display = 'block';
        trigger.style.borderColor = '#5865F2';
        trigger.style.borderRadius = '0 0 6px 6px';
    } else {
        dd.style.display = 'none';
        trigger.style.borderColor = '#30363d';
        trigger.style.borderRadius = '6px';
    }
}

function toggleCompGroup(group) {
    var groups = ['my', 'guild'];
    groups.forEach(function(g) {
        var el = document.getElementById('compGroup' + g.charAt(0).toUpperCase() + g.slice(1));
        var arrow = document.getElementById('compArrow' + g.charAt(0).toUpperCase() + g.slice(1));
        if (g === group) {
            var open = el.style.display !== 'none';
            el.style.display = open ? 'none' : 'block';
            arrow.textContent = open ? '▶' : '▼';
        } else {
            el.style.display = 'none';
            arrow.textContent = '▶';
        }
    });
}

function pickComp(id, label) {
    document.getElementById('editCompositionId').value = id || '';
    document.getElementById('editCompDisplay').textContent = label;
    document.getElementById('editCompDisplay').style.color = id ? '#e6edf3' : '#484f58';
    document.getElementById('editCompDD').style.display = 'none';
    var trigger = document.getElementById('editCompTrigger');
    trigger.style.borderColor = '#30363d';
    trigger.style.borderRadius = '6px';
}

// UTC 시계 업데이트
var editClockInterval = null;
function startEditClock() {
    function update() {
        var now = new Date();
        document.getElementById('editUtcClock').innerHTML = '<svg viewBox="0 0 24 24" style="width:13px;height:13px;fill:#8b949e;vertical-align:middle;margin-right:4px;"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg>현재 시각 ' + now.getUTCFullYear() + '-' + pad(now.getUTCMonth()+1) + '-' + pad(now.getUTCDate()) + ' ' + pad(now.getUTCHours()) + ':' + pad(now.getUTCMinutes()) + ':' + pad(now.getUTCSeconds()) + ' UTC';
    }
    update();
    editClockInterval = setInterval(update, 1000);
}
function stopEditClock() { if (editClockInterval) clearInterval(editClockInterval); }

function submitEdit() {
    var postId = document.getElementById('editPostId').value;
    var isCreate = !postId;
    var dateVal = document.getElementById('editDate').value;
    var hourVal = document.getElementById('editHour').value.trim();
    var minVal = document.getElementById('editMinute').value.trim();
    var scheduledAt = null;

    // 시간만 입력하고 날짜 안 입력한 경우 경고
    if (!dateVal && (hourVal || minVal)) {
        alert('날짜를 입력해주세요.');
        return;
    }
    if (dateVal) {
        var h = hourVal ? pad(parseInt(hourVal)) : '00';
        var m = minVal ? pad(parseInt(minVal)) : '00';
        if (h === 'NaN' || isNaN(parseInt(h))) h = '00';
        if (m === 'NaN' || isNaN(parseInt(m))) m = '00';
        scheduledAt = dateVal + 'T' + h + ':' + m + ':00';
    }

    var content = document.getElementById('editContent').value.trim();
    if (!content && (isCreate || !(allPosts.find(function(p) { return String(p.id) === String(postId); }) || {}).source === 'DISCORD')) {
        if (!content) { alert('내용을 입력해주세요.'); return; }
    }
    if (content.length > 2000) { alert('내용은 2000자 이하여야 합니다.'); return; }

    var body = {
        isPublic: document.getElementById('editIsPublic').checked,
        mandatory: document.getElementById('editMandatory').checked ? 'Y' : 'N',
        scheduledAt: scheduledAt,
        minMembers: parseInt(document.getElementById('editMinMembers').value) || null,
        maxMembers: parseInt(document.getElementById('editMaxMembers').value) || null,
        compositionId: parseInt(document.getElementById('editCompositionId').value) || null
    };
    if (content) body.content = content;

    if (body.minMembers && (body.minMembers < 1 || body.minMembers > 300)) { alert('인원은 1~300 사이로 설정해주세요.'); return; }
    if (body.maxMembers && (body.maxMembers < 1 || body.maxMembers > 300)) { alert('인원은 1~300 사이로 설정해주세요.'); return; }
    if (body.minMembers && body.maxMembers && body.minMembers > body.maxMembers) { alert('최소 인원이 최대 인원보다 클 수 없습니다.'); return; }

    var url = isCreate
        ? '/' + guildSubdomain + '/recruit/posts/create'
        : '/' + guildSubdomain + '/recruit/posts/' + postId + '/edit';

    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: JSON.stringify(body)
    })
    .then(function(r) { return r.json(); })
    .then(function(d) {
        if (d.success) { closeEditModal(); loadPosts(); }
        else alert(d.message || (isCreate ? '작성에 실패했습니다.' : '수정에 실패했습니다.'));
    })
    .catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
}

function loadPosts() {
    fetch('/' + guildSubdomain + '/recruit/posts')
        .then(function(r) { return r.json(); })
        .then(function(posts) { allPosts = posts; renderPosts(); })
        .catch(function() { document.getElementById('postList').innerHTML = '<div class="empty-state">불러오기에 실패했습니다.</div>'; });
}

function formatDatetime(str) {
    if (!str) return '';
    // DB에서 UTC 형태로 오므로 그대로 파싱
    var parts = str.replace('T', ' ').split(/[- :]/);
    return parts[0] + '.' + parts[1] + '.' + parts[2] + ' ' + parts[3] + ':' + parts[4];
}

function pad(n) { return n < 10 ? '0' + n : n; }

function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

loadPosts();

var recruitSub = null;
function subscribeRecruit() {
    if (!window.stompClient || !window.stompClient.connected) { setTimeout(subscribeRecruit, 500); return; }
    if (recruitSub) { try { recruitSub.unsubscribe(); } catch(e) {} }
    recruitSub = stompClient.subscribe('/topic/guild/' + guildSubdomain + '/recruit', function() { loadPosts(); });
}
subscribeRecruit();

var recruitObserver = new MutationObserver(function() {
    if (!document.getElementById('postList')) {
        if (recruitSub) recruitSub.unsubscribe();
        recruitObserver.disconnect();
    }
});
recruitObserver.observe(document.getElementById('mainContent') || document.body, { childList:true });
</script>

<!-- 수정 모달 -->
<div class="modal-overlay" id="editModal" onclick="if(event.target===this)closeEditModal()">
    <div style="background:#21262d;border:1px solid #30363d;border-radius:16px;padding:32px 28px;max-width:560px;width:90%;position:relative;">
        <h3 id="editModalTitle" style="font-size:1.1rem;font-weight:700;margin-bottom:4px;">모집글 수정</h3>
        <p id="editUtcClock" style="font-size:0.75rem;color:#8b949e;margin-bottom:10px;text-align:right;"></p>
        <input type="hidden" id="editPostId">

        <div style="display:flex;flex-direction:column;gap:14px;">
            <div style="display:flex;gap:20px;">
                <label style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:#e6edf3;" title="선택 시 길드 멤버가 아닌 모든 사이트 방문자가 볼 수 있습니다. 믹스 파티 모집 등에 활용하세요.">
                    <input type="checkbox" id="editIsPublic" style="width:16px;height:16px;"> 공개
                </label>
                <label style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:#e6edf3;">
                    <input type="checkbox" id="editMandatory" style="width:16px;height:16px;"> Mandatory
                </label>
            </div>
            <div>
                <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:4px;">시간</label>
                <div style="display:flex;gap:6px;align-items:center;">
                    <input type="date" id="editDate" class="edit-input" style="flex:2;">
                    <input type="text" id="editHour" maxlength="2" placeholder="00" class="edit-input" style="flex:1;text-align:center;" oninput="this.value=this.value.replace(/[^0-9]/g,'').slice(0,2)">
                    <span style="color:#8b949e;">:</span>
                    <input type="text" id="editMinute" maxlength="2" placeholder="00" class="edit-input" style="flex:1;text-align:center;" oninput="this.value=this.value.replace(/[^0-9]/g,'').slice(0,2)">
                    <span style="font-size:0.78rem;color:#8b949e;white-space:nowrap;">(24시간 기준, UTC)</span>
                </div>
            </div>
            <div style="display:flex;gap:10px;">
                <div style="flex:1;">
                    <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:4px;">최소 인원</label>
                    <input type="number" id="editMinMembers" min="1" max="300" class="edit-input">
                </div>
                <div style="flex:1;">
                    <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:4px;">최대 인원</label>
                    <input type="number" id="editMaxMembers" min="1" max="300" class="edit-input">
                </div>
                <div style="flex:2;">
                    <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:4px;">빌드</label>
                    <div style="position:relative;" id="editCompFieldWrap">
                        <div id="editCompTrigger" onclick="toggleCompDD()" class="edit-input" style="cursor:pointer;display:flex;align-items:center;">
                            <span id="editCompDisplay" style="color:#484f58;">미지정</span>
                        </div>
                        <input type="hidden" id="editCompositionId" value="">
                        <div id="editCompDD" style="display:none;position:absolute;bottom:100%;left:0;right:0;z-index:300;background:#1e1f22;border:1px solid #5865F2;border-bottom:none;border-radius:6px 6px 0 0;max-height:200px;overflow-y:auto;">
                            <div class="comp-dd-item" onclick="pickComp('','미지정')" style="padding:8px 12px;cursor:pointer;font-size:0.82rem;color:#8b949e;">미지정</div>
                            <div class="comp-dd-group-header" onclick="toggleCompGroup('my')">
                                <span class="comp-dd-arrow" id="compArrowMy">▶</span> 내 빌드
                            </div>
                            <div class="comp-dd-group-items" id="compGroupMy" style="display:none;"></div>
                            <div class="comp-dd-group-header" onclick="toggleCompGroup('guild')">
                                <span class="comp-dd-arrow" id="compArrowGuild">▶</span> 공유 빌드
                            </div>
                            <div class="comp-dd-group-items" id="compGroupGuild" style="display:none;"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div>
                <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:4px;">내용</label>
                <textarea id="editContent" class="edit-textarea" maxlength="2000" placeholder="모집 내용을 입력하세요"></textarea>
            </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:24px;">
            <button onclick="submitEdit()" style="flex:1;padding:11px;background:#5865F2;color:#fff;border:none;border-radius:8px;font-size:0.88rem;font-weight:600;cursor:pointer;font-family:inherit;">저장</button>
            <button onclick="closeEditModal()" style="flex:1;padding:11px;background:transparent;color:#8b949e;border:1px solid #30363d;border-radius:8px;font-size:0.88rem;cursor:pointer;font-family:inherit;">취소</button>
        </div>
    </div>
</div>