<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Never Disband</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark">
        <div class="container">
            <span class="navbar-brand">Never Disband</span>
            <div class="d-flex align-items-center">
                <% if (session.getAttribute("user_avatar_url") != null) { %>
                    <img src="<%= session.getAttribute("user_avatar_url") %>"
                         alt="avatar" class="rounded-circle me-2" width="32" height="32">
                <% } %>
                <span class="text-white me-3"><%= session.getAttribute("user_name") %></span>
                <%-- Spring Security 로그아웃은 POST 방식 (CSRF 보호) --%>
                <form action="/logout" method="post" class="d-inline">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn btn-outline-light btn-sm">로그아웃</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="card">
            <div class="card-body text-center">
                <h3>환영합니다, <%= session.getAttribute("user_name") %>님!</h3>
                <p class="text-muted">Discord 로그인에 성공했습니다.</p>
            </div>
        </div>
    </div>
</body>
</html>
