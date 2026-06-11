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
        .main-content { flex: 1; padding: 24px; overflow-y: auto; }
        .main-content p { color: #949ba4; font-size: 0.9rem; }

        /* 반응형 */
        @media (max-width: 768px) {
            .sidebar { width: 60px; }
            .sidebar-header h1, .nav-section-title, .nav-item span, .user-info { display: none; }
            .sidebar-header { justify-content: center; }
            .nav-item { justify-content: center; padding: 10px; }
            .sidebar-footer { justify-content: center; }
        }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-placeholder"></div>
            <h1><c:out value="${guild.name}" /></h1>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section">
                <p class="nav-section-title">메뉴</p>
                <a href="#" class="nav-item active">
                    <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                    <span>홈</span>
                </a>
                <a href="#" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                    <span>길드원</span>
                </a>
                <a href="#" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>
                    <span>리기어</span>
                </a>
            </div>
        </nav>

        <div class="sidebar-footer">
            <div class="user-avatar">${characterName.substring(0, 1).toUpperCase()}</div>
            <div class="user-info">
                <p class="char-name"><c:out value="${characterName}" /></p>
                <p class="balance"><c:out value="${balance}" /> Silver</p>
            </div>
        </div>
    </aside>

    <div class="main-area">
        <header class="main-header">
            <h2>홈</h2>
        </header>
        <main class="main-content">
            <p>길드 메인 페이지입니다.</p>
        </main>
    </div>
</body>
</html>
