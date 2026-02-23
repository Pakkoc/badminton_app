---
name: database
description: "프로젝트의 데이터베이스 스키마를 설계하고 docs/database.md 문서로 정리한다"
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

# Database — DB 스키마 설계

## 개요

프로젝트의 데이터베이스 스키마를 설계한다. 데이터 흐름을 먼저 서술하고, 이를 기반으로 테이블, 관계, 인덱스, 보안 정책을 설계한다.

**시작 시 안내:** "database 스킬을 실행합니다. 프로젝트 DB 스키마를 설계합니다."

## 사용법

```
/database              # DB 스키마 문서 생성
/database update       # 기존 문서 갱신
/database check        # 기존 문서와 ui-specs 간 데이터 정합성 검사
```

## 실행 절차

### Step 1: 프로젝트 문서 파악

1. **기획 문서 읽기** — `docs/service-overview*`, `docs/requirements*`, `docs/plans/*.md`
2. **기술 스택 확인** — `docs/techstack*` (DB 종류 확인: PostgreSQL, MySQL 등)
3. **UI 스펙 전체 읽기** — `docs/ui-specs/*.md` (각 화면에서 사용하는 데이터 파악)
4. **기존 DB 문서 확인** — `docs/database*`

### Step 2: 데이터 흐름 서술

UI 스펙의 각 화면에서 어떤 데이터가 생성되고, 읽히고, 수정되고, 삭제되는지를 서술한다.

```markdown
## 데이터 흐름

### 사용자 등록
1. 소셜 로그인 → users 테이블에 기본 정보 저장
2. 프로필 설정 → users 테이블에 역할/이름/전화번호 추가

### 작업 접수
1. 사장님이 회원 선택 + 거트 정보 입력 → orders 테이블에 INSERT
2. 상태 변경 → orders.status UPDATE → Push 알림 트리거
```

**규칙: UI 스펙/기획에 명시적으로 언급된 데이터만 포함한다. 추측으로 테이블을 추가하지 않는다.**

### Step 3: 스키마 설계

각 테이블을 다음 형식으로 정의한다:

```markdown
### 테이블: users

| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|---------|------|
| id | UUID | PK, DEFAULT gen_random_uuid() | 사용자 고유 ID |
| role | TEXT | NOT NULL, CHECK (role IN ('customer', 'owner')) | 역할 |
| ... | ... | ... | ... |
```

### Step 4: 관계 다이어그램

Mermaid ER 다이어그램으로 테이블 관계를 시각화한다:

```markdown
\```mermaid
erDiagram
    users ||--o{ shops : "owns"
    shops ||--o{ members : "has"
    members ||--o{ orders : "has"
\```
```

### Step 5: 보안 정책 (RLS)

BaaS(Supabase, Firebase 등) 사용 시 Row Level Security 정책을 정의한다:

```markdown
## RLS 정책

### users 테이블
- SELECT: 자신의 데이터만 조회 가능
- UPDATE: 자신의 데이터만 수정 가능

### orders 테이블
- SELECT: 해당 shop의 owner이거나 해당 member의 user인 경우
- INSERT: 해당 shop의 owner만
- UPDATE: 해당 shop의 owner만 (status 변경)
```

### Step 6: 인덱스 및 마이그레이션

```markdown
## 인덱스

| 테이블 | 컬럼 | 유형 | 이유 |
|--------|------|------|------|
| orders | shop_id, status | 복합 인덱스 | 샵별 상태 필터링 빈번 |

## 마이그레이션 SQL

\```sql
-- 1. users 테이블
CREATE TABLE users ( ... );

-- 2. shops 테이블
CREATE TABLE shops ( ... );
\```
```

### Step 7: 문서 생성 및 커밋

`docs/database.md`에 위 내용을 통합하여 생성하고 커밋한다.

## 출력 구조

```markdown
# 데이터베이스 스키마

## 데이터 흐름
[Step 2 내용]

## 테이블 정의
[Step 3 내용 — 테이블별 상세]

## 관계 다이어그램
[Step 4 — Mermaid ER]

## RLS 정책
[Step 5 — 보안 정책]

## 인덱스
[Step 6 — 인덱스 테이블]

## 마이그레이션 SQL
[Step 6 — SQL]
```

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다.

| 대상 | 탐색 방법 |
|------|----------|
| 기획 문서 | `docs/service-overview*`, `docs/requirements*`, `docs/plans/*.md` |
| 기술 스택 | `docs/techstack*` |
| UI 스펙 | `docs/ui-specs/*.md` 또는 `**/ui-specs/*.md` |
| 기존 DB 문서 | `docs/database*` |

## 핵심 원칙

1. **데이터 흐름 먼저** — 테이블부터 만들지 않고, 데이터가 어떻게 흐르는지를 먼저 서술한다
2. **과잉 설계 금지** — UI 스펙/기획에 명시된 데이터만 포함한다. 미래를 위한 추측 테이블 금지
3. **마이그레이션 SQL 필수** — 바로 실행 가능한 SQL을 포함한다
4. **프로젝트 무관** — 어떤 프로젝트에서도 동일하게 동작한다
