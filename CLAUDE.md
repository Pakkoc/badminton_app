# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 빌드 및 테스트 명령어

```bash
# 빌드 (반드시 스크립트 사용 — dart-define 필수)
bash scripts/build.sh

# 빌드 + 연결된 기기에 설치
bash scripts/install.sh

# 전체 테스트
flutter test

# 단일 테스트 파일
flutter test test/screens/customer/home/customer_home_screen_test.dart

# 특정 디렉터리 테스트
flutter test test/screens/owner/dashboard/

# 코드 분석 (lint)
flutter analyze

# freezed/json_serializable 코드 생성
dart run build_runner build --delete-conflicting-outputs
```

**주의**: `flutter build apk --release`만 실행하면 환경변수가 빈 문자열 → "서버 오류" 발생. 반드시 `scripts/build.sh` 사용.

## 아키텍처

```
lib/
  app/           — 테마(AppTheme), 라우터(go_router 22개 라우트)
  core/          — config, error(AppException), utils(Formatters, Validators)
  models/        — freezed 불변 데이터 모델 10개 + Enum 6개
  repositories/  — Supabase 데이터 접근 (12개 리포지토리)
  providers/     — Riverpod providers (auth, shop, community 등)
  services/      — FCM 서비스
  widgets/       — 공통 위젯 8개 (StatusBadge, EmptyState, CourtBackground 등)
  screens/
    auth/        — 스플래시, 로그인, 프로필 설정, 샵 등록
    customer/    — 고객 홈, 주문 상세/이력, 샵 검색/상세, 마이페이지
    owner/       — 대시보드, 작업 접수/관리, 샵 QR/설정, 재고/게시글 관리
    community/   — 커뮤니티 목록/상세/작성
    admin/       — 샵 승인, 신고 관리
```

### 핵심 흐름
- **고객**: QR 스캔 → `https://gutalarm.app/shop/{id}` 딥링크 → 자동 회원등록 + 작업 접수
- **사장님**: 대시보드에서 작업 관리 → 상태 변경 → Realtime + FCM으로 고객에게 알림
- **인증 가드**: `router.dart`에서 역할별(admin/owner/customer) redirect 처리

### 데이터 흐름
```
UI (Screen) → Notifier (StateNotifier) → Repository → Supabase
                  ↑ Riverpod Provider로 연결
```

## 스킬 사용 판별

| 사용자 요청 패턴 | 스킬 | 진입점 |
|----------------|------|--------|
| "에이전트 만들어줘", "새 에이전트 생성" | `subagent-creator` | SKILL.md |
| "스킬 만들어줘", "새 스킬 생성" | `skill-creator` | SKILL.md |
| "ㅇㅇㅇ 오류가 발생했습니다", "ㅇㅇㅇ 에러/버그" | `problem-tracker` | SKILL.md |
| "레이아웃", "스크롤", "Sliver", "GoRouter", "딥링크", "QR스캔", "Isolate", "공유 기능" | `flutter-skill` | SKILL.md |

## Git Commit Convention

### 규칙
- **Conventional Commits** 형식을 따른다
- 커밋 메시지는 **한국어**로 작성한다
- 형식: `<type>: <subject>`

### Type
| Type | 설명 |
|------|------|
| feat | 새로운 기능 추가 |
| fix | 버그 수정 |
| docs | 문서 변경 |
| style | 코드 포맷팅, 세미콜론 누락 등 (동작 변경 없음) |
| refactor | 리팩토링 (기능 변경 없음) |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 파일 등 기타 변경 |

### 커밋 시점
- 작업이 마무리되면 즉시 커밋한다
- 사용자에게 커밋 여부를 묻지 않고, 변경사항이 있으면 바로 커밋한다
- push는 사용자가 명시적으로 요청할 때만 수행한다

## TDD 규칙

### Red → Green → Refactor
1. **Red** — 실패하는 테스트를 먼저 작성한다
2. **Green** — 테스트를 통과하는 최소한의 코드를 작성한다
3. **Refactor** — 동작을 유지하면서 코드를 정리한다

### 테스트 피라미드
| 레벨 | 비율 | 도구 |
|------|------|------|
| Unit Test | 70% | flutter_test, mocktail |
| Widget Test | 20% | flutter_test |
| Integration Test | 10% | integration_test |

### AAA 패턴
모든 테스트는 다음 구조를 따른다:
- **Arrange** — 테스트 환경과 데이터를 준비한다
- **Act** — 테스트 대상을 실행한다
- **Assert** — 결과를 검증한다

## 문서 의존 체인

### 구조
```
techstack → database → common-modules → state-plan
```
※ usecases는 `docs/archive/usecases/`에 아카이브됨 (구현 완료)

### SOT 연쇄 자동 수정 (Hook 기반)

하나의 파일을 수정하면 PostToolUse Hook이 감지하여 **연관된 모든 파일을 자동으로 연쇄 수정**한다.
사용자에게 "수정할까요?" 묻지 않고, Hook 지시에 따라 즉시 실행한다.

