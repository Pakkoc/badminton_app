---
name: state-plan
description: "화면별 상태 관리를 설계하고 docs/pages/{N}-{name}/state.md 문서로 정리한다"
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

# State Plan — 화면별 상태 관리 설계

## 개요

특정 화면/페이지의 상태 관리를 설계한다. 어떤 상태를 관리하고, 어떤 조건에서 상태가 변하며, UI가 어떻게 반응하는지를 문서화한다.

**시작 시 안내:** "state-plan 스킬을 실행합니다. 화면별 상태 관리를 설계합니다."

## 사용법

```
/state-plan [화면명]       # 특정 화면의 상태 설계
/state-plan all           # 전체 화면에 대해 상태 설계
/state-plan list          # 설계가 필요한 화면 목록 나열
```

## 실행 절차

### Step 1: 프로젝트 문서 파악

1. **전체 문서 읽기**:
   - `docs/techstack*` (상태 관리 라이브러리 확인)
   - `docs/database*`
   - `docs/common-modules*`
2. **해당 화면 관련 문서 읽기**:
   - `docs/ui-specs/{화면명}.md`
   - `docs/usecases/` 에서 관련 유스케이스 찾기

### Step 2: 상태 데이터 분류

화면에서 다루는 데이터를 **상태**와 **비-상태**로 분류한다.

```markdown
## 상태 데이터 (State)

직접 관리해야 하는 데이터:

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| selectedMember | Member? | null | 선택된 회원 |
| isSubmitting | bool | false | 제출 중 여부 |

## 비-상태 데이터 (Non-State)

화면에 표시되지만 직접 관리하지 않는 데이터:

| 이름 | 출처 | 설명 |
|------|------|------|
| memberSearchResults | 서버 캐시 | 회원 검색 결과 |
| shopInfo | 상위 Provider | 현재 샵 정보 |
```

### Step 3: 상태 변화 조건표

각 상태가 언제, 왜 변하는지, 변할 때 UI가 어떻게 달라지는지 표로 정리한다.

```markdown
## 상태 변화 조건표

| 트리거 | 상태 변화 | UI 변화 |
|--------|----------|---------|
| 회원 선택 | selectedMember = member | 선택 카드 하이라이트, 폼 활성화 |
| 접수 버튼 탭 | isSubmitting = true | 버튼 로딩, 입력 비활성화 |
| 접수 성공 | isSubmitting = false | 토스트 표시, 이전 화면 복귀 |
| 접수 실패 | isSubmitting = false, error = msg | 에러 스낵바 표시 |
```

### Step 4: 상태 관리 구조 시각화

프로젝트의 techstack에 맞는 상태 관리 패턴으로 시각화한다.

**상태 관리 라이브러리별 패턴:**

| 라이브러리 | 패턴 |
|-----------|------|
| Riverpod | Action → Notifier → State → Widget |
| Bloc | Event → Bloc → State → Widget |
| Redux/Zustand | Action → Store → State → Widget |
| Context+useReducer | Action → Reducer → State → Component |

```markdown
## Provider/Bloc 구조

\```mermaid
flowchart LR
    A[사용자 액션] --> B[Notifier 메서드]
    B --> C[State 갱신]
    C --> D[Widget 리빌드]
    B --> E[Repository 호출]
    E --> F[Supabase API]
    F --> E
    E --> B
\```
```

### Step 5: 자식 위젯 노출 인터페이스

이 화면의 상태 관리가 자식 위젯에 노출하는 변수와 함수를 나열한다.

```markdown
## 노출 인터페이스

### 읽기 (State)
- `selectedMember` — 현재 선택된 회원
- `isSubmitting` — 제출 중 여부
- `orders` — 작업 목록

### 쓰기 (Actions)
- `selectMember(Member)` — 회원 선택
- `submitOrder(OrderData)` — 작업 접수
- `clearSelection()` — 선택 초기화
```

### Step 6: 문서 생성 및 커밋

`docs/pages/{N}-{name}/state.md`에 저장하고 커밋한다.

```
docs/pages/
├── 1-social-login/state.md
├── 3-order-create/state.md
└── ...
```

번호는 해당 기능의 유스케이스 번호를 따른다.

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다.

| 대상 | 탐색 방법 |
|------|----------|
| 기술 스택 | `docs/techstack*` |
| DB 스키마 | `docs/database*` |
| UI 스펙 | `docs/ui-specs/*.md` |
| 유스케이스 | `docs/usecases/**/*.md` |
| 공통 모듈 | `docs/common-modules*` |
| 기존 상태 설계 | `docs/pages/*/state.md` |

## 핵심 원칙

1. **인터페이스 중심** — 구현 코드가 아닌 상태 인터페이스를 설계한다
2. **상태 vs 비-상태 구분** — 직접 관리할 데이터와 외부에서 오는 데이터를 명확히 분류한다
3. **조건표 필수** — 상태 변화의 트리거, 변화, UI 반응을 표로 정의한다
4. **DRY** — 공통 모듈에 이미 있는 상태를 중복 정의하지 않는다
5. **프로젝트 무관** — 상태 관리 라이브러리는 techstack에 따라 결정한다
