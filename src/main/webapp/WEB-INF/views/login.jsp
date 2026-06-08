<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Never Disband - 로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-dark d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="card shadow-lg" style="width: 400px;">
        <div class="card-body text-center p-5">
            <h2 class="mb-4">Never Disband</h2>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" role="alert">
                    ${errorMessage}
                </div>
            </c:if>

            <p class="text-muted mb-4">Discord 계정으로 로그인하세요 :)</p>

            <a href="${authUrl}" class="btn btn-primary btn-lg w-100">
                Discord로 로그인
            </a>
        </div>
    </div>
</body>
</html>
