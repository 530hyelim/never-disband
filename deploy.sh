#!/bin/bash
set -e  # 오류 발생 시 즉시 중단

APP_DIR="/home/ubuntu/never-disband"
JAR_NAME="never-disband.jar"
SERVICE_NAME="neverdisband"

echo "=== 배포 시작 ==="

# 1. 최신 코드 받기
cd $APP_DIR
git pull origin main

# 2. 빌드 (테스트 생략, 메모리 제한)
echo "=== 빌드 중... ==="
MAVEN_OPTS="-Xmx256m" mvn clean package -DskipTests -B

# 3. 서비스 재시작
echo "=== 서비스 재시작 ==="
sudo systemctl restart $SERVICE_NAME

# 4. 시작 확인 (최대 30초 대기)
echo "=== 시작 확인 중... ==="
for i in $(seq 1 30); do
    if curl -sf http://localhost:8080/login > /dev/null 2>&1; then
        echo "=== 배포 완료! ==="
        exit 0
    fi
    echo "대기 중... ($i/30)"
    sleep 1
done

echo "=== 경고: 30초 내 응답 없음. 로그 확인: journalctl -u $SERVICE_NAME -n 50 ==="
exit 1
