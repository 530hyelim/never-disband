# Never Disband

Spring Boot + JSP + MySQL 웹 애플리케이션  

## 기술 스택

- Java 17
- Spring Boot 3.3
- Spring Security
- MySQL 8.0
- Maven
- Docker
- OCI Ubuntu
- GitHub Actions

---

## 로컬 개발환경

### 필요한 것

- Docker Desktop ([다운로드](https://www.docker.com/products/docker-desktop/))
- DB 클라이언트

### 실행

```bash
git clone https://github.com/530hyelim/never-disband.git
cd never-disband
# .env 파일 추가
docker compose up --build
```

`http://localhost:8080` 접속하여 확인

### 개발 흐름

- JSP 파일 수정 → 브라우저 새로고침 하여 반영
- Java 코드 수정 → `docker compose restart app`
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

1. Issue & branch 생성
2. 작업 후 commit & push
3. GitHub에서 main으로 PR 생성
4. PR merge → 자동 배포

---

## 운영 배포

### 자동 배포

`main` 브랜치에 PR merge 시 GitHub Actions가 자동으로 운영서버에 배포

### 수동 배포

```bash
ssh ubuntu@<서버IP>
cd /home/ubuntu/never-disband
./deploy.sh
```

---

## 프로젝트 구조

```
never-disband/
├── pom.xml                          # Maven 설정
├── Dockerfile                       # Docker 이미지 빌드
├── docker-compose.yml               # 로컬 개발 환경
├── deploy.sh                        # 서버 수동 배포
├── .github/workflows/deploy.yml     # 자동 배포
├── infra/
│   └── neverdisband.service         # systemd 서비스 파일
└── src/main/
    ├── java/com/neverdisband/
    │   ├── config/                  # Security, OAuth 설정
    │   ├── controller/              # Spring MVC 컨트롤러
    │   ├── dao/                     # DB 접근 (JdbcTemplate)
    │   ├── model/                   # 도메인 모델
    │   ├── service/                 # 비즈니스 로직
    │   └── exception/               # 커스텀 예외
    ├── resources/
    │   └── application.properties   # 앱 설정
    └── webapp/
        ├── index.jsp                # 메인 페이지
        └── WEB-INF/views/          # JSP 뷰
```
