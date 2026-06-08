# Never Disband

Java + JSP + MySQL 웹 애플리케이션

## 기술 스택

- Java 17
- Tomcat 10.1
- MySQL 8.0
- Maven
- Docker

---

## 로컬 개발환경 설정

### 필요한 것

- Docker Desktop ([다운로드](https://www.docker.com/products/docker-desktop/))
- DB 클라이언트

### 실행

```bash
git clone https://github.com/530hyelim/never-disband.git
cd never-disband
docker-compose up
```

`http://localhost:8080` 접속하여 확인

### 개발 흐름

- JSP 파일 수정 → 브라우저 새로고침 하여 반영
- Java(Servlet) 수정 → `docker-compose restart app`
- DB 스키마 변경 → DB 클라이언트로 직접 수정

### DB 접속 정보

`.env` 파일 참고

---

## 브랜치 전략

| 브랜치 | 용도 |
|--------|------|
| `main` | 운영 배포 (merge 시 자동 배포) |
| `issue/기능명` | 기능별 작업 브랜치 |

### 작업 흐름

1. Issue 생성
2. 브랜치 생성: `git checkout -b issue/기능명`
3. 작업 후 commit & push
4. GitHub에서 main으로 PR 생성
5. PR merge → 자동 배포

---

## 운영 배포

### 자동 배포

`main` 브랜치에 PR merge 또는 직접 push하면 GitHub Actions가 자동으로 운영 서버에 배포

### 수동 배포 (서버 직접 접속 시)

```bash
ssh ubuntu@<서버IP>
cd /home/ubuntu/never-disband
./deploy.sh
```

---

## 프로젝트 구조

```
never-disband/
├── pom.xml                         # Maven 설정
├── Dockerfile                      # Docker 이미지 빌드
├── docker-compose.yml              # 로컬 개발 환경 (Tomcat only)
├── deploy.sh                       # 서버 수동 배포
├── .github/workflows/deploy.yml    # 자동 배포 (GitHub Actions)
└── src/main/
    ├── java/com/neverdisband/      # Java 소스 (Servlet, DAO 등)
    ├── resources/                  # 설정 파일
    └── webapp/
        ├── index.jsp               # 페이지
        └── WEB-INF/web.xml         # 웹앱 설정
```
