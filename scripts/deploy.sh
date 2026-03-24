#!/bin/bash
# ==============================================
# EC2 배포 스크립트
# EC2에 접속 후 실행하거나, CI/CD에서 호출
# 사용법: bash scripts/deploy.sh [환경명]
# ==============================================

set -e

ENV=${1:-prod}
PROJECT_DIR="/home/ec2-user/erp-infra"

echo "=== ERP 배포 시작 (환경: ${ENV}) ==="

cd "$PROJECT_DIR"

echo "[1/4] 최신 코드 pull..."
git pull origin main

echo "[2/4] Secrets Manager에서 .env 생성..."
bash scripts/fetch-secrets.sh "$ENV"

echo "[3/4] Docker 이미지 빌드 & 컨테이너 재시작..."
docker compose pull 2>/dev/null || true   # ECR 이미지 사용 시
docker compose up -d --build

echo "[4/4] 서비스 상태 확인..."
sleep 5
docker compose ps

echo "=== 배포 완료 ==="
