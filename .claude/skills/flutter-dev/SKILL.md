---
name: flutter-dev
description: Flutter/Dart 클라이언트 코드 품질 전문 스킬. 위젯 패턴, Riverpod 상태관리, Pencil→Flutter 매핑, 성능 최적화, TDD 가이드를 제공한다.
---

# Flutter Dev — Flutter 클라이언트 코드 전문 스킬

Flutter/Dart 코드 작성 시 프로젝트 컨벤션에 맞는 고품질 코드를 생성하기 위한 전문 가이드.

## 존재 이유

- Flutter 코드 작성 시 프로젝트의 기존 패턴(Riverpod, freezed, go_router 등)과 불일치하는 코드가 생성됨
- Pencil 디자인을 Flutter 위젯으로 변환할 때 매핑 규칙이 없어 일관성이 떨어짐
- 위젯 분리, 상태 관리, 에러 처리 등의 패턴이 매번 다르게 적용됨
- AI가 프로젝트 컨벤션을 모른 채 일반적인 Flutter 코드를 생성하는 문제 방지

## 트리거

- "Flutter 코드 작성", "화면 구현", "위젯 만들어줘"
- "Riverpod 패턴", "Provider 만들어", "상태 관리"
- "Pencil을 Flutter로", "디자인을 코드로"
- "Flutter 성능", "위젯 최적화"
- "flutter", "dart", "widget", "screen", "provider"

## 전제 조건

- `lib/` 디렉토리가 존재하는 Flutter 프로젝트
- `docs/design-system.md` — 디자인 시스템 정의
- `lib/app/theme.dart` — AppTheme 클래스
- `pubspec.yaml` — 의존성 목록

## 프로토콜

### Phase 1: 컨텍스트 파악

코드 작성 전에 반드시 확인:

1. **대상 화면/모듈의 UI 스펙** — `docs/ui-specs/{name}.md`
2. **상태 설계** — `docs/pages/{N}-{name}/state.md`
3. **기존 코드 패턴** — 같은 레이어의 기존 파일 1~2개 읽기
4. **공통 모듈** — `docs/common-modules.md`에서 재사용 가능한 것 확인

### Phase 2: 코드 작성 (references 참조)

작성할 코드 종류에 따라 해당 가이드를 참조:

| 코드 종류 | 참조 문서 |
|-----------|----------|
| 화면/위젯 | `references/widget-patterns-guide.md` |
| Provider/Notifier/State | `references/riverpod-patterns-guide.md` |
| Pencil → Flutter 변환 | `references/pencil-flutter-mapping-guide.md` |
| 코드 리뷰/최종 검증 | `references/flutter-quality-checklist.md` |

### Phase 3: 자가 검증

코드 작성 후 `references/flutter-quality-checklist.md`의 체크리스트로 검증.

## 참조 문서

| 파일 | 설명 |
|------|------|
| `references/widget-patterns-guide.md` | 위젯 합성, private 위젯, const, 레이아웃 패턴 |
| `references/riverpod-patterns-guide.md` | Provider 유형 선택, Notifier 패턴, ref 사용 규칙 |
| `references/pencil-flutter-mapping-guide.md` | Pencil 노드 → Flutter 위젯 1:1 매핑 규칙 |
| `references/flutter-quality-checklist.md` | 코드 품질 체크리스트 (위젯, 상태, 테스트, 성능) |
