#!/bin/bash
# ==============================================
# AWS Secrets Manager에서 값을 가져와 .env 생성
# EC2 배포 시 docker-compose up 전에 실행
# 사용법: bash scripts/fetch-secrets.sh [환경명]
# 예시:   bash scripts/fetch-secrets.sh prod
# ==============================================

set -e  # 오류 발생 시 즉시 중단

ENV=${1:-prod}
SECRET_NAME="erp/${ENV}"
REGION="ap-northeast-2"
OUTPUT_FILE=".env"

echo "[1/3] AWS Secrets Manager에서 시크릿 가져오는 중... (${SECRET_NAME})"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --region "${REGION}" \
  --query SecretString \
  --output text)

if [ -z "$SECRET_JSON" ]; then
  echo "ERROR: 시크릿을 가져오지 못했습니다. IAM 권한 또는 시크릿 이름을 확인하세요."
  exit 1
fi

echo "[2/3] .env 파일 생성 중..."

# JSON → KEY=VALUE 형식으로 변환
echo "$SECRET_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for k, v in data.items():
    # 값에 특수문자가 있어도 안전하게 처리
    print(f'{k}={v}')
" > "$OUTPUT_FILE"

chmod 600 "$OUTPUT_FILE"  # 소유자만 읽기/쓰기 가능

echo "[3/3] 완료: ${OUTPUT_FILE} 생성됨 ($(wc -l < $OUTPUT_FILE)개 항목)"
echo "이제 docker-compose up -d 를 실행하세요."
