<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.info-icon { display:inline-flex; align-items:center; justify-content:center; width:15px; height:15px; border-radius:50%; border:1px solid #6e7681; color:#6e7681; font-size:0.6rem; font-weight:700; cursor:default; position:relative; font-style:normal; margin-left:5px; flex-shrink:0; }
.info-icon:hover { border-color:#e6edf3; color:#e6edf3; }
.info-icon .info-tooltip { position:absolute; bottom:calc(100% + 8px); left:0; background:#1e1f22; border:1px solid #3f4147; color:#c9d1d9; font-size:0.75rem; font-weight:400; padding:8px 12px; border-radius:8px; white-space:nowrap; pointer-events:none; opacity:0; transition:opacity 0.15s; z-index:100; box-shadow:0 4px 12px rgba(0,0,0,0.4); }
.info-icon:hover .info-tooltip { opacity:1; }
.page-drag-handle { cursor:grab; display:inline-flex; align-items:center; padding:2px; color:#5a6173; margin-right:10px; }
.page-drag-handle:active { cursor:grabbing; }
.page-drag-handle svg { width:12px; height:14px; fill:currentColor; }
.page-row.dragging { opacity:0.4; }
.page-row.drag-over { border-top:2px solid #5865F2; }
</style>

<div class="admin-content" style="max-width:800px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:28px;">사이트 설정</h2>
    <!-- <p style="font-size:0.85rem;color:#949ba4;margin-bottom:28px;">페이지 사용 여부와 디스코드 채널 연동을 설정합니다.</p> -->

    <div class="admin-section">
        <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:0px;">페이지 설정</h3>
        <div style="display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:16px;margin-top:-10px;">
            <p style="font-size:0.82rem;color:#949ba4;">수정내용 반영을 위해 페이지를 새로고침 해주세요.</p>
            <button onclick="location.reload()" style="display:inline-flex;align-items:center;gap:6px;padding:9px 18px;background:transparent;color:#8b949e;border-radius:8px;font-size:0.84rem;font-weight:600;border:1px solid #30363d;cursor:pointer;font-family:inherit;">
                <svg viewBox="0 0 24 24" style="width:14px;height:14px;fill:currentColor;"><path d="M17.65 6.35A7.958 7.958 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg>
                새로고침
            </button>
        </div>

        <c:forEach var="page" items="${pages}">
            <div class="page-row" draggable="true" data-page-type="${page.pageType}">
                <div class="page-info" style="display:flex;align-items:center;">
                    <span class="page-drag-handle"><svg viewBox="0 0 10 14"><circle cx="3" cy="2" r="1.5"/><circle cx="7" cy="2" r="1.5"/><circle cx="3" cy="7" r="1.5"/><circle cx="7" cy="7" r="1.5"/><circle cx="3" cy="12" r="1.5"/><circle cx="7" cy="12" r="1.5"/></svg></span>
                    <span class="page-name">
                        <c:choose>
                            <c:when test="${page.pageType == 'HOME'}">홈</c:when>
                            <c:when test="${page.pageType == 'RECRUIT'}">컨텐츠 모집</c:when>

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
        <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:12px;">디스코드 설정</h3>
        <p style="font-size:0.82rem;color:#949ba4;margin-bottom:20px;">사이트와 연동된 디스코드 서버의 채널을 설정합니다.</p>

        <div style="display:flex;flex-direction:column;gap:12px;margin-bottom:16px;">
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:120px;">연동된 서버</span>
                <c:choose>
                    <c:when test="${not empty discordServerName}"><span style="font-size:0.82rem;color:#57F287;font-weight:500;">${discordServerName}</span></c:when>
                    <c:otherwise><span style="font-size:0.82rem;color:#ed4245;">연결 안 됨</span></c:otherwise>
                </c:choose>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:120px;display:inline-flex;align-items:center;">길드 멤버 역할
                    <i class="info-icon">i<span class="info-tooltip">
                        길드원이 아니더라도 이 역할을 가진 디스코드 멤버에게 사이트 이용 권한이 자동 부여됩니다.<br>
                        미설정 시 인게임 길드원만 사이트 이용이 가능합니다.
                    </span></i></span>
                <select class="channel-select" id="select-member-role" data-prev="" onchange="onMemberRoleSelect(this)">
                    <option value="">미설정</option>
                </select>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:120px;display:inline-flex;align-items:center;">모집 채널
                    <i class="info-icon">i<span class="info-tooltip">
                        해당 채널의 게시글 및 접근 권한이 컨텐츠 모집 페이지에 동기화됩니다.<br>
                        미설정 시 디스코드 연동 없이 사이트에서만 운영이 가능합니다.
                    </span></i></span>
                <select class="channel-select" id="select-recruit-channel" data-prev="" onchange="onRecruitChannelSelect(this)">
                    <option value="">미설정</option>
                </select>
            </div>
            <div style="display:flex;align-items:center;gap:10px;min-height:36px;">
                <span style="font-size:0.82rem;color:#e6edf3;min-width:120px;display:inline-flex;align-items:center;">보이스 카테고리
                    <i class="info-icon">i<span class="info-tooltip">
                        모집 파티의 음성채널이 이 카테고리 아래에 생성됩니다.<br>
                        미설정 시 모집 채널의 카테고리 또는 서버 최상위에 생성됩니다.
                    </span></i></span>
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

        fetch('/' + guildSubdomain + '/setting/channels')
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
        fetch('/' + guildSubdomain + '/setting/categories')
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
        fetch('/' + guildSubdomain + '/setting/roles')
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
        fetch('/' + guildSubdomain + '/setting/pages/toggle', {
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
            fetch('/' + guildSubdomain + '/setting/channels/unlink', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'pageType=RECRUIT&' + csrfParam + '=' + csrfToken
            }).then(function(r) { return r.json(); }).then(function(d) {
                if (d.success) selectEl.setAttribute('data-prev', '');
            });
        } else {
            fetch('/' + guildSubdomain + '/setting/channels/link', {
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
        fetch('/' + guildSubdomain + '/setting/voice-category', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'categoryId=' + (categoryId || '') + '&' + csrfParam + '=' + csrfToken
        }).then(function(r) { return r.json(); }).then(function(d) {
            if (d.success) selectEl.setAttribute('data-prev', categoryId);
        });
    }

    function onMemberRoleSelect(selectEl) {
        var roleId = selectEl.value;
        fetch('/' + guildSubdomain + '/setting/member-role', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'roleId=' + (roleId || '') + '&' + csrfParam + '=' + csrfToken
        }).then(function(r) { return r.json(); }).then(function(d) {
            if (d.success) { selectEl.setAttribute('data-prev', roleId); loadMembers(); }
        });
    }

    // ===== 페이지 순서 드래그 =====
    (function() {
        var draggedRow = null;
        var rows = document.querySelectorAll('.page-row[draggable="true"]');

        rows.forEach(function(row) {
            row.addEventListener('dragstart', function(e) {
                draggedRow = row;
                row.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
            });

            row.addEventListener('dragend', function() {
                row.classList.remove('dragging');
                rows.forEach(function(r) { r.classList.remove('drag-over'); });
                draggedRow = null;
            });

            row.addEventListener('dragover', function(e) {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
                if (row !== draggedRow) {
                    row.classList.add('drag-over');
                }
            });

            row.addEventListener('dragleave', function() {
                row.classList.remove('drag-over');
            });

            row.addEventListener('drop', function(e) {
                e.preventDefault();
                row.classList.remove('drag-over');
                if (!draggedRow || draggedRow === row) return;

                var container = row.parentNode;
                var allRows = Array.from(container.querySelectorAll('.page-row[draggable="true"]'));
                var draggedIdx = allRows.indexOf(draggedRow);
                var targetIdx = allRows.indexOf(row);

                if (draggedIdx < targetIdx) {
                    container.insertBefore(draggedRow, row.nextSibling);
                } else {
                    container.insertBefore(draggedRow, row);
                }

                savePageOrder();
            });
        });
    })();

    function savePageOrder() {
        var rows = document.querySelectorAll('.page-row[draggable="true"]');
        var order = [];
        rows.forEach(function(row) {
            order.push(row.getAttribute('data-page-type'));
        });

        fetch('/' + guildSubdomain + '/setting/pages/reorder', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'order=' + order.join(',') + '&' + csrfParam + '=' + csrfToken
        });
    }


</script>
