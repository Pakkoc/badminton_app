#!/usr/bin/env bash
# PostToolUse Hook: 설계 문서 수정 후 연쇄 자동 수정
# 트리거: Edit, Write (docs/ 경로 파일만)
set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# docs/ 디렉토리의 .md 또는 .yaml 파일만 처리
if [[ "$FILE_PATH" != *docs/* ]]; then
  exit 0
fi
if [[ "$FILE_PATH" != *.md ]] && [[ "$FILE_PATH" != *.yaml ]]; then
  exit 0
fi

# 아카이브 파일은 무시
if [[ "$FILE_PATH" == *archive/* ]]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
CONTEXT=""

case "$FILE_PATH" in
  *techstack*)
    CONTEXT="[SOT 연쇄 수정] techstack.md가 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. database.md에서 변경된 기술 스택과 불일치하는 부분을 수정하라\n2. common-modules.md에서 영향받는 모듈을 수정하라\n3. 영향받는 state.md가 있으면 수정하라\n4. 영향받는 lib/ 코드가 있으면 수정하라"
    ;;
  *database*)
    CONTEXT="[SOT 연쇄 수정] database.md가 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. lib/models/ 에서 변경된 스키마와 불일치하는 freezed 모델을 수정하라\n2. lib/repositories/ 에서 변경된 테이블/컬럼을 사용하는 리포지토리를 수정하라\n3. 영향받는 state.md가 있으면 수정하라\n4. build_runner를 실행하여 코드 생성을 갱신하라"
    ;;
  *common-modules*)
    CONTEXT="[SOT 연쇄 수정] common-modules.md가 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. 영향받는 state.md를 찾아 수정하라\n2. 영향받는 lib/ 코드(providers, services, widgets)를 수정하라"
    ;;
  *design-system*)
    CONTEXT="[SOT 연쇄 수정] design-system.md가 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. 변경된 디자인 토큰(색상, 폰트, 간격)을 모든 UI 스펙(docs/ui-specs/*.md)에서 찾아 수정하라\n2. Pencil 디자인(.pen)에서 해당 토큰을 사용하는 모든 화면을 수정하라\n3. lib/app/theme/ 코드에서 변경된 토큰을 반영하라\n4. lib/screens/ 에서 하드코딩된 값이 있으면 테마 참조로 교체하라"
    ;;
  *ui-specs/*)
    CONTEXT="[SOT 연쇄 수정] UI 스펙(${BASENAME})이 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. 해당 화면의 lib/screens/ 코드에서 변경된 스펙(색상, 크기, 텍스트, 컴포넌트)을 반영하라\n2. 해당 화면의 state.md에 영향이 있으면 수정하라\n주의: UI 스펙의 SOT는 Pencil이다. 스펙을 직접 수정한 경우, Pencil 디자인도 반드시 같이 수정하라."
    ;;
  *screen-registry*)
    CONTEXT="[SOT 연쇄 수정] screen-registry.yaml이 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. 추가/삭제/변경된 화면에 대해 UI 스펙 파일을 생성/삭제/수정하라\n2. 라우터(lib/app/router/)에서 라우트를 추가/삭제/수정하라\n3. Pencil 디자인에 새 화면 프레임을 추가하거나 기존 것을 수정하라"
    ;;
  *pages/*/state.md)
    CONTEXT="[SOT 연쇄 수정] 상태 설계(${BASENAME})가 수정되었다. 사용자에게 묻지 말고 즉시 실행하라:\n1. 해당 화면의 lib/providers/ 코드를 변경된 상태 설계에 맞게 수정하라\n2. 해당 화면의 lib/screens/ 코드에서 상태 사용 부분을 수정하라\n3. 해당 화면의 테스트 코드를 수정하라"
    ;;
  *)
    exit 0
    ;;
esac

if [[ -n "$CONTEXT" ]]; then
  jq -n --arg ctx "<sot-cascade-trigger>\n${CONTEXT}\n\n이 모든 작업을 완료한 후에만 사용자에게 결과를 보고하라. 중간에 멈추거나 사용자에게 \"수정할까요?\"라고 묻지 마라.\n</sot-cascade-trigger>" \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": $ctx } }'
fi

exit 0
