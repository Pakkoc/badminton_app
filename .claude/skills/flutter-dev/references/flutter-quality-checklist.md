# Flutter 코드 품질 체크리스트

코드 작성 후 자가 검증용 체크리스트.

---

## 1. 위젯 품질

- [ ] helper 메서드(`_buildXxx`) 대신 private Widget 클래스를 사용했는가?
- [ ] 가능한 모든 위젯에 `const` 생성자를 사용했는가?
- [ ] `super.key` 패턴을 사용했는가?
- [ ] build() 안에서 네트워크 호출이나 복잡한 계산이 없는가?
- [ ] 긴 목록에 `ListView.builder`를 사용했는가? (모든 아이템을 한번에 빌드하지 않는가?)
- [ ] ConsumerWidget/ConsumerStatefulWidget을 올바르게 선택했는가?

## 2. 상태 관리

- [ ] build()에서 `ref.watch()`, 이벤트에서 `ref.read()`를 사용했는가?
- [ ] Notifier에서 다른 Provider 접근 시 `ref.read()`를 사용했는가?
- [ ] 스트림 구독 시 `ref.onDispose()`에서 해제했는가?
- [ ] 상태 모델이 freezed로 정의되었는가?
- [ ] 상태 변경이 `copyWith()`로 이루어지는가? (직접 변이 없는가?)
- [ ] 로딩/에러/데이터 3-way 분기를 처리했는가?

## 3. 스타일링

- [ ] 색상을 하드코딩하지 않았는가? (AppTheme/colorScheme 사용)
- [ ] 텍스트 스타일을 `Theme.of(context).textTheme`에서 가져왔는가?
- [ ] 폰트 크기/Weight를 직접 지정하지 않았는가?
- [ ] 모서리 둥글기가 규칙(14/20/999)을 따르는가?
- [ ] `withValues(alpha: N)` 사용했는가? (`withOpacity` 아님)

## 4. 네비게이션

- [ ] `context.go()` (스택 교체) vs `context.push()` (스택 추가)를 올바르게 사용했는가?
- [ ] 라우트 경로가 `lib/app/router.dart`에 정의되어 있는가?
- [ ] 파라미터를 pathParameters/queryParameters로 전달했는가?

## 5. 에러 처리

- [ ] Repository에서 `ErrorHandler.handle(e)`로 에러를 변환했는가?
- [ ] Notifier에서 `on AppException catch`로 처리했는가?
- [ ] UI에서 `ErrorView` 공통 위젯을 사용했는가?
- [ ] 사용자에게 기술적 에러 메시지를 노출하지 않는가?

## 6. 공통 모듈 활용

- [ ] `lib/widgets/`의 기존 공통 위젯을 재사용했는가?
- [ ] `lib/core/utils/validators.dart`의 유효성 검증을 사용했는가?
- [ ] `lib/core/utils/formatters.dart`의 포맷 유틸을 사용했는가?
- [ ] 이미 존재하는 Repository를 직접 재구현하지 않았는가?

## 7. 코드 스타일

- [ ] 파일명: `snake_case.dart`
- [ ] 클래스명: `PascalCase`
- [ ] 변수/함수: `camelCase`
- [ ] Provider: `*Provider` suffix
- [ ] Repository: `*Repository` class
- [ ] Notifier: `*Notifier` class
- [ ] State: `*State` (freezed) class
- [ ] 줄 길이 80자 이하
- [ ] 함수 20줄 이내

## 8. 테스트

- [ ] 모델: JSON 직렬화/역직렬화 테스트
- [ ] Validator: 정상/경계/에러 케이스 테스트
- [ ] Notifier: 상태 변화 테스트 (mocktail로 Repository mock)
- [ ] Widget: 주요 UI 요소 존재 확인
- [ ] AAA 패턴 (Arrange-Act-Assert) 준수

## 9. 성능

- [ ] `const` 위젯으로 불필요한 리빌드 방지
- [ ] `ListView.builder`로 대량 아이템 lazy loading
- [ ] 무거운 계산을 `compute()`로 별도 isolate에서 실행
- [ ] build() 내에서 매 프레임 재생성되는 객체가 없는가?
- [ ] `.autoDispose`로 사용하지 않는 Provider 자동 해제

## 10. 접근성

- [ ] 텍스트 대비 비율 4.5:1 이상
- [ ] 터치 영역 최소 44x44
- [ ] `Semantics` 위젯으로 시맨틱 레이블 제공 (아이콘 버튼 등)
- [ ] 동적 텍스트 크기 대응 (MediaQuery.textScaleFactor)
