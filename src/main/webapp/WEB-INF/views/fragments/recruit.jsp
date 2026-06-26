<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.filter-bar { display:flex; gap:8px; margin-bottom:16px; }
.filter-btn { font-size:0.8rem; padding:5px 14px; border-radius:14px; border:1px solid #3f4147; background:transparent; color:#949ba4; cursor:pointer; font-family:inherit; transition:all 0.1s; }
.filter-btn.active { background:#5865F2; border-color:#5865F2; color:#fff; }
.post-wrap { display:flex; flex-direction:column; }
.post-list { display:flex; flex-direction:column; gap:50px; }
.post-card { background:#2b2d31; border:1px solid #3f4147; border-radius:12px; padding:16px 20px; transition:opacity 0.2s, border-radius 0.2s; position:relative; }
.post-card.closed .post-content-box { opacity:0.45; }
.post-card.closed .post-avatars { opacity:0.45; }
.post-card.closed .post-meta-row { opacity:0.45; }
.post-card.closed .card-actions { opacity:0.45; }
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
.post-side { display:flex; flex-direction:column; align-items:flex-start; justify-content:flex-end; gap:6px; min-width:150px; flex-shrink:0; padding-top:30px; }
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
.post-meta-row { display:flex; align-items:center; gap:6px; font-size:0.82rem; color:#c9d1d9; margin-bottom:4px; }
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
/* 조합 슬롯 패널 내부 */
.slot-panel-title { font-size:0.8rem; color:#8b949e; margin-bottom:10px; }
.slot-grid { display:flex; flex-direction:column; gap:6px; }
.slot-row { display:flex; align-items:center; gap:10px; padding:0px 15px; border-radius:7px; border:1px solid #3f4147; background:#2b2d31; font-size:0.82rem; min-height:40px; }
.slot-row.taken { color:#5a6173; background:#1a1b1e; border-color:#25272b; }
.slot-row.taken .slot-weapon { color:#5a6173; }
.slot-row.taken .slot-occupant { color:#5a6173; }
.slot-row.taken .slot-join-btn { opacity:0.4; }
.slot-row.mine { border-color:#5865F2; background:rgba(88,101,242,0.08); }
.slot-weapon { flex:1; display:flex; align-items:center; gap:8px; min-width:0; overflow:hidden; }
.slot-weapon-label { font-size:0.78rem; color:#c9d1d9; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; width:160px; flex-shrink:0; }
.slot-weapon-icons { display:flex; gap:3px; align-items:center; flex-shrink:0; }
.slot-weapon-icons img { width:30px; height:30px; border-radius:3px; background:#21262d; border:1px solid #30363d; }
.slot-weapon-icons .equip-placeholder { width:30px; height:30px; border-radius:3px; background:#21262d; border:1px solid #30363d; }
.slot-occupant { font-size:0.78rem; color:#8b949e; flex-shrink:0; }
.slot-join-btn { padding:4px 0; width:64px; border-radius:6px; border:1px solid #3f4147; background:transparent; color:#949ba4; font-size:0.78rem; cursor:pointer; font-family:inherit; transition:all 0.15s; flex-shrink:0; text-align:center; }
.slot-join-btn:hover { border-color:#e6edf3; color:#e6edf3; }
.slot-join-btn.mine-btn { border-color:#ed4245; color:#ed4245; }
.slot-join-btn.mine-btn:hover { background:#ed4245; color:#fff; }
.slot-join-btn:disabled { opacity:0.35; cursor:not-allowed; }
/* 역할 아이콘 */
.slot-role-badge { flex-shrink:0; display:inline-flex; align-items:center; justify-content:center; line-height:0; }
/* 정산 패널 */
.settle-panel { background:#1e1f22; border:1px solid #3f4147; border-top:none; border-radius:0 0 12px 12px; overflow:hidden; max-height:0; transition:max-height 0.25s ease, padding 0.25s ease, border-width 0s 0.25s; padding:0 14px; border-width:0; }
.settle-panel.open { max-height:600px; padding:12px 18px; border-width:0 1px 1px 1px; transition:max-height 0.25s ease, padding 0.25s ease, border-width 0s; }
.settle-columns { display:flex; gap:32px; }
.settle-section { flex:1; background:#2b2d31; border:1px solid #3f4147; border-radius:8px; padding:14px 16px; }
.settle-section.disabled { cursor:not-allowed; pointer-events:none; background:#232528; border-color:#2a2c30; }
.settle-section.disabled .settle-section-title { color:#5a6173; }
.settle-section.disabled label { color:#484f58; }
.settle-section.disabled input.settle-amount { background:#1a1b1e; border-color:#272a2e; color:#484f58; }
.settle-section-title { font-size:0.82rem; font-weight:600; color:#e6edf3; margin-bottom:10px; }
.settle-section label { display:block; font-size:0.78rem; color:#8b949e; margin-bottom:4px; }
.settle-section input.settle-amount { width:100%; padding:8px 10px; background:#161b22; border:1px solid #30363d; border-radius:6px; color:#e6edf3; font-size:0.84rem; font-family:inherit; box-sizing:border-box; -moz-appearance:textfield; }
.settle-section input.settle-amount:focus { border-color:#5865F2; outline:none; }
.settle-section select { width:100%; padding:8px 10px; background:#161b22; border:1px solid #30363d; border-radius:6px; color:#e6edf3; font-size:0.84rem; font-family:inherit; box-sizing:border-box; cursor:pointer; }
.settle-section select:focus { border-color:#5865F2; outline:none; }
.settle-disabled-hint { font-size:0.72rem; color:#ed4245; text-align:center; margin-top:12px; line-height:1.4; }
</style>

<div style="max-width:700px;margin:0 auto;">
<c:if test="${accessDenied}">
    <div style="text-align:center;padding:60px 20px;">
        <svg viewBox="0 0 24 24" style="width:48px;height:48px;fill:#ed4245;margin-bottom:16px;"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V10a2 2 0 0 0-2-2zm-6 9a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>
        <h3 style="color:#e6edf3;font-size:1.1rem;margin-bottom:8px;">접근 권한 없음</h3>
        <p style="color:#949ba4;font-size:0.9rem;">${accessDeniedMessage}</p>
        <p style="color:#6e7681;font-size:0.8rem;margin-top:12px;">디스코드 서버에서 해당 채널의 읽기 권한을 부여받으면 이용할 수 있습니다.</p>
    </div>
</c:if>

<c:if test="${!accessDenied}">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:8px;">컨텐츠 모집</h2>
    <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">파티 모집, 참여, 조합, 보이스 채널을 한꺼번에 관리합니다.</p>

    <div class="filter-bar">
        <button class="filter-btn active" onclick="setFilter('all',this)">전체</button>
        <button class="filter-btn" onclick="setFilter('JOINED',this)">참여중</button>
        <button class="filter-btn" onclick="setFilter('IN_PROGRESS',this)">진행중</button>
        <button class="filter-btn" onclick="setFilter('OPEN',this)">모집중</button>
        <button class="filter-btn" onclick="setFilter('CLOSED',this)">완료</button>
        <button class="filter-btn" style="margin-left:auto;background:#5865F2;border-color:#5865F2;color:#fff;" onclick="openCreateModal()">+ 모집글 작성</button>
    </div>
    <div class="post-list" id="postList">
        <div class="empty-state">불러오는 중...</div>
    </div>
</c:if>
</div>

<script>
var currentMemberId = parseInt('${currentMemberId}') || 0;
var isGuildMaster = ('${isGuildMaster}' === 'true');
var canMentionEveryone = ('${canMentionEveryone}' === 'true');
var bankEnabled = ('${bankEnabled}' === 'true');
var splitEnabled = ('${splitEnabled}' === 'true');
var canSetMandatory = ('${canSetMandatory}' === 'true');
var currentFilter = 'all';
var allPosts = [];

function setFilter(filter, btn) {
    currentFilter = filter;
    document.querySelectorAll('.filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    renderPosts();
}

var renderedPostIds = []; // 현재 DOM에 렌더된 post id 순서
var LAZY_BATCH = 8; // 한 번에 렌더할 개수
var lazyObserver = null;

function getFilteredPosts() {
    var filtered = allPosts.filter(function(p) {
        var ds = getDisplayStatus(p);
        if (currentFilter === 'all') return true;
        if (currentFilter === 'IN_PROGRESS') return ds === 'in-progress';
        if (currentFilter === 'OPEN') return ds === 'open';
        if (currentFilter === 'CLOSED') return ds === 'closed';
        if (currentFilter === 'JOINED') {
            return (p.participants || []).some(function(pt) { return pt.memberId === currentMemberId; });
        }
        return true;
    });
    filtered.sort(function(a, b) {
        var ma = a.mandatory === 'Y' ? 0 : 1;
        var mb = b.mandatory === 'Y' ? 0 : 1;
        if (ma !== mb) return ma - mb;
        return b.id - a.id;
    });
    return filtered;
}

function renderPosts() {
    var list = document.getElementById('postList');
    var filtered = getFilteredPosts();

    if (!filtered.length) { list.innerHTML = '<div class="empty-state">게시글이 없습니다.</div>'; renderedPostIds = []; return; }

    // 전체 초기 렌더 (lazy loading)
    list.innerHTML = '';
    renderedPostIds = [];
    if (lazyObserver) lazyObserver.disconnect();

    // 첫 배치 즉시 렌더
    var firstBatch = filtered.slice(0, LAZY_BATCH);
    firstBatch.forEach(function(p) {
        list.insertAdjacentHTML('beforeend', buildCard(p));
        renderedPostIds.push(p.id);
    });

    // 패널이 열려있으면 상태 갱신
    if (openDetailPostId) {
        var openCard = document.getElementById('post-card-' + openDetailPostId);
        if (openCard) {
            openCard.style.borderRadius = '12px 12px 0 0';
            updateDetailButtons(openDetailPostId, openDetailTab);
            renderDetailContent(openDetailPostId, openDetailTab);
        } else {
            // 카드가 아직 안 렌더됐으면 패널 닫기
            openDetailPostId = null;
            openDetailTab = null;
        }
    }

    // 나머지: 센티널로 lazy load
    if (filtered.length > LAZY_BATCH) {
        var sentinel = document.createElement('div');
        sentinel.id = 'lazySentinel';
        sentinel.style.height = '1px';
        list.appendChild(sentinel);

        var nextIdx = LAZY_BATCH;
        lazyObserver = new IntersectionObserver(function(entries) {
            if (!entries[0].isIntersecting) return;
            var batch = filtered.slice(nextIdx, nextIdx + LAZY_BATCH);
            if (!batch.length) { lazyObserver.disconnect(); sentinel.remove(); return; }
            batch.forEach(function(p) {
                sentinel.insertAdjacentHTML('beforebegin', buildCard(p));
                renderedPostIds.push(p.id);
            });
            nextIdx += LAZY_BATCH;
            if (nextIdx >= filtered.length) { lazyObserver.disconnect(); sentinel.remove(); }
        }, { root: null, threshold: 0 });
        lazyObserver.observe(sentinel);
    }
}

/**
 * 단일 카드 부분 업데이트 - 전체 리렌더 대신 해당 카드만 교체
 */
function updateSingleCard(postId) {
    var post = allPosts.find(function(p) { return p.id === postId; });
    if (!post) return;

    var existingCard = document.getElementById('post-card-' + postId);
    if (!existingCard) return; // 아직 렌더 안 된 카드면 무시

    var wrap = existingCard.parentNode;
    var panel = wrap.querySelector('.settle-panel'); // detail-panel

    // 새 카드 생성
    var tmp = document.createElement('div');
    tmp.innerHTML = buildCard(post);
    var newWrap = tmp.firstChild;
    var newCard = newWrap.querySelector('.post-card');

    // 카드 내용만 교체 (패널 DOM은 유지)
    if (newCard) {
        existingCard.innerHTML = newCard.innerHTML;
        existingCard.className = newCard.className;
    }

    // 패널 열려있으면 상태 유지
    if (openDetailPostId === postId) {
        // 상태 바뀌어서 패널이 무효하면 닫기
        var shouldClose = false;
        if (openDetailTab === 'settle' && post.status !== 'CLOSED') shouldClose = true;
        if (openDetailTab === 'slot' && post.status === 'CLOSED') shouldClose = true;
        if (shouldClose) {
            if (panel) panel.classList.remove('open');
            existingCard.style.borderRadius = '';
            openDetailPostId = null;
            openDetailTab = null;
            unsubscribeComp();
        } else {
            existingCard.style.borderRadius = '12px 12px 0 0';
            updateDetailButtons(postId, openDetailTab);
        }
    }
}

/**
 * 전체 posts 갱신 시: 변경된 카드만 부분 업데이트, 새 카드는 추가, 삭제된 카드는 제거
 */
function smartUpdatePosts() {
    var list = document.getElementById('postList');
    var filtered = getFilteredPosts();
    var filteredIds = filtered.map(function(p) { return p.id; });

    if (!filtered.length) { list.innerHTML = '<div class="empty-state">게시글이 없습니다.</div>'; renderedPostIds = []; return; }

    // 삭제된 카드 제거
    renderedPostIds.forEach(function(id) {
        if (filteredIds.indexOf(id) === -1) {
            var card = document.getElementById('post-card-' + id);
            if (card && card.parentNode) card.parentNode.remove();
        }
    });

    // 기존에 렌더된 카드는 부분 업데이트
    renderedPostIds.forEach(function(id) {
        if (filteredIds.indexOf(id) !== -1) {
            updateSingleCard(id);
        }
    });

    // 새로 추가된 카드 (아직 렌더 안 된 것 중 화면에 보여야 하는 것)
    filtered.forEach(function(p) {
        if (renderedPostIds.indexOf(p.id) === -1) {
            // 새 카드를 적절한 위치에 삽입
            var idx = filteredIds.indexOf(p.id);
            var wraps = list.querySelectorAll('.post-wrap');
            if (idx < wraps.length) {
                wraps[idx].insertAdjacentHTML('beforebegin', buildCard(p));
            } else {
                list.insertAdjacentHTML('beforeend', buildCard(p));
            }
            renderedPostIds.push(p.id);
        }
    });

    // renderedPostIds 갱신
    renderedPostIds = filteredIds.filter(function(id) { return renderedPostIds.indexOf(id) !== -1 || document.getElementById('post-card-' + id); });
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
    var canManagePost = isLeader || isGuildMaster;
    var participants = p.participants || [];
    var displayStatus = getDisplayStatus(p);

    // 아바타 (최대 10명, 나머지 +N)
    var MAX_AVATARS = 10;
    var avatarHtml = participants.slice(0, MAX_AVATARS).map(function(pt, i) {
        var isL = i === 0;
        var name = escapeHtml(pt.characterName || '?');
        var crown = isL ? '<svg class="avatar-crown" viewBox="0 0 24 24" fill="#FEE75C"><path d="M5 16L3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5zm0 2h14v2H5v-2z"/></svg>' : '';
        var img = pt.avatarUrl
            ? '<img class="avatar-img' + (isL ? ' leader' : '') + '" src="' + pt.avatarUrl + '?size=64" onerror="this.style.display=\'none\';this.nextSibling.style.display=\'flex\'" alt="' + name + '"><span class="avatar-fallback' + (isL ? ' leader' : '') + '" style="display:none">' + name.charAt(0).toUpperCase() + '</span>'
            : '<span class="avatar-fallback' + (isL ? ' leader' : '') + '">' + name.charAt(0).toUpperCase() + '</span>';
        return '<div class="avatar-wrap"><span class="avatar-tooltip">' + name + '</span>' + crown + img + '</div>';
    }).join('');
    if (participants.length > MAX_AVATARS) {
        avatarHtml += '<span style="font-size:0.75rem;color:#8b949e;margin-left:2px;">외 ' + (participants.length - MAX_AVATARS) + '명</span>';
    }

    // 상태 배지 - 파티장이면 클릭으로 토글
    var badgeClass = 'status-badge ' + displayStatus + (canManagePost ? ' clickable' : '');
    var badgeOnclick = canManagePost ? ' onclick="toggleStatus(' + p.id + ',\'' + p.status + '\')"' : '';
    var statusBadge = '<span class="' + badgeClass + '"' + badgeOnclick + '>' + getStatusLabel(displayStatus) + '</span>';

    // 우측 메타
    var scheduledText = p.scheduledAt ? formatDatetime(p.scheduledAt) + ' UTC' : '미정';
    var memberText = '미정';
    if (p.minMembers || p.maxMembers) {
        if (p.minMembers && p.maxMembers) memberText = p.minMembers + ' ~ ' + p.maxMembers + '명';
        else if (p.maxMembers) memberText = '최대 ' + p.maxMembers + '명';
        else memberText = '최소 ' + p.minMembers + '명';
    }

    // 카드 우상단 아이콘 (파티장만, CLOSED 아닐 때만)
    var cardActions = '';
    if (canManagePost && !isClosed) {
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
    if (isClosed && canManagePost) {
        // CLOSED 상태 → 정산 버튼만 표시
        var settle = p.settlement;
        if (!settle) {
            actionBtn = '<button class="btn-join btn-settle-toggle" data-tab="settle" style="border-color:#57F287;color:#57F287;cursor:pointer;" onclick="toggleDetailPanel(' + p.id + ', \'settle\', this)">정산</button>';
        } else {
            var splitDone = settle.splitStatus === 'DONE' || settle.splitStatus === 'NONE';
            var feeDone = settle.feeStatus === 'DONE' || settle.feeStatus === 'NONE';
            if (splitDone && feeDone) {
                if (settle.splitStatus === 'DONE') {
                    actionBtn = '<button class="btn-join" style="border-color:#8b949e;color:#8b949e;cursor:pointer;" onclick="openSplitModal(' + p.id + ', true)">게임 결과</button>';
                } else {
                    actionBtn = '<button class="btn-join" style="border-color:#ed4245;color:#ed4245;opacity:0.6;cursor:default;" disabled>정산완료</button>';
                }
            } else if (settle.splitStatus === 'PENDING') {
                actionBtn = '<button class="btn-join" style="border-color:#5865F2;color:#5865F2;cursor:pointer;" onclick="openSplitModal(' + p.id + ')">게임 보기</button>';
            } else {
                actionBtn = '<button class="btn-join" style="border-color:#FEE75C;color:#1e1f22;background:#FEE75C;opacity:0.6;cursor:default;" disabled>정산중</button>';
            }
        }
    } else if (p.compositionId) {
        // 조합 있음 → 인원 마감여도 현황은 볼 수 있게
        actionBtn = '<button class="btn-join btn-panel-toggle" data-tab="slot" style="cursor:pointer;" onclick="toggleDetailPanel(' + p.id + ', \'slot\', this)">참여 현황</button>';
    } else if (!isLeader) {
        if (alreadyJoined) {
            actionBtn = '<button class="btn-join joined"' + (isClosed ? ' disabled' : '') + ' onclick="toggleJoin(' + p.id + ')">참여 취소</button>';
        } else {
            actionBtn = '<button class="btn-join"' + dis + (isFull ? ' title="인원이 가득 찼습니다"' : '') + ' onclick="toggleJoin(' + p.id + ')">참여' + (isFull ? ' 마감' : '') + '</button>';
        }
    } else {
        // 파티 리더, 조합 없음
        actionBtn = '';
    }

    // 보이스 입장 버튼 (참여자만)
    var voiceBtn = '';
    var iAmParticipant = participants.some(function(pt) { return pt.memberId === currentMemberId; });
    if (iAmParticipant && !isClosed) {
        voiceBtn = '<button class="btn-join" style="margin-top:4px;border-color:#57F287;color:#57F287;" onclick="joinVoice(' + p.id + ')">보이스 챗</button>';
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
        +       '<div class="post-meta-row"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg><span>' + memberText + '</span></div>'
        +       '<div class="post-meta-row"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2zm1 11H7.5a1 1 0 0 1 0-2H11V7a1 1 0 0 1 2 0v5a1 1 0 0 1-1 1h1z"/></svg><span>' + scheduledText + '</span></div>'
        +     '</div>'
        +     actionBtn
        +     voiceBtn
        +   '</div>'
        + '</div>'
        + '</div>'
        + '<div class="settle-panel" id="detail-panel-' + p.id + '"></div>'
        + '</div>';
}

// 파티장: 상태 배지 클릭 토글
// 모집중 or 진행중 → CLOSED, 완료 → OPEN
var statusChanging = {};
function toggleStatus(postId, currentDbStatus) {
    if (statusChanging[postId]) return; // 연타 방지
    statusChanging[postId] = true;

    var newStatus = currentDbStatus === 'CLOSED' ? 'OPEN' : 'CLOSED';

    // 패널이 열려있고 상태 변경으로 무효해지면 먼저 닫기
    if (openDetailPostId === postId) {
        if ((openDetailTab === 'settle' && newStatus !== 'CLOSED') ||
            (openDetailTab === 'slot' && newStatus === 'CLOSED')) {
            var panel = document.getElementById('detail-panel-' + postId);
            var card = document.getElementById('post-card-' + postId);
            if (panel) panel.classList.remove('open');
            if (card) card.style.borderRadius = '';
            resetDetailButtons(postId);
            unsubscribeComp();
            openDetailPostId = null;
            openDetailTab = null;
        }
    }

    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/status', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'status=' + newStatus + '&' + csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) {
        statusChanging[postId] = false;
        if (d.success) refreshSinglePost(postId);
        else if (d.message) alert(d.message);
    }).catch(function() {
        statusChanging[postId] = false;
    });
}

function toggleJoin(postId) {
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/join', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) { if (d.success) refreshSinglePost(postId); });
}

var ROLE_STYLES = {
    OFF_TANK:    { label:'O TANK',  color:'#57a9f2', bg:'rgba(87,169,242,0.1)',  border:'rgba(87,169,242,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#2980b9"/><g transform="translate(64,64)"><path d="M256 80l-130 65v110c0 95 55 170 130 190 75-20 130-95 130-190V145L256 80z" fill="#7ec8f2"/></g></svg>' },
    DEF_TANK:    { label:'D TANK',  color:'#57a9f2', bg:'rgba(87,169,242,0.1)',  border:'rgba(87,169,242,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#2980b9"/><g transform="translate(64,64)"><path d="M256 80l-130 65v110c0 95 55 170 130 190 75-20 130-95 130-190V145L256 80z" fill="#7ec8f2"/></g></svg>' },
    MDPS:        { label:'MDPS',    color:'#ed4245', bg:'rgba(237,66,69,0.1)',   border:'rgba(237,66,69,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#c0392b"/><g transform="translate(64,64)"><path d="M124.812 388.907a60.718 60.718 0 0 0 16.564 11.588L107.28 435.07a48.756 48.756 0 0 0-28.35-28.006l34.16-34.576a61.093 61.093 0 0 0 11.722 16.42zm209.598-276.44c-32.754 33.14-57.813 79.127-103.008 124.853-9.13 9.245-40.292 37.355-58.303 53.555l49.223 48.64c15.98-18.24 43.727-49.744 52.858-58.978 45.154-45.726 90.828-71.39 123.57-104.477C452.683 121.485 481 28.492 481 28.492s-92.67 29.4-146.59 83.976zM83.656 430.594a30.92 30.92 0 1 0 .26 43.727 30.817 30.817 0 0 0-.26-43.727zm91.13-40.603c11.16 0 20.822-2.81 24.497-6.56l20.885-21.103-69.88-69.047-20.823 21.135c-7.964 8.068-11.233 43.06 7.85 61.905 10.12 10.026 24.79 13.66 37.47 13.66z" fill="#f1c40f"/></g></svg>' },
    RDPS:        { label:'RDPS',    color:'#f5813a', bg:'rgba(245,129,58,0.1)',  border:'rgba(245,129,58,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#d35400"/><g transform="translate(64,64)"><path d="m492.656 20.406-118.594 56.22L413.875 86l-86.97 86.97-305.5 259.374.69.687 104.75-47.467-46.376 105.843.905.906 272.5-319.875 73.22-73.218 9.342 39.81 56.22-118.624zm-473.25.063c-1.347 23.43 5 39.947 16.563 52.218l24.093 302.28 17.562-14.874-21.72-272.438C113.879 119.609 225 112.82 272.811 194.375l66.625-56.564 1.22-1.218C292.74 38.666 86.01 99.716 19.406 20.47zm359.531 151.56-1.156 1.157-57.25 67.188c82.006 47.945 75.587 159.267 107.283 218.03l-272.157-24.5-14.812 17.408 301.562 27.125c12.48 12.283 29.4 19.084 53.688 17.687-79.95-67.2-18.36-275.754-117.156-324.094z" fill="#f1c40f"/></g></svg>' },
    HEALER:      { label:'HEAL',    color:'#57F287', bg:'rgba(87,242,135,0.1)',  border:'rgba(87,242,135,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#27ae60"/><g transform="translate(64,64)"><path d="M389.917 128.73v100.836h-22.802v-158.5a17.11 17.11 0 0 0-17.11-17.11h-11.863a17.11 17.11 0 0 0-17.11 17.11v158.5h-22.698V46.993a17.11 17.11 0 0 0-17.11-17.11h-11.863a17.11 17.11 0 0 0-17.11 17.11v182.573H229.5V77.33a17.11 17.11 0 0 0-17.108-17.11h-11.864a17.11 17.11 0 0 0-17.11 17.11v263.873l-63.858-51.14a23.385 23.385 0 0 0-30.743 1.32l-5.567 5.31a23.385 23.385 0 0 0-2.01 31.678l102.19 125.647a72.028 72.028 0 0 0 57.092 28.1h60.85A134.637 134.637 0 0 0 436 347.5V128.73a17.11 17.11 0 0 0-17.11-17.108h-11.864a17.11 17.11 0 0 0-17.11 17.11z" fill="#90f5a8"/></g></svg>' },
    SUPPORT:     { label:'SUP',     color:'#FEE75C', bg:'rgba(254,231,92,0.1)', border:'rgba(254,231,92,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#f5c518"/><g transform="translate(64,64) scale(-1,1) translate(-512,0)"><path d="M356.688 19.188c-6.83-.032-12.837.64-18.125 1.843-24.178 5.495-36.437 21.983-50.938 41.157-14.5 19.175-31.317 40.993-62.78 47.47C195.08 115.78 154.27 108.253 91.25 78.5c-10.013 44.88-33.406 128.62-60.906 178.656 60.093 28.5 97.245 34.926 121 30.875.01 0 .02.004.03 0 21.59-5.827 34.487-20.094 47.876-43.092 17.014-29.227 32.563-72.198 60.25-123.188l16.406 8.938c-16.69 30.735-28.802 58.617-40 82.937 8.552-6.512 18.633-11.77 31.063-14.594 27.71-6.296 65.053-.495 121.655 24.75-6.932-29.276-1.885-61.913 9.875-92.218 12.686-32.69 33.038-62.907 56.28-84.03-42.595-19.553-73.152-27.554-95.124-28.282-1.01-.033-1.993-.058-2.97-.063zm127.54 14.144a10.775 10.775 0 0 0-2.664.266c-4.378.977-8.94 4.424-12.084 11.097L289.53 497.31h23.61L490.972 49.368c3.475-10.153-.75-15.86-6.746-16.035z" fill="#d35400"/></g></svg>' },
    BATTLEMOUNT: { label:'BM',      color:'#8b949e', bg:'rgba(139,148,158,0.1)', border:'rgba(139,148,158,0.3)', icon:'<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#7f8c8d"/><g transform="translate(64,64)"><path d="M400 16c-21.335 9.73-58.244 17.34-73.086 48.232-22.36 1.948-72.753 10.673-122.22 40.25-58.098 34.74-116.017 97.417-131.776 213.702l-.48 3.537-2.774 2.25c-30.87 25.002-40.657 38.937-44.416 61.153-3.536 20.9-.72 51.46-.363 101.877H328.36c3.455-16.892 10.44-29.245 12.472-41.568 2.337-14.176.19-29.938-20.812-58.547-43.078-58.683-46.853-129.458-12.916-171.28-8.654-2.765-15.09-6.887-19.458-12.546-6.115-7.924-7.4-17.006-8.57-25.884l17.848-2.352c1.112 8.446 2.38 13.88 4.97 17.237 2.59 3.356 7.31 6.472 19.55 8.46l-.022.128.172-.17 5.998 9.424c19.957 31.358 42.84 51.292 73.332 54.44l6.51.672 1.367 6.4c2.74 12.828 8.626 19.095 15.116 22.238 6.49 3.143 14.225 2.944 20.47.205 9.316-4.086 14.518-11.35 16.7-22.712 2.122-11.05.546-25.834-5.137-42.106-33.538-38.248-44.475-87.277-63.903-128.772-6.055-9.947-12.448-18.518-20.385-24.856C376.808 55.126 386.456 34.852 400 16z" fill="#2c3e50"/></g></svg>' }
};

// 통합 패널: 참여 현황 / 정산 탭 전환
var openDetailPostId = null;
var openDetailTab = null; // 'slot' or 'settle'

function toggleDetailPanel(postId, tab, btn) {
    var panel = document.getElementById('detail-panel-' + postId);
    var card = document.getElementById('post-card-' + postId);
    if (!panel) return;
    var isOpen = panel.classList.contains('open');

    // 이미 열려있고 같은 탭 → 닫기
    if (isOpen && openDetailPostId === postId && openDetailTab === tab) {
        panel.classList.remove('open');
        if (card) card.style.borderRadius = '';
        openDetailPostId = null;
        openDetailTab = null;
        resetDetailButtons(postId);
        unsubscribeComp();
        return;
    }

    // 이미 열려있고 다른 탭 → 내용만 교체 (패널 열림 유지)
    if (isOpen && openDetailPostId === postId && openDetailTab !== tab) {
        openDetailTab = tab;
        unsubscribeComp();
        renderDetailContent(postId, tab);
        updateDetailButtons(postId, tab);
        return;
    }

    // 다른 포스트의 패널이 열려있으면 먼저 닫기
    if (openDetailPostId && openDetailPostId !== postId) {
        var prevPanel = document.getElementById('detail-panel-' + openDetailPostId);
        var prevCard = document.getElementById('post-card-' + openDetailPostId);
        if (prevPanel) prevPanel.classList.remove('open');
        if (prevCard) prevCard.style.borderRadius = '';
        resetDetailButtons(openDetailPostId);
        unsubscribeComp();
    }

    // 패널 열기
    openDetailPostId = postId;
    openDetailTab = tab;
    if (card) card.style.borderRadius = '12px 12px 0 0';
    panel.innerHTML = '<div style="color:#8b949e;font-size:0.82rem;padding:4px 0;">불러오는 중...</div>';
    panel.classList.add('open');
    renderDetailContent(postId, tab);
    updateDetailButtons(postId, tab);
}

function renderDetailContent(postId, tab) {
    if (tab === 'slot') {
        loadSlotPanel(postId);
        var post = allPosts.find(function(p) { return p.id === postId; });
        if (post && post.compositionId) subscribeComp(post.compositionId, postId);
    } else if (tab === 'settle') {
        loadSettleContent(postId);
    }
}

function updateDetailButtons(postId, activeTab) {
    var card = document.getElementById('post-card-' + postId);
    if (!card) return;
    var slotBtn = card.querySelector('.btn-panel-toggle');
    var settleBtn = card.querySelector('.btn-settle-toggle');
    if (slotBtn) slotBtn.textContent = (activeTab === 'slot') ? '닫기' : '참여 현황';
    if (settleBtn) {
        settleBtn.textContent = (activeTab === 'settle') ? '닫기' : '정산';
        settleBtn.style.color = (activeTab === 'settle') ? '#949ba4' : '#57F287';
        settleBtn.style.borderColor = (activeTab === 'settle') ? '#3f4147' : '#57F287';
        settleBtn.style.background = 'transparent';
    }
}

function resetDetailButtons(postId) {
    var card = document.getElementById('post-card-' + postId);
    if (!card) return;
    var slotBtn = card.querySelector('.btn-panel-toggle');
    if (slotBtn) slotBtn.textContent = '참여 현황';
    var settleBtn = card.querySelector('.btn-settle-toggle');
    if (settleBtn) {
        settleBtn.textContent = '정산';
        settleBtn.style.color = '#57F287';
        settleBtn.style.borderColor = '#57F287';
        settleBtn.style.background = 'transparent';
    }
}

function subscribeComp(compId, postId) {
    unsubscribeComp();
    if (!window.stompClient || !window.stompClient.connected) return;
    subscribedCompId = compId;
    compSub = stompClient.subscribe('/topic/compositions/' + compId, function() {
        if (openDetailPostId === postId) loadSlotPanel(postId);
    });
}

function unsubscribeComp() {
    if (compSub) { try { compSub.unsubscribe(); } catch(e) {} compSub = null; }
    subscribedCompId = null;
}

function loadSlotPanel(postId) {
    var panel = document.getElementById('detail-panel-' + postId);
    if (!panel) return;

    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/composition')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.error) { panel.classList.remove('open'); openDetailPostId = null; openDetailTab = null; return; }

            var slots = data.slots || [];
            var participants = data.participants || [];
            var maxMembers = data.maxMembers;
            var post = allPosts.find(function(p) { return p.id === postId; });
            var isLeader = post && post.leaderMemberId === currentMemberId;
            var isPostClosed = post && post.status === 'CLOSED';

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
                var badge = '<span class="slot-role-badge">' + (style.icon || '') + '</span>';
                // 장비: 무기 이름 + 아이템 이미지 나열
                var weaponName = s.weapon || '';
                var equipIds = [s.weaponId, s.offhandId, s.headId, s.chestId, s.shoesId, s.capeId, s.foodId];
                var equipNames = [s.weapon, s.offhand, s.head, s.chest, s.shoes, s.cape, s.food];
                var iconHtml = equipIds.map(function(id, i) {
                    if (!id) return '<span class="equip-placeholder"></span>';
                    return '<img src="https://render.albiononline.com/v1/item/' + encodeURIComponent(id) + '.png?size=64" title="' + escapeHtml(equipNames[i] || '') + '">';
                }).join('');
                var weapon = '<div class="slot-weapon"><span class="slot-weapon-label" title="' + escapeHtml(weaponName) + '">' + escapeHtml(weaponName) + '</span><div class="slot-weapon-icons">' + iconHtml + '</div></div>';
                var badge = '<span class="slot-role-badge">' + (style.icon || '') + '</span>';
                var rowContent = badge + weapon;
                var occupant = occupiedMap[s.id];
                var isMine = s.id === mySlotId;
                var isTaken = !!occupant && !isMine;
                var rowClass = 'slot-row' + (isMine ? ' mine' : (isTaken ? ' taken' : ''));
                var occupantHtml = occupant
                    ? '<span class="slot-occupant">' + escapeHtml(occupant) + '</span>'
                    : '<span class="slot-occupant" style="color:#3f4147">비어있음</span>';
                var joinBtn;
                if (isPostClosed) {
                    joinBtn = '<button class="slot-join-btn" disabled style="opacity:0;border:none;"></button>';
                } else if (isMine) {
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

            // 자유참여 row — 대기 자리가 있거나 slot_id가 null인 참여자가 있으면 표시
            var freeParticipants = participants.filter(function(p) { return !p.slotId; });
            if (freeSlots > 0 || freeParticipants.length > 0) {
                freeRemain = freeRemain <= 0 ? 0 : freeRemain;
                var freeBadgeColor = freeRemain <= 0 ? 'ed4245' : '57F287';
                var freeBadgeRgb = freeRemain <= 0 ? '237,66,69' : '87,242,135';
                var waitIcon = '<svg viewBox="0 0 640 640" width="18" height="18"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#111"/><rect x="50" y="50" width="540" height="540" rx="60" fill="none" stroke="#ed4245" stroke-width="64"/><line x1="510" y1="130" x2="130" y2="510" stroke="#ed4245" stroke-width="64" stroke-linecap="round"/></svg>';
                var freeLabel = '<span class="slot-role-badge">' + waitIcon + '</span>';
                // 대기자 명단
                var freeNames = freeParticipants.map(function(p) { return escapeHtml(p.characterName || '?'); }).join(' , ');
                var freeWeapon = '<span class="slot-weapon" style="color:#8b949e">' + (freeNames || '') + '</span>';
                var freeOccupant = '<span class="slot-occupant" style="color:#8b949e">' + freeRemain + '자리 남음</span>';
                var freeBtn;
                if (isPostClosed) {
                    freeBtn = '<button class="slot-join-btn" disabled style="opacity:0;border:none;"></button>';
                } else if (!isLeader) {
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
            var PAGE_SIZE = 20;
            var currentPage = parseInt(panel.dataset.page || '0');
            var totalPages = Math.ceil(allRows.length / PAGE_SIZE);
            if (currentPage >= totalPages) currentPage = totalPages - 1;
            if (currentPage < 0) currentPage = 0;
            panel.dataset.page = currentPage;

            var pageRows = allRows.slice(currentPage * PAGE_SIZE, (currentPage + 1) * PAGE_SIZE);

            // 파티 구분 헤더 (20명 단위, 페이징된 결과에 적용)
            // 파티 구분: 현재 페이지 첫 번째 슬롯이 몇 파티인지 계산
            var PARTY_SIZE = 20;
            var slotsOnly = allRows.length - (freeSlots > 0 ? 1 : 0);
            var globalStart = currentPage * PAGE_SIZE;
            var currentParty = Math.floor(globalStart / PARTY_SIZE) + 1;
            var totalParties = Math.ceil(slotsOnly / PARTY_SIZE) || 1;
            var partyLabel = currentParty + '파티';

            // 페이지 내에서 파티 경계가 있으면 중간에 구분선 삽입 (페이지 시작 지점은 타이틀로 이미 표시)
            var withHeaders = [];
            for (var ri = 0; ri < pageRows.length; ri++) {
                var globalIdx = globalStart + ri;
                if (globalIdx < slotsOnly && globalIdx > 0 && globalIdx % PARTY_SIZE === 0 && globalIdx !== globalStart) {
                    var nextParty = Math.floor(globalIdx / PARTY_SIZE) + 1;
                    withHeaders.push('<div class="slot-panel-title" style="display:flex;align-items:center;justify-content:space-between;margin-top:10px;padding-top:10px;border-top:1px solid #3f4147;">' + nextParty + '파티' + countBadge + '</div>');
                }
                withHeaders.push(pageRows[ri]);
            }
            pageRows = withHeaders;

            var pager = '';
            if (totalPages > 1) {
                var prevDis = currentPage === 0 ? ' disabled' : '';
                var nextDis = currentPage >= totalPages - 1 ? ' disabled' : '';
                pager = '<div style="display:flex;align-items:center;justify-content:center;gap:6px;margin-top:8px;">'
                    + '<button class="slot-join-btn"' + prevDis + ' style="width:28px;height:24px;padding:0;" onclick="slotPanelPage(' + postId + ',-1)">‹</button>'
                    + '<span style="font-size:0.78rem;color:#8b949e;">' + (currentPage+1) + ' / ' + totalPages + '</span>'
                    + '<button class="slot-join-btn"' + nextDis + ' style="width:28px;height:24px;padding:0;" onclick="slotPanelPage(' + postId + ',1)">›</button>'
                    + '</div>';
            }

            panel.innerHTML = '<div class="slot-panel-title" style="display:flex;align-items:center;justify-content:space-between;">' + partyLabel + countBadge + '</div>'
                + '<div class="slot-grid">' + pageRows.join('') + '</div>'
                + pager;
        })
        .catch(function() { panel.classList.remove('open'); openDetailPostId = null; openDetailTab = null; });
}

function slotPanelPage(postId, dir) {
    var panel = document.getElementById('detail-panel-' + postId);
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
            if (openDetailPostId === postId) {
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
                openDetailPostId = null;
                openDetailTab = null;
                refreshSinglePost(postId);
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
    menu.innerHTML = (canMentionEveryone ? '<div class="ping-option" onclick="pingPost(' + postId + ', \'everyone\')">@everyone</div>'
        + '<div class="ping-option" onclick="pingPost(' + postId + ', \'here\')">@here</div>' : '')
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

function joinVoice(postId) {
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/voice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: '{}'
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (!d.success) { alert(d.message || '음성채널 입장에 실패했습니다.'); return; }
        if (d.moved) {
            // 자동 이동 완료
        } else if (d.inviteUrl) {
            window.open(d.inviteUrl, '_blank');
        } else {
            alert(d.message || '음성채널에 입장해주세요.');
        }
    }).catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
}

function deletePost(postId) {
    if (!confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) return;
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/delete', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.success) { openDetailPostId = null; openDetailTab = null; loadPosts(); }
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
    var mandatoryEl = document.getElementById('editMandatory');
    if (mandatoryEl) mandatoryEl.checked = false;
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
    var mandatoryEl2 = document.getElementById('editMandatory');
    if (mandatoryEl2) mandatoryEl2.checked = (post.mandatory === 'Y');
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

function setTimeOffset(minutes) {
    var future = new Date(Date.now() + minutes * 60000);
    document.getElementById('editDate').value = future.getUTCFullYear() + '-' + pad(future.getUTCMonth()+1) + '-' + pad(future.getUTCDate());
    document.getElementById('editHour').value = pad(future.getUTCHours());
    document.getElementById('editMinute').value = pad(future.getUTCMinutes());
}

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
                var label = '<span style="flex:1;">' + escapeHtml(c.name) + '</span><span style="font-size:0.72rem;color:#5a6173;margin-left:auto;">' + slotCount + '명</span>';
                myGroup.innerHTML += '<div class="comp-dd-item" style="display:flex;align-items:center;" onclick="pickComp(' + c.id + ',\'' + escapeHtml(c.name) + '\')">' + label + '</div>';
                if (selectedId && c.id === selectedId) {
                    display.textContent = c.name;
                    display.style.color = '#e6edf3';
                }
            });
        });

    fetch('/' + guildSubdomain + '/recruit/compositions/public')
        .then(function(r) { return r.json(); })
        .then(function(comps) {
            comps.forEach(function(c) {
                var slotCount = c.slots ? c.slots.length : 0;
                var label = '<span style="flex:1;">' + escapeHtml(c.name) + '</span><span style="font-size:0.72rem;color:#5a6173;margin-left:auto;">' + slotCount + '명</span>';
                guildGroup.innerHTML += '<div class="comp-dd-item" style="display:flex;align-items:center;" onclick="pickComp(' + c.id + ',\'' + escapeHtml(c.name) + '\')">' + label + '</div>';
                if (selectedId && c.id === selectedId && display.style.color !== 'rgb(230, 237, 243)') {
                    display.textContent = c.name;
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
        mandatory: (document.getElementById('editMandatory') && document.getElementById('editMandatory').checked) ? 'Y' : 'N',
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

var isFirstLoad = true;
function loadPosts() {
    fetch('/' + guildSubdomain + '/recruit/posts')
        .then(function(r) { return r.json(); })
        .then(function(posts) {
            allPosts = posts;
            if (isFirstLoad) {
                isFirstLoad = false;
                renderPosts();
            } else {
                smartUpdatePosts();
            }
            scheduleStatusUpdate();
        })
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

function formatSettleInput(el) {
    var raw = el.value.replace(/[^0-9]/g, '');
    if (raw === '') { el.value = ''; return; }
    el.value = parseInt(raw).toLocaleString();
}

function parseSettleAmount(el) {
    if (!el) return 0;
    return parseInt(el.value.replace(/[^0-9]/g, '')) || 0;
}

function loadSettleContent(postId) {
    var panel = document.getElementById('detail-panel-' + postId);
    if (!panel) return;

    var post = allPosts.find(function(p) { return p.id === postId; });
    var participants = post ? (post.participants || []) : [];

    // 참여자 목록 HTML
    var participantsHtml = '';
    if (participants.length > 0) {
        participantsHtml = '<div style="margin-top:10px;">'
            + '<div style="font-size:0.75rem;color:#8b949e;margin-bottom:6px;">참여자 (' + participants.length + '명)</div>'
            + '<div style="display:flex;flex-wrap:wrap;gap:4px;">'
            + participants.map(function(pt) {
                return '<span style="font-size:0.75rem;color:#c9d1d9;background:#2b2d31;border:1px solid #3f4147;border-radius:4px;padding:2px 7px;">' + escapeHtml(pt.characterName || '?') + '</span>';
            }).join('')
            + '</div></div>';
    }

    // 분배금 비활성화 (SPLIT 페이지 미활성화 시)
    var splitDisabled = !splitEnabled;
    var splitSectionClass = splitDisabled ? ' disabled' : '';
    var splitHint = '';
    if (splitDisabled) {
        splitHint = '<div class="settle-disabled-hint">분배 페이지 활성화 후 사용이 가능합니다</div>';
    }

    // 참여비 비활성화
    var feeDisabled = !(canSetMandatory && bankEnabled);
    var feeSectionClass = feeDisabled ? ' disabled' : '';
    var feeHint = '';
    if (!bankEnabled) {
        feeHint = '<div class="settle-disabled-hint">실버리기어 활성화 후 사용이 가능합니다</div>';
    } else if (!canSetMandatory) {
        feeHint = '<div class="settle-disabled-hint">컨텐츠 리더 권한이 필요합니다</div>';
    }

    panel.innerHTML = '<div style="display:flex; gap:32px; margin-bottom:14px;">'
        +   '<div style="flex:1;padding-left:4px;font-size:0.85rem;font-weight:600;">SPLIT</div>'
        +   '<div style="flex:1;padding-left:4px;font-size:0.85rem;font-weight:600;">ATTENDANCE</div>'
        + '</div>'
        + '<div class="settle-columns">'
        +   '<div class="settle-section' + splitSectionClass + '">'
        +     '<label>분배금</label>'
        +     '<input type="text" class="settle-amount" id="settleDistAmount-' + postId + '" placeholder="없음" oninput="formatSettleInput(this);updateSettleSummary(' + postId + ')">'
        +     '<div style="display:flex;flex-direction:row;justify-content:space-between;margin-top:10px;gap:10px;">'
        +       '<div style="flex:1;display:flex;flex-direction:column;">'
        +         '<label>분배방식</label>'
        +         '<select id="settleMethod-' + postId + '" onchange="updateSettleSummary(' + postId + ')">'
        +           '<option value="">선택</option>'
        +           '<option value="dice">주사위</option>'
        +           '<option value="horse">경마</option>'
        +           '<option value="ladder">사다리</option>'
        +         '</select>'
        +       '</div>'
        +       '<div style="flex:1;display:flex;flex-direction:column;">'
        +         '<label>마감시간</label>'
        +         '<select id="settleTime-' + postId + '">'
        +           '<option value="5">5분 후</option>'
        +           '<option value="3">3분 후</option>'
        +           '<option value="1">1분 후</option>'
        +         '</select>'
        +       '</div>'
        +     '</div>'
        +     splitHint
        +   '</div>'
        +   '<div class="settle-section' + feeSectionClass + '">'
        +     '<label>참여비</label>'
        +     '<input type="text" class="settle-amount" id="settleFeeAmount-' + postId + '" placeholder="없음" oninput="formatSettleInput(this);updateSettleSummary(' + postId + ')">'
        +     feeHint
        +     participantsHtml
        +   '</div>'
        + '</div>'
        + '<div style="margin-top:14px;padding-top:10px;border-top:1px solid #3f4147;display:flex;align-items:flex-end;justify-content:space-between;">'
        +   '<div id="settleSummaryText-' + postId + '" style="font-size:0.78rem;color:#8b949e;"></div>'
        +   '<button class="btn-join" style="border-color:#57F287;color:#57F287;width:150px;flex-shrink:0;" onclick="submitSettle(' + postId + ')">정산 시작</button>'
        + '</div>';
    updateSettleSummary(postId);
}

function updateSettleSummary(postId) {
    var post = allPosts.find(function(p) { return p.id === postId; });
    var participants = post ? (post.participants || []) : [];
    var count = participants.length;

    var distAmount = parseSettleAmount(document.getElementById('settleDistAmount-' + postId));
    var feeAmount = 0;
    var feeEl = document.getElementById('settleFeeAmount-' + postId);
    if (feeEl && canSetMandatory && bankEnabled) feeAmount = parseSettleAmount(feeEl);
    var method = document.getElementById('settleMethod-' + postId).value;

    var summary = document.getElementById('settleSummaryText-' + postId);
    if (!summary) return;

    if (distAmount <= 0 && feeAmount <= 0) {
        summary.textContent = '분배금 또는 참여비를 입력해주세요.';
        return;
    }

    var lines = [];
    lines.push('참여인원: ' + count + '명');

    if (distAmount > 0) {
        var perPerson = Math.floor(distAmount / count);
        lines.push('1인당 분배금: ' + perPerson.toLocaleString() + ' 실버');
    }
    if (feeAmount > 0) {
        var totalFee = feeAmount * count;
        lines.push('참여비 차감: 총 ' + totalFee.toLocaleString() + ' 실버');
    }
    summary.innerHTML = lines.join('<br>');
}

function submitSettle(postId) {
    var distAmount = parseSettleAmount(document.getElementById('settleDistAmount-' + postId));
    var feeAmount = 0;
    var feeEl = document.getElementById('settleFeeAmount-' + postId);
    if (feeEl && canSetMandatory && bankEnabled) feeAmount = parseSettleAmount(feeEl);
    var method = document.getElementById('settleMethod-' + postId).value;
    var splitTime = parseInt(document.getElementById('settleTime-' + postId).value) || 5;

    if (distAmount <= 0 && feeAmount <= 0) { alert('분배금 또는 참여비를 입력해주세요.'); return; }
    if (distAmount > 0 && !method) { alert('분배방식을 선택해주세요.'); return; }

    if (!confirm('정산을 시작하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) return;

    fetch('/' + guildSubdomain + '/recruit/posts/' + postId + '/settle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
        body: JSON.stringify({
            distributeAmount: distAmount,
            feeAmount: feeAmount,
            method: method || null,
            splitMinutes: splitTime
        })
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (d.success) {
            var panel = document.getElementById('detail-panel-' + postId);
            if (panel) panel.classList.remove('open');
            var card = document.getElementById('post-card-' + postId);
            if (card) card.style.borderRadius = '';
            openDetailPostId = null;
            openDetailTab = null;
            refreshSinglePost(postId);
        } else {
            alert(d.message || '정산에 실패했습니다.');
        }
    }).catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
}

loadPosts();

// scheduledAt 기준으로 상태 전환 타이머
var statusTimer = null;
function scheduleStatusUpdate() {
    if (statusTimer) clearTimeout(statusTimer);
    var now = new Date();
    var nextChange = null;
    allPosts.forEach(function(p) {
        if (p.status === 'CLOSED' || !p.scheduledAt) return;
        var scheduled = new Date(p.scheduledAt + 'Z');
        if (scheduled > now) {
            var diff = scheduled - now;
            if (!nextChange || diff < nextChange) nextChange = diff;
        }
    });
    if (nextChange && nextChange < 3600000) { // 1시간 이내만
        statusTimer = setTimeout(function() {
            renderPosts();
            scheduleStatusUpdate();
            // 배너도 갱신
            if (typeof checkMandatoryBanner === 'function') checkMandatoryBanner();
        }, nextChange + 1000);
    }
}

var recruitSub = null;
var compSub = null;
var subscribedCompId = null;
var loadPostsTimer = null;
function loadPostsDebounced() {
    if (loadPostsTimer) clearTimeout(loadPostsTimer);
    loadPostsTimer = setTimeout(function() { loadPostsTimer = null; loadPosts(); }, 300);
}

/**
 * 단일 포스트만 서버에서 가져와서 allPosts 갱신 + DOM 부분 업데이트
 */
function refreshSinglePost(postId) {
    fetch('/' + guildSubdomain + '/recruit/posts/' + postId)
        .then(function(r) { return r.json(); })
        .then(function(postData) {
            // allPosts에서 교체
            var idx = allPosts.findIndex(function(p) { return p.id === postId; });
            if (idx >= 0) {
                allPosts[idx] = postData;
            } else {
                allPosts.unshift(postData); // 새 포스트면 앞에 추가
            }
            updateSingleCard(postId);
        });
}
var recruitSub = null;
function subscribeRecruit() {
    if (!window.stompClient || !window.stompClient.connected) { setTimeout(subscribeRecruit, 500); return; }
    if (recruitSub) return; // 이미 구독 중이면 재구독 안 함
    recruitSub = stompClient.subscribe('/topic/guild/' + guildSubdomain + '/recruit', function(msg) {
        try {
            var data = JSON.parse(msg.body);
            if (data.postId) refreshSinglePost(data.postId);
            else loadPostsDebounced();
        } catch(e) { loadPostsDebounced(); }
    });
}
subscribeRecruit();

var recruitObserver = new MutationObserver(function() {
    if (!document.getElementById('postList')) {
        // 모집 페이지 떠남 → 구독 해제
        if (recruitSub) { try { recruitSub.unsubscribe(); } catch(e) {} recruitSub = null; }
        if (loadPostsTimer) { clearTimeout(loadPostsTimer); loadPostsTimer = null; }
        recruitObserver.disconnect();
    }
});
recruitObserver.observe(document.getElementById('mainContent') || document.body, { childList:true });
</script>

<!-- 수정 모달 -->
<div class="modal-overlay" id="editModal" onmousedown="if(event.target===this)this.dataset.closeOk='1'" onmouseup="if(event.target===this&&this.dataset.closeOk==='1')closeEditModal();delete this.dataset.closeOk" onclick="">
    <div style="background:#21262d;border:1px solid #30363d;border-radius:16px;padding:32px 28px;max-width:560px;width:90%;position:relative;">
        <h3 id="editModalTitle" style="font-size:1.1rem;font-weight:700;margin-bottom:4px;">모집글 수정</h3>
        <p id="editUtcClock" style="font-size:0.75rem;color:#8b949e;margin-bottom:10px;text-align:right;"></p>
        <input type="hidden" id="editPostId">

        <div style="display:flex;flex-direction:column;gap:14px;">
            <div style="display:flex;gap:20px;">
                <c:if test="${canSetMandatory}">
                <label style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:#e6edf3;">
                    <input type="checkbox" id="editMandatory" style="width:16px;height:16px;"> Mandatory
                </label>
                </c:if>
            </div>
            <div>
                <label style="display:block;font-size:0.78rem;color:#8b949e;margin-bottom:6px;">시간</label>
                <div style="display:flex;gap:4px;margin-bottom:6px;">
                    <button type="button" onclick="setTimeOffset(5)" style="padding:3px 8px;font-size:0.7rem;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;">+5분</button>
                    <button type="button" onclick="setTimeOffset(10)" style="padding:3px 8px;font-size:0.7rem;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;">+10분</button>
                    <button type="button" onclick="setTimeOffset(30)" style="padding:3px 8px;font-size:0.7rem;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;">+30분</button>
                    <button type="button" onclick="setTimeOffset(60)" style="padding:3px 8px;font-size:0.7rem;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;">+1시간</button>
                </div>
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


<%@ include file="split-modal.jsp" %>
