---
name: ui-screen-spec
description: 앱 요구사항 문서를 기반으로 화면별 UI 스펙 문서를 생성한다
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
---

# UI 화면 스펙 생성

## 개요

거트알림 배드민턴 앱의 요구사항 문서를 읽고, 화면별 구조화된 UI 스펙 문서를 생성한다.

**시작 시 안내:** "ui-screen-spec 스킬을 사용하여 UI 화면 스펙을 생성합니다."

## 사용법

```
/ui-screen-spec [screen-name]    # 특정 화면 스펙 생성
/ui-screen-spec all              # 전체 화면 스펙 일괄 생성
```

### 화면 이름 목록

고객 화면:
- `customer-home` — 고객 홈 (진행 중 작업 목록)
- `customer-order-detail` — 작업 상세
- `customer-shop-search` — 주변 샵 검색
- `customer-shop-detail` — 샵 상세
- `customer-my-qr` — 내 QR코드
- `customer-history` — 작업 이력
- `customer-mypage` — 마이페이지

샵 사장님 화면:
- `owner-dashboard` — 대시보드
- `owner-order-create` — 작업 접수
- `owner-order-manage` — 작업 관리
- `owner-member-list` — 회원 목록
- `owner-member-register` — 회원 등록
- `owner-shop-settings` — 샵 설정

공통 화면:
- `auth-login` — 로그인
- `auth-signup` — 회원가입
- `splash` — 스플래시

## 실행 절차

1. **요구사항 문서 읽기**: `docs/plans/2026-02-08-gut-app-design.md`를 읽어 전체 맥락을 파악한다.
2. **기존 스펙 확인**: `docs/ui-specs/` 디렉토리에 이미 작성된 스펙이 있는지 확인한다.
3. **템플릿 참조**: `C:\dev\badminton_app\.claude\skills\ui-screen-spec\templates\screen-spec-template.md`의 구조를 따른다.
4. **예제 참조**: `C:\dev\badminton_app\.claude\skills\ui-screen-spec\examples\customer-home.md`를 참고하여 상세도와 형식을 맞춘다.
5. **스펙 생성**: 화면별로 `docs/ui-specs/{screen-name}.md` 파일을 생성한다.
6. **커밋**: 생성된 파일을 커밋한다.

## 작성 원칙

- **모든 내용은 한국어**로 작성한다.
- 요구사항 문서에 명시된 DB 테이블 구조를 기반으로 **데이터 바인딩과 API 연동**을 구체적으로 기술한다.
- 각 컴포넌트의 **상태(활성/비활성/로딩/에러)**를 빠짐없이 정의한다.
- **사용자 인터랙션**은 이벤트와 결과 액션을 쌍으로 기술한다.
- 네비게이션은 **진입 경로와 이동 가능 화면**을 명확히 한다.
- 필드 검증 규칙은 **구체적인 조건**을 명시한다 (예: "2~20자", "010-XXXX-XXXX 형식").
- 화면 상태(로딩/빈 상태/에러/정상)별 **UI 분기**를 정의한다.

## 출력 위치

모든 스펙 파일은 `docs/ui-specs/` 디렉토리에 저장한다.

```
docs/ui-specs/
├── customer-home.md
├── customer-order-detail.md
├── customer-shop-search.md
├── ...
└── splash.md
```

## 참고 파일

- 템플릿: `.claude/skills/ui-screen-spec/templates/screen-spec-template.md`
- 예제: `.claude/skills/ui-screen-spec/examples/customer-home.md`
- 요구사항: `docs/plans/2026-02-08-gut-app-design.md`
