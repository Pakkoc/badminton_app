#!/usr/bin/env bash
# PostToolUse Hook: Pencil batch_design 후 UI spec 자동 동기화 지시
# 트리거: mcp__pencil__batch_design
set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Pencil 디자인 수정 감지
if [[ "$TOOL_NAME" == "mcp__pencil__batch_design" ]]; then
  cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "<sot-auto-sync>\n[SOT 자동 동기화] Pencil 디자인이 수정되었습니다.\n\n반드시 다음을 수행하세요:\n1. 수정된 화면의 UI 스펙(docs/ui-specs/*.md)을 Pencil 디자인과 일치하도록 업데이트\n2. 동일 요소가 있는 다른 화면도 확인하여 일관성 유지\n3. screen-registry.yaml의 pencil_id가 정확한지 확인\n\n이 작업을 완료한 후에만 다음 작업으로 진행하세요.\n</sot-auto-sync>"
  }
}
HOOK_JSON
fi

exit 0
