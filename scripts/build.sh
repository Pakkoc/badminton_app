#!/usr/bin/env bash
# .env 파일에서 dart-define을 자동 생성하여 빌드하는 스크립트
# 사용법: ./scripts/build.sh [추가 flutter build 옵션]
# 예시:
#   ./scripts/build.sh                    # release APK 빌드
#   ./scripts/build.sh --debug            # debug APK 빌드
#   ./scripts/build.sh appbundle          # AAB 빌드
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env 파일이 없습니다. .env.example을 참고하여 생성하세요."
  exit 1
fi

# .env에서 필요한 키만 추출하여 --dart-define 옵션 생성
DART_DEFINES=""
REQUIRED_KEYS=(SUPABASE_URL SUPABASE_ANON_KEY NAVER_MAP_CLIENT_ID NAVER_MAP_CLIENT_SECRET)

for key in "${REQUIRED_KEYS[@]}"; do
  value=$(grep "^${key}=" "$ENV_FILE" | head -1 | cut -d'=' -f2-)
  if [[ -z "$value" ]]; then
    echo "WARNING: ${key}가 .env에 없거나 비어있습니다."
  else
    DART_DEFINES="$DART_DEFINES --dart-define=${key}=${value}"
  fi
done

# 기본: apk --release, 인자가 있으면 덮어쓰기
BUILD_TYPE="apk"
BUILD_MODE="--release"

if [[ $# -gt 0 ]]; then
  case "$1" in
    appbundle|apk)
      BUILD_TYPE="$1"
      shift
      ;;
    --debug|--profile|--release)
      BUILD_MODE="$1"
      shift
      ;;
  esac
fi

# 남은 인자 처리
if [[ $# -gt 0 ]]; then
  case "$1" in
    --debug|--profile|--release)
      BUILD_MODE="$1"
      shift
      ;;
  esac
fi

echo "=== 거트알림 빌드 ==="
echo "  타입: $BUILD_TYPE"
echo "  모드: $BUILD_MODE"
echo "  dart-define: ${#REQUIRED_KEYS[@]}개 키 로드됨"
echo ""

eval flutter build "$BUILD_TYPE" "$BUILD_MODE" $DART_DEFINES "$@"
