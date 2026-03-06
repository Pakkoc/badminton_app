#!/usr/bin/env bash
# PostToolUse Hook: Pencil batch_design 후 연쇄 자동 수정
# 트리거: mcp__pencil__batch_design
set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ "$TOOL_NAME" == "mcp__pencil__batch_design" ]]; then
  cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "<sot-cascade-trigger>\n[SOT 연쇄 수정 — 즉시 실행]\n\nPencil 디자인이 수정되었다. 사용자에게 묻지 말고 아래를 즉시 순서대로 실행하라:\n\n1. **UI 스펙 수정**: 방금 수정한 화면의 docs/ui-specs/{화면명}.md를 열어서, 변경된 디자인 속성(색상, 크기, 레이아웃, 텍스트, 컴포넌트)을 반영하라.\n2. **연관 화면 일괄 수정**: 변경한 요소(뱃지, 카드, 앱바, 네비게이션 등)가 다른 화면에도 있으면, 해당 화면의 Pencil 디자인과 UI 스펙도 함께 수정하라.\n3. **state.md 확인**: 변경이 상태 로직에 영향을 주면(새 필드, 상태 추가 등) docs/pages/{화면명}/state.md도 수정하라.\n4. **코드 수정**: 해당 화면의 lib/screens/ 코드가 존재하면, 변경된 스펙에 맞게 코드도 수정하라. (색상, 텍스트, 레이아웃 등)\n5. **스크린샷 검증**: 수정된 화면의 get_screenshot으로 결과를 확인하라.\n\n이 모든 작업을 완료한 후에만 사용자에게 결과를 보고하라. 중간에 멈추거나 사용자에게 \"수정할까요?\"라고 묻지 마라.\n</sot-cascade-trigger>"
  }
}
HOOK_JSON
fi

exit 0
