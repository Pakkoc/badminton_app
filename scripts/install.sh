#!/usr/bin/env bash
# .env 기반 빌드 후 연결된 모든 기기에 설치하는 스크립트
# 사용법: ./scripts/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 1단계: 빌드 ==="
bash "$SCRIPT_DIR/build.sh"

echo ""
echo "=== 2단계: 연결된 기기에 설치 ==="

# Android 기기 목록 추출
DEVICES=$(flutter devices 2>/dev/null | grep 'android' | sed 's/.*• \([^ ]*\) *• android.*/\1/')

if [[ -z "$DEVICES" ]]; then
  echo "ERROR: 연결된 Android 기기가 없습니다."
  exit 1
fi

PIDS=()
for device in $DEVICES; do
  echo "  설치 시작: $device"
  flutter install -d "$device" &
  PIDS+=($!)
done

# 모든 설치 완료 대기
FAIL=0
for pid in "${PIDS[@]}"; do
  if ! wait "$pid"; then
    FAIL=1
  fi
done

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "=== 모든 기기 설치 완료 ==="
else
  echo "=== 일부 기기 설치 실패 ==="
  exit 1
fi
