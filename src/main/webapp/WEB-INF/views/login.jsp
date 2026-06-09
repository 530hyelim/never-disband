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
        body { font-family: 'Noto Sans KR', sans-serif; background: #404EED; color: #fff; min-height: 100vh; overflow-x: hidden; }
        /* Hero Section */
        .hero { position: relative; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; padding: 80px 20px 120px; overflow: hidden; }
        .hero::before { content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 100%; background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 600'%3E%3Cpath fill='%23ffffff' d='M0,600 L0,480 Q360,420 720,460 Q1080,500 1440,440 L1440,600 Z'/%3E%3C/svg%3E") no-repeat bottom center; background-size: 100% auto; pointer-events: none; z-index: 0; }
        .hero-content { position: relative; z-index: 1; max-width: 900px; }
        .hero-title { font-size: 3.5rem; font-weight: 900; line-height: 1.2; margin-bottom: 24px; letter-spacing: -1px; }
        .hero-subtitle { font-size: 1.2rem; font-weight: 300; line-height: 1.8; color: rgba(255, 255, 255, 0.85); max-width: 660px; margin: 0 auto 40px; }
        .hero-cta { display: inline-flex; align-items: center; gap: 12px; padding: 18px 40px; background: #fff; color: #23272a; border-radius: 28px; font-size: 1.1rem; font-weight: 700; text-decoration: none; transition: all 0.2s ease; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15); }
        .hero-cta:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(0, 0, 0, 0.2); color: #5865F2; }
        .hero-cta svg { width: 24px; height: 24px; fill: #5865F2; }
        /* 배경 장식 */
        .floating-shapes { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; overflow: hidden; }
        .shape { position: absolute; border-radius: 50%; opacity: 0.08; background: #fff; }
        .shape-1 { width: 400px; height: 400px; top: -100px; right: -100px; }
        .shape-2 { width: 300px; height: 300px; bottom: 150px; left: -80px; }
        .shape-3 { width: 200px; height: 200px; top: 30%; right: 10%; }
        /* 기능 섹션 */
        .features-section { background: #fff; color: #23272a; padding: 100px 20px; }
        .features-container { max-width: 1100px; margin: 0 auto; }
        .features-header { text-align: center; margin-bottom: 64px; }
        .features-header h2 { font-size: 2.2rem; font-weight: 900; margin-bottom: 16px; color: #23272a; }
        .features-header p { font-size: 1.05rem; color: #5c6770; max-width: 560px; margin: 0 auto; line-height: 1.7; }
        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 32px; }
        .feature-card { background: #f6f6f6; border-radius: 16px; padding: 32px 24px; text-align: center; transition: all 0.2s ease; }
        .feature-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08); }
        .feature-icon { width: 56px; height: 56px; background: linear-gradient(135deg, #5865F2, #7289DA); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
        .feature-icon svg { width: 28px; height: 28px; fill: #fff; }
        .feature-card h3 { font-size: 1rem; font-weight: 700; margin-bottom: 8px; color: #23272a; }
        .feature-card p { font-size: 0.85rem; color: #5c6770; line-height: 1.6; }
        /* CTA 섹션 */
        .cta-section { background: #f6f6f6; padding: 80px 20px; text-align: center; }
        .cta-section h2 { font-size: 2rem; font-weight: 900; color: #23272a; margin-bottom: 12px; }
        .cta-section p { color: #5c6770; margin-bottom: 32px; font-size: 1rem; }
        .cta-discord { display: inline-flex; align-items: center; gap: 12px; padding: 16px 36px; background: #5865F2; color: #fff; border-radius: 28px; font-size: 1rem; font-weight: 600; text-decoration: none; transition: all 0.2s ease; box-shadow: 0 4px 16px rgba(88, 101, 242, 0.3); }
        .cta-discord:hover { background: #4752C4; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(88, 101, 242, 0.4); color: #fff; }
        .cta-discord svg { width: 22px; height: 22px; fill: #fff; }
        /* 에러 메시지 */
        .error-alert { background: rgba(248, 81, 73, 0.1); border: 1px solid rgba(248, 81, 73, 0.3); color: #f85149; padding: 12px 20px; border-radius: 10px; margin-bottom: 24px; font-size: 0.9rem; display: inline-block; }
        /* 푸터 */
        .footer { background: #23272a; color: #72767d; padding: 40px 20px; text-align: center; font-size: 0.8rem; }
        /* 반응형 */
        .top-nav { position: absolute; top: 0; left: 0; right: 0; z-index: 10; display: flex; align-items: center; padding: 20px 40px; }
        .top-nav .logo { display: flex; align-items: center; gap: 10px; text-decoration: none; color: #fff; }
        .top-nav .logo img { width: 32px; height: 32px; }
        .top-nav .logo-placeholder { width: 32px; height: 32px; background: rgba(255,255,255,0.2); border-radius: 8px; }
        .top-nav .logo-text { font-size: 1rem; font-weight: 900; letter-spacing: 0.5px; color: #fff; }
        @media (max-width: 768px) { .hero-title { font-size: 2.2rem; } .hero-subtitle { font-size: 1rem; } .features-grid { grid-template-columns: repeat(2, 1fr); gap: 16px; } .feature-card { padding: 24px 16px; } .top-nav { padding: 16px 20px; } }
        @media (max-width: 480px) { .features-grid { grid-template-columns: 1fr; } .hero-cta { padding: 14px 28px; font-size: 1rem; } }
    </style>
</head>
<body>
    <!-- Hero 영역 -->
    <section class="hero">
        <nav class="top-nav">
            <a href="/" class="logo">
                <!-- TODO: 로고 이미지로 교체 -->
                <!-- <img src="/images/logo.png" alt="Never Disband"> -->
                <div class="logo-placeholder"></div>
                <span class="logo-text">NEVER DISBAND</span>
            </a>
        </nav>
        <div class="floating-shapes">
            <div class="shape shape-1"></div>
            <div class="shape shape-2"></div>
            <div class="shape shape-3"></div>
        </div>
        <div class="hero-content">
            <h1 class="hero-title">길드 운영의 모든 것,<br>하나의 플랫폼에서.</h1>
            <p class="hero-subtitle">
                파티 모집, 분배, 리기어, 거래, 빌드 공유까지.<br>
                복잡한 디스코드 봇 설정 없이 누구나 쉽게 길드를 운영할 수 있습니다.
            </p>

            <c:if test="${not empty errorMessage}">
                <div class="error-alert">${errorMessage}</div>
            </c:if>

            <a href="${authUrl}" class="hero-cta">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
                </svg>
                Discord로 시작하기
            </a>
        </div>
    </section>

    <!-- 기능 소개 -->
    <section class="features-section">
        <div class="features-container">
            <div class="features-header">
                <h2>Never Disband가 제공하는 기능</h2>
                <p>여러 디스코드 봇과 수작업으로 분산되어 있던 길드 운영을 하나로 통합합니다.</p>
            </div>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                    </div>
                    <h3>컨텐츠 모집</h3>
                    <p>길드 컨텐츠 참여자를 모집하고 관리하세요</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/></svg>
                    </div>
                    <h3>분배 & 리기어</h3>
                    <p>전리품 분배와 리기어 신청을 체계적으로</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
                    </div>
                    <h3>길드 거래</h3>
                    <p>길드 내 아이템 거래를 안전하게 관리</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                    </div>
                    <h3>빌드 공유</h3>
                    <p>길드원끼리 장비 빌드를 공유하고 추천</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M19 4h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V10h14v10zm0-12H5V6h14v2zm-7 5h5v5h-5v-5z"/></svg>
                    </div>
                    <h3>일정 관리</h3>
                    <p>공지사항과 길드 일정을 한눈에</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24"><path d="M21 3H3c-1.11 0-2 .89-2 2v12c0 1.1.89 2 2 2h5v2h8v-2h5c1.1 0 2-.9 2-2V5c0-1.11-.9-2-2-2zm0 14H3V5h18v12zm-5-6l-7 4V7l7 4z"/></svg>
                    </div>
                    <h3>영상 피드백</h3>
                    <p>전투 영상에 피드백을 주고받는 공간</p>
                </div>
            </div>
        </div>
    </section>

    <!-- 하단 CTA -->
    <section class="cta-section">
        <h2>지금 바로 시작하세요</h2>
        <p>Discord 계정 하나로 길드 운영을 시작할 수 있습니다.</p>
        <a href="${authUrl}" class="cta-discord">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
            </svg>
            Discord로 로그인
        </a>
    </section>

    <!-- 푸터 -->
    <div class="footer">
        &copy; 2026 Never Disband. All rights reserved.
    </div>
</body>
</html>
