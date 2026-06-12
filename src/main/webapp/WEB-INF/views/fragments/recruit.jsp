<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.filter-bar { display:flex; gap:8px; margin-bottom:16px; }
.filter-btn { font-size:0.8rem; padding:5px 14px; border-radius:14px; border:1px solid #3f4147; background:transparent; color:#949ba4; cursor:pointer; font-family:inherit; transition:all 0.1s; }
.filter-btn.active { background:#5865F2; border-color:#5865F2; color:#fff; }
.post-list { display:flex; flex-direction:column; gap:12px; }
.post-card { background:#2b2d31; border:1px solid #3f4147; border-radius:12px; padding:16px 20px; transition:opacity 0.2s; }
.post-card.closed { opacity:0.45; }
.post-layout { display:flex; gap:24px; align-items:stretch; }
.post-main { flex:1; min-width:0; display:flex; flex-direction:column; gap:10px; }
.post-top { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.post-content-box { flex:1; font-size:0.88rem; color:#c9d1d9; line-height:1.65; white-space:pre-wrap; word-break:break-word; background:#1e1f22; border:1px solid #3f4147; border-radius:8px; padding:12px 14px; }
.post-side { display:flex; flex-direction:column; align-items:flex-start; justify-content:space-between; gap:6px; min-width:150px; flex-shrink:0; }
.status-badge { font-size:0.78rem; font-weight:600; border-radius:12px; padding:3px 10px; border:1px solid; }
.status-badge.open { color:#57F287; background:rgba(87,242,135,0.1); border-color:rgba(87,242,135,0.3); }
.status-badge.in-progress { color:#FEE75C; background:rgba(254,231,92,0.1); border-color:rgba(254,231,92,0.3); }
.status-badge.closed { color:#ed4245; background:rgba(237,66,69,0.1); border-color:rgba(237,66,69,0.3); }
.status-badge.clickable { cursor:pointer; transition:filter 0.15s; }
.status-badge.clickable:hover { filter:brightness(1.2); }
.post-avatars { display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
.avatar-wrap { position:relative; display:inline-block; }
.avatar-wrap .avatar-tooltip { position:absolute; bottom:calc(100% + 6px); left:50%; transform:translateX(-50%); background:#111214; color:#e6edf3; font-size:0.72rem; padding:3px 8px; border-radius:5px; white-space:nowrap; pointer-events:none; opacity:0; transition:opacity 0.15s; z-index:10; }
.avatar-wrap:hover .avatar-tooltip { opacity:1; }
.avatar-img { width:28px; height:28px; border-radius:50%; object-fit:cover; border:2px solid #3f4147; display:block; }
.avatar-img.leader { border-color:#57F287; }
.avatar-fallback { width:28px; height:28px; border-radius:50%; background:linear-gradient(135deg,#5865F2,#57F287); display:flex; align-items:center; justify-content:center; font-size:0.72rem; font-weight:700; color:#fff; border:2px solid #3f4147; }
.avatar-fallback.leader { border-color:#57F287; }
.post-meta-row { display:flex; align-items:center; gap:6px; font-size:0.82rem; color:#c9d1d9; }
.post-meta-row svg { width:15px; height:15px; fill:#949ba4; flex-shrink:0; }
.btn-join { width:100%; padding:7px 24px; border-radius:8px; border:2px solid #e6edf3; background:transparent; color:#e6edf3; font-size:0.85rem; font-weight:600; cursor:pointer; font-family:inherit; transition:all 0.15s; }
.btn-join:hover { background:#e6edf3; color:#1e1f22; }
.btn-join.joined { border-color:#ed4245; color:#ed4245; }
.btn-join.joined:hover { background:#ed4245; color:#fff; }
.btn-join:disabled { opacity:0.4; cursor:not-allowed; }
.btn-edit { width:100%; padding:7px 20px; border-radius:8px; border:1px solid #3f4147; background:transparent; color:#949ba4; font-size:0.82rem; cursor:pointer; font-family:inherit; transition:all 0.15s; }
.btn-edit:hover { border-color:#e6edf3; color:#e6edf3; }
.empty-state { text-align:center; padding:60px 0; color:#949ba4; font-size:0.88rem; }
</style>

<div style="max-width:860px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:8px;">컨텐츠 모집</h2>
    <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">파티 모집, 참여, 조합, 정산을 한꺼번에 관리합니다.</p>

    <div class="filter-bar">
        <button class="filter-btn active" onclick="setFilter('all',this)">전체</button>
        <button class="filter-btn" onclick="setFilter('OPEN',this)">모집중</button>
        <button class="filter-btn" onclick="setFilter('CLOSED',this)">완료</button>
    </div>
    <div class="post-list" id="postList">
        <div class="empty-state">불러오는 중...</div>
    </div>
</div>

<script>
var currentMemberId = parseInt('${currentMemberId}') || 0;
var currentFilter = 'all';
var allPosts = [];

function setFilter(filter, btn) {
    currentFilter = filter;
    document.querySelectorAll('.filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    renderPosts();
}

function renderPosts() {
    var list = document.getElementById('postList');
    var filtered = allPosts.filter(function(p) {
        if (currentFilter === 'all') return true;
        if (currentFilter === 'OPEN') return p.status === 'OPEN';
        if (currentFilter === 'CLOSED') return p.status === 'CLOSED';
        return true;
    });
    if (!filtered.length) { list.innerHTML = '<div class="empty-state">게시글이 없습니다.</div>'; return; }
    list.innerHTML = filtered.map(buildCard).join('');
}

// DB status(OPEN/CLOSED) + scheduledAt으로 표시용 상태 계산
function getDisplayStatus(p) {
    if (p.status === 'CLOSED') return 'closed';
    if (p.scheduledAt) {
        var scheduled = new Date(p.scheduledAt);
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
        var img = pt.avatarUrl
            ? '<img class="avatar-img' + (isL ? ' leader' : '') + '" src="' + pt.avatarUrl + '?size=64" onerror="this.style.display=\'none\';this.nextSibling.style.display=\'flex\'" alt="' + name + '"><span class="avatar-fallback' + (isL ? ' leader' : '') + '" style="display:none">' + name.charAt(0).toUpperCase() + '</span>'
            : '<span class="avatar-fallback' + (isL ? ' leader' : '') + '">' + name.charAt(0).toUpperCase() + '</span>';
        return '<div class="avatar-wrap"><span class="avatar-tooltip">' + name + '</span>' + img + '</div>';
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

    // 우측 하단 버튼
    var actionBtn = '';
    if (isLeader) {
        actionBtn = '<button class="btn-edit" onclick="editPost(' + p.id + ')">수정</button>';
        // TODO: 완료 상태에서는 정산 버튼 (분배 / 리기어 / 출석비 / 스킵)
    } else {
        var alreadyJoined = participants.some(function(pt) { return pt.memberId === currentMemberId; });
        var dis = isClosed ? ' disabled' : '';
        actionBtn = alreadyJoined
            ? '<button class="btn-join joined"' + dis + ' onclick="toggleJoin(' + p.id + ')">참여 취소</button>'
            : '<button class="btn-join"' + dis + ' onclick="toggleJoin(' + p.id + ')">참여</button>';
    }

    return '<div class="post-card' + (isClosed ? ' closed' : '') + '">'
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

function editPost(postId) {
    // TODO: 수정 모달
    alert('준비 중입니다.');
}

function loadPosts() {
    fetch('/' + guildSubdomain + '/recruit/posts')
        .then(function(r) { return r.json(); })
        .then(function(posts) { allPosts = posts; renderPosts(); })
        .catch(function() { document.getElementById('postList').innerHTML = '<div class="empty-state">불러오기에 실패했습니다.</div>'; });
}

function formatDatetime(str) {
    if (!str) return '';
    var d = new Date(str);
    return d.getUTCFullYear() + '.' + pad(d.getUTCMonth()+1) + '.' + pad(d.getUTCDate()) + ' ' + pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes());
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
