---
name: doc-sync
description: "구현 중 설계 변경 시 문서 의존 체인을 따라 관련 문서를 전부 갱신하고 변경 이력을 기록한다"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
---

# Doc Sync — 설계 문서 동기화

## 개요

구현 중 설계가 변경되었을 때, 문서 의존 체인을 따라 관련 문서를 전부 갱신하고 변경 이력을 기록한다. 문서 간 정합성(SOT)을 유지하기 위한 스킬이다.

**시작 시 안내:** "doc-sync 스킬을 실행합니다. 설계 변경의 영향 범위를 분석하고 문서를 동기화합니다."

## SOT (Single Source of Truth) 정의

| 영역 | SOT | 동기화 방향 | 담당 스킬 |
|------|-----|-----------|----------|
| 화면 메타정보 (ID, 이름, 네비게이션) | `screen-registry.yaml` | 레지스트리 → 스펙/디자인 | `/sync` |
| 시각 디자인 (레이아웃, 스타일) | Pencil `.pen` 파일 | Pencil → UI 스펙 | `/design-sync` |
| **설계 문서 (DB, 유스케이스, 상태 등)** | **각 문서 자체** | **상위 → 하위** | **`/doc-sync`** |

### `/sync` vs `/design-sync` vs `/doc-sync` 구분

| | `/sync` | `/design-sync` | `/doc-sync` |
|---|---------|----------------|-------------|
| **사용 시점** | 화면 추가/삭제/이름변경 후 | 디자인 수정 후 | 설계 문서 변경 후 |
| **대상** | 메타정보 | 시각 속성 | 설계 문서 간 정합성 |
| **SOT** | screen-registry.yaml | Pencil .pen | 각 설계 문서 |
| **방향** | 레지스트리 → 스펙 | Pencil → 스펙 | 상위 문서 → 하위 문서 |

## 문서 의존 체인

```
techstack
    ↓
database ←──── 변경 시 아래 모든 문서에 영향
    ↓
usecases ←──── 변경 시 아래 모든 문서에 영향
    ↓
common-modules
    ↓
state-plan ←── 변경 시 plan에 영향
    ↓
plan
```

**상위 문서가 변경되면 하위 문서를 모두 검토하고 필요 시 갱신한다.**

## 사용법

```
/doc-sync                    # 변경 내용을 분석하고 영향 문서 동기화
/doc-sync check              # 검사만 (수정하지 않고 불일치 보고)
/doc-sync [문서명]            # 특정 문서 변경에 대해 동기화
```

## 실행 절차

### Step 1: 변경 내용 파악

1. **무엇이 바뀌었는가** — 사용자와의 대화 또는 git diff에서 변경 사항 식별
2. **어느 문서가 변경되었는가** — 변경된 설계 문서 식별
3. **변경 유형 분류**:
   - DB 스키마 변경 (컬럼 추가/삭제, 테이블 추가/삭제, enum 변경)
   - 기능 흐름 변경 (유스케이스 변경)
   - 공통 모듈 변경 (인터페이스 변경)
   - 상태 관리 변경 (상태 추가/삭제)

### Step 2: 영향 범위 도출

의존 체인을 따라 영향받는 문서를 나열한다.

```
예시: database.md에서 orders 테이블에 'pickup_completed' 상태 추가

영향받는 문서:
  1. docs/usecases/4-order-status-change/spec.md  ← 새 상태 흐름 추가
  2. docs/common-modules.md                        ← enum 정의 갱신
  3. docs/pages/4-order-detail/state.md            ← 상태 변화 조건표 갱신
  4. docs/pages/4-order-detail/plan.md             ← 구현 계획 갱신
```

### Step 3: 상위 문서부터 순서대로 갱신

의존 체인의 **상위부터 하위 순서**로 문서를 갱신한다.

1. `database.md` (이미 변경됨)
2. `usecases/` 관련 문서
3. `common-modules.md`
4. `pages/*/state.md`
5. `pages/*/plan.md`

### Step 4: 변경 이력 기록

`docs/changes/` 디렉토리에 변경 기록을 생성한다.

```
docs/changes/
├── YYYY-MM-DD-{변경명}/
│   ├── proposal.md     ← 왜, 무엇을 바꾸었는가
│   └── impact.md       ← 영향받은 문서 목록과 변경 내용
└── archive/            ← 완료된 변경
    └── YYYY-MM-DD-{변경명}/
```

**proposal.md 형식:**
```markdown
# 변경: [변경명]

## 배경
[왜 이 변경이 필요한가]

## 변경 내용
[무엇을 바꾸었는가]

## 날짜
[YYYY-MM-DD]
```

**impact.md 형식:**
```markdown
# 영향 범위

## 변경된 문서

| 문서 | 변경 내용 | 상태 |
|------|----------|------|
| database.md | orders.status에 pickup_completed 추가 | ✅ 완료 |
| usecases/4-order-status-change/spec.md | 수령완료 흐름 추가 | ✅ 완료 |
| ... | ... | ... |
```

### Step 5: 결과 보고

```
## Doc Sync 결과

### 변경 원인
- [문서명]: [변경 내용]

### 영향받은 문서
- [문서명]: [갱신 내용] — ✅ 완료 / ⚠️ 수동 확인 필요

### 변경 이력
- docs/changes/YYYY-MM-DD-{변경명}/ 생성됨

### 추가 조치 필요
- (있으면 나열)
```

### Step 6: 아카이브

모든 갱신이 완료되면 `docs/changes/{변경명}/`을 `docs/changes/archive/`로 이동한다.

## check 모드

`/doc-sync check`로 호출하면 수정하지 않고 불일치만 보고한다.

1. 의존 체인의 모든 문서를 스캔
2. 문서 간 데이터 불일치 탐지 (예: database.md의 enum과 common-modules의 enum이 다름)
3. 불일치 목록을 표로 정리하여 보고

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다.

| 대상 | 탐색 방법 |
|------|----------|
| 기술 스택 | `docs/techstack*` |
| DB 스키마 | `docs/database*` |
| 유스케이스 | `docs/usecases/**/*.md` |
| 공통 모듈 | `docs/common-modules*` |
| 상태 설계 | `docs/pages/*/state.md` |
| 구현 계획 | `docs/pages/*/plan.md` |
| 변경 이력 | `docs/changes/` |

## 핵심 원칙

1. **상위 먼저** — 의존 체인의 상위 문서부터 하위 순서로 갱신한다
2. **영향 범위 전부** — 하나만 수정하고 끝내지 않는다. 관련 문서를 전부 갱신한다
3. **이력 기록** — 왜 바꾸었는지를 기록하여 의사결정을 추적 가능하게 한다
4. **프로젝트 무관** — 어떤 프로젝트에서도 동일하게 동작한다
