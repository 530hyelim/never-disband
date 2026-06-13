<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${guild.name}" /> - Never Disband</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#3f4147; border-radius:3px; }
        ::-webkit-scrollbar-thumb:hover { background:#5a6173; }
        body { font-family: 'Noto Sans KR', sans-serif; background: #313338; color: #e6edf3; height: 100vh; display: flex; overflow: hidden; }

        /* 사이드바 */
        .logo-placeholder { width: 28px; height: 28px; background: linear-gradient(135deg, #5865F2, #57F287); border-radius: 7px; }
        .sidebar { width: 240px; background: #2b2d31; display: flex; flex-direction: column; height: 100vh; flex-shrink: 0; }
        .sidebar-header { padding: 16px; border-bottom: 1px solid #1e1f22; display: flex; align-items: center; gap: 10px; height: 56px; }
        .sidebar-header h1 { font-size: 0.95rem; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .sidebar-nav { flex: 1; padding: 8px; overflow-y: auto; }
        .nav-section { margin-bottom: 16px; }
        .nav-section-title { font-size: 0.7rem; font-weight: 700; color: #949ba4; text-transform: uppercase; letter-spacing: 0.5px; padding: 0 8px; margin-bottom: 4px; }
        .nav-item { display: flex; align-items: center; gap: 10px; padding: 8px 12px; border-radius: 6px; color: #949ba4; font-size: 0.88rem; font-weight: 500; cursor: pointer; transition: all 0.1s ease; text-decoration: none; }
        .nav-item:hover { background: #35373c; color: #e6edf3; }
        .nav-item.active { background: #404249; color: #fff; }
        .nav-item svg { width: 20px; height: 20px; fill: currentColor; flex-shrink: 0; }

        /* 사이드바 하단 유저 정보 */
        .sidebar-footer { padding: 12px; background: #232428; border-top: 1px solid #1e1f22; display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #5865F2, #57F287); display: flex; align-items: center; justify-content: center; font-size: 0.8rem; font-weight: 700; color: #fff; flex-shrink: 0; }
        .user-info { flex: 1; min-width: 0; }
        .user-info .char-name { font-size: 0.82rem; font-weight: 600; color: #e6edf3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .user-info .balance { font-size: 0.72rem; color: #57F287; font-weight: 500; }

        /* 메인 컨텐츠 */
        .main-area { flex: 1; display: flex; flex-direction: column; }
        .main-header { height: 56px; padding: 0 16px; border-bottom: 1px solid #1e1f22; display: flex; align-items: center; }
        .main-header h2 { font-size: 0.95rem; font-weight: 600; }
        .main-content { flex: 1; padding: 24px; padding-bottom: 60px; overflow-y: auto; }
        .main-content p { color: #949ba4; font-size: 0.9rem; }

        /* 반응형 */
        @media (max-width: 768px) {
            .sidebar { width: 60px; }
            .sidebar-header h1, .nav-section-title, .nav-item span, .user-info { display: none; }
            .sidebar-header { justify-content: center; }
            .nav-item { justify-content: center; padding: 10px; }
            .sidebar-footer { justify-content: center; }
        }
        /* Admin fragment styles */
        .admin-section { background: #2b2d31; border: 1px solid #3f4147; border-radius: 12px; padding: 24px; }
        .channel-row { display: flex; align-items: center; justify-content: space-between; padding: 14px 0; border-bottom: 1px solid #3f4147; }
        .channel-row:last-child { border-bottom: none; }
        .channel-label { font-size: 0.88rem; font-weight: 500; }
        .channel-label small { display: block; font-size: 0.75rem; color: #949ba4; font-weight: 400; margin-top: 2px; }
        .channel-select { padding: 8px 12px; background: #1e1f22; border: 1px solid #3f4147; border-radius: 6px; color: #e6edf3; font-size: 0.82rem; font-family: inherit; cursor: pointer; min-width: 160px; outline: none; }
        .channel-select:focus { border-color: #5865F2; }
        .channel-select:disabled { opacity: 0.5; cursor: not-allowed; }
        /* 페이지 관리 */
        .page-row { display: flex; align-items: center; justify-content: space-between; padding: 14px 0; border-bottom: 1px solid #3f4147; }
        .page-row:last-child { border-bottom: none; }
        .page-name { font-size: 0.88rem; font-weight: 500; }
        .page-controls { display: flex; align-items: center; gap: 12px; }
        /* 토글 스위치 */
        .toggle { position: relative; display: inline-block; width: 38px; height: 20px; }
        .toggle input { opacity: 0; width: 0; height: 0; }
        .toggle-slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background: #3f4147; border-radius: 20px; transition: 0.2s; }
        .toggle-slider:before { position: absolute; content: ""; height: 14px; width: 14px; left: 3px; bottom: 3px; background: #fff; border-radius: 50%; transition: 0.2s; }
        .toggle input:checked + .toggle-slider { background: #57F287; }
        .toggle input:checked + .toggle-slider:before { transform: translateX(18px); }
        /* 페이지 로딩 스피너 */
        .page-loader { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(49, 51, 56, 0.6); z-index: 900; align-items: center; justify-content: center; }
        .page-loader.active { display: flex; }
        .loader-spinner { width: 40px; height: 40px; border: 4px solid #3f4147; border-top-color: #5865F2; border-radius: 50%; animation: spin 0.8s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <!-- Mandatory 알림 띠 -->
    <div id="mandatoryBanner" style="display:none;position:fixed;top:0;left:0;right:0;height:24px;background:#ed4245;z-index:9999;overflow:hidden;">
        <div id="mandatoryBannerText" style="white-space:nowrap;font-size:0.72rem;font-weight:600;color:#fff;line-height:24px;position:absolute;left:100%;animation:marquee 25s linear infinite;"></div>
    </div>
    <style>
        @keyframes marquee { 0% { transform:translateX(0); } 100% { transform:translateX(calc(-100% - 100vw)); } }
        body.has-mandatory-banner { padding-top:24px; }
        body.has-mandatory-banner .sidebar { height:calc(100vh - 24px); }
    </style>

    <aside class="sidebar">
        <div class="sidebar-header">
            <a href="/" style="display:flex;align-items:center;"><div class="logo-placeholder"></div></a>
            <h1><c:out value="${guild.name}" /></h1>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section">
                <p class="nav-section-title">메뉴</p>
                <c:forEach var="page" items="${guildPages}">
                    <c:if test="${page.enabled}">
                        <c:choose>
                            <c:when test="${page.pageType == 'HOME'}">
                                <a href="#" class="nav-item active" data-page="home">
                                    <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                                    <span>홈</span>
                                </a>
                            </c:when>
                            <c:when test="${page.pageType == 'RECRUIT'}">
                                <c:if test="${canViewRecruit}">
                                <a href="#" class="nav-item" data-page="recruit">
                                    <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                                    <span>컨텐츠 모집</span>
                                </a>
                                </c:if>
                            </c:when>
                            <c:when test="${page.pageType == 'SPLIT'}">
                                <a href="#" class="nav-item" data-page="split">
                                    <svg viewBox="0 0 24 24"><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z"/></svg>
                                    <span>분배</span>
                                </a>
                            </c:when>
                            <c:when test="${page.pageType == 'BANK'}">
                                <a href="#" class="nav-item" data-page="bank">
                                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1.41 16.09V20h-2.67v-1.93c-1.71-.36-3.16-1.46-3.27-3.4h1.96c.1 1.05.82 1.87 2.65 1.87 1.96 0 2.4-.98 2.4-1.59 0-.83-.44-1.61-2.67-2.14-2.48-.6-4.18-1.62-4.18-3.67 0-1.72 1.39-2.84 3.11-3.21V4h2.67v1.95c1.86.45 2.79 1.86 2.85 3.39H14.3c-.05-1.11-.64-1.87-2.22-1.87-1.5 0-2.4.68-2.4 1.64 0 .84.65 1.39 2.67 1.94s4.18 1.36 4.18 3.87c0 1.92-1.43 2.99-3.12 3.17z"/></svg>
                                    <span>은행</span>
                                </a>
                            </c:when>
                            <c:when test="${page.pageType == 'REGEAR'}">
                                <a href="#" class="nav-item" data-page="regear">
                                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>
                                    <span>리기어</span>
                                </a>
                            </c:when>
                        </c:choose>
                    </c:if>
                </c:forEach>
            </div>

            <c:if test="${isGuildMaster}">
                <div class="nav-section">
                    <p class="nav-section-title">관리</p>
                    <a href="#" class="nav-item" data-page="admin">
                        <svg viewBox="0 0 24 24"><path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58a.49.49 0 00.12-.61l-1.92-3.32a.49.49 0 00-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54a.484.484 0 00-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96a.49.49 0 00-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58a.49.49 0 00-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/></svg>
                        <span>사이트 관리</span>
                    </a>
                </div>
            </c:if>
        </nav>

        <div class="sidebar-footer">
            <div class="user-avatar">${characterName.substring(0, 1).toUpperCase()}</div>
            <div class="user-info">
                <p class="char-name"><c:out value="${characterName}" /></p>
                <p class="balance"><svg viewBox="0 0 24 24" style="width:12px;height:12px;fill:#FEE75C;vertical-align:middle;margin-right:2px;"><circle cx="12" cy="12" r="10"/><text x="12" y="16" text-anchor="middle" font-size="12" fill="#1a1b1e" font-weight="bold">S</text></svg><span id="balanceDisplay"><c:out value="${balance}" /></span></p>
            </div>
        </div>
    </aside>

    <div class="main-area">
        <header class="main-header">

        </header>
        <main class="main-content" id="mainContent"></main>
    </div>

    <!-- 로딩 스피너 -->
    <div class="page-loader" id="pageLoader">
        <div class="loader-spinner"></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script>
        var guildSubdomain = '${guild.subdomain}';
        var csrfParam = '${_csrf.parameterName}';
        var csrfToken = '${_csrf.token}';

        // balance K/M/B 표시
        (function() {
            var el = document.getElementById('balanceDisplay');
            if (!el) return;
            var val = parseInt(el.textContent) || 0;
            if (val >= 1000000000) el.textContent = (val / 1000000000).toFixed(1).replace(/\.0$/, '') + 'B';
            else if (val >= 1000000) el.textContent = (val / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
            else if (val >= 1000) el.textContent = (val / 1000).toFixed(1).replace(/\.0$/, '') + 'K';
        })();

        // 전역 STOMP 클라이언트 - 페이지 전환 시에도 연결 유지
        var stompClient = null;

        function connectWs() {
            // 기존 연결이 살아있으면 재연결하지 않음
            if (stompClient && stompClient.connected) return;
            // 이전 연결 정리
            if (stompClient) {
                try { stompClient.disconnect(); } catch(e) {}
                stompClient = null;
            }
            var socket = new SockJS('/ws');
            stompClient = Stomp.over(socket);
            stompClient.debug = null; // 콘솔 로그 억제
            stompClient.connect({}, function() {
                console.log('[WS] connected');
            }, function() {
                stompClient = null;
                // 재연결 시도
                setTimeout(connectWs, 3000);
            });
        }

        connectWs();

        // Mandatory 알림 띠 체크
        function checkMandatoryBanner() {
            fetch('/${guild.subdomain}/recruit/posts')
                .then(function(r) { return r.ok ? r.json() : []; })
                .then(function(posts) {
                    var now = new Date();
                    var mandatory = posts.filter(function(p) {
                        if (p.mandatory !== 'Y' || p.status === 'CLOSED') return false;
                        // 진행중(scheduledAt 지남)은 항상 표시
                        if (p.scheduledAt && new Date(p.scheduledAt + 'Z') <= now) return true;
                        // 모집중: scheduledAt이 1시간 이내이거나 미정일 때만 표시
                        if (p.scheduledAt) {
                            var diff = new Date(p.scheduledAt + 'Z') - now;
                            return diff <= 3600000; // 1시간 이내
                        }
                        return false; // 시간 미정이면 띠 안 뜸
                    });
                    var banner = document.getElementById('mandatoryBanner');
                    var text = document.getElementById('mandatoryBannerText');
                    if (mandatory.length > 0) {
                        var hasInProgress = mandatory.some(function(p) {
                            if (!p.scheduledAt) return false;
                            return new Date() >= new Date(p.scheduledAt + 'Z');
                        });
                        if (hasInProgress) {
                            text.textContent = '⚠️ 필참 컨텐츠가 진행중입니다. 접속중인 길드원은 반드시 참여해주세요!';
                            banner.style.background = '#ed4245';
                            text.style.color = '#fff';
                        } else {
                            text.textContent = '⚠️ 필참 컨텐츠를 모집중입니다. 컨텐츠 모집 글을 확인해주세요!';
                            banner.style.background = '#FEE75C';
                            text.style.color = '#1a1b1e';
                        }
                        banner.style.display = 'block';
                        document.body.classList.add('has-mandatory-banner');
                    } else {
                        banner.style.display = 'none';
                        document.body.classList.remove('has-mandatory-banner');
                    }
                })
                .catch(function() {});
        }
        checkMandatoryBanner();
        setInterval(checkMandatoryBanner, 30000);

        // WebSocket 연결 후 recruit 브로드캐스트 수신 시 배너 갱신
        (function waitWsForBanner() {
            if (!window.stompClient || !window.stompClient.connected) { setTimeout(waitWsForBanner, 500); return; }
            stompClient.subscribe('/topic/guild/${guild.subdomain}/recruit', function() {
                checkMandatoryBanner();
            });
        })();

        // 사이드바 메뉴 클릭 처리
        document.querySelectorAll('.nav-item').forEach(function(item) {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                var page = this.getAttribute('data-page');
                if (!page) return;

                document.querySelectorAll('.nav-item').forEach(function(el) { el.classList.remove('active'); });
                this.classList.add('active');

                loadPage(page);
            });
        });

        function showLoader() { document.getElementById('pageLoader').classList.add('active'); }
        function hideLoader() { document.getElementById('pageLoader').classList.remove('active'); }

        function loadPage(page) {
            var content = document.getElementById('mainContent');

            showLoader();
            fetch('/' + guildSubdomain + '/' + page)
                .then(function(res) {
                    // 세션 만료 시 OAuth 리다이렉트 감지 → 전체 페이지 새로고침으로 재로그인
                    if (res.redirected) {
                        window.location.reload();
                        return;
                    }
                    if (!res.ok) throw new Error(res.status);
                    return res.text();
                })
                .then(function(html) {
                    if (!html) return;
                    content.innerHTML = html;
                    executeScripts(content);
                    hideLoader();
                })
                .catch(function() {
                    content.innerHTML = '<p style="color:#949ba4;">페이지를 불러올 수 없습니다.</p>';
                    hideLoader();
                });
        }

        // innerHTML로 삽입된 script 태그를 실행
        function executeScripts(container) {
            var scripts = container.querySelectorAll('script');
            scripts.forEach(function(oldScript) {
                var newScript = document.createElement('script');
                if (oldScript.src) {
                    newScript.src = oldScript.src;
                } else {
                    newScript.textContent = oldScript.textContent;
                }
                oldScript.parentNode.replaceChild(newScript, oldScript);
            });
        }
    </script>
</body>
</html>
