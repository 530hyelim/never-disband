<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="admin-content" style="max-width:800px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:28px;">사이트 관리</h2>
    <!-- <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">페이지 사용 여부와 디스코드 채널 연동을 설정합니다.</p> -->

    <div class="admin-section">
        <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:0px;">페이지 관리</h3>
        <div style="display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:16px;margin-top:-10px;">
            <p style="font-size:0.82rem;color:#949ba4;">수정내용 반영을 위해 페이지를 새로고침 해주세요.</p>
            <button onclick="location.reload()" style="display:inline-flex;align-items:center;gap:6px;padding:9px 18px;background:transparent;color:#8b949e;border-radius:8px;font-size:0.84rem;font-weight:600;border:1px solid #30363d;cursor:pointer;font-family:inherit;">
                <svg viewBox="0 0 24 24" style="width:14px;height:14px;fill:currentColor;"><path d="M17.65 6.35A7.958 7.958 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg>
                새로고침
            </button>
        </div>

        <c:forEach var="page" items="${pages}">
            <div class="page-row">
                <div class="page-info">
                    <span class="page-name">
                        <c:choose>
                            <c:when test="${page.pageType == 'HOME'}">홈</c:when>
                            <c:when test="${page.pageType == 'RECRUIT'}">컨텐츠 모집</c:when>
                            <c:when test="${page.pageType == 'SPLIT'}">분배</c:when>
                            <c:when test="${page.pageType == 'BANK'}">은행</c:when>
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
                </div>
            </div>
        </c:forEach>
    </div>

    <div class="admin-section" style="margin-top:32px;">
        <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:12px;">디스코드 관리</h3>
        <p style="font-size:0.82rem;color:#949ba4;margin-bottom:20px;">사이트와 연동된 디스코드 서버의 채널을 설정합니다.</p>

        <div style="display:flex;flex-direction:column;gap:12px;margin-bottom:16px;">
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:100px;">연동된 서버</span>
                <c:choose>
                    <c:when test="${not empty discordServerName}"><span style="font-size:0.82rem;color:#57F287;font-weight:500;">${discordServerName}</span></c:when>
                    <c:otherwise><span style="font-size:0.82rem;color:#ed4245;">연결 안 됨</span></c:otherwise>
                </c:choose>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:100px;">길드 멤버 역할</span>
                <select class="channel-select" id="select-member-role" data-prev="" onchange="onMemberRoleSelect(this)">
                    <option value="">미설정</option>
                </select>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:100px;">모집 채널</span>
                <select class="channel-select" id="select-recruit-channel" data-prev="" onchange="onRecruitChannelSelect(this)">
                    <option value="">미설정</option>
                </select>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:100px;">보이스 카테고리</span>
                <select class="channel-select" id="select-voice-category" data-prev="" onchange="onVoiceCategorySelect(this)">
                    <option value="">미설정</option>
                </select>
            </div>
            <div style="display:flex;align-items:center;justify-content:space-between;margin-top:16px;">
                <span style="font-size:0.82rem;color:#949ba4;">봇이 서버에서 추방되었거나 권한이 없을 때 재초대하세요.
                    <br>원활한 사용경험을 위해 봇 초대 시 관리자 권한을 허용해주세요.</span>
                <a href="${botInviteUrl}" target="_blank" style="display:inline-flex;align-items:center;gap:6px;padding:9px 18px;background:#5865F2;color:#fff;border-radius:8px;font-size:0.84rem;font-weight:600;text-decoration:none;font-family:inherit;">
                    <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:#fff;"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                    봇 재초대
                </a>
            </div>
        </div>
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
        // 모집 채널 select 로드
        var recruitSelect = document.getElementById('select-recruit-channel');
        var recruitChannelId = currentChannelValues['RECRUIT'] || '';
        recruitSelect.setAttribute('data-prev', recruitChannelId);

        fetch('/' + guildSubdomain + '/admin/channels')
            .then(function(res) { return res.json(); })
            .then(function(channels) {
                channels.forEach(function(ch) {
                    var opt = document.createElement('option');
                    opt.value = ch.id;
                    opt.textContent = ch.name;
                    opt.setAttribute('data-name', ch.name);
                    if (recruitChannelId === ch.id) opt.selected = true;
                    recruitSelect.appendChild(opt);
                });
            })
            .catch(function() { recruitSelect.innerHTML = '<option value="">봇 연결 필요</option>'; recruitSelect.disabled = true; });

        // 보이스 카테고리 select 로드
        var voiceSelect = document.getElementById('select-voice-category');
        var savedVoiceCategoryId = '${voiceCategoryId != null ? voiceCategoryId : ""}';
        voiceSelect.setAttribute('data-prev', savedVoiceCategoryId);
        fetch('/' + guildSubdomain + '/admin/categories')
            .then(function(res) { return res.json(); })
            .then(function(cats) {
                cats.forEach(function(cat) {
                    var opt = document.createElement('option');
                    opt.value = cat.id;
                    opt.textContent = cat.name;
                    if (savedVoiceCategoryId === cat.id) opt.selected = true;
                    voiceSelect.appendChild(opt);
                });
            })
            .catch(function() { voiceSelect.innerHTML = '<option value="">봇 연결 필요</option>'; voiceSelect.disabled = true; });

        // 길드 멤버 역할 select 로드
        var roleSelect = document.getElementById('select-member-role');
        var savedMemberRoleId = '${memberRoleId != null ? memberRoleId : ""}';
        roleSelect.setAttribute('data-prev', savedMemberRoleId);
        fetch('/' + guildSubdomain + '/admin/roles')
            .then(function(res) { return res.json(); })
            .then(function(roles) {
                roles.forEach(function(r) {
                    var opt = document.createElement('option');
                    opt.value = r.id;
                    opt.textContent = r.name;
                    if (savedMemberRoleId === r.id) opt.selected = true;
                    roleSelect.appendChild(opt);
                });
            })
            .catch(function() { roleSelect.innerHTML = '<option value="">봇 연결 필요</option>'; roleSelect.disabled = true; });
    })();

    function togglePage(pageType, enabled) {
        fetch('/' + guildSubdomain + '/admin/pages/toggle', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'pageType=' + pageType + '&enabled=' + enabled + '&' + csrfParam + '=' + csrfToken
        });
    }

    function onRecruitChannelSelect(selectEl) {
        var channelId = selectEl.value;
        var channelName = selectEl.options[selectEl.selectedIndex].getAttribute('data-name') || '';
        var prevValue = selectEl.getAttribute('data-prev') || '';

        if (!channelId) {
            fetch('/' + guildSubdomain + '/admin/channels/unlink', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'pageType=RECRUIT&' + csrfParam + '=' + csrfToken
            }).then(function(r) { return r.json(); }).then(function(d) {
                if (d.success) selectEl.setAttribute('data-prev', '');
            });
        } else {
            fetch('/' + guildSubdomain + '/admin/channels/link', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'pageType=RECRUIT&discordChannelId=' + channelId + '&discordChannelName=' + encodeURIComponent(channelName) + '&' + csrfParam + '=' + csrfToken
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

    function onVoiceCategorySelect(selectEl) {
        var categoryId = selectEl.value;
        fetch('/' + guildSubdomain + '/admin/voice-category', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'categoryId=' + (categoryId || '') + '&' + csrfParam + '=' + csrfToken
        }).then(function(r) { return r.json(); }).then(function(d) {
            if (d.success) selectEl.setAttribute('data-prev', categoryId);
        });
    }

    function onMemberRoleSelect(selectEl) {
        var roleId = selectEl.value;
        fetch('/' + guildSubdomain + '/admin/member-role', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'roleId=' + (roleId || '') + '&' + csrfParam + '=' + csrfToken
        }).then(function(r) { return r.json(); }).then(function(d) {
            if (d.success) selectEl.setAttribute('data-prev', roleId);
        });
    }
</script>
