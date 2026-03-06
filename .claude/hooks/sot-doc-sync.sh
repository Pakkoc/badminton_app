#!/usr/bin/env bash
# PostToolUse Hook: 설계 문서 수정 후 의존 체인 동기화 지시
# 트리거: Edit, Write (docs/ 경로 파일만)
set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# docs/ 디렉토리의 .md 파일만 처리
if [[ "$FILE_PATH" != *docs/* ]] || [[ "$FILE_PATH" != *.md ]]; then
  exit 0
fi

# 파일명 추출
BASENAME=$(basename "$FILE_PATH")

# 문서 의존 체인: techstack → database → usecases → common-modules → state-plan
# 상위 문서 수정 시 하위 문서 갱신 필요
CONTEXT=""

case "$FILE_PATH" in
  *techstack*)
    CONTEXT="[SOT 의존 체인] techstack.md가 수정되었습니다.\n하위 문서 확인 필요: database.md → usecases/ → common-modules.md → state.md\n변경된 기술 스택이 하위 문서에 영향을 주는지 검토하세요."
    ;;
  *database*)
    CONTEXT="[SOT 의존 체인] database.md가 수정되었습니다.\n하위 문서 확인 필요: usecases/ → common-modules.md → state.md\n변경된 스키마가 모델/리포지토리 코드와 일치하는지 검토하세요."
    ;;
  *common-modules*)
    CONTEXT="[SOT 의존 체인] common-modules.md가 수정되었습니다.\n하위 문서 확인 필요: state.md\n공통 모듈 변경이 화면별 상태 설계에 영향을 주는지 검토하세요."
    ;;
  *ui-specs/*)
    CONTEXT="[SOT 동기화] UI 스펙(${BASENAME})이 수정되었습니다.\nPencil 디자인(.pen)과 불일치가 없는지 확인하세요.\n주의: 시각 디자인의 SOT는 Pencil입니다. 스펙을 먼저 수정한 경우, Pencil도 반드시 업데이트하세요."
    ;;
  *screen-registry*)
    CONTEXT="[SOT 동기화] screen-registry.yaml이 수정되었습니다.\n화면 메타정보의 SOT입니다. UI 스펙과 Pencil 디자인에 반영이 필요한지 확인하세요."
    ;;
  *design-system*)
    CONTEXT="[SOT 동기화] design-system.md가 수정되었습니다.\n디자인 토큰 변경이 모든 화면의 UI 스펙과 Pencil 디자인에 반영되어야 합니다."
    ;;
  *state.md)
    CONTEXT="[SOT 확인] 상태 설계(${BASENAME})가 수정되었습니다.\n해당 화면의 실제 코드(lib/screens/)가 상태 설계와 일치하는지 확인하세요."
    ;;
  *)
    # 기타 docs 파일은 무시
    exit 0
    ;;
esac

if [[ -n "$CONTEXT" ]]; then
  jq -n --arg ctx "<sot-auto-sync>\n${CONTEXT}\n</sot-auto-sync>" \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": $ctx } }'
fi

exit 0
