# CLAUDE.md

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
techstack → database → usecases → common-modules → state-plan → plan
```

### 규칙
- 상위 문서가 변경되면 하위 문서를 모두 검토하고 필요 시 갱신한다
- 설계 변경 시 `/doc-sync` 스킬을 사용하여 영향 문서를 동기화한다
- 문서 간 정합성(SOT)을 항상 유지한다

### SOT (Single Source of Truth)
| 영역 | SOT | 동기화 스킬 |
|------|-----|-----------|
| 화면 메타정보 (ID, 이름, 역할) | screen-registry.yaml | /sync |
| 시각 디자인 (레이아웃, 스타일, 네비게이션) | Pencil .pen 파일 | /design-sync |
| 설계 문서 (DB, 유스케이스, 상태 등) | 각 문서 자체 | /doc-sync |

## 화면 구현 규칙

### Pencil → Spec → Code 정합성
- 화면 구현 시 해당 UI 스펙(`docs/ui-specs/*.md`)의 컴포넌트 목록을 **1:1 대조**한다
- 색상, 크기, 텍스트는 Spec에 명시된 값을 **정확히** 사용한다 (임의 변경 금지)
- 화면 구현 완료 후 반드시 `/design-sync [screen-name]`을 실행하여 Pencil↔Spec↔Code 정합성을 검증한다

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
