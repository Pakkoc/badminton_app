#!/usr/bin/env bash
# PostToolUse Hook: 코드 수정 후 spec 준수 확인 지시
# 트리거: Edit, Write (lib/ 경로 파일만)
set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# lib/ 디렉토리의 .dart 파일만 처리
if [[ "$FILE_PATH" != *lib/* ]] || [[ "$FILE_PATH" != *.dart ]]; then
  exit 0
fi

# 화면 코드인지 확인 (lib/screens/)
if [[ "$FILE_PATH" == *lib/screens/* ]]; then
  # 화면 이름 추출 (예: lib/screens/owner/order_create_screen.dart → order-create)
  FILENAME=$(basename "$FILE_PATH" .dart)
  # _screen 접미사 제거, _ 를 - 로 변환
  SCREEN_NAME=$(echo "$FILENAME" | sed 's/_screen$//' | sed 's/_/-/g')

  # 해당 화면의 UI spec이 존재하는지 확인
  SPEC_CANDIDATES=(
    "docs/ui-specs/${SCREEN_NAME}.md"
  )

  FOUND_SPEC=""
  for spec in "${SPEC_CANDIDATES[@]}"; do
    if [[ -f "$spec" ]]; then
      FOUND_SPEC="$spec"
      break
    fi
  done

  if [[ -n "$FOUND_SPEC" ]]; then
    jq -n --arg screen "$SCREEN_NAME" --arg spec "$FOUND_SPEC" \
      '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": ("<sot-auto-sync>\n[SOT 코드-스펙 확인] 화면 코드(" + $screen + ")가 수정되었습니다.\nUI 스펙(" + $spec + ")에 명시된 색상, 크기, 텍스트를 정확히 사용하고 있는지 확인하세요.\n</sot-auto-sync>") } }'
  fi

# 모델/리포지토리 코드인지 확인
elif [[ "$FILE_PATH" == *lib/models/* ]] || [[ "$FILE_PATH" == *lib/repositories/* ]]; then
  jq -n \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "<sot-auto-sync>\n[SOT 데이터 확인] 모델 또는 리포지토리 코드가 수정되었습니다.\ndocs/database.md의 스키마 정의와 일치하는지 확인하세요.\n</sot-auto-sync>" } }'

# Provider 코드인지 확인
elif [[ "$FILE_PATH" == *lib/providers/* ]]; then
  jq -n \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "<sot-auto-sync>\n[SOT 상태 확인] Provider 코드가 수정되었습니다.\n해당 화면의 docs/pages/*/state.md 상태 설계와 일치하는지 확인하세요.\n</sot-auto-sync>" } }'
fi

exit 0
