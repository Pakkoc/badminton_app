---
name: usecase
description: "기능 단위 유스케이스 문서를 docs/usecases/ 경로에 작성한다"
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

# Usecase — 유스케이스 작성

## 개요

기능 단위의 유스케이스 문서를 작성한다. 화면 단위(ui-specs)가 아닌 **기능 단위**로 전체 흐름을 관통하여 기술한다.

**시작 시 안내:** "usecase 스킬을 실행합니다. 기능 단위 유스케이스를 작성합니다."

## 사용법

```
/usecase [기능명]       # 특정 기능의 유스케이스 작성
/usecase all           # 전체 기능에 대해 유스케이스 일괄 작성
/usecase list          # 작성해야 할 유스케이스 목록 나열
```

## 실행 절차

### Step 1: 프로젝트 문서 파악

1. **전체 문서 읽기**:
   - `docs/service-overview*`, `docs/requirements*`
   - `docs/techstack*`
   - `docs/database*`
   - `docs/ui-specs/*.md`
   - `docs/plans/*.md`
2. **기존 유스케이스 확인** — `docs/usecases/` 디렉토리 존재 여부 및 이미 작성된 문서 확인

### Step 2: 유스케이스 목록 도출

UI 스펙과 기획 문서를 기반으로 기능 단위 유스케이스를 나열한다.

```
예시:
1. 소셜 로그인 + 프로필 설정
2. QR 스캔 → 회원 등록
3. 작업 접수
4. 작업 상태 변경 → Push 알림
5. 주변 샵 검색
6. 게시글 작성
7. 재고 관리
```

**번호는 사용자 흐름(userflow) 순서를 따른다.**

### Step 3: 유스케이스 작성

각 유스케이스를 아래 템플릿 구조로 작성한다.

**템플릿 참조:** `.claude/skills/usecase/templates/usecase-template.md`

포함할 섹션:
1. **개요** — 목적, 범위, 액터
2. **선행 조건** — 실행 전 충족 조건
3. **기본 흐름** — Input → Processing → Output 단계별 기술 + Mermaid 시퀀스 다이어그램
4. **대안 흐름** — 기본과 다른 경로
5. **예외 흐름** — 에러 코드 + 사용자 메시지
6. **후행 조건** — 성공/실패 시 데이터 상태
7. **테스트 시나리오** — 성공/실패 케이스 테이블
8. **관련 유스케이스** — 선행/후행/연관

**제외 항목** (이미 다른 문서에 있거나 MVP에 불필요):
- 비기능 요구사항 → techstack/common-modules에서 다룸
- UI/UX 요구사항 → ui-specs에 이미 있음
- 변경 로그, 부록 → 불필요

### Step 4: 저장 및 커밋

각 유스케이스를 `docs/usecases/{N}-{name}/spec.md`에 저장하고 커밋한다.

```
docs/usecases/
├── 1-social-login/spec.md
├── 2-qr-member-register/spec.md
├── 3-order-create/spec.md
└── ...
```

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다.

| 대상 | 탐색 방법 |
|------|----------|
| 기획 문서 | `docs/service-overview*`, `docs/requirements*`, `docs/plans/*.md` |
| 기술 스택 | `docs/techstack*` |
| DB 스키마 | `docs/database*` |
| UI 스펙 | `docs/ui-specs/*.md` 또는 `**/ui-specs/*.md` |
| 기존 유스케이스 | `docs/usecases/` |

## 핵심 원칙

1. **기능 단위** — 화면이 아닌 기능을 관통하는 흐름을 기술한다
2. **구현 코드 금지** — 유스케이스에 코드를 포함하지 않는다
3. **에러 흐름 필수** — 예외 상황과 에러 코드를 반드시 정의한다
4. **테스트 시나리오 필수** — 성공/실패 케이스를 테이블로 정의한다
5. **과잉 문서 금지** — MVP에 필요한 핵심 섹션만 포함한다
6. **프로젝트 무관** — 어떤 프로젝트에서도 동일하게 동작한다
