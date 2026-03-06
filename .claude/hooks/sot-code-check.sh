#!/usr/bin/env bash
# PostToolUse Hook: 코드 수정 후 스펙/문서 역방향 확인
# 트리거: Edit, Write (lib/ 경로 파일만)
# 주의: 이 Hook은 cascade 루프를 방지하기 위해 "확인만" 수행
set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# lib/ 디렉토리의 .dart 파일만 처리
if [[ "$FILE_PATH" != *lib/* ]] || [[ "$FILE_PATH" != *.dart ]]; then
  exit 0
fi

# SOT cascade에 의한 수정인지 확인 (cascade 중이면 무한루프 방지)
# cascade 트리거가 이미 활성화된 상태에서의 코드 수정은 검증만
if [[ "$FILE_PATH" == *lib/screens/* ]]; then
  FILENAME=$(basename "$FILE_PATH" .dart)
  SCREEN_NAME=$(echo "$FILENAME" | sed 's/_screen$//' | sed 's/_/-/g')

  if [[ -f "docs/ui-specs/${SCREEN_NAME}.md" ]]; then
    jq -n --arg screen "$SCREEN_NAME" --arg spec "docs/ui-specs/${SCREEN_NAME}.md" \
      '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": ("<sot-verify>\n[SOT 검증] 화면 코드(" + $screen + ")가 수정되었다.\nUI 스펙(" + $spec + ")과 코드가 일치하는지 확인하라. 불일치가 있으면 코드를 스펙에 맞게 수정하라.\n단, 이 확인은 현재 작업의 일부로 이미 수행 중이라면 건너뛰어도 된다.\n</sot-verify>") } }'
  fi

elif [[ "$FILE_PATH" == *lib/models/* ]]; then
  jq -n \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "<sot-verify>\n[SOT 검증] 모델 코드가 수정되었다.\ndocs/database.md 스키마와 일치하는지 확인하라. 불일치가 있으면 코드를 database.md에 맞게 수정하라.\n단, 이 확인은 현재 작업의 일부로 이미 수행 중이라면 건너뛰어도 된다.\n</sot-verify>" } }'

elif [[ "$FILE_PATH" == *lib/providers/* ]]; then
  jq -n \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "<sot-verify>\n[SOT 검증] Provider 코드가 수정되었다.\n해당 화면의 docs/pages/*/state.md와 일치하는지 확인하라. 불일치가 있으면 코드를 state.md에 맞게 수정하라.\n단, 이 확인은 현재 작업의 일부로 이미 수행 중이라면 건너뛰어도 된다.\n</sot-verify>" } }'
fi

exit 0
