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
    </main>

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
    </script>
</body>
</html>
