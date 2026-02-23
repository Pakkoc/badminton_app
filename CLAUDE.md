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
| 화면 메타정보 (ID, 이름, 네비게이션) | screen-registry.yaml | /sync |
| 시각 디자인 (레이아웃, 스타일) | Pencil .pen 파일 | /design-sync |
| 설계 문서 (DB, 유스케이스, 상태 등) | 각 문서 자체 | /doc-sync |
