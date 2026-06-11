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
        .main-content { flex: 1; padding: 40px 32px; max-width: 960px; margin: 0 auto; width: 100%; }
        .page-title { font-size: 1.6rem; font-weight: 700; margin-bottom: 8px; }
        .page-desc { font-size: 0.9rem; color: #8b949e; margin-bottom: 32px; }
        @media (max-width: 640px) { .main-content { padding: 24px 16px; } .top-header { padding: 16px 16px 0; } }
    </style>
</head>
<body>
    <header class="top-header">
        <a href="/" class="logo">
            <div class="logo-placeholder"></div>
            <span class="logo-text">NEVER DISBAND</span>
        </a>
    </header>

    <main class="main-content">
        <h1 class="page-title">메인</h1>
    </main>
</body>
</html>
