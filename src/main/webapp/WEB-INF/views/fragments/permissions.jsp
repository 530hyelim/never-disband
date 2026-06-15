<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.perm-table { width:100%; border-collapse:collapse; }
.perm-table th, .perm-table td { padding:10px 12px; border-bottom:1px solid #3f4147; font-size:0.82rem; text-align:center; }
.perm-table th { color:#949ba4; font-weight:500; position:sticky; top:0; background:#2b2d31; cursor:default; }
.perm-table th:first-child { text-align:left; cursor:pointer; }
.perm-table th:first-child:hover { color:#e6edf3; }
.perm-table td:first-child { text-align:left; color:#e6edf3; font-weight:500; }
.perm-table tr:hover td { background:#32343a; }
.perm-filter-bar { display:flex; gap:6px; margin-bottom:12px; flex-wrap:wrap; align-items:center; }
.perm-filter-btn { font-size:0.78rem; padding:4px 12px; border-radius:12px; border:1px solid #3f4147; background:transparent; color:#949ba4; cursor:pointer; font-family:inherit; transition:all 0.1s; }
.perm-filter-btn.active { background:#5865F2; border-color:#5865F2; color:#fff; }
</style>

<div style="max-width:900px;margin:0 auto;">
    <h2 style="font-size:1.2rem;font-weight:700;margin-bottom:8px;">권한 관리</h2>
    <p style="font-size:0.85rem;color:#949ba4;margin-bottom:24px;">길드 멤버에게 오피서 권한을 부여합니다.</p>

    <div style="display:flex;gap:12px;margin-bottom:12px;flex-wrap:wrap;align-items:center;">
        <input type="text" id="permSearchInput" placeholder="캐릭터명 검색..." oninput="applyPermFilters()" style="flex:1;min-width:180px;max-width:300px;padding:8px 12px;background:#1e1f22;border:1px solid #3f4147;border-radius:6px;color:#e6edf3;font-size:0.82rem;font-family:inherit;outline:none;box-sizing:border-box;">
        <select id="permSortSelect" onchange="applyPermFilters()" style="padding:8px 12px;background:#1e1f22;border:1px solid #3f4147;border-radius:6px;color:#e6edf3;font-size:0.82rem;font-family:inherit;outline:none;cursor:pointer;">
            <option value="name_asc">오름차순</option>
            <option value="name_desc">내림차순</option>
            <option value="roles_desc">권한 많은 순</option>
        </select>
    </div>

    <div class="perm-filter-bar">
        <button class="perm-filter-btn active" onclick="setPermFilter('ALL', this)">전체</button>
        <button class="perm-filter-btn" onclick="setPermFilter('MEMBER', this)">Member</button>
        <button class="perm-filter-btn" onclick="setPermFilter('CONTENTS_LEADER', this)">Contents Leader</button>
        <button class="perm-filter-btn" onclick="setPermFilter('RECRUITER', this)">Recruiter</button>
        <button class="perm-filter-btn" onclick="setPermFilter('SILVER_MASTER', this)">Silver Master</button>
        <button class="perm-filter-btn" onclick="setPermFilter('REGEAR_OFFICER', this)">Regear Officer</button>
    </div>

    <div class="admin-section" style="max-height:500px;overflow-y:auto;">
        <table class="perm-table" id="permTable">
            <thead>
                <tr>
                    <th style="min-width:120px;">캐릭터명</th>
                    <th title="사이트 이용 권한">MEMBER</th>
                    <th title="Mandatory 파티 생성 가능">CONTENTS LEADER</th>
                    <th title="가입신청 페이지 열람 가능">RECRUITER</th>
                    <th title="은행에서 실버 입출금 가능">SILVER MASTER</th>
                    <th title="리기어 신청 승인/반려 가능">REGEAR OFFICER</th>
                </tr>
            </thead>
            <tbody id="permTableBody">
                <tr><td colspan="6" style="text-align:center;color:#949ba4;">불러오는 중...</td></tr>
            </tbody>
        </table>
    </div>
    <div id="permPagination" style="display:flex;align-items:center;justify-content:center;gap:8px;margin-top:12px;"></div>
</div>

<script>
var permMembers = [];
var permRoles = ['MEMBER', 'CONTENTS_LEADER', 'RECRUITER', 'SILVER_MASTER', 'REGEAR_OFFICER'];
var currentPermFilter = 'ALL';
var permPage = 1;
var permPageSize = 30;
var permFilteredMembers = [];

function loadPermMembers() {
    fetch('/' + guildSubdomain + '/admin/permissions/members')
        .then(function(r) { return r.json(); })
        .then(function(members) {
            permMembers = members;
            permPage = 1;
            applyPermFilters();
        })
        .catch(function() {
            document.getElementById('permTableBody').innerHTML = '<tr><td colspan="6" style="text-align:center;color:#ed4245;">로드 실패</td></tr>';
        });
}

function setPermFilter(filter, btn) {
    currentPermFilter = filter;
    document.querySelectorAll('.perm-filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    permPage = 1;
    applyPermFilters();
}

function applyPermFilters() {
    var query = document.getElementById('permSearchInput').value.toLowerCase();
    var sort = document.getElementById('permSortSelect').value;

    permFilteredMembers = permMembers.filter(function(m) {
        if (query && m.characterName.toLowerCase().indexOf(query) === -1) return false;
        if (currentPermFilter !== 'ALL') {
            if (!m.roles || m.roles.indexOf(currentPermFilter) === -1) return false;
        }
        return true;
    });

    permFilteredMembers.sort(function(a, b) {
        if (sort === 'name_asc') return a.characterName.localeCompare(b.characterName);
        if (sort === 'name_desc') return b.characterName.localeCompare(a.characterName);
        if (sort === 'roles_desc') return (b.roles ? b.roles.length : 0) - (a.roles ? a.roles.length : 0);
        return 0;
    });

    renderPermPage();
}

function renderPermPage() {
    var totalPages = Math.ceil(permFilteredMembers.length / permPageSize) || 1;
    if (permPage > totalPages) permPage = totalPages;
    var start = (permPage - 1) * permPageSize;
    var pageMembers = permFilteredMembers.slice(start, start + permPageSize);
    renderPermTable(pageMembers);
    renderPermPagination(totalPages);
}

function renderPermTable(members) {
    var tbody = document.getElementById('permTableBody');
    if (members.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#949ba4;">멤버가 없습니다</td></tr>';
        return;
    }
    var html = '';
    members.forEach(function(m) {
        html += '<tr><td>' + escapeHtmlPerm(m.characterName) + '</td>';
        permRoles.forEach(function(role) {
            var has = m.roles && m.roles.indexOf(role) !== -1;
            var checked = has ? 'checked' : '';
            html += '<td><label class="toggle"><input type="checkbox" ' + checked + ' onchange="togglePerm(' + m.memberId + ',\'' + role + '\',this.checked)"><span class="toggle-slider"></span></label></td>';
        });
        html += '</tr>';
    });
    tbody.innerHTML = html;
}

function renderPermPagination(totalPages) {
    var container = document.getElementById('permPagination');
    if (totalPages <= 1) { container.innerHTML = ''; return; }
    var html = '';
    html += '<button onclick="goPermPage(' + (permPage - 1) + ')" ' + (permPage <= 1 ? 'disabled' : '') + ' style="padding:4px 10px;background:transparent;border:1px solid #3f4147;border-radius:4px;color:#949ba4;cursor:pointer;font-family:inherit;font-size:0.8rem;">&lt;</button>';
    html += '<span style="font-size:0.8rem;color:#949ba4;">' + permPage + ' / ' + totalPages + '</span>';
    html += '<button onclick="goPermPage(' + (permPage + 1) + ')" ' + (permPage >= totalPages ? 'disabled' : '') + ' style="padding:4px 10px;background:transparent;border:1px solid #3f4147;border-radius:4px;color:#949ba4;cursor:pointer;font-family:inherit;font-size:0.8rem;">&gt;</button>';
    container.innerHTML = html;
}

function goPermPage(page) {
    var totalPages = Math.ceil(permFilteredMembers.length / permPageSize) || 1;
    if (page < 1 || page > totalPages) return;
    permPage = page;
    renderPermPage();
}

function togglePerm(memberId, role, grant) {
    fetch('/' + guildSubdomain + '/admin/permissions/members/' + memberId + '/role', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'role=' + role + '&grant=' + grant + '&' + csrfParam + '=' + csrfToken
    }).then(function(r) { return r.json(); }).then(function(d) {
        if (!d.success) alert(d.message || '처리에 실패했습니다.');
        else {
            permMembers.forEach(function(m) {
                if (m.memberId === memberId) {
                    if (grant && m.roles.indexOf(role) === -1) m.roles.push(role);
                    if (!grant) m.roles = m.roles.filter(function(r) { return r !== role; });
                }
            });
        }
    });
}

function escapeHtmlPerm(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
}

loadPermMembers();
</script>
