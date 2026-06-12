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
        .slot-row { background: #161b22; border: 1px solid #30363d; border-radius: 10px; overflow: hidden; min-height: fit-content; flex-shrink: 0; }
        .slot-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 14px; cursor: pointer; }
        .slot-header:hover { background: #1c2128; }
        .slot-header-left { display: flex; align-items: center; gap: 10px; }
        .slot-collapse-arrow { font-size: 0.7rem; color: #8b949e; transition: transform 0.15s; }
        .slot-row.collapsed .slot-collapse-arrow { transform: rotate(-90deg); }
        .slot-row.collapsed .slot-body { display: none; }
        .slot-role-select { padding: 6px 10px; background: #21262d; border: 1px solid #30363d; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; }
        .slot-role-select:focus { border-color: #5865F2; }
        .slot-remove { background: none; border: none; color: #f85149; cursor: pointer; font-size: 0.78rem; font-weight: 500; padding: 4px 8px; border-radius: 4px; }
        .slot-remove:hover { background: rgba(248,81,73,0.1); }
        /* 슬롯 본체: 좌 이미지 + 우 드롭다운 */
        .slot-body { display: flex; gap: 16px; padding: 0 14px 14px; }
        .slot-icons { display: grid; grid-template-columns: repeat(3, 70px); grid-template-rows: repeat(3, 70px); gap: 10px; align-content: center; justify-content: center; min-width: 226px; }
        .slot-icon-cell { width: 70px; height: 70px; border-radius: 8px; background: #21262d; border: 1px solid #30363d; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: border-color 0.15s; position: relative; }
        .slot-icon-cell:hover { border-color: #5865F2; }
        .slot-icon-cell.active { border-color: #5865F2; box-shadow: 0 0 0 2px rgba(88,101,242,0.3); }
        .slot-icon-cell img { width: 60px; height: 60px; border-radius: 4px; }
        .slot-icon-cell .icon-label { position: absolute; bottom: -14px; font-size: 0.6rem; color: #8b949e; white-space: nowrap; }
        .slot-right { flex: 1; display: flex; flex-direction: column; position: relative; }
        .equip-field { position: relative; }
        .equip-field label { display: none; }
        /* 커스텀 드롭다운 트리거 */
        .equip-trigger { width: 100%; padding: 9px 12px; background: #21262d; border: 1px solid #30363d; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; min-height: 36px; display: flex; align-items: center; }
        .equip-trigger input { background: none; border: none; color: #e6edf3; font-size: 0.82rem; font-family: inherit; outline: none; width: 100%; }
        .equip-trigger input::placeholder { color: #484f58; }
        .equip-trigger.open { border-color: #5865F2; border-radius: 6px 6px 0 0; }
        .equip-icon { display: none; }
        /* 드롭다운 패널 */
        .equip-dropdown { background: #1e1f22; border: 1px solid #5865F2; border-top: none; border-radius: 0 0 6px 6px; z-index: 200; display: none; max-height: 200px; flex-direction: column; }
        .equip-dropdown.active { display: flex; }
        .equip-dropdown .dd-list { flex: 1; overflow-y: auto; }
        .dd-group-header { padding: 6px 10px; font-size: 0.7rem; font-weight: 600; color: #8b949e; background: #21262d; cursor: pointer; display: flex; align-items: center; gap: 6px; position: sticky; top: 0; }
        .dd-group-header:hover { color: #e6edf3; }
        .dd-group-header .arrow { font-size: 0.6rem; transition: transform 0.15s; }
        .dd-group-header.expanded .arrow { transform: rotate(90deg); }
        .dd-group-items { display: none; }
        .dd-group-items.expanded { display: block; }
        .dd-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px 6px 20px; cursor: pointer; font-size: 0.78rem; color: #e6edf3; }
        .dd-item:hover { background: #30363d; }
        .dd-item img { width: 22px; height: 22px; border-radius: 3px; flex-shrink: 0; }
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
        <div class="modal" style="max-width:720px;max-height:80vh;overflow:hidden;">
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
                <span style="font-size:0.75rem;color:#8b949e;">다른 유저에게도 보이기</span>
            </div>

            <div style="display:flex;align-items:center;justify-content:space-between;margin:20px 0 10px;">
                <span style="font-size:0.85rem;font-weight:600;">슬롯 목록</span>
                <button class="btn-create" style="padding:6px 14px;font-size:0.78rem;border-radius:8px;" onclick="addSlotRow()">
                    <svg class="btn-icon" viewBox="0 0 24 24" style="width:14px;height:14px;"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                    슬롯 추가
                </button>
            </div>

            <div id="slotContainer" style="display:flex;flex-direction:column;gap:10px;max-height:315px;overflow-y:auto;padding-right:4px;"></div>

            <button class="btn-verify" style="margin-top:20px;" onclick="saveComposition()">저장</button>
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

        // 모달 외부 클릭 시 닫기
        document.getElementById('guildModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
        // 모달 내부 클릭 시 이벤트 전파 차단
        document.querySelector('.modal').addEventListener('click', function(e) {
            e.stopPropagation();
        });

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

        // 모달 외부 클릭 시 닫기
        document.getElementById('joinModal').addEventListener('click', function(e) {
            if (e.target === this) closeJoinModal();
        });

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
            slotCounter = 0;

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

        document.getElementById('compModal').addEventListener('click', function(e) {
            if (e.target === this) closeCompModal();
        });

        function addSlotRow(data) {
            slotCounter++;
            var idx = slotCounter;
            var role = data ? data.role : 'OFF_TANK';
            var equips = ['weapon', 'offhand', 'head', 'chest', 'shoes', 'cape', 'food'];
            var labels = ['무기', '보조', '머리', '갑옷', '신발', '망토', '음식'];
            // 아이콘 그리드: row1(빈, head, cape), row2(weapon, chest, offhand), row3(빈, shoes, food)
            var gridOrder = ['', 'head', 'cape', 'weapon', 'chest', 'offhand', '', 'shoes', 'food'];

            var html = '<div class="slot-row" id="slot-' + idx + '">'
                + '<div class="slot-header" onclick="toggleSlotCollapse(' + idx + ', event)">'
                + '<div class="slot-header-left">'
                + '<span class="slot-collapse-arrow">▼</span>'
                + '<span style="font-size:0.8rem;font-weight:600;color:#e6edf3;">#' + idx + '</span>'
                + '<select class="slot-role-select" data-slot="' + idx + '" onclick="event.stopPropagation()">'
                + '<option value="OFF_TANK"' + (role === 'OFF_TANK' ? ' selected' : '') + '>OFF_TANK</option>'
                + '<option value="RDPS"' + (role === 'RDPS' ? ' selected' : '') + '>RDPS</option>'
                + '<option value="MDPS"' + (role === 'MDPS' ? ' selected' : '') + '>MDPS</option>'
                + '<option value="HEALER"' + (role === 'HEALER' ? ' selected' : '') + '>HEALER</option>'
                + '<option value="SUPPORT"' + (role === 'SUPPORT' ? ' selected' : '') + '>SUPPORT</option>'
                + '<option value="DEF_TANK"' + (role === 'DEF_TANK' ? ' selected' : '') + '>DEF_TANK</option>'
                + '<option value="BATTLEMOUNT"' + (role === 'BATTLEMOUNT' ? ' selected' : '') + '>BATTLEMOUNT</option>'
                + '</select>'
                + '</div>'
                + '<button class="slot-remove" onclick="event.stopPropagation();removeSlot(' + idx + ')">삭제</button>'
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
                        + '<span class="icon-label">' + labels[labelIdx] + '</span>'
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
            // 다른 슬롯 접기
            collapseAllSlotsExcept(idx);
            // 스크롤 맨 아래
            var container = document.getElementById('slotContainer');
            container.scrollTop = container.scrollHeight;
            // 첫 번째(무기) 활성화
            activateEquip(idx, 'weapon');
        }

        function removeSlot(idx) {
            var el = document.getElementById('slot-' + idx);
            if (el) el.remove();
        }

        // 좌측 아이콘 셀 클릭 시 우측에 해당 장비 드롭다운 표시
        function activateEquip(slot, equip) {
            var slotEl = document.getElementById('slot-' + slot);
            if (!slotEl) return;
            slotEl.querySelectorAll('.equip-field').forEach(function(f) { f.style.display = 'none'; });
            slotEl.querySelectorAll('.slot-icon-cell').forEach(function(c) { c.classList.remove('active'); });

            var field = document.getElementById('eqfield-' + slot + '-' + equip);
            if (field) field.style.display = 'block';
            var cell = document.getElementById('icell-' + slot + '-' + equip);
            if (cell) cell.classList.add('active');

            // 드롭다운 열기
            openEquipDD(slot, equip);
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
        }

        function collapseAllSlots() {
            document.querySelectorAll('.slot-row').forEach(function(row) {
                row.classList.add('collapsed');
            });
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
                        + '<span>' + escapeHtml2(item.localizedName) + '</span>'
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
        }

        function escapeHtml2(str) {
            if (!str) return '';
            return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        }

        // 저장
        function saveComposition() {
            var name = document.getElementById('compNameInput').value.trim();
            if (!name) { alert('빌드 이름을 입력해주세요.'); return; }

            var slotRows = document.querySelectorAll('.slot-row');
            var slots = [];
            slotRows.forEach(function(row) {
                var role = row.querySelector('.slot-role-select').value;
                var slot = { role: role };
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
                        var pubLabel = c.isPublic ? '공개' : '비공개';

                        return '<div class="comp-card">'
                            + '<div class="comp-card-header">'
                            + '<span class="comp-card-name">' + escapeHtml2(c.name) + '</span>'
                            + '<div class="comp-card-actions">'
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
