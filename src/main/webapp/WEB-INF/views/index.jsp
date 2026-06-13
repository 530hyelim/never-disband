<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Never Disband</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#3f4147; border-radius:3px; }
        ::-webkit-scrollbar-thumb:hover { background:#5a6173; }
        body { font-family: 'Noto Sans KR', sans-serif; background: #1a1b1e; color: #e6edf3; min-height: 100vh; display: flex; flex-direction: column; }
        .top-header { padding: 24px 32px 0; display: flex; align-items: center; justify-content: space-between; }
        .logo { display: flex; align-items: center; gap: 10px; text-decoration: none; color: #fff; }
        .logo-placeholder { width: 28px; height: 28px; background: linear-gradient(135deg, #5865F2, #57F287); border-radius: 7px; }
        .logo-text { font-size: 0.9rem; font-weight: 900; letter-spacing: 0.5px; }
        .user-area { display: flex; align-items: center; gap: 12px; }
        .user-greeting { font-size: 0.85rem; color: #8b949e; font-weight: 400; }
        .user-greeting strong { color: #e6edf3; font-weight: 600; }
        .btn-logout { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; background: #21262d; border: 1px solid #30363d; border-radius: 8px; cursor: pointer; transition: all 0.2s ease; }
        .btn-logout:hover { border-color: #f85149; background: rgba(248, 81, 73, 0.1); }
        .btn-logout svg { width: 18px; height: 18px; fill: #8b949e; }
        .btn-logout:hover svg { fill: #f85149; }
        .main-content { flex: 1; padding: 40px 32px; max-width: 960px; margin: 0 auto; width: 100%; }
        /* 섹션 구분 */
        .section-divider { border: none; border-top: 1px solid #30363d; margin: 48px 0 32px; }
        .page-title { font-size: 1.6rem; font-weight: 700; margin-bottom: 8px; }
        .page-desc { font-size: 0.9rem; color: #8b949e; margin-bottom: 32px; }
        .action-bar { display: flex; gap: 12px; margin-bottom: 32px; }
        .btn-create { display: inline-flex; align-items: center; gap: 8px; padding: 12px 24px; background: #5865F2; color: #fff; border: none; border-radius: 10px; font-size: 0.9rem; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; }
        .btn-create:hover { background: #4752C4; transform: translateY(-1px); }
        .btn-join { display: inline-flex; align-items: center; gap: 8px; padding: 12px 24px; background: transparent; color: #e6edf3; border: 1px solid #30363d; border-radius: 10px; font-size: 0.9rem; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; }
        .btn-join:hover { border-color: #5865F2; color: #a5b4fc; transform: translateY(-1px); }
        .btn-icon { width: 18px; height: 18px; fill: currentColor; }
        .guild-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
        .guild-card { background: #21262d; border: 1px solid #30363d; border-radius: 14px; padding: 24px; transition: all 0.2s ease; cursor: pointer; text-decoration: none; color: inherit; display: block; }
        .guild-card:hover { border-color: #5865F2; transform: translateY(-3px); box-shadow: 0 8px 24px rgba(88, 101, 242, 0.15); }
        .guild-card-header { display: flex; align-items: center; gap: 14px; margin-bottom: 14px; }
        .guild-icon { width: 48px; height: 48px; border-radius: 12px; background: linear-gradient(135deg, #5865F2, #7289DA); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; font-weight: 700; color: #fff; flex-shrink: 0; }
        .guild-info h3 { font-size: 1rem; font-weight: 700; margin-bottom: 2px; }
        .guild-info p { font-size: 0.8rem; color: #8b949e; }
        .guild-meta { display: flex; gap: 16px; font-size: 0.78rem; color: #8b949e; }
        .guild-meta span { display: flex; align-items: center; gap: 4px; }
        .guild-meta svg { width: 14px; height: 14px; fill: #8b949e; }
        /* 모달 */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.7); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(4px); }
        .modal-overlay.active { display: flex; }
        .modal { background: #21262d; border: 1px solid #30363d; border-radius: 16px; padding: 40px 36px; max-width: 460px; width: 90%; position: relative; animation: modalIn 0.2s ease; }
        @keyframes modalIn { from { opacity: 0; transform: scale(0.95) translateY(10px); } to { opacity: 1; transform: scale(1) translateY(0); } }
        .modal-close { position: absolute; top: 16px; right: 16px; width: 32px; height: 32px; background: none; border: none; color: #8b949e; cursor: pointer; display: flex; align-items: center; justify-content: center; border-radius: 6px; transition: all 0.15s ease; }
        .modal-close:hover { background: #30363d; color: #e6edf3; }
        .modal-close svg { width: 20px; height: 20px; fill: currentColor; }
        .modal-title { font-size: 1.3rem; font-weight: 700; margin-bottom: 8px; }
        .modal-desc { font-size: 0.85rem; color: #8b949e; margin-bottom: 28px; line-height: 1.6; }
        .form-group { margin-bottom: 18px; }
        .form-label { display: block; font-size: 0.8rem; font-weight: 500; color: #8b949e; margin-bottom: 6px; }
        .form-input { width: 100%; padding: 11px 14px; background: #161b22; border: 1px solid #30363d; border-radius: 8px; color: #e6edf3; font-size: 0.9rem; font-family: inherit; outline: none; transition: border-color 0.2s ease; }
        .form-input:focus { border-color: #5865F2; }
        .form-hint { font-size: 0.72rem; color: #484f58; margin-top: 4px; }
        .btn-verify { width: 100%; padding: 13px; background: #5865F2; color: #fff; border: none; border-radius: 10px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.2s ease; font-family: inherit; margin-top: 8px; }
        .btn-verify:hover { background: #4752C4; }
        .btn-verify:disabled { background: #30363d; color: #484f58; cursor: not-allowed; }
        /* 검증 결과 */
        .verify-result { display: none; text-align: center; padding: 20px 0; }
        .verify-result.active { display: block; }
        .verify-spinner { width: 48px; height: 48px; border: 4px solid #30363d; border-top-color: #5865F2; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 16px; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .verify-spinner-text { font-size: 0.85rem; color: #8b949e; }
        .verify-icon { width: 56px; height: 56px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 14px; }
        .verify-icon.success { background: rgba(87, 242, 135, 0.1); }
        .verify-icon.fail { background: rgba(248, 81, 73, 0.1); }
        .verify-icon svg { width: 28px; height: 28px; }
        .verify-icon.success svg { fill: #57F287; }
        .verify-icon.fail svg { fill: #f85149; }
        .verify-title { font-size: 1rem; font-weight: 600; margin-bottom: 6px; }
        .verify-title.success { color: #57F287; }
        .verify-title.fail { color: #f85149; }
        .verify-msg { font-size: 0.82rem; color: #8b949e; line-height: 1.5; }
        .btn-confirm { width: 100%; padding: 13px; background: #57F287; color: #1a1b1e; border: none; border-radius: 10px; font-size: 0.9rem; font-weight: 700; cursor: pointer; transition: all 0.2s ease; font-family: inherit; margin-top: 20px; }
        .btn-confirm:hover { background: #3dd96e; }
        .btn-retry { width: 100%; padding: 13px; background: transparent; color: #8b949e; border: 1px solid #30363d; border-radius: 10px; font-size: 0.9rem; font-weight: 500; cursor: pointer; transition: all 0.2s ease; font-family: inherit; margin-top: 12px; }
        .btn-retry:hover { border-color: #5865F2; color: #a5b4fc; }
        /* 반응형 */
        @media (max-width: 640px) { .main-content { padding: 24px 16px; } .top-header { padding: 16px 16px 0; } .guild-grid { grid-template-columns: 1fr; } .action-bar { flex-direction: column; } .modal { padding: 28px 20px; } }
        /* 빌드 슬롯 */
        .slot-row { background: #161b22; border: 1px solid #30363d; border-radius: 10px; overflow: visible; min-height: fit-content; flex-shrink: 0; position:relative; z-index:1; }
        .slot-row:active { cursor:default; }
        .slot-row:not(.collapsed) { z-index:10; }
        .slot-drag-handle { cursor:grab; display:inline-flex; align-items:center; padding:2px; color:#5a6173; }
        .slot-drag-handle:active { cursor:grabbing; }
        .slot-drag-handle svg { width:12px; height:14px; fill:currentColor; }
        .slot-role-icon { display:inline-flex; align-items:center; cursor:pointer; position:relative; }
        .role-menu { display:none; position:fixed; background:#1e1f22; border:1px solid #3f4147; border-radius:8px; padding:4px 6px; box-shadow:0 4px 12px rgba(0,0,0,0.5); z-index:1200; white-space:nowrap; gap:4px; }
        .role-menu.active { display:flex; }
        .role-menu-item { cursor:pointer; border-radius:4px; padding:2px; transition:background 0.1s; }
        .role-menu-item:hover { background:#30363d; }
        .role-menu-item.selected { background:rgba(88,101,242,0.2); }
        .slot-header { display: flex; align-items: center; justify-content: space-between; padding: 8px 12px; cursor: pointer; }
        .slot-header:hover { background: #1c2128; }
        .slot-header-left { display: flex; align-items: center; gap: 10px; }
        .slot-collapse-arrow { font-size: 0.7rem; color: #8b949e; transition: transform 0.15s; }
        .slot-row.collapsed .slot-collapse-arrow { transform: rotate(-90deg); }
        .slot-row.collapsed .slot-body { display: none; }
        .slot-remove { background: none; border: none; color: #f85149; cursor: pointer; font-size: 0.78rem; font-weight: 500; padding: 4px 8px; border-radius: 4px; }
        .slot-remove:hover { background: rgba(248,81,73,0.1); }
        /* 슬롯 본체: 좌 이미지 + 우 드롭다운 */
        .slot-body { display: flex; gap: 12px; padding: 12px; position:absolute; top:100%; left:-1px; right:-1px; background:#161b22; border:1px solid #30363d; border-top:none; border-radius:0 0 10px 10px; z-index:20; overflow:hidden; }
        .slot-row:not(.collapsed) { border-radius:10px 10px 0 0; }
        .slot-icons { display: grid; grid-template-columns: repeat(3, 56px); grid-template-rows: repeat(3, 56px); gap: 6px; align-content: center; justify-content: center; }
        .slot-icon-cell { width: 56px; height: 56px; border-radius: 8px; background: #21262d; border: 1px solid #30363d; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: border-color 0.15s; position: relative; }
        .slot-icon-cell:hover { border-color: #5865F2; }
        .slot-icon-cell.active { border-color: #5865F2; box-shadow: 0 0 0 2px rgba(88,101,242,0.3); }
        .slot-icon-cell img { width: 48px; height: 48px; border-radius: 4px; }
        .slot-icon-cell .icon-label { position: absolute; bottom: -12px; font-size: 0.55rem; color: #8b949e; white-space: nowrap; }
        .slot-right { flex: 1; display: flex; flex-direction: column; position: relative; min-width:0; overflow:hidden; }
        .equip-field { position: relative; }
        .equip-field label { display: none; }
        /* 커스텀 드롭다운 트리거 */
        .equip-trigger { width: 100%; padding: 5px 10px; background: #21262d; border: 1px solid #30363d; border-radius: 6px; color: #e6edf3; font-size: 0.78rem; min-height: 28px; display: flex; align-items: center; }
        .equip-trigger input { background: none; border: none; color: #e6edf3; font-size: 0.78rem; font-family: inherit; outline: none; width: 100%; }
        .equip-trigger input::placeholder { color: #484f58; }
        .equip-trigger.open { border-color: #5865F2; border-radius: 6px 6px 0 0; }
        .equip-icon { display: none; }
        /* 드롭다운 패널 */
        .equip-dropdown { background: #1e1f22; border: 1px solid #5865F2; border-top: none; border-radius: 0 0 6px 6px; z-index: 200; display: none; max-height: 150px; flex-direction: column; overflow:hidden; }
        .equip-dropdown.active { display: flex; }
        .equip-dropdown .dd-list { flex: 1; overflow-y: auto; overflow-x:hidden; }
        .dd-group-header { padding: 6px 10px; font-size: 0.7rem; font-weight: 600; color: #8b949e; background: #21262d; cursor: pointer; display: flex; align-items: center; gap: 6px; position: sticky; top: 0; }
        .dd-group-header:hover { color: #e6edf3; }
        .dd-group-header .arrow { font-size: 0.6rem; transition: transform 0.15s; }
        .dd-group-header.expanded .arrow { transform: rotate(90deg); }
        .dd-group-items { display: none; }
        .dd-group-items.expanded { display: block; }
        .dd-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px 6px 20px; cursor: pointer; font-size: 0.78rem; color: #e6edf3; overflow:hidden; }
        .dd-item:hover { background: #30363d; }
        .dd-item img { width: 22px; height: 22px; border-radius: 3px; flex-shrink: 0; }
        .dd-item .dd-item-text { white-space:nowrap; display:inline-block; }
        .dd-item .dd-item-text.scrolling { animation:scrollText 3s linear 0.3s forwards; }
        @keyframes scrollText { 0% { transform:translateX(0); } 100% { transform:translateX(calc(-100% + 80px)); } }
        .dd-item.hidden { display: none; }
        /* 빌드 카드 */
        .comp-card { background: #21262d; border: 1px solid #30363d; border-radius: 14px; padding: 20px; transition: all 0.2s ease; }
        .comp-card:hover { border-color: #5865F2; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(88,101,242,0.12); }
        .comp-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
        .comp-card-name { font-size: 0.95rem; font-weight: 700; }
        .comp-card-actions { display: flex; gap: 6px; }
        .comp-card-btn { background: none; border: none; color: #8b949e; cursor: pointer; padding: 4px; border-radius: 4px; }
        .comp-card-btn:hover { background: #30363d; color: #e6edf3; }
        .comp-card-btn svg { width: 16px; height: 16px; fill: currentColor; }
        .comp-card-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; }
        .pub-badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 12px; font-size: 0.72rem; font-weight: 500; }
        .pub-badge.pub-public { background: rgba(87,242,135,0.12); color: #57F287; }
        .pub-badge.pub-private { background: rgba(254,231,92,0.12); color: #FEE75C; }
        .slot-count { font-size: 0.78rem; color: #8b949e; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
        .slot-count svg { width: 14px; height: 14px; fill: #8b949e; }
    </style>
</head>
<body>
    <header class="top-header">
        <a href="/" class="logo">
            <div class="logo-placeholder"></div>
            <span class="logo-text">NEVER DISBAND</span>
        </a>
        <div class="user-area">
            <span class="user-greeting">안녕하세요, <strong><%= session.getAttribute("user_name") != null ? session.getAttribute("user_name") : "Guest" %></strong> 님</span>
            <form action="/logout" method="post" style="margin:0;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button type="submit" class="btn-logout" title="로그아웃">
                    <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
                </button>
            </form>
        </div>
    </header>

    <main class="main-content">
        <h1 class="page-title">내 길드</h1>
        <p class="page-desc">참여 중인 길드를 선택하거나, 새로운 길드를 만들어 보세요.</p>

        <div class="action-bar">
            <a href="/guild/create" class="btn-create">
                <svg class="btn-icon" viewBox="0 0 24 24"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                길드 등록
            </a>
            <a href="#" class="btn-join" onclick="openJoinModal(); return false;">
                <svg class="btn-icon" viewBox="0 0 24 24"><path d="M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-2V7H4v3H1v2h3v3h2v-3h3v-2H6zm9 4c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                길드 참여
            </a>
        </div>

        <div class="guild-grid">
            <c:choose>
                <c:when test="${not empty guilds}">
                    <c:forEach var="guild" items="${guilds}">
                        <a href="/${guild.subdomain}/main" class="guild-card">
                            <div class="guild-card-header">
                                <div class="guild-icon">${guild.name.substring(0, 1).toUpperCase()}</div>
                                <div class="guild-info">
                                    <h3><c:out value="${guild.displayName}" /></h3>
                                    <c:if test="${not empty guild.myCharacterName}">
                                        <p style="color:#a5b4fc;font-size:0.82rem;"><c:out value="${guild.myCharacterName}" /></p>
                                    </c:if>
                                </div>
                            </div>
                            <div class="guild-meta" style="justify-content:space-between;">
                                <c:if test="${not empty guild.founded}">
                                    <span><svg viewBox="0 0 24 24" style="width:12px;height:12px;fill:#8b949e;vertical-align:middle;margin-right:2px;"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg>Since. ${guild.founded.substring(0, 10)}</span>
                                </c:if>
                                <span><svg viewBox="0 0 24 24" style="width:12px;height:12px;fill:#8b949e;vertical-align:middle;margin-right:2px;"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>${guild.registeredMemberCount} / ${guild.memberCount} 참여중</span>
                            </div>
                        </a>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="color: #8b949e; font-size: 0.9rem;">참여 중인 길드가 없습니다. 길드를 생성하거나 참여해보세요.</p>
                </c:otherwise>
            </c:choose>
        </div>

    <!-- 내 빌드 섹션 -->
    <c:if test="${not empty guilds}">
    <hr class="section-divider">
    <h1 class="page-title">내 빌드</h1>
    <p class="page-desc">빌드 조합을 미리 만들어두고 파티 모집 시 바로 사용하세요.</p>

    <div class="action-bar">
        <button class="btn-create" onclick="openCompModal()">
            <svg class="btn-icon" viewBox="0 0 24 24"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
            빌드 생성
        </button>
    </div>

    <div class="guild-grid" id="compGrid">
        <p style="color: #8b949e; font-size: 0.9rem;">불러오는 중...</p>
    </div>
    </c:if>
    </main>

    <!-- 빌드 편집 모달 -->
    <div class="modal-overlay" id="compModal">
        <div class="modal" style="max-width:820px;max-height:85vh;overflow:hidden;">
            <button class="modal-close" onclick="closeCompModal()">
                <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
            </button>
            <h2 class="modal-title" id="compModalTitle">새 빌드 만들기</h2>
            <p class="modal-desc">빌드 이름을 입력하고 슬롯을 추가하세요. 각 슬롯에 역할과 장비를 지정합니다.</p>

            <div class="form-group">
                <label class="form-label">빌드 이름</label>
                <input type="text" class="form-input" id="compNameInput" placeholder="예: ZvZ 메인 조합">
            </div>

            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <!-- <label class="form-label" style="margin-bottom:0;">공개</label> -->
                <label class="toggle" style="margin-top:2px;">
                    <input type="checkbox" id="compPublicInput">
                    <span class="toggle-slider"></span>
                </label>
                <span style="font-size:0.75rem;color:#8b949e;">길드원에게 공유</span>
            </div>

            <div style="display:flex;align-items:center;justify-content:space-between;margin:20px 0 10px;">
                <span style="font-size:0.85rem;font-weight:600;">슬롯 목록</span>
                <button class="btn-create" style="padding:6px 14px;font-size:0.78rem;border-radius:8px;" onclick="addSlotRow()">
                    <svg class="btn-icon" viewBox="0 0 24 24" style="width:14px;height:14px;"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                    슬롯 추가
                </button>
            </div>

            <div id="slotContainer" style="display:grid;grid-template-columns:1fr 1fr;gap:8px;overflow-x:hidden;overflow-y:auto;max-height:340px;min-height:250px;padding-right:4px;align-items:start;align-content:start;"></div>
            <div id="slotPager" style="display:flex;align-items:center;justify-content:center;gap:8px;margin-top:10px;font-size:0.78rem;color:#8b949e;"></div>

            <div style="display:flex;justify-content:center;">
                <button class="btn-verify" style="width:100px;height:40px;margin-top:10px;padding:0;" onclick="saveComposition()">저장</button>
            </div>
        </div>
    </div>

    <!-- 길드 등록 모달 -->
    <div class="modal-overlay" id="guildModal">
        <div class="modal">
            <button class="modal-close" onclick="closeModal()">
                <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
            </button>

            <!-- Step 1: 입력 폼 -->
            <div id="stepForm">
                <h2 class="modal-title">길드 등록</h2>
                <p class="modal-desc">알비온 온라인 길드명과 본인 캐릭터명을 입력하세요.<br>길드 존재 여부와 소속을 확인합니다.</p>

                <div class="form-group">
                    <label class="form-label">길드명</label>
                    <input type="text" class="form-input" id="guildNameInput" placeholder="정확한 길드명을 입력하세요">
                    <p class="form-hint">알비온 온라인 내 길드 이름 (대소문자 구분)</p>
                </div>

                <div class="form-group">
                    <label class="form-label">캐릭터명</label>
                    <input type="text" class="form-input" id="charNameInput" placeholder="본인 캐릭터명을 입력하세요">
                    <p class="form-hint">해당 길드에 가입되어 있는 캐릭터여야 합니다</p>
                </div>

                <button class="btn-verify" id="btnVerify" onclick="verifyGuild()">확인</button>
            </div>

            <!-- Step 2: 로딩 -->
            <div id="stepLoading" class="verify-result">
                <div class="verify-spinner"></div>
                <p class="verify-spinner-text">길드 정보를 확인하고 있습니다...</p>
            </div>

            <!-- Step 3: 성공 -->
            <div id="stepSuccess" class="verify-result">
                <div class="verify-icon success">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
                <p class="verify-title success">확인 완료</p>
                <p class="verify-msg" id="successMsg">길드와 캐릭터 소속이 확인되었습니다.</p>

                <form action="/guild/create/confirm" method="post" id="guildCreateForm">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <input type="hidden" name="discordGuildId" id="hiddenDiscordGuildId" value="<%= session.getAttribute("guild_create_discord_guild_id") != null ? session.getAttribute("guild_create_discord_guild_id") : "" %>">
                    <input type="hidden" name="albionGuildId" id="hiddenAlbionGuildId" value="">
                    <input type="hidden" name="guildName" id="hiddenGuildName" value="">
                    <input type="hidden" name="characterName" id="hiddenCharName" value="">
                    <button type="submit" class="btn-confirm">길드 등록</button>
                </form>
                <button class="btn-retry" onclick="closeModal()">취소</button>
            </div>

            <!-- Step 4: 실패 -->
            <div id="stepFail" class="verify-result">
                <div class="verify-icon fail">
                    <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
                <p class="verify-title fail" id="failTitle">확인 실패</p>
                <p class="verify-msg" id="failMsg">길드를 찾을 수 없거나 캐릭터가 소속되어 있지 않습니다.</p>
                <a href="/guild/create" class="btn-retry" id="failBtnPrimary" style="display:none;">봇 다시 초대하기</a>
                <button class="btn-retry" id="failBtnRetry" onclick="resetModal()">다시 입력</button>
            </div>
        </div>
    </div>

    <!-- 길드 참여 모달 -->
    <div class="modal-overlay" id="joinModal">
        <div class="modal" style="max-width:460px;">
            <button class="modal-close" onclick="closeJoinModal()">
                <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
            </button>

            <!-- Step 1: 입력 폼 -->
            <div id="joinStepForm">
                <h2 class="modal-title">길드 참여</h2>
                <p class="modal-desc">참여할 길드명과 본인 캐릭터명을 입력하세요.<br>디스코드 서버 참여 여부와 캐릭터 존재 여부를 확인합니다.</p>

                <div class="form-group">
                    <label class="form-label">길드명</label>
                    <input type="text" class="form-input" id="joinGuildNameInput" placeholder="정확한 길드명을 입력하세요">
                    <p class="form-hint">알비온 온라인 내 길드 이름 (대소문자 구분)</p>
                </div>

                <div class="form-group">
                    <label class="form-label">캐릭터명</label>
                    <input type="text" class="form-input" id="joinCharNameInput" placeholder="본인 캐릭터명을 입력하세요">
                    <p class="form-hint">알비온 온라인 인게임 캐릭터명 (대소문자 구분)</p>
                </div>

                <button class="btn-verify" onclick="verifyJoin()">확인</button>
            </div>

            <!-- Step 2: 로딩 -->
            <div id="joinStepLoading" class="verify-result">
                <div class="verify-spinner"></div>
                <p class="verify-spinner-text">정보를 확인하고 있습니다...</p>
            </div>

            <!-- Step 3: 성공 (길드 정보 표시 + 참여 버튼) -->
            <div id="joinStepSuccess" class="verify-result">
                <div class="verify-icon success">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
                <p class="verify-title success">확인 완료</p>
                <p class="verify-msg" id="joinSuccessMsg"></p>
                <button class="btn-confirm" onclick="submitJoin()">참여</button>
                <button class="btn-retry" onclick="resetJoinModal()">취소</button>
            </div>

            <!-- Step 4: 실패 -->
            <div id="joinStepFail" class="verify-result">
                <div class="verify-icon fail">
                    <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
                <p class="verify-title fail">확인 실패</p>
                <p class="verify-msg" id="joinFailMsg"></p>
                <button class="btn-retry" onclick="resetJoinModal()">다시 입력</button>
            </div>
        </div>
    </div>

    <script>
        // URL 파라미터로 모달 자동 오픈 및 알림 처리
        (function() {
            var params = new URLSearchParams(window.location.search);

            if (params.get('error')) {
                alert(decodeURIComponent(params.get('error')));
                history.replaceState(null, '', '/');
            }
            if (params.get('success')) {
                alert(decodeURIComponent(params.get('success')));
                history.replaceState(null, '', '/');
            }
            if (params.get('guildCreate') === 'true') {
                openModal();
                history.replaceState(null, '', '/');
            }
            // 소유자 검증 실패 시 모달로 에러 표시
            if (params.get('ownerFail') === 'true') {
                openModal();
                showOwnerFail();
                history.replaceState(null, '', '/');
            }
            // 길드 참여 유도 (서브도메인 접근 시 멤버가 아닌 경우)
            if (params.get('joinGuild')) {
                var guildName = decodeURIComponent(params.get('joinGuild'));
                openJoinModal();
                document.getElementById('joinGuildNameInput').value = guildName;
                history.replaceState(null, '', '/');
            }
        })();

        function openModal() {
            document.getElementById('guildModal').classList.add('active');
            resetModal();
        }

        function closeModal() {
            document.getElementById('guildModal').classList.remove('active');
        }

        function resetModal() {
            document.getElementById('stepForm').style.display = 'block';
            document.getElementById('stepLoading').classList.remove('active');
            document.getElementById('stepSuccess').classList.remove('active');
            document.getElementById('stepFail').classList.remove('active');
        }

        // 모달 외부 클릭 시 닫기 (드래그 보호)
        (function() {
            var guildModal = document.getElementById('guildModal');
            var mouseDownOnOverlay = false;
            guildModal.addEventListener('mousedown', function(e) { mouseDownOnOverlay = (e.target === guildModal); });
            guildModal.addEventListener('mouseup', function(e) { if (mouseDownOnOverlay && e.target === guildModal) closeModal(); mouseDownOnOverlay = false; });
        })();

        function showOwnerFail() {
            document.getElementById('stepForm').style.display = 'none';
            document.getElementById('failTitle').textContent = '소유자 검증 실패';
            document.getElementById('failMsg').textContent = '디스코드 서버의 소유자만 길드를 생성할 수 있습니다. 본인 소유의 서버에 봇을 초대해주세요.';
            document.getElementById('failBtnPrimary').style.display = 'block';
            document.getElementById('failBtnRetry').style.display = 'none';
            document.getElementById('stepFail').classList.add('active');
        }

        function showVerifyFail(msg) {
            document.getElementById('failTitle').textContent = '확인 실패';
            document.getElementById('failMsg').textContent = msg;
            document.getElementById('failBtnPrimary').style.display = 'none';
            document.getElementById('failBtnRetry').style.display = 'block';
            document.getElementById('stepFail').classList.add('active');
        }

        function verifyGuild() {
            var guildName = document.getElementById('guildNameInput').value.trim();
            var charName = document.getElementById('charNameInput').value.trim();

            if (!guildName || !charName) {
                alert('길드명과 캐릭터명을 모두 입력해주세요.');
                return;
            }

            // 입력폼 숨기고 로딩 표시
            document.getElementById('stepForm').style.display = 'none';
            document.getElementById('stepLoading').classList.add('active');

            // 백엔드 API 호출
            fetch('/guild/verify?guildName=' + encodeURIComponent(guildName) + '&characterName=' + encodeURIComponent(charName))
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    document.getElementById('stepLoading').classList.remove('active');

                    if (data.success) {
                        document.getElementById('successMsg').textContent =
                            '길드 "' + data.guildName + '"에서 캐릭터 "' + charName + '"의 소속이 확인되었습니다.';
                        document.getElementById('hiddenAlbionGuildId').value = data.albionGuildId || '';
                        document.getElementById('hiddenGuildName').value = data.guildName || guildName;
                        document.getElementById('hiddenCharName').value = charName;
                        document.getElementById('stepSuccess').classList.add('active');
                    } else {
                        showVerifyFail(data.message || '길드를 찾을 수 없거나 캐릭터가 소속되어 있지 않습니다.');
                    }
                })
                .catch(function(err) {
                    document.getElementById('stepLoading').classList.remove('active');
                    showVerifyFail('서버와 통신 중 오류가 발생했습니다.');
                });
        }

        // ===== 길드 참여 모달 =====
        var joinSelectedGuildId = null;
        var joinSelectedCharName = null;

        function openJoinModal() {
            document.getElementById('joinModal').classList.add('active');
            resetJoinModal();
        }

        function closeJoinModal() {
            document.getElementById('joinModal').classList.remove('active');
        }

        function resetJoinModal() {
            document.getElementById('joinStepForm').style.display = 'block';
            document.getElementById('joinStepLoading').classList.remove('active');
            document.getElementById('joinStepSuccess').classList.remove('active');
            document.getElementById('joinStepFail').classList.remove('active');
            document.getElementById('joinGuildNameInput').value = '';
            document.getElementById('joinCharNameInput').value = '';
            joinSelectedGuildId = null;
            joinSelectedCharName = null;
        }

        // joinModal 외부 클릭 시 닫기 (드래그 보호)
        (function() {
            var joinModal = document.getElementById('joinModal');
            var mouseDownOnOverlay = false;
            joinModal.addEventListener('mousedown', function(e) { mouseDownOnOverlay = (e.target === joinModal); });
            joinModal.addEventListener('mouseup', function(e) { if (mouseDownOnOverlay && e.target === joinModal) closeJoinModal(); mouseDownOnOverlay = false; });
        })();

        function verifyJoin() {
            var guildName = document.getElementById('joinGuildNameInput').value.trim();
            var charName = document.getElementById('joinCharNameInput').value.trim();

            if (!guildName || !charName) {
                alert('길드명과 캐릭터명을 모두 입력해주세요.');
                return;
            }

            document.getElementById('joinStepForm').style.display = 'none';
            document.getElementById('joinStepLoading').classList.add('active');

            fetch('/guild/join/verify?guildName=' + encodeURIComponent(guildName) + '&characterName=' + encodeURIComponent(charName))
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    document.getElementById('joinStepLoading').classList.remove('active');

                    if (data.success) {
                        joinSelectedGuildId = data.guildId;
                        joinSelectedCharName = charName;
                        document.getElementById('joinSuccessMsg').textContent =
                            '길드 "' + data.guildName + '" (참여자 ' + data.memberCount + '명)\n캐릭터 "' + charName + '"으로 가입 신청합니다.';
                        document.getElementById('joinStepSuccess').classList.add('active');
                    } else {
                        document.getElementById('joinFailMsg').textContent = data.message;
                        document.getElementById('joinStepFail').classList.add('active');
                    }
                })
                .catch(function() {
                    document.getElementById('joinStepLoading').classList.remove('active');
                    document.getElementById('joinFailMsg').textContent = '서버와 통신 중 오류가 발생했습니다.';
                    document.getElementById('joinStepFail').classList.add('active');
                });
        }

        function submitJoin() {
            if (!joinSelectedGuildId || !joinSelectedCharName) return;

            fetch('/guild/join', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'guildId=' + joinSelectedGuildId + '&characterName=' + encodeURIComponent(joinSelectedCharName) + '&${_csrf.parameterName}=${_csrf.token}'
            })
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.success) {
                    location.href = '/' + data.subdomain + '/main';
                } else {
                    document.getElementById('joinStepSuccess').classList.remove('active');
                    document.getElementById('joinFailMsg').textContent = data.message;
                    document.getElementById('joinStepFail').classList.add('active');
                }
            })
            .catch(function() {
                alert('서버와 통신 중 오류가 발생했습니다.');
            });
        }

        // ===== 내 빌드 =====
        var editingCompId = null;
        var slotCounter = 0;
        var RENDER_URL = 'https://render.albiononline.com/v1/item/';

        function openCompModal(compId) {
            editingCompId = compId || null;
            document.getElementById('compModalTitle').textContent = compId ? '빌드 수정' : '새 빌드 만들기';
            document.getElementById('compNameInput').value = '';
            document.getElementById('compPublicInput').checked = false;
            document.getElementById('slotContainer').innerHTML = '';
            document.getElementById('slotPager').innerHTML = '';
            slotCounter = 0;
            slotCurrentPage = 0;

            if (compId) {
                fetch('/api/compositions/' + compId)
                    .then(function(r) { return r.json(); })
                    .then(function(comp) {
                        document.getElementById('compNameInput').value = comp.name;
                        document.getElementById('compPublicInput').checked = comp.isPublic;

                        var allNames = [];
                        (comp.slots || []).forEach(function(slot) {
                            ['weapon','offhand','head','chest','shoes','cape','food'].forEach(function(eq) {
                                if (slot[eq]) allNames.push(slot[eq]);
                            });
                        });

                        if (allNames.length > 0) {
                            fetch('/api/items/names', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json', '${_csrf.headerName}': '${_csrf.token}' },
                                body: JSON.stringify(allNames)
                            })
                            .then(function(r2) { return r2.json(); })
                            .then(function(nameMap) {
                                (comp.slots || []).forEach(function(slot) {
                                    slot._nameMap = nameMap;
                                    addSlotRow(slot);
                                });
                                collapseAllSlots();
                            });
                        } else {
                            (comp.slots || []).forEach(function(slot) { addSlotRow(slot); });
                            collapseAllSlots();
                        }
                    });
            } else {
                // 새 빌드: 슬롯 하나 기본 추가
                addSlotRow(null);
            }

            document.getElementById('compModal').classList.add('active');
        }

        function closeCompModal() {
            document.getElementById('compModal').classList.remove('active');
        }

        // compModal 외부 클릭 시 닫기 (드래그 보호)
        (function() {
            var compModal = document.getElementById('compModal');
            var mouseDownOnOverlay = false;
            compModal.addEventListener('mousedown', function(e) { mouseDownOnOverlay = (e.target === compModal); });
            compModal.addEventListener('mouseup', function(e) { if (mouseDownOnOverlay && e.target === compModal) closeCompModal(); mouseDownOnOverlay = false; });
        })();

        function addSlotRow(data) {
            slotCounter++;
            var idx = slotCounter;
            var role = data ? data.role : 'OFF_TANK';
            var equips = ['weapon', 'offhand', 'head', 'chest', 'shoes', 'cape', 'food'];
            var labels = ['무기', '보조', '머리', '갑옷', '신발', '망토', '음식'];
            // 아이콘 그리드: row1(빈, head, cape), row2(weapon, chest, offhand), row3(빈, shoes, food)
            var gridOrder = ['', 'head', 'cape', 'weapon', 'chest', 'offhand', '', 'shoes', 'food'];

            var dbIdAttr = data && data.id ? ' data-db-id="' + data.id + '"' : '';
            var html = '<div class="slot-row" id="slot-' + idx + '"' + dbIdAttr + ' ondragover="slotDragOver(event)" ondrop="slotDrop(event,' + idx + ')" ondragend="slotDragEnd(event)">'
                + '<div class="slot-header" onclick="toggleSlotCollapse(' + idx + ', event)">'
                + '<div class="slot-header-left">'
                + '<span class="slot-drag-handle" draggable="true" ondragstart="slotDragStart(event,' + idx + ')" onclick="event.stopPropagation()"><svg viewBox="0 0 10 14"><circle cx="3" cy="2" r="1.5"/><circle cx="7" cy="2" r="1.5"/><circle cx="3" cy="7" r="1.5"/><circle cx="7" cy="7" r="1.5"/><circle cx="3" cy="12" r="1.5"/><circle cx="7" cy="12" r="1.5"/></svg></span>'
                + '<span class="slot-collapse-arrow">▼</span>'
                + '<span class="slot-num" style="font-size:0.8rem;font-weight:600;color:#e6edf3;">#' + idx + '</span>'
                + '<span class="slot-role-icon" id="role-icon-' + idx + '" onclick="event.stopPropagation();toggleRoleMenu(' + idx + ', this)">' + getRoleIcon(role) + '</span>'
                + '<span class="slot-weapon-name" id="slot-weapon-name-' + idx + '" style="font-size:0.75rem;color:#8b949e;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:200px;">' + (data && data._nameMap && data.weapon && data._nameMap[data.weapon] ? escapeAttr(data._nameMap[data.weapon]) : (data && data.weapon ? escapeAttr(data.weapon) : '')) + '</span>'
                + '<input type="hidden" class="slot-role-value" data-slot="' + idx + '" value="' + role + '">'
                + '</div>'
                + '<div style="display:flex;gap:4px;">'
                + '<button class="slot-remove" style="color:#8b949e;" onclick="event.stopPropagation();duplicateSlot(' + idx + ')">복사</button>'
                + '<button class="slot-remove" onclick="event.stopPropagation();removeSlot(' + idx + ')">삭제</button>'
                + '</div>'
                + '</div>'
                + '<div class="slot-body">'
                + '<div class="slot-icons">';

            gridOrder.forEach(function(eq) {
                if (!eq) {
                    html += '<div style="width:70px;height:70px;"></div>';
                } else {
                    var val = data ? (data[eq] || '') : '';
                    var iconSrc = val ? RENDER_URL + encodeURIComponent(val) + '.png?size=64' : '';
                    var labelIdx = equips.indexOf(eq);
                    html += '<div class="slot-icon-cell" id="icell-' + idx + '-' + eq + '" onclick="activateEquip(\'' + idx + '\',\'' + eq + '\')">'
                        + (iconSrc ? '<img src="' + iconSrc + '" loading="lazy">' : '')
                        // + '<span class="icon-label">' + labels[labelIdx] + '</span>'
                        + '</div>';
                }
            });

            html += '</div><div class="slot-right">';

            equips.forEach(function(eq, i) {
                var val = data ? (data[eq] || '') : '';
                var displayVal = val;
                if (val && data && data._nameMap && data._nameMap[val]) {
                    displayVal = data._nameMap[val];
                }
                html += '<div class="equip-field" id="eqfield-' + idx + '-' + eq + '" style="display:none;">'
                    + '<input type="hidden" data-slot="' + idx + '" data-equip="' + eq + '" value="' + escapeAttr(val) + '">'
                    + '<div class="equip-trigger" id="trigger-' + idx + '-' + eq + '">'
                    + '<input type="text" placeholder="' + labels[i] + ' 선택 또는 검색..." value="' + escapeAttr(displayVal) + '" onfocus="openEquipDD(\'' + idx + '\',\'' + eq + '\')" oninput="filterDD(\'' + idx + '\',\'' + eq + '\',this.value)">'
                    + '</div>'
                    + '<div class="equip-dropdown" id="dd-' + idx + '-' + eq + '">'
                    + '<div class="dd-list" id="ddlist-' + idx + '-' + eq + '"></div>'
                    + '</div>'
                    + '</div>';
            });

            html += '</div></div></div>';
            document.getElementById('slotContainer').insertAdjacentHTML('beforeend', html);
            // 새 슬롯은 접힌 상태로 추가, 무기 활성화 (드롭다운 닫힌 상태)
            var newSlot = document.getElementById('slot-' + idx);
            if (newSlot) newSlot.classList.add('collapsed');
            activateEquip(idx, 'weapon');
            // 마지막 페이지로 이동
            var totalSlots = document.getElementById('slotContainer').querySelectorAll('.slot-row').length;
            slotCurrentPage = Math.ceil(totalSlots / slotPageSize) - 1;
            renumberSlots();
            // 스크롤 맨 아래
            var container = document.getElementById('slotContainer');
            container.scrollTop = container.scrollHeight;
        }

        function removeSlot(idx) {
            var el = document.getElementById('slot-' + idx);
            if (el) el.remove();
            renumberSlots();
        }

        function duplicateSlot(idx) {
            var row = document.getElementById('slot-' + idx);
            if (!row) return;
            var role = row.querySelector('.slot-role-value').value;
            var data = { role: role, _nameMap: {} };
            ['weapon','offhand','head','chest','shoes','cape','food'].forEach(function(eq) {
                var inp = row.querySelector('input[data-equip="' + eq + '"]');
                data[eq] = inp ? inp.value : '';
                // trigger input에서 display name 가져오기
                var triggerEl = document.getElementById('trigger-' + idx + '-' + eq);
                if (triggerEl) {
                    var tInput = triggerEl.querySelector('input[type="text"]');
                    if (tInput && tInput.value && data[eq]) data._nameMap[data[eq]] = tInput.value;
                }
            });
            addSlotRow(data);
        }

        var ROLE_ICONS = {
            OFF_TANK: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#2980b9"/><g transform="translate(64,64)"><path d="M256 80l-130 65v110c0 95 55 170 130 190 75-20 130-95 130-190V145L256 80z" fill="#7ec8f2"/></g></svg>',
            DEF_TANK: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#2980b9"/><g transform="translate(64,64)"><path d="M256 80l-130 65v110c0 95 55 170 130 190 75-20 130-95 130-190V145L256 80z" fill="#7ec8f2"/></g></svg>',
            MDPS: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#c0392b"/><g transform="translate(64,64)"><path d="M124.812 388.907a60.718 60.718 0 0 0 16.564 11.588L107.28 435.07a48.756 48.756 0 0 0-28.35-28.006l34.16-34.576a61.093 61.093 0 0 0 11.722 16.42zm209.598-276.44c-32.754 33.14-57.813 79.127-103.008 124.853-9.13 9.245-40.292 37.355-58.303 53.555l49.223 48.64c15.98-18.24 43.727-49.744 52.858-58.978 45.154-45.726 90.828-71.39 123.57-104.477C452.683 121.485 481 28.492 481 28.492s-92.67 29.4-146.59 83.976zM83.656 430.594a30.92 30.92 0 1 0 .26 43.727 30.817 30.817 0 0 0-.26-43.727zm91.13-40.603c11.16 0 20.822-2.81 24.497-6.56l20.885-21.103-69.88-69.047-20.823 21.135c-7.964 8.068-11.233 43.06 7.85 61.905 10.12 10.026 24.79 13.66 37.47 13.66z" fill="#f1c40f"/></g></svg>',
            RDPS: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#d35400"/><g transform="translate(64,64)"><path d="m492.656 20.406-118.594 56.22L413.875 86l-86.97 86.97-305.5 259.374.69.687 104.75-47.467-46.376 105.843.905.906 272.5-319.875 73.22-73.218 9.342 39.81 56.22-118.624zm-473.25.063c-1.347 23.43 5 39.947 16.563 52.218l24.093 302.28 17.562-14.874-21.72-272.438C113.879 119.609 225 112.82 272.811 194.375l66.625-56.564 1.22-1.218C292.74 38.666 86.01 99.716 19.406 20.47zm359.531 151.56-1.156 1.157-57.25 67.188c82.006 47.945 75.587 159.267 107.283 218.03l-272.157-24.5-14.812 17.408 301.562 27.125c12.48 12.283 29.4 19.084 53.688 17.687-79.95-67.2-18.36-275.754-117.156-324.094z" fill="#f1c40f"/></g></svg>',
            HEALER: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#27ae60"/><g transform="translate(64,64)"><path d="M389.917 128.73v100.836h-22.802v-158.5a17.11 17.11 0 0 0-17.11-17.11h-11.863a17.11 17.11 0 0 0-17.11 17.11v158.5h-22.698V46.993a17.11 17.11 0 0 0-17.11-17.11h-11.863a17.11 17.11 0 0 0-17.11 17.11v182.573H229.5V77.33a17.11 17.11 0 0 0-17.108-17.11h-11.864a17.11 17.11 0 0 0-17.11 17.11v263.873l-63.858-51.14a23.385 23.385 0 0 0-30.743 1.32l-5.567 5.31a23.385 23.385 0 0 0-2.01 31.678l102.19 125.647a72.028 72.028 0 0 0 57.092 28.1h60.85A134.637 134.637 0 0 0 436 347.5V128.73a17.11 17.11 0 0 0-17.11-17.108h-11.864a17.11 17.11 0 0 0-17.11 17.11z" fill="#90f5a8"/></g></svg>',
            SUPPORT: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#f5c518"/><g transform="translate(64,64) scale(-1,1) translate(-512,0)"><path d="M356.688 19.188c-6.83-.032-12.837.64-18.125 1.843-24.178 5.495-36.437 21.983-50.938 41.157-14.5 19.175-31.317 40.993-62.78 47.47C195.08 115.78 154.27 108.253 91.25 78.5c-10.013 44.88-33.406 128.62-60.906 178.656 60.093 28.5 97.245 34.926 121 30.875.01 0 .02.004.03 0 21.59-5.827 34.487-20.094 47.876-43.092 17.014-29.227 32.563-72.198 60.25-123.188l16.406 8.938c-16.69 30.735-28.802 58.617-40 82.937 8.552-6.512 18.633-11.77 31.063-14.594 27.71-6.296 65.053-.495 121.655 24.75-6.932-29.276-1.885-61.913 9.875-92.218 12.686-32.69 33.038-62.907 56.28-84.03-42.595-19.553-73.152-27.554-95.124-28.282-1.01-.033-1.993-.058-2.97-.063zm127.54 14.144a10.775 10.775 0 0 0-2.664.266c-4.378.977-8.94 4.424-12.084 11.097L289.53 497.31h23.61L490.972 49.368c3.475-10.153-.75-15.86-6.746-16.035z" fill="#d35400"/></g></svg>',
            BATTLEMOUNT: '<svg viewBox="0 0 640 640" width="22" height="22"><rect width="640" height="640" rx="80" fill="#2c3e50" stroke="#1a1a1a" stroke-width="20"/><rect x="50" y="50" width="540" height="540" rx="60" fill="#7f8c8d"/><g transform="translate(64,64)"><path d="M400 16c-21.335 9.73-58.244 17.34-73.086 48.232-22.36 1.948-72.753 10.673-122.22 40.25-58.098 34.74-116.017 97.417-131.776 213.702l-.48 3.537-2.774 2.25c-30.87 25.002-40.657 38.937-44.416 61.153-3.536 20.9-.72 51.46-.363 101.877H328.36c3.455-16.892 10.44-29.245 12.472-41.568 2.337-14.176.19-29.938-20.812-58.547-43.078-58.683-46.853-129.458-12.916-171.28-8.654-2.765-15.09-6.887-19.458-12.546-6.115-7.924-7.4-17.006-8.57-25.884l17.848-2.352c1.112 8.446 2.38 13.88 4.97 17.237 2.59 3.356 7.31 6.472 19.55 8.46l-.022.128.172-.17 5.998 9.424c19.957 31.358 42.84 51.292 73.332 54.44l6.51.672 1.367 6.4c2.74 12.828 8.626 19.095 15.116 22.238 6.49 3.143 14.225 2.944 20.47.205 9.316-4.086 14.518-11.35 16.7-22.712 2.122-11.05.546-25.834-5.137-42.106-33.538-38.248-44.475-87.277-63.903-128.772-6.055-9.947-12.448-18.518-20.385-24.856C376.808 55.126 386.456 34.852 400 16zM214.068 34.97C179.55 35.06 146.075 43.06 96 58.58c31.146 9.92 70.397 18.9 86.037 39.01 4.463-3.017 8.94-5.88 13.418-8.56 40.51-24.22 80.387-35.286 108.23-40.04-35.854-9.477-63.047-14.094-89.617-14.023zM157.16 96.712c-1.13-.01-2.265-.01-3.402.004-30.353.37-63.1 9.745-96.647 31.283 27.186 3.672 54.67 3.724 72.58 15.398 15.9-17.92 33.144-32.634 50.677-44.668a151.904 151.904 0 0 0-23.207-2.017zM368 128a13.214 13.215 0 0 1 13.213 13.215A13.214 13.215 0 0 1 368 154.432a13.214 13.215 0 0 1-13.213-13.217A13.214 13.215 0 0 1 368 128zm-238.906 16.068c-36.395 1.495-68.903 6.53-104.76 24.766 33.236 7.095 50.913 13.507 65.025 33.83 11.522-22.53 25.045-41.93 39.734-58.596zM74.518 201.46C53.53 201.65 36.614 213.14 16 224c27.854 0 46.067 3.862 58.71 12.055 4.33-11.652 9.16-22.615 14.41-32.924-5.12-1.19-9.963-1.71-14.602-1.67zm-.623 36.82c-17.933 5.845-35.452 7.15-54.23 22.284 17.62 4.638 34.79 9.596 41.398 22.034 3.496-15.77 7.814-30.523 12.832-44.32zm370.142 8.57a42.449 42.449 0 0 1 4.783.187l-1.64 17.926c-3.928-.36-5.513.416-5.57.465-.058.048-1.035.656-.635 5.886l-17.95 1.372c-.638-8.35 1.297-16.207 6.955-20.997 4.245-3.593 9.206-4.735 14.057-4.84zM52.215 290.723c-10.352.13-23.76 5.646-34.656 12.334 12.173 6.83 12.357 23.472 8.938 37.668 7.3-9.105 16.855-18.323 29.158-28.48 1.016-7.043 2.19-13.9 3.506-20.585-2.082-.67-4.42-.97-6.947-.937z" fill="#2c3e50"/></g></svg>'
        };
        function getRoleIcon(role) { return ROLE_ICONS[role] || ''; }
        function updateRoleIcon(idx, role) {
            var el = document.getElementById('role-icon-' + idx);
            if (el) el.innerHTML = getRoleIcon(role);
        }

        var ROLE_LIST = ['OFF_TANK','DEF_TANK','MDPS','RDPS','HEALER','SUPPORT','BATTLEMOUNT'];
        var activeRoleMenu = null;
        function toggleRoleMenu(idx, iconEl) {
            closeRoleMenu();
            var menu = document.createElement('div');
            menu.className = 'role-menu active';
            var currentRole = iconEl.parentNode.querySelector('.slot-role-value').value;
            ROLE_LIST.forEach(function(r) {
                var item = document.createElement('span');
                item.className = 'role-menu-item' + (r === currentRole ? ' selected' : '');
                item.innerHTML = ROLE_ICONS[r];
                item.title = r;
                item.onclick = function(e) { e.stopPropagation(); selectRole(idx, r); };
                menu.appendChild(item);
            });
            document.body.appendChild(menu);
            // 아이콘 오른쪽에 위치
            var rect = iconEl.getBoundingClientRect();
            menu.style.top = (rect.top + rect.height / 2 - menu.offsetHeight / 2) + 'px';
            menu.style.left = (rect.right + 6) + 'px';
            activeRoleMenu = menu;
            setTimeout(function() { document.addEventListener('click', closeRoleMenu, { once: true }); }, 0);
        }
        function selectRole(idx, role) {
            var row = document.getElementById('slot-' + idx);
            if (row) row.querySelector('.slot-role-value').value = role;
            updateRoleIcon(idx, role);
            closeRoleMenu();
        }
        function closeRoleMenu() { if (activeRoleMenu) { activeRoleMenu.remove(); activeRoleMenu = null; } }

        var draggedSlotId = null;
        function slotDragStart(e, idx) { draggedSlotId = idx; e.dataTransfer.effectAllowed = 'move'; var row = document.getElementById('slot-' + idx); if (row) { row.style.opacity = '0.4'; e.dataTransfer.setDragImage(row, 50, 20); } }
        function slotDragOver(e) { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; }
        function slotDrop(e, targetIdx) {
            e.preventDefault();
            if (draggedSlotId === null || draggedSlotId === targetIdx) return;
            var container = document.getElementById('slotContainer');
            var draggedEl = document.getElementById('slot-' + draggedSlotId);
            var targetEl = document.getElementById('slot-' + targetIdx);
            if (!draggedEl || !targetEl) return;
            var allSlots = Array.from(container.children);
            if (allSlots.indexOf(draggedEl) < allSlots.indexOf(targetEl)) {
                container.insertBefore(draggedEl, targetEl.nextSibling);
            } else {
                container.insertBefore(draggedEl, targetEl);
            }
            renumberSlots();
        }
        function slotDragEnd(e) { var row = document.getElementById('slot-' + draggedSlotId); if (row) row.style.opacity = ''; draggedSlotId = null; }
        function renumberSlots() {
            var slots = document.getElementById('slotContainer').querySelectorAll('.slot-row');
            slots.forEach(function(el, i) {
                var numEl = el.querySelector('.slot-num');
                if (numEl) numEl.textContent = '#' + (i + 1);
            });
            renderSlotPage();
        }

        var slotPageSize = 20;
        var slotCurrentPage = 0;
        function renderSlotPage() {
            var container = document.getElementById('slotContainer');
            var slots = container.querySelectorAll('.slot-row');
            var total = slots.length;
            var totalPages = Math.ceil(total / slotPageSize) || 1;
            if (slotCurrentPage >= totalPages) slotCurrentPage = totalPages - 1;
            if (slotCurrentPage < 0) slotCurrentPage = 0;
            var start = slotCurrentPage * slotPageSize;
            var end = start + slotPageSize;
            slots.forEach(function(el, i) {
                el.style.display = (i >= start && i < end) ? '' : 'none';
            });
            // 페이저 UI
            var pager = document.getElementById('slotPager');
            if (totalPages <= 1) { pager.innerHTML = ''; return; }
            pager.innerHTML = '<button style="padding:2px 8px;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;" onclick="slotPageNav(-1)"' + (slotCurrentPage === 0 ? ' disabled style="opacity:0.4;cursor:not-allowed;padding:2px 8px;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;font-family:inherit;"' : '') + '>‹</button>'
                + '<span>' + (slotCurrentPage + 1) + ' / ' + totalPages + '</span>'
                + '<button style="padding:2px 8px;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;cursor:pointer;font-family:inherit;" onclick="slotPageNav(1)"' + (slotCurrentPage >= totalPages - 1 ? ' disabled style="opacity:0.4;cursor:not-allowed;padding:2px 8px;border:1px solid #30363d;background:transparent;color:#8b949e;border-radius:4px;font-family:inherit;"' : '') + '>›</button>';
        }
        function slotPageNav(dir) {
            slotCurrentPage += dir;
            renderSlotPage();
        }

        // 좌측 아이콘 셀 클릭 시 우측에 해당 장비 드롭다운 표시
        function activateEquip(slot, equip) {
            var slotEl = document.getElementById('slot-' + slot);
            if (!slotEl) return;

            var cell = document.getElementById('icell-' + slot + '-' + equip);
            var field = document.getElementById('eqfield-' + slot + '-' + equip);
            var dd = document.getElementById('dd-' + slot + '-' + equip);

            // 이미 같은 셀이 활성화되어 있으면 드롭다운 닫기만
            if (cell && cell.classList.contains('active')) {
                if (dd) dd.classList.remove('active');
                return;
            }

            // 다른 필드 숨기기, 다른 드롭다운 닫기
            slotEl.querySelectorAll('.equip-field').forEach(function(f) { f.style.display = 'none'; });
            slotEl.querySelectorAll('.equip-dropdown').forEach(function(d) { d.classList.remove('active'); });
            slotEl.querySelectorAll('.slot-icon-cell').forEach(function(c) { c.classList.remove('active'); });

            if (cell) cell.classList.add('active');
            if (field) field.style.display = 'block';
            // 드롭다운은 닫힌 상태로 활성화
        }

        function toggleSlotCollapse(idx, event) {
            var slotEl = document.getElementById('slot-' + idx);
            if (!slotEl) return;

            if (slotEl.classList.contains('collapsed')) {
                // 펼치기 — 다른 슬롯 접기
                collapseAllSlotsExcept(idx);
            } else {
                slotEl.classList.add('collapsed');
            }
        }

        function collapseAllSlotsExcept(idx) {
            document.querySelectorAll('.slot-row').forEach(function(row) {
                if (row.id === 'slot-' + idx) {
                    row.classList.remove('collapsed');
                } else {
                    row.classList.add('collapsed');
                }
            });
            activateEquip(idx, 'weapon');
        }

        function collapseAllSlots() {
            document.querySelectorAll('.slot-row').forEach(function(row) {
                row.classList.add('collapsed');
            });
            slotCurrentPage = 0;
            renderSlotPage();
        }

        function escapeAttr(str) {
            if (!str) return '';
            return str.replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        }

        // ===== 커스텀 드롭다운 =====
        var ddCache = {}; // 슬롯별 카테고리+아이템 캐시
        var activeDD = null; // 현재 열린 드롭다운 식별자

        function openEquipDD(slot, equip) {
            var ddId = 'dd-' + slot + '-' + equip;
            var triggerId = 'trigger-' + slot + '-' + equip;
            var dd = document.getElementById(ddId);
            var trigger = document.getElementById(triggerId);

            // 이미 열려있으면 무시
            if (dd.classList.contains('active')) return;

            // 다른 열린 드롭다운 닫기
            closeAllDD();

            trigger.classList.add('open');
            dd.classList.add('active');
            activeDD = slot + '-' + equip;

            // 데이터 로드
            loadDDData(slot, equip);
        }

        function closeAllDD() {
            document.querySelectorAll('.equip-dropdown.active').forEach(function(el) { el.classList.remove('active'); });
            document.querySelectorAll('.equip-trigger.open').forEach(function(el) { el.classList.remove('open'); });
            activeDD = null;
        }

        // 외부 클릭으로 닫기
        document.addEventListener('mousedown', function(e) {
            if (e.target.closest('.equip-field')) return;
            closeAllDD();
        });

        function loadDDData(slot, equip) {
            var listEl = document.getElementById('ddlist-' + slot + '-' + equip);
            var cacheKey = equip;

            if (ddCache[cacheKey]) {
                renderDDList(listEl, ddCache[cacheKey], slot, equip);
                return;
            }

            listEl.innerHTML = '<div style="padding:10px;color:#8b949e;font-size:0.78rem;">불러오는 중...</div>';

            // 카테고리 목록 가져오기
            fetch('/api/items/categories?slot=' + equip)
                .then(function(r) { return r.json(); })
                .then(function(cats) {
                    // 각 카테고리별 아이템도 함께 로드
                    var promises = cats.map(function(cat) {
                        return fetch('/api/items/byCategory?subCategory=' + encodeURIComponent(cat.id) + '&slot=' + equip)
                            .then(function(r) { return r.json(); })
                            .then(function(items) {
                                return { id: cat.id, name: cat.name, items: items };
                            });
                    });
                    return Promise.all(promises);
                })
                .then(function(groups) {
                    ddCache[cacheKey] = groups;
                    renderDDList(listEl, groups, slot, equip);
                })
                .catch(function() {
                    listEl.innerHTML = '<div style="padding:10px;color:#f85149;font-size:0.78rem;">로드 실패</div>';
                });
        }

        function renderDDList(listEl, groups, slot, equip) {
            var html = '';
            groups.forEach(function(group) {
                html += '<div class="dd-group" data-group="' + escapeAttr(group.id) + '">'
                    + '<div class="dd-group-header" onclick="toggleDDGroup(this)">'
                    + '<span class="arrow">▶</span> ' + escapeHtml2(group.name) + ' <span style="color:#484f58;font-weight:400;">(' + group.items.length + ')</span>'
                    + '</div>'
                    + '<div class="dd-group-items">';

                group.items.forEach(function(item) {
                    html += '<div class="dd-item" data-name="' + escapeAttr(item.localizedName.toLowerCase()) + ' ' + escapeAttr(item.uniqueName.toLowerCase()) + '" data-uname="' + escapeAttr(item.uniqueName) + '" data-dname="' + escapeAttr(item.localizedName) + '">'
                        + '<span class="dd-item-text">' + escapeHtml2(item.localizedName) + '</span>'
                        + '</div>';
                });

                html += '</div></div>';
            });

            listEl.innerHTML = html || '<div style="padding:10px;color:#8b949e;font-size:0.78rem;">아이템이 없습니다.</div>';

            // 그룹이 1개면 자동 펼침
            var allGroups = listEl.querySelectorAll('.dd-group');
            if (allGroups.length === 1) {
                var h = allGroups[0].querySelector('.dd-group-header');
                h.classList.add('expanded');
                h.style.display = 'none';
                h.nextElementSibling.classList.add('expanded');
            }

            // 이벤트 위임: 아이템 클릭
            listEl.onclick = function(e) {
                var item = e.target.closest('.dd-item');
                if (!item) return;
                e.stopPropagation();
                var uname = item.getAttribute('data-uname');
                var dname = item.getAttribute('data-dname');
                if (uname) pickItem(slot, equip, uname, dname);
            };
        }

        function toggleDDGroup(header) {
            var parent = header.closest('.dd-list');
            var wasExpanded = header.classList.contains('expanded');

            // 같은 드롭다운 내 다른 그룹 모두 접기
            parent.querySelectorAll('.dd-group-header.expanded').forEach(function(h) {
                h.classList.remove('expanded');
                h.nextElementSibling.classList.remove('expanded');
            });

            // 클릭한 그룹이 이미 열려있었으면 접기만 (위에서 처리됨)
            if (!wasExpanded) {
                header.classList.add('expanded');
                header.nextElementSibling.classList.add('expanded');
            }
        }

        function filterDD(slot, equip, query) {
            var listEl = document.getElementById('ddlist-' + slot + '-' + equip);
            var q = query.toLowerCase().trim();

            var groups = listEl.querySelectorAll('.dd-group');
            groups.forEach(function(group) {
                var itemsWrap = group.querySelector('.dd-group-items');
                var items = itemsWrap.querySelectorAll('.dd-item');
                var visibleCount = 0;

                items.forEach(function(item) {
                    var name = item.getAttribute('data-name') || '';
                    if (!q || name.indexOf(q) !== -1) {
                        item.classList.remove('hidden');
                        visibleCount++;
                    } else {
                        item.classList.add('hidden');
                    }
                });

                // 매칭 없는 그룹은 숨김, 있으면 보임 (펼침 상태는 건드리지 않음)
                if (q) {
                    group.style.display = visibleCount > 0 ? '' : 'none';
                } else {
                    group.style.display = '';
                }
            });
        }

        function pickItem(slot, equip, uniqueName, displayName) {
            // hidden input 값 설정
            var input = document.querySelector('input[data-slot="' + slot + '"][data-equip="' + equip + '"]');
            if (input) input.value = uniqueName;

            // 트리거 input 텍스트 업데이트
            var trigger = document.getElementById('trigger-' + slot + '-' + equip);
            var triggerInput = trigger.querySelector('input[type="text"]');
            if (triggerInput) triggerInput.value = displayName;

            // 좌측 아이콘 셀 업데이트
            var cell = document.getElementById('icell-' + slot + '-' + equip);
            if (cell) {
                var label = cell.querySelector('.icon-label');
                cell.innerHTML = '<img src="' + RENDER_URL + encodeURIComponent(uniqueName) + '.png?size=64" loading="lazy">';
                if (label) cell.appendChild(label);
                else {
                    var span = document.createElement('span');
                    span.className = 'icon-label';
                    cell.appendChild(span);
                }
            }

            closeAllDD();

            // 무기 선택 시 헤더에 이름 표시
            if (equip === 'weapon') {
                var nameEl = document.getElementById('slot-weapon-name-' + slot);
                if (nameEl) nameEl.textContent = displayName || '';
            }
        }

        function escapeHtml2(str) {
            if (!str) return '';
            return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        }

        // 드롭다운 아이템 hover 시 넘치는 텍스트만 스크롤 애니메이션
        document.addEventListener('mouseenter', function(e) {
            var item = e.target.closest('.dd-item');
            if (!item) return;
            var textEl = item.querySelector('.dd-item-text');
            if (!textEl) return;
            // 텍스트 실제 폭 vs 부모 가용 폭 비교
            if (textEl.offsetWidth > item.clientWidth - 30) {
                textEl.classList.add('scrolling');
            }
        }, true);
        document.addEventListener('mouseleave', function(e) {
            var item = e.target.closest('.dd-item');
            if (!item) return;
            var textEl = item.querySelector('.dd-item-text');
            if (textEl) textEl.classList.remove('scrolling');
        }, true);

        // 저장
        function saveComposition() {
            var name = document.getElementById('compNameInput').value.trim();
            if (!name) { alert('빌드 이름을 입력해주세요.'); return; }

            var slotRows = document.querySelectorAll('.slot-row');
            var slots = [];
            slotRows.forEach(function(row) {
                var role = row.querySelector('.slot-role-value').value;
                var slot = { role: role };
                // 기존 슬롯이면 DB ID 포함
                if (row.dataset.dbId) slot.id = parseInt(row.dataset.dbId);
                ['weapon','offhand','head','chest','shoes','cape','food'].forEach(function(eq) {
                    var inp = row.querySelector('input[data-equip="' + eq + '"]');
                    slot[eq] = inp ? inp.value.trim() : '';
                });
                slots.push(slot);
            });

            var body = JSON.stringify({
                name: name,
                isPublic: document.getElementById('compPublicInput').checked,
                slots: slots
            });

            var url = editingCompId ? '/api/compositions/' + editingCompId : '/api/compositions';
            var method = editingCompId ? 'PUT' : 'POST';

            fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    '${_csrf.headerName}': '${_csrf.token}'
                },
                body: body
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    closeCompModal();
                    loadCompositions();
                } else {
                    alert(data.message || '저장에 실패했습니다.');
                }
            })
            .catch(function() { alert('서버와 통신 중 오류가 발생했습니다.'); });
        }

        // 복사
        function duplicateComposition(id) {
            fetch('/api/compositions/' + id)
                .then(function(r) { return r.json(); })
                .then(function(comp) {
                    var body = {
                        name: comp.name + ' (복사)',
                        isPublic: comp.isPublic,
                        slots: (comp.slots || []).map(function(s) {
                            return { role: s.role, weapon: s.weapon, offhand: s.offhand, head: s.head, chest: s.chest, shoes: s.shoes, cape: s.cape, food: s.food };
                        })
                    };
                    fetch('/api/compositions', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json', '${_csrf.headerName}': '${_csrf.token}' },
                        body: JSON.stringify(body)
                    })
                    .then(function(r) { return r.json(); })
                    .then(function(d) { if (d.success) loadCompositions(); });
                });
        }

        // 삭제
        function deleteComposition(id) {
            if (!confirm('이 빌드를 삭제하시겠습니까?')) return;
            fetch('/api/compositions/' + id, {
                method: 'DELETE',
                headers: { '${_csrf.headerName}': '${_csrf.token}' }
            })
            .then(function(r) { return r.json(); })
            .then(function(data) { if (data.success) loadCompositions(); })
            .catch(function() { alert('삭제에 실패했습니다.'); });
        }

        // 목록 로드
        function loadCompositions() {
            var grid = document.getElementById('compGrid');
            if (!grid) return;

            fetch('/api/compositions')
                .then(function(r) { return r.json(); })
                .then(function(comps) {
                    if (!comps.length) {
                        grid.innerHTML = '<p style="color:#8b949e;font-size:0.9rem;">아직 생성된 빌드가 없습니다. 새 빌드를 조합해보세요.</p>';
                        return;
                    }
                    grid.innerHTML = comps.map(function(c) {
                        var slotCount = (c.slots || []).length;
                        var pubClass = c.isPublic ? 'pub-public' : 'pub-private';
                        var pubLabel = c.isPublic ? '공유' : '미공유';

                        return '<div class="comp-card">'
                            + '<div class="comp-card-header">'
                            + '<span class="comp-card-name">' + escapeHtml2(c.name) + '</span>'
                            + '<div class="comp-card-actions">'
                            + '<button class="comp-card-btn" title="복사" onclick="duplicateComposition(' + c.id + ')"><svg viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg></button>'
                            + '<button class="comp-card-btn" title="수정" onclick="openCompModal(' + c.id + ')"><svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg></button>'
                            + '<button class="comp-card-btn" title="삭제" onclick="deleteComposition(' + c.id + ')"><svg viewBox="0 0 24 24"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg></button>'
                            + '</div></div>'
                            + '<div class="comp-card-footer">'
                            + '<span class="pub-badge ' + pubClass + '">' + pubLabel + '</span>'
                            + '<span class="slot-count"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>' + slotCount + '명</span>'
                            + '</div>'
                            + '</div>';
                    }).join('');
                })
                .catch(function() {
                    grid.innerHTML = '<p style="color:#8b949e;font-size:0.9rem;">빌드 목록을 불러올 수 없습니다.</p>';
                });
        }

        // 페이지 로드 시 빌드 목록 불러오기
        if (document.getElementById('compGrid')) {
            loadCompositions();
        }
    </script>
</body>
</html>
