---
name: flutter-skill
description: "Flutter 앱 개발 시 레이아웃, 라우팅, 딥링크, QR스캔, 동시성, 공유 기능에 관한 실전 가이드라인을 제공한다. 키워드: 레이아웃, 스크롤, CustomScrollView, Sliver, CarouselView, 라우팅, GoRouter, 페이지 이동, 딥링크, deep link, Universal Links, App Links, 바코드, QR코드, 스캔, scanner, mobile_scanner, 카메라 스캔, Isolate, 동시성, concurrency, UI Jank, 공유, share, share_plus, 공유 버튼 (project)"
---

# Flutter Skill

거트알림 프로젝트에 적합한 Flutter 개발 실전 가이드라인을 제공합니다.

## 존재 이유

Flutter 개발 시 레이아웃 구성, 라우팅, 딥링크, QR 스캔, 성능 최적화(Isolate), 공유 기능 등은 반복적으로 필요하지만 매번 문서를 찾아보기 번거롭다. 본 스킬은 검증된 패턴과 코드 예제를 즉시 참조할 수 있도록 정리하여 개발 속도를 높인다.

## 트리거

- "레이아웃 구성해줘", "스크롤 화면 만들어줘", "Sliver 사용법"
- "라우팅 설정", "GoRouter", "페이지 이동", "redirect"
- "딥링크 구현", "Universal Links", "App Links"
- "QR코드 스캔", "바코드", "카메라 스캔", "mobile_scanner"
- "Isolate 사용", "성능 최적화", "UI Jank", "compute"
- "공유 기능", "share_plus", "공유 버튼"

## 전제 조건

- 거트알림 프로젝트 기술 스택 (Riverpod, go_router, Supabase, Material 3)
- 코드 예제의 Provider/Firebase Auth/Comic 디자인 부분은 프로젝트 컨벤션으로 치환하여 적용

## 프로토콜

1. **요청 분류**: 사용자 요청의 키워드를 아래 Workflow에서 매칭
2. **문서 참조**: 해당 reference 문서를 읽고 패턴/코드 예제 확인
3. **프로젝트 적응**: 코드 예제 적용 시 프로젝트 컨벤션에 맞게 치환
   - `Provider/ChangeNotifier` → **Riverpod Provider**
   - `FirebaseAuth.instance` → **Supabase Auth (supabase.auth)**
   - `Comic*` 위젯 → **Material 3 위젯**
   - `T.xxx` (i18n) → **직접 한국어 문자열**
4. **구현**: CLAUDE.md의 Flutter/Dart 코딩 규칙을 준수하며 구현

## Workflow

개발자 요청에 따라 아래 워크플로우를 따릅니다:

1. **레이아웃 요청 시**: [Flutter Layout 문서](./references/flutter-layout.md) 참조
   - 키워드: 레이아웃, 스크롤, CustomScrollView, ListView, Sliver, CarouselView, 위젯 배치

2. **라우팅 요청 시**: [Go Route 문서](./references/go_route.md) 참조
   - 키워드: 라우팅, 네비게이션, GoRouter, 페이지 이동, redirect, guard

3. **딥링크 요청 시**: [Deeplink 문서](./references/deeplink.md) 참조
   - 키워드: 딥링크, deep link, Universal Links, App Links

4. **바코드/QR코드 스캔 요청 시**: [Mobile Scanner 문서](./references/mobile-scanner.md) 참조
   - 키워드: 바코드, QR코드, 스캔, scanner, mobile_scanner, 카메라 스캔

5. **동시성/Isolate 요청 시**: [Concurrency 문서](./references/concurrency-and-isolates.md) 참조
   - 키워드: Isolate, 동시성, concurrency, UI Jank, compute

6. **공유 기능 요청 시**: [Share Plus 문서](./references/share-plus.md) 참조
   - 키워드: 공유, share, 공유 버튼, share_plus, 외부 앱 공유

## 참조 문서

| 문서 | 내용 |
|------|------|
| [flutter-layout.md](./references/flutter-layout.md) | CustomScrollView, Sliver, ListView, CarouselView, 반응형 레이아웃 |
| [go_route.md](./references/go_route.md) | GoRouter 라우팅, 파라미터 전달, redirect, guard |
| [deeplink.md](./references/deeplink.md) | 딥링크 구현, Universal Links, App Links, GoRouter 연동 |
| [mobile-scanner.md](./references/mobile-scanner.md) | mobile_scanner 바코드/QR코드 실시간 스캔, 카메라 제어 |
| [concurrency-and-isolates.md](./references/concurrency-and-isolates.md) | Dart Isolate, UI Jank 방지, compute() |
| [share-plus.md](./references/share-plus.md) | share_plus 텍스트/파일/URI 공유, iPad 호환 |

## 주의사항

reference 문서는 범용 Flutter 프로젝트(philgo_app)에서 가져온 것이므로, 코드 예제에 다음이 포함될 수 있다. 반드시 거트알림 컨벤션으로 치환하여 적용할 것:

| 원본 (reference) | 거트알림 치환 |
|------------------|-------------|
| `Provider`, `ChangeNotifier`, `context.read/watch` | Riverpod `ref.watch/read` |
| `FirebaseAuth.instance.currentUser` | `supabase.auth.currentUser` |
| `ComicButton`, `ComicTextFormField` 등 | Material 3 위젯 (`ElevatedButton`, `TextFormField` 등) |
| `T.xxx`, `.tr()` (i18n) | 직접 한국어 문자열 |
| `FontAwesomeIcons.xxx` | `Icons.xxx` (Material Icons) |
| `philgo.com` URL | 거트알림 도메인 |
