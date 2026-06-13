<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="admin-content" style="max-width:800px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:8px;">사이트 관리</h2>
    <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">페이지 사용 여부와 디스코드 채널 연동을 설정합니다.</p>

    <div class="admin-section">
        <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:16px;">페이지 관리</h3>

        <c:forEach var="page" items="${pages}">
            <div class="page-row">
                <div class="page-info">
                    <span class="page-name">
                        <c:choose>
                            <c:when test="${page.pageType == 'HOME'}">홈</c:when>
                            <c:when test="${page.pageType == 'RECRUIT'}">컨텐츠 모집</c:when>
                            <c:when test="${page.pageType == 'NOTICE'}">공지사항</c:when>
                            <c:when test="${page.pageType == 'ATTENDANCE'}">출석체크</c:when>
                            <c:when test="${page.pageType == 'REGEAR'}">리기어</c:when>
                            <c:otherwise>${page.pageType}</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="page-controls">
                    <label class="toggle">
                        <input type="checkbox" ${page.enabled ? 'checked' : ''} onchange="togglePage('${page.pageType}', this.checked)">
                        <span class="toggle-slider"></span>
                    </label>
                    <select class="channel-select" id="select-${page.pageType}" data-prev="${page.discordChannelId != null ? page.discordChannelId : ''}" onchange="onChannelSelect('${page.pageType}', this)">
                        <option value="">미연동</option>
                    </select>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

<script>
    var currentChannelValues = {};
    <c:forEach var="page" items="${pages}">
        <c:if test="${not empty page.discordChannelId}">
            currentChannelValues['${page.pageType}'] = '${page.discordChannelId}';
        </c:if>
    </c:forEach>

    (function() {
        fetch('/' + guildSubdomain + '/admin/channels')
            .then(function(res) { return res.json(); })
            .then(function(channels) {
                document.querySelectorAll('.channel-select').forEach(function(select) {
                    var type = select.id.replace('select-', '');
                    channels.forEach(function(ch) {
                        var opt = document.createElement('option');
                        opt.value = ch.id;
                        opt.textContent = '# ' + ch.name;
                        opt.setAttribute('data-name', ch.name);
                        if (currentChannelValues[type] === ch.id) opt.selected = true;
                        select.appendChild(opt);
                    });
                });
            })
            .catch(function() {
                document.querySelectorAll('.channel-select').forEach(function(select) {
                    select.innerHTML = '<option value="">봇 연결 필요</option>';
                    select.disabled = true;
                });
            });
    })();

    function togglePage(pageType, enabled) {
        fetch('/' + guildSubdomain + '/admin/pages/toggle', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'pageType=' + pageType + '&enabled=' + enabled + '&' + csrfParam + '=' + csrfToken
        });
    }

    function onChannelSelect(pageType, selectEl) {
        var channelId = selectEl.value;
        var channelName = selectEl.options[selectEl.selectedIndex].getAttribute('data-name') || '';
        var prevValue = selectEl.getAttribute('data-prev') || '';

        if (!channelId) {
            fetch('/' + guildSubdomain + '/admin/channels/unlink', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'pageType=' + pageType + '&' + csrfParam + '=' + csrfToken
            }).then(function(r) { return r.json(); }).then(function(d) {
                if (d.success) selectEl.setAttribute('data-prev', '');
            });
        } else {
            fetch('/' + guildSubdomain + '/admin/channels/link', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'pageType=' + pageType + '&discordChannelId=' + channelId + '&discordChannelName=' + encodeURIComponent(channelName) + '&' + csrfParam + '=' + csrfToken
            }).then(function(r) { return r.json(); }).then(function(d) {
                if (d.success) {
                    selectEl.setAttribute('data-prev', channelId);
                } else {
                    alert(d.message || '채널 연동에 실패했습니다.');
                    selectEl.value = prevValue;
                }
            });
        }
    }
</script>
