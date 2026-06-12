<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.filter-bar { display:flex; gap:8px; margin-bottom:16px; }
.filter-btn { font-size:0.8rem; padding:5px 14px; border-radius:14px; border:1px solid #3f4147; background:transparent; color:#949ba4; cursor:pointer; font-family:inherit; transition:all 0.1s; }
.filter-btn.active { background:#5865F2; border-color:#5865F2; color:#fff; }
.post-list { display:flex; flex-direction:column; gap:12px; }
.post-card { background:#2b2d31; border:1px solid #3f4147; border-radius:12px; padding:16px 20px; transition:opacity 0.2s; }
.post-card.closed { opacity:0.45; }
.post-card.mandatory { animation: mandatoryPulse 1.5s ease-in-out infinite; }
.post-card.mandatory.closed { animation: none; }
@keyframes mandatoryPulse {
    0%, 100% { border-color: #3f4147; }
    50% { border-color: #ed4245; }
}
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
/* .avatar-img.leader { border-color:#57F287; } */
.avatar-fallback { width:28px; height:28px; border-radius:50%; background:linear-gradient(135deg,#5865F2,#57F287); display:flex; align-items:center; justify-content:center; font-size:0.72rem; font-weight:700; color:#fff; border:2px solid #3f4147; }
/* .avatar-fallback.leader { border-color:#57F287; } */
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
#editModal { display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;backdrop-filter:blur(4px); }
#editModal.active { display:flex; }
.edit-input { width:100%; padding:9px 10px; background:#161b22; border:1px solid #30363d; border-radius:6px; color:#e6edf3; font-size:0.84rem; font-family:inherit; box-sizing:border-box; height:36px; }
.edit-input:focus { border-color:#5865F2; outline:none; }
#editModal input[type="number"] { -moz-appearance: textfield; }
#editModal input[type="number"]::-webkit-outer-spin-button,
#editModal input[type="number"]::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.comp-dd-group-header { padding:7px 12px; font-size:0.78rem; font-weight:600; color:#8b949e; background:#21262d; cursor:pointer; display:flex; align-items:center; gap:6px; }
.comp-dd-group-header:hover { color:#e6edf3; }
.comp-dd-arrow { font-size:0.6rem; }
.comp-dd-item { padding:7px 12px 7px 22px; font-size:0.82rem; color:#e6edf3; cursor:pointer; }
.comp-dd-item:hover { background:#30363d; }
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

    return '<div class="post-card' + (isClosed ? ' closed' : '') + (p.mandatory === 'Y' ? ' mandatory' : '') + '">'
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
    var post = allPosts.find(function(p) { return p.id === postId; });
    if (!post) return;

    document.getElementById('editPostId').value = postId;
    document.getElementById('editIsPublic').checked = post.isPublic;
    document.getElementById('editMandatory').checked = (post.mandatory === 'Y');
    document.getElementById('editMinMembers').value = post.minMembers || '';
    document.getElementById('editMaxMembers').value = post.maxMembers || '';
    document.getElementById('editCompositionId').value = post.compositionId || '';

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
    var dateVal = document.getElementById('editDate').value;
    var scheduledAt = null;
    if (dateVal) {
        var h = pad(parseInt(document.getElementById('editHour').value));
        var m = pad(parseInt(document.getElementById('editMinute').value));
        scheduledAt = dateVal + 'T' + h + ':' + m + ':00';
    }

    var body = {
        isPublic: document.getElementById('editIsPublic').checked,
        mandatory: document.getElementById('editMandatory').checked ? 'Y' : 'N',
        scheduledAt: scheduledAt,
        minMembers: parseInt(document.getElementById('editMinMembers').value) || null,
        maxMembers: parseInt(document.getElementById('editMaxMembers').value) || null,
        compositionId: parseInt(document.getElementById('editCompositionId').value) || null
    };

    if (body.minMembers && (body.minMembers < 1 || body.minMembers > 300)) { alert('인원은 1~300 사이로 설정해주세요.'); return; }
    if (body.maxMembers && (body.maxMembers < 1 || body.maxMembers > 300)) { alert('인원은 1~300 사이로 설정해주세요.'); return; }
    if (body.minMembers && body.maxMembers && body.minMembers > body.maxMembers) { alert('최소 인원이 최대 인원보다 클 수 없습니다.'); return; }

    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/edit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: JSON.stringify(body)
    })
    .then(function(r) { return r.json(); })
    .then(function(d) {
        if (d.success) { closeEditModal(); loadPosts(); }
        else alert(d.message || '수정에 실패했습니다.');
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
        <h3 style="font-size:1.1rem;font-weight:700;margin-bottom:4px;">모집글 수정</h3>
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
        </div>

        <div style="display:flex;gap:10px;margin-top:24px;">
            <button onclick="submitEdit()" style="flex:1;padding:11px;background:#5865F2;color:#fff;border:none;border-radius:8px;font-size:0.88rem;font-weight:600;cursor:pointer;font-family:inherit;">저장</button>
            <button onclick="closeEditModal()" style="flex:1;padding:11px;background:transparent;color:#8b949e;border:1px solid #30363d;border-radius:8px;font-size:0.88rem;cursor:pointer;font-family:inherit;">취소</button>
        </div>
    </div>
</div>