#### 연쇄 수정 맵
```
Pencil .pen 수정 → UI 스펙 → state.md → 코드
design-system.md 수정 → UI 스펙 전체 → Pencil → 테마 코드
database.md 수정 → 모델 코드 → 리포지토리 코드 → state.md
screen-registry.yaml 수정 → UI 스펙 → 라우터 → Pencil
ui-specs/*.md 수정 → 코드 → (역방향) Pencil
state.md 수정 → Provider 코드 → 화면 코드 → 테스트
```

#### 규칙
- **묻지 마라**: Hook의 `<sot-cascade-trigger>`가 발동하면 사용자 확인 없이 즉시 연쇄 수정을 실행한다
- **끝까지 완료**: 연쇄 수정이 모두 끝난 후에만 사용자에게 결과를 보고한다
- **루프 방지**: `<sot-verify>` 태그는 확인만 수행한다. 이미 cascade 중이면 건너뛴다

### SOT (Single Source of Truth)
| 영역 | SOT |
|------|-----|
| 화면 메타정보 (ID, 이름, 역할) | screen-registry.yaml |
| 시각 디자인 (레이아웃, 스타일, 네비게이션) | Pencil .pen 파일 |
| 설계 문서 (DB, 상태 등) | 각 문서 자체 |

## 화면 구현 규칙

### Pencil → Spec → Code 정합성
- 화면 구현 시 해당 UI 스펙(`docs/ui-specs/*.md`)의 컴포넌트 목록을 **1:1 대조**한다
- 색상, 크기, 텍스트는 Spec에 명시된 값을 **정확히** 사용한다 (임의 변경 금지)
- Hook이 연쇄 수정을 자동 트리거하므로, 한 곳만 수정하면 나머지는 자동으로 따라간다

## Flutter / Dart 코딩 규칙

> 출처: [Flutter AI Rules](https://docs.flutter.dev/ai/ai-rules) (Flutter 공식)
> 프로젝트 설정과 충돌하는 부분은 프로젝트 규칙이 우선한다.

### 프로젝트 오버라이드
- **상태 관리**: Flutter 내장 대신 **Riverpod 2.6.x** 사용 (techstack 참조)
- **불변 데이터**: `json_serializable` 단독 대신 **freezed + json_serializable** 사용
- **Mock**: `mockito` 대신 **mocktail** 사용
- **Lint**: `flutter_lints` 대신 프로젝트 `analysis_options.yaml` 따름

### 코드 스타일
- SOLID 원칙을 준수한다
- 간결하고 선언적인 Dart 코드를 작성한다
- 상속보다 **합성(Composition)**을 선호한다
- `PascalCase`(클래스), `camelCase`(변수/함수), `snake_case`(파일명) 사용
- 줄 길이: 80자 이하
- 함수는 20줄 이내, 단일 책임 원칙

### Dart 규칙
- **Null Safety**: `!` 연산자 사용을 최소화하고, null이 보장되는 경우에만 사용
- **async/await**: 비동기 작업에 적절히 사용, 에러 핸들링 필수
- **패턴 매칭**: 코드를 단순화하는 곳에 적극 사용
- **exhaustive switch**: break 없는 완전한 switch 문/표현식 사용
- **arrow syntax**: 한 줄 함수에 사용

### Flutter 위젯 규칙
- **const 생성자**: 가능한 모든 위젯에 `const` 사용하여 리빌드 최소화
- **private Widget 클래스**: helper 메서드 대신 작은 private Widget 클래스로 분리
- **ListView.builder**: 긴 목록에는 반드시 builder 사용 (lazy loading)
- **build() 성능**: build() 내에서 네트워크 호출이나 복잡한 계산 금지
- **Isolate**: 무거운 계산(JSON 파싱 등)은 `compute()`로 별도 isolate에서 실행

### 테마 규칙
- **ColorScheme.fromSeed()**: 단일 시드 색상으로 일관된 팔레트 생성
- **Light/Dark 모드**: 양쪽 모두 지원
- **ThemeExtension**: 커스텀 디자인 토큰은 ThemeExtension으로 정의
- **Theme.of(context)**: 텍스트 스타일은 항상 textTheme에서 가져옴

### 네비게이션
- **go_router**: 선언적 라우팅, 딥링크, 인증 리다이렉트 사용
- **Navigator**: 딥링크 불필요한 임시 화면(다이얼로그 등)에만 사용

### JSON 직렬화
- `fieldRename: FieldRename.snake`로 camelCase ↔ snake_case 자동 변환
- `@JsonKey(name:)` 사용 (freezed 모델에서)

### 코드 생성
- `build_runner`로 freezed, json_serializable 코드 생성
- 생성 후: `dart run build_runner build --delete-conflicting-outputs`

### 접근성 (A11Y)
- 텍스트 대비 비율 최소 **4.5:1**
- 동적 텍스트 크기 조정 대응
- `Semantics` 위젯으로 시맨틱 레이블 제공

### 레이아웃
- **Expanded/Flexible**: Row/Column에서 공간 분배
- **Wrap**: 오버플로우 방지 시 줄바꿈
- **LayoutBuilder/MediaQuery**: 반응형 UI
- **OverlayPortal**: 커스텀 드롭다운/툴팁
