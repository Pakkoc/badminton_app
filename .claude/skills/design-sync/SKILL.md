---
name: design-sync
description: "You MUST use this after any Pencil design (.pen) modification - color changes, layout adjustments, component updates, or style fixes. Syncs design changes to UI specs and checks cross-screen consistency."
user-invocable: true
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Design Sync — 디자인-스펙 동기화

## Overview

Pencil 디자인(.pen) 수정 후 UI 스펙과 연관 화면의 일관성을 자동으로 동기화한다.

<HARD-GATE>
Pencil 디자인을 수정한 후에는 반드시 이 스킬을 실행해야 한다. 디자인만 수정하고 스펙을 업데이트하지 않으면 디자인과 문서가 불일치하게 된다. 이 규칙은 모든 프로젝트에 동일하게 적용된다.
</HARD-GATE>

## SOT (Single Source of Truth) 정의

| 영역 | SOT | 동기화 방향 | 담당 스킬 |
|------|-----|-----------|----------|
| 화면 메타정보 (ID, 이름, 네비게이션) | `screen-registry.yaml` | 레지스트리 → 스펙/디자인 | `/sync` |
| 디자인 토큰 (색상, 폰트, 간격 정의) | `design-system.md` | 디자인 시스템 → 스펙/디자인 | 수동 |
| 시각 디자인 (레이아웃, 컴포넌트 스타일) | **Pencil `.pen` 파일** | **Pencil → UI 스펙** | **`/design-sync`** |

**핵심 규칙**: 시각 디자인 수정은 항상 Pencil에서 먼저 수행하고, UI 스펙이 Pencil을 따라간다. UI 스펙을 먼저 수정하고 Pencil을 따라가게 하지 않는다.

### `/sync` vs `/design-sync` 구분

| | `/sync` | `/design-sync` |
|---|---------|----------------|
| **사용 시점** | 화면 추가/삭제/이름변경 후 | 디자인 수정 후 |
| **대상** | 메타정보 (ID, 이름, 네비게이션 경로) | 시각 속성 (색상, 크기, 레이아웃) |
| **SOT** | `screen-registry.yaml` | Pencil `.pen` 파일 |

## 호출 방법

```
/design-sync                  # 최근 수정된 화면 기준으로 동기화
/design-sync [screen-name]    # 특정 화면 동기화
/design-sync check            # 검사만 (수정하지 않고 불일치 보고)
```

## 실행 절차

### Step 1: 변경 내역 파악

1. **수정된 화면 식별** — 사용자와의 대화에서 어떤 화면의 어떤 요소가 변경되었는지 파악
2. **변경 요소 목록화** — 변경된 속성을 정리 (색상, 크기, 레이아웃, 컴포넌트 등)

### Step 2: 연관 화면 일관성 체크

수정된 요소가 다른 화면에도 존재하는지 확인한다.

1. **동일 요소 검색** — Pencil `batch_get`으로 전체 화면을 스캔하여 같은 종류의 요소를 찾는다
   - 공통 요소 예시: 지도 마커, 상태 뱃지, 상태 전환 버튼, 카드, 하단 네비게이션, 앱바
2. **불일치 비교** — 수정된 화면의 요소와 다른 화면의 동일 요소를 비교
3. **일괄 수정** — 불일치가 발견되면 모든 연관 화면을 함께 수정
4. **스크린샷 검증** — 수정된 모든 화면의 스크린샷을 확인

### Step 3: UI 스펙 동기화

디자인 변경사항을 UI 스펙 문서에 반영한다.

1. **스펙 파일 위치 탐색**
   - 화면 레지스트리(`**/screen-registry.yaml`)가 있으면 `spec_file` 필드로 스펙 파일 경로 확인
   - 없으면 `docs/ui-specs/*.md`에서 화면 ID/이름으로 검색
2. **변경 대상 스펙 읽기** — 해당 화면의 UI 스펙 파일을 읽는다
3. **변경사항 반영** — 디자인에서 수정된 속성을 스펙에 업데이트
   - 색상값 (hex 또는 변수명)
   - 크기 (width, height, fontSize, padding, gap 등)
   - 컴포넌트 구조 변경
   - 레이아웃 변경
4. **Cross-reference 확인** — 다른 스펙에서 이 화면의 변경된 요소를 참조하는 부분이 있으면 함께 수정
   - `docs/ui-specs/*.md` 전체에서 변경된 값(색상, 크기 등)을 Grep 검색
5. **디자인 시스템 확인** — 변경사항이 디자인 시스템(`docs/design-system*`)과 충돌하는지 검증
   - 충돌 시: 사용자에게 보고하고 어느 쪽을 수정할지 확인

### Step 4: 결과 보고

수정 결과를 정리하여 보고한다.

```
## Design Sync 결과

### 변경된 화면
- [화면명]: [변경 요소] — [변경 전] → [변경 후]

### 연관 화면 수정
- [화면명]: [동일 요소 함께 수정됨]

### UI 스펙 업데이트
- [스펙 파일명]: [수정된 항목]

### 디자인 시스템 충돌
- (없음 / 충돌 내역)
```

## check 모드

`/design-sync check`로 호출하면 수정하지 않고 불일치만 보고한다.

1. Pencil 디자인 파일의 모든 화면을 스캔
2. 동일 요소 간 속성 불일치 목록 생성
3. Pencil 디자인과 UI 스펙 간 불일치 목록 생성
4. 디자인 시스템과의 충돌 목록 생성
5. 결과를 표로 정리하여 보고

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다. 다음 규칙으로 파일 위치를 동적으로 탐색한다:

| 대상 | 탐색 방법 |
|------|----------|
| 디자인 파일 | `**/*.pen` Glob 검색, 또는 Pencil MCP `get_editor_state`로 활성 파일 확인 |
| UI 스펙 | `docs/ui-specs/*.md` 또는 `**/ui-specs/*.md` |
| 디자인 시스템 | `docs/design-system*` 또는 `**/design-system*` |
| 화면 레지스트리 | `**/screen-registry.yaml` (선택 — 없어도 동작) |

## 핵심 원칙

1. **디자인 수정 = 스펙 수정** — 디자인만 수정하고 끝내지 않는다
2. **한 화면 수정 = 연관 화면 확인** — 같은 요소가 있는 모든 화면을 함께 확인한다
3. **프로젝트 무관** — 어떤 프로젝트에서도 동일하게 동작한다
4. **검증 필수** — 스크린샷으로 시각적 일관성을 반드시 확인한다
