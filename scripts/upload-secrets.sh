#!/bin/bash
# ==============================================
# 로컬 .env 파일을 AWS Secrets Manager에 업로드
# 최초 1회 또는 값 변경 시 실행
# 사용법: bash scripts/upload-secrets.sh [환경명]
# 예시:   bash scripts/upload-secrets.sh prod
# ==============================================

set -e

ENV=${1:-prod}
SECRET_NAME="erp/${ENV}"
REGION="ap-northeast-2"
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: ${ENV_FILE} 파일이 없습니다."
  exit 1
fi

echo "[1/3] .env 파일을 JSON으로 변환 중..."

# KEY=VALUE → JSON 변환 (주석, 빈 줄 제외)
SECRET_JSON=$(python3 -c "
import sys

data = {}
with open('${ENV_FILE}', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            continue
        key, _, value = line.partition('=')
        data[key.strip()] = value.strip()

import json
print(json.dumps(data))
")

echo "[2/3] AWS Secrets Manager에 업로드 중... (${SECRET_NAME})"

# 시크릿이 이미 존재하면 update, 없으면 create
if aws secretsmanager describe-secret \
     --secret-id "${SECRET_NAME}" \
     --region "${REGION}" > /dev/null 2>&1; then
  aws secretsmanager update-secret \
    --secret-id "${SECRET_NAME}" \
    --secret-string "${SECRET_JSON}" \
    --region "${REGION}" > /dev/null
  echo "[3/3] 기존 시크릿 업데이트 완료: ${SECRET_NAME}"
else
  aws secretsmanager create-secret \
    --name "${SECRET_NAME}" \
    --description "ERP ${ENV} 환경 변수" \
    --secret-string "${SECRET_JSON}" \
    --region "${REGION}" > /dev/null
  echo "[3/3] 새 시크릿 생성 완료: ${SECRET_NAME}"
fi
