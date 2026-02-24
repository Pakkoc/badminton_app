# 거트알림 전체 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 거트알림(배드민턴 거트 작업 알림 서비스) Flutter 앱의 전체 구현

**Architecture:** Flutter 3.27 + Riverpod 2.6 상태 관리 + Supabase BaaS(PostgreSQL, Auth, Realtime, Edge Function, Storage) + go_router 네비게이션. Repository 패턴으로 데이터 접근을 추상화하고, TDD(Red→Green→Refactor)로 개발한다.

**Tech Stack:** Flutter/Dart, Riverpod, Supabase, go_router, FCM, Naver Map, freezed, mocktail

---

## 구현 순서 개요

| Phase | 내용 | 의존성 |
|-------|------|--------|
| 0 | 프로젝트 초기 설정 | 없음 |
| 1 | 공통 모듈 (M1~M12) | Phase 0 |
| 2 | 인증 플로우 (splash, login, profile-setup, shop-signup) | Phase 1 |
| 3 | 사장님 핵심 (dashboard, order-create, order-manage, shop-qr) | Phase 2 |
| 4 | 고객 핵심 (customer-home, order-detail, order-history) | Phase 2 |
| 5 | 샵 탐색 (shop-search, shop-detail) | Phase 2 |
| 6 | 콘텐츠 (post-create, post-list, post-detail) | Phase 3, 5 |
| 7 | 재고/알림 (inventory-manage, notifications) | Phase 3, 4 |
| 8 | 설정/프로필 (profile-edit, shop-settings, mypage) | Phase 2 |

---

## Phase 0: 프로젝트 초기 설정

### Task 0.1: Flutter 프로젝트 생성

**Files:**
- Create: `lib/main.dart` (자동 생성)
- Create: `pubspec.yaml` (자동 생성)

**Step 1: 프로젝트 생성**

```bash
flutter create --org com.gutarim badminton_app
```

**Step 2: 생성 확인**

Run: `flutter doctor`
Expected: Flutter 3.27.x 확인

**Step 3: Commit**

```bash
git add .
git commit -m "chore: Flutter 프로젝트 초기 생성"
```

---

### Task 0.2: pubspec.yaml 의존성 추가

**Files:**
- Edit: `pubspec.yaml`

**Step 1: pubspec.yaml 작성**

```yaml
name: badminton_app
description: 거트알림 - 배드민턴 거트 작업 알림 서비스
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter

  # BaaS / DB
  supabase_flutter: ^2.8.0

  # 상태 관리
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # 네비게이션
  go_router: ^14.6.2

  # Firebase (FCM)
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.6

  # 소셜 로그인
  kakao_flutter_sdk: ^1.9.7
  flutter_naver_login: ^1.8.0
  sign_in_with_apple: ^6.1.3
  google_sign_in: ^6.2.2

  # 지도
  flutter_naver_map: ^1.3.0

  # 이미지
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1

  # QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^6.0.2

  # 데이터 클래스 / JSON
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # UI
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # 코드 생성
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.2

  # 테스트
  mocktail: ^1.0.4

  # Lint
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

**Step 2: 의존성 설치 확인**

Run: `flutter pub get`
Expected: PASS (모든 패키지 resolve 성공)

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: 전체 의존성 패키지 추가"
```

---

### Task 0.3: 디렉토리 구조 생성

**Files:**
- Create: 전체 디렉토리 구조 + `.gitkeep` 파일

**Step 1: 디렉토리 생성**

```bash
# lib 구조
mkdir -p lib/app
mkdir -p lib/core/config
mkdir -p lib/core/error
mkdir -p lib/core/utils
mkdir -p lib/core/constants
mkdir -p lib/models
mkdir -p lib/repositories
mkdir -p lib/providers
mkdir -p lib/services
mkdir -p lib/widgets
mkdir -p lib/screens/auth
mkdir -p lib/screens/customer
mkdir -p lib/screens/owner

# test 구조
mkdir -p test/helpers
mkdir -p test/models
mkdir -p test/repositories
mkdir -p test/providers
mkdir -p test/widgets
mkdir -p test/screens/auth
mkdir -p test/screens/customer
mkdir -p test/screens/owner
mkdir -p test/integration
```

**Step 2: .gitkeep 추가 (빈 디렉토리 유지)**

```bash
for dir in lib/app lib/core/config lib/core/error lib/core/utils lib/core/constants \
  lib/models lib/repositories lib/providers lib/services lib/widgets \
  lib/screens/auth lib/screens/customer lib/screens/owner \
  test/helpers test/models test/repositories test/providers test/widgets \
  test/screens/auth test/screens/customer test/screens/owner test/integration; do
  touch "$dir/.gitkeep"
done
```

**Step 3: Commit**

```bash
git add .
git commit -m "chore: 프로젝트 디렉토리 구조 생성"
```

---

### Task 0.4: analysis_options.yaml 설정

**Files:**
- Edit: `analysis_options.yaml`

**Step 1: analysis_options.yaml 작성**

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_type_to_string
    - avoid_unnecessary_containers
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - directives_ordering
    - no_duplicate_case_values
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - require_trailing_commas
    - sort_child_properties_last
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_string_escapes
    - use_build_context_synchronously
    - use_key_in_widget_constructors
```

**Step 2: 분석 실행 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add analysis_options.yaml
git commit -m "chore: analysis_options.yaml 린트 규칙 설정"
```

---

### Task 0.5: .env 파일 및 .gitignore 설정

**Files:**
- Create: `.env.example`
- Edit: `.gitignore`

**Step 1: .env.example 작성**

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
NAVER_MAP_CLIENT_ID=your-naver-map-client-id
```

**Step 2: .gitignore에 환경/생성 파일 제외 규칙 추가**

```gitignore
# Environment
.env
.env.local
.env.production

# Generated files
*.g.dart
*.freezed.dart

# IDE
.vscode/
.idea/

# Firebase config (secrets)
google-services.json
GoogleService-Info.plist
firebase_options.dart
```

**Step 3: Commit**

```bash
git add .env.example .gitignore
git commit -m "chore: 환경 변수 템플릿 및 .gitignore 설정"
```

---

## Phase 2: 인증 플로우

### Task 2.1: Splash Screen (스플래시 화면)

> 화면 ID: `splash`
> UI 스펙: `docs/ui-specs/splash.md`
> 상태 설계: `docs/pages/splash/state.md`
> 유스케이스: UC-1 소셜 로그인 + 프로필 설정

#### Step 1: 실패하는 단위 테스트 작성

**파일: `test/screens/auth/splash/splash_notifier_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/screens/auth/splash/splash_providers.dart';
import 'package:gut_alarm/models/user.dart' as app;

// --- Mocks ---
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  group('splashRouteProvider', () {
    late ProviderContainer container;
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockSupabase.auth).thenReturn(mockAuth);
    });

    tearDown(() => container.dispose());

    // TC: 세션 없음 → SplashRoute.login
    test('세션이 없으면 SplashRoute.login을 반환한다', () async {
      // Arrange
      when(() => mockAuth.currentSession).thenReturn(null);

      container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
      );

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.login);
    });

    // TC: 세션 있음 + users 테이블에 없음 (신규 사용자) → SplashRoute.profileSetup
    test('세션이 있지만 users 테이블에 없으면 SplashRoute.profileSetup을 반환한다', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(
          accessToken: 'token',
          tokenType: 'bearer',
          user: mockUser,
        ),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          isNewUserProvider.overrideWith((ref) => true),
        ],
      );

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.profileSetup);
    });

    // TC: 기존 고객 → SplashRoute.customerHome
    test('기존 고객이면 SplashRoute.customerHome을 반환한다', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(
          accessToken: 'token',
          tokenType: 'bearer',
          user: mockUser,
        ),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          isNewUserProvider.overrideWith((ref) => false),
          userRoleProvider.overrideWith((ref) => app.UserRole.customer),
        ],
      );

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.customerHome);
    });

    // TC: 기존 사장님 → SplashRoute.ownerDashboard
    test('기존 사장님이면 SplashRoute.ownerDashboard를 반환한다', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(
          accessToken: 'token',
          tokenType: 'bearer',
          user: mockUser,
        ),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          isNewUserProvider.overrideWith((ref) => false),
          userRoleProvider.overrideWith((ref) => app.UserRole.shopOwner),
        ],
      );

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.ownerDashboard);
    });

    // TC: 5초 타임아웃 → SplashRoute.login 폴백
    test('5초 타임아웃 시 SplashRoute.login으로 폴백한다', () async {
      // Arrange — 응답이 6초 걸리는 상황 시뮬레이션
      when(() => mockAuth.currentSession).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 6), () => null),
      );

      container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
      );

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.login);
    });
  });
}
```

#### Step 2: Provider 구현

**파일: `lib/screens/auth/splash/splash_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/models/user.dart' as app;

part 'splash_providers.g.dart';

/// 스플래시 화면에서 결정하는 라우팅 목적지
enum SplashRoute {
  login,
  customerHome,
  ownerDashboard,
  profileSetup,
}

/// 인증 상태를 확인하여 라우팅 목적지를 결정하는 FutureProvider.
/// - 세션 없음 → login
/// - 신규 사용자 → profileSetup
/// - 기존 고객 → customerHome
/// - 기존 사장님 → ownerDashboard
/// - 5초 타임아웃 → login (폴백)
@riverpod
Future<SplashRoute> splashRoute(SplashRouteRef ref) async {
  try {
    final route = await Future(() async {
      // 최소 1.5초 표시 보장
      final minDisplay = Future.delayed(const Duration(milliseconds: 1500));

      final supabase = ref.read(supabaseProvider);
      final session = supabase.auth.currentSession;

      if (session == null) {
        await minDisplay;
        return SplashRoute.login;
      }

      // 신규 사용자 확인
      final isNew = await ref.read(isNewUserProvider.future);
      if (isNew) {
        await minDisplay;
        return SplashRoute.profileSetup;
      }

      // 기존 사용자 역할 확인
      final role = await ref.read(userRoleProvider.future);
      await minDisplay;

      return switch (role) {
        app.UserRole.customer => SplashRoute.customerHome,
        app.UserRole.shopOwner => SplashRoute.ownerDashboard,
      };
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: () => SplashRoute.login,
    );

    return route;
  } catch (_) {
    return SplashRoute.login;
  }
}
```

#### Step 3: 위젯 테스트 작성

**파일: `test/screens/auth/splash/splash_screen_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/screens/auth/splash/splash_screen.dart';
import 'package:gut_alarm/screens/auth/splash/splash_providers.dart';

void main() {
  group('SplashScreen 위젯 테스트', () {
    // TC: 로고 아이콘 표시 (셔틀콕 80x80, #16A34A)
    testWidgets('셔틀콕 아이콘과 앱 이름이 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashRouteProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 10),
                () => SplashRoute.login,
              ),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('거트알림'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('배드민턴 거트 추적 서비스'), findsOneWidget);
    });

    // TC: 로딩 인디케이터 색상 (#16A34A)
    testWidgets('로딩 중 CircularProgressIndicator가 초록색으로 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashRouteProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 10),
                () => SplashRoute.login,
              ),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Act
      await tester.pump(const Duration(milliseconds: 700));

      // Assert
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, const Color(0xFF16A34A));
    });
  });
}
```

#### Step 4: 화면 위젯 구현

**파일: `lib/screens/auth/splash/splash_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/screens/auth/splash/splash_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<double> _spinnerFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 로고: 0~500ms fade + scale
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.556, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.556, curve: Curves.easeOut),
      ),
    );

    // 텍스트: 200ms 딜레이 + 400ms fade
    _textFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.222, 0.667, curve: Curves.easeOut),
      ),
    );

    // 스피너: 600ms 딜레이 + 300ms fade
    _spinnerFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.667, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // splashRouteProvider 결과 감시 → 라우팅
    ref.listen(splashRouteProvider, (previous, next) {
      next.whenData((route) {
        if (!mounted) return;
        switch (route) {
          case SplashRoute.login:
            context.go('/login');
          case SplashRoute.profileSetup:
            context.go('/profile-setup');
          case SplashRoute.customerHome:
            context.go('/customer/home');
          case SplashRoute.ownerDashboard:
            context.go('/owner/dashboard');
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 아이콘 (셔틀콕)
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const Icon(
                      Icons.sports_tennis,
                      size: 80,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 앱 이름
                FadeTransition(
                  opacity: _logoFade,
                  child: const Text(
                    '거트알림',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 슬로건
                FadeTransition(
                  opacity: _textFade,
                  child: const Text(
                    '배드민턴 거트 추적 서비스',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 32),
                // 로딩 스피너
                FadeTransition(
                  opacity: _spinnerFade,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

#### Step 5: 테스트 실행

```bash
flutter test test/screens/auth/splash/
```

#### Step 6: 커밋

```bash
git add lib/screens/auth/splash/ test/screens/auth/splash/
git commit -m "feat: 스플래시 화면 구현 (라우팅 분기 + 애니메이션)"
```

---

### Task 2.2: Login Screen (로그인 화면)

> 화면 ID: `login`
> UI 스펙: `docs/ui-specs/login.md`
> 상태 설계: `docs/pages/login/state.md`
> 유스케이스: UC-1 소셜 로그인 + 프로필 설정

#### Step 1: 실패하는 단위 테스트 작성

**파일: `test/screens/auth/login/login_notifier_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:gut_alarm/screens/auth/login/login_state.dart';
import 'package:gut_alarm/screens/auth/login/login_notifier.dart';
import 'package:gut_alarm/repositories/auth_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/core/error/app_exception.dart';

// --- Mocks ---
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginNotifier', () {
    late ProviderContainer container;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
    });

    tearDown(() => container.dispose());

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
    }

    // TC: 초기 상태는 idle
    test('초기 상태는 LoginState.idle()이다', () {
      // Arrange
      container = createContainer();

      // Act
      final state = container.read(loginNotifierProvider);

      // Assert
      expect(state, const LoginState.idle());
    });

    // TC: 카카오 로그인 시작 → authenticating(kakao)
    test('signInWithKakao 호출 시 authenticating(kakao) 상태가 된다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenAnswer((_) async {});
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      final future = notifier.signInWithKakao();

      // Assert
      expect(
        container.read(loginNotifierProvider),
        const LoginState.authenticating(OAuthProvider.kakao),
      );
      await future;
    });

    // TC: 네이버 로그인 시작 → authenticating(naver)
    test('signInWithNaver 호출 시 authenticating(naver) 상태가 된다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.naver))
          .thenAnswer((_) async {});
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      final future = notifier.signInWithNaver();

      // Assert
      expect(
        container.read(loginNotifierProvider),
        const LoginState.authenticating(OAuthProvider.naver),
      );
      await future;
    });

    // TC: Google 로그인 시작 → authenticating(google)
    test('signInWithGoogle 호출 시 authenticating(google) 상태가 된다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.google))
          .thenAnswer((_) async {});
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      final future = notifier.signInWithGoogle();

      // Assert
      expect(
        container.read(loginNotifierProvider),
        const LoginState.authenticating(OAuthProvider.google),
      );
      await future;
    });

    // TC: 로그인 성공 → idle 복귀
    test('소셜 로그인 성공 시 idle 상태로 복귀한다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenAnswer((_) async {});
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.signInWithKakao();

      // Assert
      expect(container.read(loginNotifierProvider), const LoginState.idle());
    });

    // TC: 사용자 취소 → idle (에러 메시지 없음)
    test('사용자가 로그인을 취소하면 idle로 복귀한다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(const AppException.cancelled());
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.signInWithKakao();

      // Assert
      expect(container.read(loginNotifierProvider), const LoginState.idle());
    });

    // TC: 네트워크 에러 → error 상태
    test('네트워크 오류 시 error 상태로 변경된다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(const AppException.network());
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.signInWithKakao();

      // Assert
      expect(
        container.read(loginNotifierProvider),
        const LoginState.error('네트워크 연결을 확인해주세요'),
      );
    });

    // TC: 기타 에러 → error 상태
    test('기타 로그인 실패 시 에러 메시지를 표시한다', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(Exception('unknown'));
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);

      // Act
      await notifier.signInWithKakao();

      // Assert
      expect(
        container.read(loginNotifierProvider),
        const LoginState.error('로그인에 실패했습니다. 다시 시도해주세요'),
      );
    });
  });
}
```

#### Step 2: 상태 클래스 및 Notifier 구현

**파일: `lib/screens/auth/login/login_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// OAuth 제공자 열거형
enum OAuthProvider { kakao, naver, google }

/// 로그인 화면 상태 (freezed union)
@freezed
class LoginState with _$LoginState {
  /// 기본 상태. 모든 소셜 로그인 버튼 활성
  const factory LoginState.idle() = LoginStateIdle;

  /// 특정 소셜 로그인 진행 중. 해당 버튼에 스피너, 전체 비활성
  const factory LoginState.authenticating(OAuthProvider provider) =
      LoginStateAuthenticating;

  /// 로그인 실패. 에러 스낵바 표시 후 idle로 자동 복귀
  const factory LoginState.error(String message) = LoginStateError;
}
```

**파일: `lib/screens/auth/login/login_notifier.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/screens/auth/login/login_state.dart';
import 'package:gut_alarm/repositories/auth_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/core/error/app_exception.dart';

part 'login_notifier.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginState.idle();

  /// 카카오 소셜 로그인
  Future<void> signInWithKakao() => _signIn(OAuthProvider.kakao);

  /// 네이버 소셜 로그인
  Future<void> signInWithNaver() => _signIn(OAuthProvider.naver);

  /// Google 소셜 로그인
  Future<void> signInWithGoogle() => _signIn(OAuthProvider.google);

  Future<void> _signIn(OAuthProvider provider) async {
    state = LoginState.authenticating(provider);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithOAuth(provider);
      state = const LoginState.idle();
    } on AppException catch (e) {
      state = e.maybeWhen(
        cancelled: () => const LoginState.idle(),
        network: () => const LoginState.error('네트워크 연결을 확인해주세요'),
        orElse: () =>
            const LoginState.error('로그인에 실패했습니다. 다시 시도해주세요'),
      );
    } catch (_) {
      state = const LoginState.error('로그인에 실패했습니다. 다시 시도해주세요');
    }
  }
}
```

#### Step 3: 위젯 테스트 작성

**파일: `test/screens/auth/login/login_screen_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/screens/auth/login/login_screen.dart';
import 'package:gut_alarm/screens/auth/login/login_state.dart';
import 'package:gut_alarm/screens/auth/login/login_notifier.dart';

void main() {
  group('LoginScreen 위젯 테스트', () {
    // TC: 소셜 로그인 버튼 3개 표시
    testWidgets('카카오, 네이버, Google 로그인 버튼이 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Assert
      expect(find.text('카카오로 시작하기'), findsOneWidget);
      expect(find.text('네이버로 시작하기'), findsOneWidget);
      expect(find.text('Google로 시작하기'), findsOneWidget);
    });

    // TC: 로고와 환영 메시지 표시
    testWidgets('로고와 환영 메시지가 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Assert
      expect(find.text('거트알림'), findsOneWidget);
      expect(find.text('반갑습니다!'), findsOneWidget);
      expect(find.text('간편하게 시작하세요'), findsOneWidget);
    });

    // TC: authenticating 상태에서 해당 버튼에 스피너 표시
    testWidgets('authenticating 상태에서 해당 버튼에 스피너가 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loginNotifierProvider.overrideWith(() {
              return _FakeLoginNotifier(
                const LoginState.authenticating(OAuthProvider.kakao),
              );
            }),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // TC: error 상태에서 에러 스낵바 표시
    testWidgets('error 상태에서 에러 스낵바가 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loginNotifierProvider.overrideWith(() {
              return _FakeLoginNotifier(
                const LoginState.error('네트워크 연결을 확인해주세요'),
              );
            }),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('네트워크 연결을 확인해주세요'), findsOneWidget);
    });

    // TC: 카카오 버튼 색상 (#FEE500)
    testWidgets('카카오 버튼의 배경색이 #FEE500이다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Assert
      final kakaoButton = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('카카오로 시작하기'),
          matching: find.byType(OutlinedButton),
        ),
      );
      final style = kakaoButton.style!;
      final bgColor = style.backgroundColor?.resolve({});
      expect(bgColor, const Color(0xFFFEE500));
    });
  });
}

/// 테스트용 가짜 LoginNotifier
class _FakeLoginNotifier extends LoginNotifier {
  final LoginState _initial;
  _FakeLoginNotifier(this._initial);

  @override
  LoginState build() => _initial;
}
```

#### Step 4: 화면 위젯 구현

**파일: `lib/screens/auth/login/login_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/screens/auth/login/login_state.dart';
import 'package:gut_alarm/screens/auth/login/login_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    // 에러 스낵바 리스너
    ref.listen(loginNotifierProvider, (prev, next) {
      next.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
              backgroundColor: const Color(0xFFFEE2E2),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        orElse: () {},
      );
    });

    final isLoading = loginState is LoginStateAuthenticating;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // 로고
              const Icon(
                Icons.sports_tennis,
                size: 56,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(height: 8),
              const Text(
                '거트알림',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 32),
              // 환영 메시지
              const Text(
                '반갑습니다!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '간편하게 시작하세요',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              const Spacer(flex: 2),
              // 소셜 로그인 버튼들
              _SocialLoginButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                isLoading: loginState ==
                    const LoginState.authenticating(OAuthProvider.kakao),
                isDisabled: isLoading,
                onPressed: () => notifier.signInWithKakao(),
              ),
              const SizedBox(height: 12),
              _SocialLoginButton(
                label: '네이버로 시작하기',
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                isLoading: loginState ==
                    const LoginState.authenticating(OAuthProvider.naver),
                isDisabled: isLoading,
                onPressed: () => notifier.signInWithNaver(),
              ),
              const SizedBox(height: 12),
              _SocialLoginButton(
                label: 'Google로 시작하기',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF1E293B),
                borderColor: const Color(0xFFE2E8F0),
                isLoading: loginState ==
                    const LoginState.authenticating(OAuthProvider.google),
                isDisabled: isLoading,
                onPressed: () => notifier.signInWithGoogle(),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
```

#### Step 5: 테스트 실행

```bash
flutter test test/screens/auth/login/
```

#### Step 6: 커밋

```bash
git add lib/screens/auth/login/ test/screens/auth/login/
git commit -m "feat: 로그인 화면 구현 (소셜 로그인 3종 + 에러 처리)"
```

---

## Phase 3: 사장님 핵심 화면

> **의존성**: Phase 1 (공통 모듈 M1~M12), Phase 2 (인증 플로우) 완료 필수
>
> **화면 목록**: 대시보드(3.1), 작업 접수(3.2), 작업 관리(3.3), 샵 QR(3.4)

## Phase 1: 공통 모듈 (M1~M12)

### Task 1.1: M4 데이터 모델 + Enum

**Files:**
- Create: `lib/models/enums.dart`
- Create: `lib/models/user.dart`
- Create: `lib/models/shop.dart`
- Create: `lib/models/member.dart`
- Create: `lib/models/order.dart`
- Create: `lib/models/post.dart`
- Create: `lib/models/inventory_item.dart`
- Create: `lib/models/notification_item.dart`
- Test: `test/models/enums_test.dart`
- Test: `test/models/user_test.dart`
- Test: `test/models/shop_test.dart`
- Test: `test/models/member_test.dart`
- Test: `test/models/order_test.dart`
- Test: `test/models/post_test.dart`
- Test: `test/models/inventory_item_test.dart`
- Test: `test/models/notification_item_test.dart`

**Step 1: Write the failing test**

```dart
// test/models/enums_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/enums.dart';

void main() {
  group('UserRole', () {
    test('toJson은 snake_case 문자열을 반환한다', () {
      expect(UserRole.customer.toJson(), 'customer');
      expect(UserRole.shopOwner.toJson(), 'shop_owner');
    });

    test('fromJson은 snake_case 문자열에서 enum을 반환한다', () {
      expect(UserRole.fromJson('customer'), UserRole.customer);
      expect(UserRole.fromJson('shop_owner'), UserRole.shopOwner);
    });

    test('fromJson에 잘못된 값을 전달하면 ArgumentError를 던진다', () {
      expect(() => UserRole.fromJson('invalid'), throwsArgumentError);
    });
  });

  group('OrderStatus', () {
    test('toJson은 snake_case 문자열을 반환한다', () {
      expect(OrderStatus.received.toJson(), 'received');
      expect(OrderStatus.inProgress.toJson(), 'in_progress');
      expect(OrderStatus.completed.toJson(), 'completed');
    });

    test('fromJson은 snake_case 문자열에서 enum을 반환한다', () {
      expect(OrderStatus.fromJson('received'), OrderStatus.received);
      expect(OrderStatus.fromJson('in_progress'), OrderStatus.inProgress);
      expect(OrderStatus.fromJson('completed'), OrderStatus.completed);
    });

    test('label은 한국어 텍스트를 반환한다', () {
      expect(OrderStatus.received.label, '접수됨');
      expect(OrderStatus.inProgress.label, '작업중');
      expect(OrderStatus.completed.label, '완료');
    });
  });

  group('PostCategory', () {
    test('toJson은 snake_case 문자열을 반환한다', () {
      expect(PostCategory.notice.toJson(), 'notice');
      expect(PostCategory.event.toJson(), 'event');
    });

    test('fromJson은 snake_case 문자열에서 enum을 반환한다', () {
      expect(PostCategory.fromJson('notice'), PostCategory.notice);
      expect(PostCategory.fromJson('event'), PostCategory.event);
    });

    test('label은 한국어 텍스트를 반환한다', () {
      expect(PostCategory.notice.label, '공지사항');
      expect(PostCategory.event.label, '이벤트');
    });
  });

  group('NotificationType', () {
    test('toJson은 snake_case 문자열을 반환한다', () {
      expect(NotificationType.statusChange.toJson(), 'status_change');
      expect(NotificationType.completion.toJson(), 'completion');
      expect(NotificationType.notice.toJson(), 'notice');
      expect(NotificationType.receipt.toJson(), 'receipt');
    });

    test('fromJson은 snake_case 문자열에서 enum을 반환한다', () {
      expect(NotificationType.fromJson('status_change'), NotificationType.statusChange);
      expect(NotificationType.fromJson('completion'), NotificationType.completion);
      expect(NotificationType.fromJson('notice'), NotificationType.notice);
      expect(NotificationType.fromJson('receipt'), NotificationType.receipt);
    });
  });
}
```

```dart
// test/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/models/enums.dart';

void main() {
  group('User', () {
    final json = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'role': 'customer',
      'name': '홍길동',
      'phone': '01012345678',
      'profile_image_url': 'https://example.com/img.jpg',
      'fcm_token': 'token123',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson은 JSON에서 User 객체를 생성한다', () {
      // Arrange & Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(user.role, UserRole.customer);
      expect(user.name, '홍길동');
      expect(user.phone, '01012345678');
      expect(user.profileImageUrl, 'https://example.com/img.jpg');
      expect(user.fcmToken, 'token123');
      expect(user.createdAt, isA<DateTime>());
    });

    test('toJson은 User 객체를 JSON으로 변환한다', () {
      final user = User.fromJson(json);
      final result = user.toJson();

      expect(result['id'], '550e8400-e29b-41d4-a716-446655440000');
      expect(result['role'], 'customer');
      expect(result['name'], '홍길동');
      expect(result['profile_image_url'], 'https://example.com/img.jpg');
    });

    test('nullable 필드가 null일 때 정상 동작한다', () {
      final minimalJson = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'role': 'shop_owner',
        'name': '김사장',
        'phone': '01098765432',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final user = User.fromJson(minimalJson);

      expect(user.profileImageUrl, isNull);
      expect(user.fcmToken, isNull);
      expect(user.role, UserRole.shopOwner);
    });

    test('copyWith으로 특정 필드만 변경한다', () {
      final user = User.fromJson(json);
      final updated = user.copyWith(name: '이순신');
      expect(updated.name, '이순신');
      expect(updated.phone, '01012345678');
    });

    test('동일한 데이터를 가진 두 User는 같다', () {
      expect(User.fromJson(json), equals(User.fromJson(json)));
    });
  });
}
```

```dart
// test/models/shop_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/shop.dart';

void main() {
  group('Shop', () {
    final json = {
      'id': '660e8400-e29b-41d4-a716-446655440001',
      'owner_id': '550e8400-e29b-41d4-a716-446655440000',
      'name': '거트 프로샵',
      'address': '서울시 강남구 역삼동 123',
      'latitude': 37.4979,
      'longitude': 127.0276,
      'phone': '0212345678',
      'description': '최고의 거트 서비스',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson은 JSON에서 Shop 객체를 생성한다', () {
      final shop = Shop.fromJson(json);
      expect(shop.id, '660e8400-e29b-41d4-a716-446655440001');
      expect(shop.ownerId, '550e8400-e29b-41d4-a716-446655440000');
      expect(shop.name, '거트 프로샵');
      expect(shop.latitude, 37.4979);
      expect(shop.longitude, 127.0276);
    });

    test('toJson은 Shop 객체를 JSON으로 변환한다', () {
      final result = Shop.fromJson(json).toJson();
      expect(result['owner_id'], '550e8400-e29b-41d4-a716-446655440000');
      expect(result['latitude'], 37.4979);
    });

    test('description이 null일 때 정상 동작한다', () {
      final minimalJson = Map<String, dynamic>.from(json)..remove('description');
      expect(Shop.fromJson(minimalJson).description, isNull);
    });

    test('동일한 데이터를 가진 두 Shop은 같다', () {
      expect(Shop.fromJson(json), equals(Shop.fromJson(json)));
    });
  });
}
```

```dart
// test/models/member_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/member.dart';

void main() {
  group('Member', () {
    final json = {
      'id': '770e8400-e29b-41d4-a716-446655440002',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'user_id': '550e8400-e29b-41d4-a716-446655440000',
      'name': '홍길동',
      'phone': '01012345678',
      'memo': '단골 고객',
      'visit_count': 5,
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson은 JSON에서 Member 객체를 생성한다', () {
      final member = Member.fromJson(json);
      expect(member.id, '770e8400-e29b-41d4-a716-446655440002');
      expect(member.shopId, '660e8400-e29b-41d4-a716-446655440001');
      expect(member.userId, '550e8400-e29b-41d4-a716-446655440000');
      expect(member.name, '홍길동');
      expect(member.visitCount, 5);
    });

    test('toJson은 Member 객체를 JSON으로 변환한다', () {
      final result = Member.fromJson(json).toJson();
      expect(result['shop_id'], '660e8400-e29b-41d4-a716-446655440001');
      expect(result['visit_count'], 5);
    });

    test('user_id가 null일 때 정상 동작한다 (앱 미가입 고객)', () {
      final offlineJson = Map<String, dynamic>.from(json)..['user_id'] = null;
      expect(Member.fromJson(offlineJson).userId, isNull);
    });

    test('memo가 null일 때 정상 동작한다', () {
      final noMemoJson = Map<String, dynamic>.from(json)..remove('memo');
      expect(Member.fromJson(noMemoJson).memo, isNull);
    });
  });
}
```

```dart
// test/models/order_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';

void main() {
  group('Order', () {
    final json = {
      'id': '880e8400-e29b-41d4-a716-446655440003',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'member_id': '770e8400-e29b-41d4-a716-446655440002',
      'status': 'received',
      'memo': '2본 작업',
      'created_at': '2026-01-15T10:00:00.000Z',
      'in_progress_at': null,
      'completed_at': null,
      'updated_at': '2026-01-15T10:00:00.000Z',
    };

    test('fromJson은 JSON에서 Order 객체를 생성한다', () {
      final order = Order.fromJson(json);
      expect(order.id, '880e8400-e29b-41d4-a716-446655440003');
      expect(order.status, OrderStatus.received);
      expect(order.memo, '2본 작업');
      expect(order.inProgressAt, isNull);
    });

    test('toJson은 Order 객체를 JSON으로 변환한다', () {
      final result = Order.fromJson(json).toJson();
      expect(result['status'], 'received');
      expect(result['shop_id'], '660e8400-e29b-41d4-a716-446655440001');
    });

    test('in_progress 상태의 Order를 파싱한다', () {
      final ipJson = Map<String, dynamic>.from(json)
        ..['status'] = 'in_progress'
        ..['in_progress_at'] = '2026-01-15T11:00:00.000Z';
      final order = Order.fromJson(ipJson);
      expect(order.status, OrderStatus.inProgress);
      expect(order.inProgressAt, isNotNull);
    });

    test('completed 상태의 Order를 파싱한다', () {
      final cJson = Map<String, dynamic>.from(json)
        ..['status'] = 'completed'
        ..['in_progress_at'] = '2026-01-15T11:00:00.000Z'
        ..['completed_at'] = '2026-01-15T12:00:00.000Z';
      final order = Order.fromJson(cJson);
      expect(order.status, OrderStatus.completed);
      expect(order.completedAt, isNotNull);
    });

    test('memo가 null일 때 정상 동작한다', () {
      final noMemoJson = Map<String, dynamic>.from(json)..remove('memo');
      expect(Order.fromJson(noMemoJson).memo, isNull);
    });
  });
}
```

```dart
// test/models/post_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/enums.dart';

void main() {
  group('Post', () {
    final noticeJson = {
      'id': '990e8400-e29b-41d4-a716-446655440004',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'category': 'notice',
      'title': '영업시간 변경 안내',
      'content': '1월부터 영업시간이 변경됩니다.',
      'images': ['https://example.com/img1.jpg'],
      'event_start_date': null,
      'event_end_date': null,
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    final eventJson = {
      'id': 'aa0e8400-e29b-41d4-a716-446655440005',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'category': 'event',
      'title': '신년 이벤트',
      'content': '거트 교체 50% 할인!',
      'images': [],
      'event_start_date': '2026-01-01',
      'event_end_date': '2026-01-31',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson은 notice 게시글을 생성한다', () {
      final post = Post.fromJson(noticeJson);
      expect(post.category, PostCategory.notice);
      expect(post.images, hasLength(1));
      expect(post.eventStartDate, isNull);
    });

    test('fromJson은 event 게시글을 생성한다', () {
      final post = Post.fromJson(eventJson);
      expect(post.category, PostCategory.event);
      expect(post.eventStartDate, isNotNull);
      expect(post.eventEndDate, isNotNull);
    });

    test('toJson은 Post 객체를 JSON으로 변환한다', () {
      final result = Post.fromJson(noticeJson).toJson();
      expect(result['category'], 'notice');
    });

    test('images가 빈 배열일 때 정상 동작한다', () {
      expect(Post.fromJson(eventJson).images, isEmpty);
    });
  });
}
```

```dart
// test/models/inventory_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    final json = {
      'id': 'bb0e8400-e29b-41d4-a716-446655440006',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'name': 'BG65',
      'category': '거트',
      'quantity': 10,
      'image_url': 'https://example.com/bg65.jpg',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

    test('fromJson은 JSON에서 InventoryItem 객체를 생성한다', () {
      final item = InventoryItem.fromJson(json);
      expect(item.name, 'BG65');
      expect(item.category, '거트');
      expect(item.quantity, 10);
    });

    test('toJson은 InventoryItem 객체를 JSON으로 변환한다', () {
      final result = InventoryItem.fromJson(json).toJson();
      expect(result['shop_id'], '660e8400-e29b-41d4-a716-446655440001');
      expect(result['quantity'], 10);
    });

    test('category와 image_url이 null일 때 정상 동작한다', () {
      final minimalJson = Map<String, dynamic>.from(json)
        ..remove('category')
        ..remove('image_url');
      final item = InventoryItem.fromJson(minimalJson);
      expect(item.category, isNull);
      expect(item.imageUrl, isNull);
    });
  });
}
```

```dart
// test/models/notification_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/models/enums.dart';

void main() {
  group('NotificationItem', () {
    final json = {
      'id': 'cc0e8400-e29b-41d4-a716-446655440007',
      'user_id': '550e8400-e29b-41d4-a716-446655440000',
      'type': 'status_change',
      'title': '작업 상태 변경',
      'body': '거트 프로샵에서 작업이 시작되었습니다.',
      'order_id': '880e8400-e29b-41d4-a716-446655440003',
      'is_read': false,
      'created_at': '2026-01-15T12:00:00.000Z',
    };

    test('fromJson은 JSON에서 NotificationItem 객체를 생성한다', () {
      final n = NotificationItem.fromJson(json);
      expect(n.type, NotificationType.statusChange);
      expect(n.title, '작업 상태 변경');
      expect(n.isRead, false);
    });

    test('toJson은 NotificationItem 객체를 JSON으로 변환한다', () {
      final result = NotificationItem.fromJson(json).toJson();
      expect(result['type'], 'status_change');
      expect(result['is_read'], false);
    });

    test('order_id가 null일 때 정상 동작한다', () {
      final noOrderJson = Map<String, dynamic>.from(json)..['order_id'] = null;
      expect(NotificationItem.fromJson(noOrderJson).orderId, isNull);
    });

    test('completion 타입을 파싱한다', () {
      final cJson = Map<String, dynamic>.from(json)..['type'] = 'completion';
      expect(NotificationItem.fromJson(cJson).type, NotificationType.completion);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/`
Expected: FAIL (모델 클래스가 아직 없으므로 컴파일 에러)

**Step 3: Write minimal implementation**

```dart
// lib/models/enums.dart

enum UserRole {
  customer,
  shopOwner;

  String toJson() {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.shopOwner:
        return 'shop_owner';
    }
  }

  static UserRole fromJson(String value) {
    switch (value) {
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
        return UserRole.shopOwner;
      default:
        throw ArgumentError('Unknown UserRole: $value');
    }
  }
}

enum OrderStatus {
  received,
  inProgress,
  completed;

  String toJson() {
    switch (this) {
      case OrderStatus.received:
        return 'received';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.completed:
        return 'completed';
    }
  }

  static OrderStatus fromJson(String value) {
    switch (value) {
      case 'received':
        return OrderStatus.received;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      default:
        throw ArgumentError('Unknown OrderStatus: $value');
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.received:
        return '접수됨';
      case OrderStatus.inProgress:
        return '작업중';
      case OrderStatus.completed:
        return '완료';
    }
  }
}

enum PostCategory {
  notice,
  event;

  String toJson() {
    switch (this) {
      case PostCategory.notice:
        return 'notice';
      case PostCategory.event:
        return 'event';
    }
  }

  static PostCategory fromJson(String value) {
    switch (value) {
      case 'notice':
        return PostCategory.notice;
      case 'event':
        return PostCategory.event;
      default:
        throw ArgumentError('Unknown PostCategory: $value');
    }
  }

  String get label {
    switch (this) {
      case PostCategory.notice:
        return '공지사항';
      case PostCategory.event:
        return '이벤트';
    }
  }
}

enum NotificationType {
  statusChange,
  completion,
  notice,
  receipt;

  String toJson() {
    switch (this) {
      case NotificationType.statusChange:
        return 'status_change';
      case NotificationType.completion:
        return 'completion';
      case NotificationType.notice:
        return 'notice';
      case NotificationType.receipt:
        return 'receipt';
    }
  }

  static NotificationType fromJson(String value) {
    switch (value) {
      case 'status_change':
        return NotificationType.statusChange;
      case 'completion':
        return NotificationType.completion;
      case 'notice':
        return NotificationType.notice;
      case 'receipt':
        return NotificationType.receipt;
      default:
        throw ArgumentError('Unknown NotificationType: $value');
    }
  }
}
```

```dart
// lib/models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    @JsonKey(fromJson: UserRole.fromJson, toJson: _userRoleToJson)
    required UserRole role,
    required String name,
    required String phone,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

String _userRoleToJson(UserRole role) => role.toJson();
```

```dart
// lib/models/shop.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop.freezed.dart';
part 'shop.g.dart';

@freezed
class Shop with _$Shop {
  const factory Shop({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
}
```

```dart
// lib/models/member.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  const factory Member({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'user_id') String? userId,
    required String name,
    required String phone,
    String? memo,
    @JsonKey(name: 'visit_count') @Default(0) int visitCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
```

```dart
// lib/models/order.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(fromJson: OrderStatus.fromJson, toJson: _orderStatusToJson)
    required OrderStatus status,
    String? memo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'in_progress_at') DateTime? inProgressAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

String _orderStatusToJson(OrderStatus status) => status.toJson();
```

```dart
// lib/models/post.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(fromJson: PostCategory.fromJson, toJson: _postCategoryToJson)
    required PostCategory category,
    required String title,
    required String content,
    @Default([]) List<String> images,
    @JsonKey(name: 'event_start_date') DateTime? eventStartDate,
    @JsonKey(name: 'event_end_date') DateTime? eventEndDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

String _postCategoryToJson(PostCategory category) => category.toJson();
```

```dart
// lib/models/inventory_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    String? category,
    @Default(0) int quantity,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
```

```dart
// lib/models/notification_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(fromJson: NotificationType.fromJson, toJson: _notificationTypeToJson)
    required NotificationType type,
    required String title,
    required String body,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

String _notificationTypeToJson(NotificationType type) => type.toJson();
```

**Step 4: Run code generation and test**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/models/`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat: M4 데이터 모델 및 Enum 정의 (freezed)"
```

---

### Task 1.2: M1 앱 초기화

**Files:**
- Create: `lib/core/config/env.dart`
- Create: `lib/providers/supabase_provider.dart`
- Edit: `lib/main.dart`
- Test: `test/core/config/env_test.dart`

**Step 1: Write the failing test**

```dart
// test/core/config/env_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/config/env.dart';

void main() {
  group('Env', () {
    test('supabaseUrl은 빈 문자열이 아니다', () {
      expect(Env.supabaseUrl, isNotEmpty);
    });

    test('supabaseAnonKey는 빈 문자열이 아니다', () {
      expect(Env.supabaseAnonKey, isNotEmpty);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/core/config/env_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/core/config/env.dart

class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static const String naverMapClientId = String.fromEnvironment(
    'NAVER_MAP_CLIENT_ID',
    defaultValue: '',
  );
}
```

```dart
// lib/providers/supabase_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
```

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '거트알림',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFF97316),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('거트알림')),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/core/config/env_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/core/config/env.dart lib/providers/supabase_provider.dart lib/main.dart
git commit -m "feat: M1 앱 초기화 및 환경 설정 모듈"
```

---

### Task 1.3: M6 에러 처리

**Files:**
- Create: `lib/core/error/app_exception.dart`
- Create: `lib/core/error/error_handler.dart`
- Test: `test/core/error/app_exception_test.dart`
- Test: `test/core/error/error_handler_test.dart`

**Step 1: Write the failing test**

```dart
// test/core/error/app_exception_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/error/app_exception.dart';

void main() {
  group('AppException', () {
    test('network 팩토리는 올바른 코드와 메시지를 생성한다', () {
      final e = AppException.network();
      expect(e.code, 'network');
      expect(e.userMessage, '네트워크 연결을 확인해주세요');
    });

    test('server 팩토리는 올바른 코드와 메시지를 생성한다', () {
      final e = AppException.server();
      expect(e.code, 'server');
      expect(e.userMessage, '서버 오류가 발생했습니다. 다시 시도해주세요');
    });

    test('unauthorized 팩토리는 올바른 코드와 메시지를 생성한다', () {
      final e = AppException.unauthorized();
      expect(e.code, 'unauthorized');
      expect(e.userMessage, '로그인이 필요합니다');
    });

    test('notFound 팩토리는 올바른 코드와 메시지를 생성한다', () {
      final e = AppException.notFound();
      expect(e.code, 'not_found');
      expect(e.userMessage, '데이터를 찾을 수 없습니다');
    });

    test('validation 팩토리는 커스텀 메시지를 설정한다', () {
      final e = AppException.validation('이름을 입력해주세요');
      expect(e.code, 'validation');
      expect(e.userMessage, '이름을 입력해주세요');
    });

    test('duplicate 팩토리는 올바른 코드와 메시지를 생성한다', () {
      final e = AppException.duplicate();
      expect(e.code, 'duplicate');
      expect(e.userMessage, '이미 등록된 데이터입니다');
    });

    test('originalError를 보존한다', () {
      final original = Exception('원본 에러');
      final e = AppException.server(originalError: original);
      expect(e.originalError, original);
    });

    test('toString은 코드와 메시지를 포함한다', () {
      final e = AppException.network();
      expect(e.toString(), contains('network'));
    });
  });
}
```

```dart
// test/core/error/error_handler_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('SocketException을 network AppException으로 변환한다', () {
      final result = ErrorHandler.handle(const SocketException('refused'));
      expect(result.code, 'network');
    });

    test('AppException은 그대로 반환한다', () {
      final error = AppException.validation('이미 존재합니다');
      final result = ErrorHandler.handle(error);
      expect(result.code, 'validation');
      expect(result.userMessage, '이미 존재합니다');
    });

    test('알 수 없는 에러를 server AppException으로 변환한다', () {
      final result = ErrorHandler.handle(Exception('unknown'));
      expect(result.code, 'server');
    });

    test('FormatException을 validation AppException으로 변환한다', () {
      final result = ErrorHandler.handle(const FormatException('bad'));
      expect(result.code, 'validation');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/core/error/`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/core/error/app_exception.dart

class AppException implements Exception {
  final String code;
  final String userMessage;
  final Object? originalError;

  const AppException({
    required this.code,
    required this.userMessage,
    this.originalError,
  });

  factory AppException.network({Object? originalError}) => AppException(
        code: 'network',
        userMessage: '네트워크 연결을 확인해주세요',
        originalError: originalError,
      );

  factory AppException.server({Object? originalError}) => AppException(
        code: 'server',
        userMessage: '서버 오류가 발생했습니다. 다시 시도해주세요',
        originalError: originalError,
      );

  factory AppException.unauthorized({Object? originalError}) => AppException(
        code: 'unauthorized',
        userMessage: '로그인이 필요합니다',
        originalError: originalError,
      );

  factory AppException.notFound({Object? originalError}) => AppException(
        code: 'not_found',
        userMessage: '데이터를 찾을 수 없습니다',
        originalError: originalError,
      );

  factory AppException.validation(String message, {Object? originalError}) =>
      AppException(
        code: 'validation',
        userMessage: message,
        originalError: originalError,
      );

  factory AppException.duplicate({Object? originalError}) => AppException(
        code: 'duplicate',
        userMessage: '이미 등록된 데이터입니다',
        originalError: originalError,
      );

  @override
  String toString() => 'AppException(code: $code, message: $userMessage)';
}
```

```dart
// lib/core/error/error_handler.dart
import 'dart:io';
import 'package:badminton_app/core/error/app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error) {
    if (error is AppException) return error;
    if (error is SocketException) return AppException.network(originalError: error);
    if (error is FormatException) {
      return AppException.validation('잘못된 데이터 형식입니다', originalError: error);
    }
    if (error is HttpException) return AppException.server(originalError: error);

    // Supabase PostgrestException 런타임 처리
    final msg = error.toString().toLowerCase();
    if (msg.contains('unique') || msg.contains('duplicate')) {
      return AppException.duplicate(originalError: error);
    }
    if (msg.contains('not found') || msg.contains('no rows')) {
      return AppException.notFound(originalError: error);
    }
    if (msg.contains('jwt') || msg.contains('unauthorized')) {
      return AppException.unauthorized(originalError: error);
    }

    return AppException.server(originalError: error);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/core/error/`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/core/error/ test/core/error/
git commit -m "feat: M6 에러 처리 모듈 (AppException, ErrorHandler)"
```

---

### Task 1.4: M10 유효성 검증

**Files:**
- Create: `lib/core/utils/validators.dart`
- Test: `test/core/utils/validators_test.dart`

**Step 1: Write the failing test**

```dart
// test/core/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('정상 이름은 null을 반환한다', () {
      expect(Validators.name('홍길동'), isNull);
      expect(Validators.name('AB'), isNull);
    });
    test('null이면 에러 메시지를 반환한다', () {
      expect(Validators.name(null), isNotNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.name(''), isNotNull);
    });
    test('1자이면 에러 메시지를 반환한다', () {
      expect(Validators.name('홍'), isNotNull);
    });
    test('20자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.name('가' * 21), isNotNull);
    });
    test('20자이면 null을 반환한다', () {
      expect(Validators.name('가' * 20), isNull);
    });
  });

  group('Validators.phone', () {
    test('010-XXXX-XXXX 형식은 null을 반환한다', () {
      expect(Validators.phone('010-1234-5678'), isNull);
    });
    test('하이픈 없는 11자리도 null을 반환한다', () {
      expect(Validators.phone('01012345678'), isNull);
    });
    test('null이면 에러 메시지를 반환한다', () {
      expect(Validators.phone(null), isNotNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.phone(''), isNotNull);
    });
    test('형식이 맞지 않으면 에러 메시지를 반환한다', () {
      expect(Validators.phone('0101234567'), isNotNull);
      expect(Validators.phone('02-1234-5678'), isNotNull);
    });
  });

  group('Validators.shopName', () {
    test('정상 샵 이름은 null을 반환한다', () {
      expect(Validators.shopName('거트 프로샵'), isNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.shopName(''), isNotNull);
    });
    test('50자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.shopName('가' * 51), isNotNull);
    });
  });

  group('Validators.description', () {
    test('빈 문자열은 null을 반환한다 (선택 입력)', () {
      expect(Validators.description(''), isNull);
    });
    test('null은 null을 반환한다', () {
      expect(Validators.description(null), isNull);
    });
    test('200자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.description('가' * 201), isNotNull);
    });
  });

  group('Validators.postTitle', () {
    test('정상 제목은 null을 반환한다', () {
      expect(Validators.postTitle('공지사항'), isNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.postTitle(''), isNotNull);
    });
    test('100자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.postTitle('가' * 101), isNotNull);
    });
  });

  group('Validators.postContent', () {
    test('정상 내용은 null을 반환한다', () {
      expect(Validators.postContent('내용입니다'), isNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.postContent(''), isNotNull);
    });
    test('2000자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.postContent('가' * 2001), isNotNull);
    });
  });

  group('Validators.memo', () {
    test('빈 문자열은 null을 반환한다', () {
      expect(Validators.memo(''), isNull);
    });
    test('null은 null을 반환한다', () {
      expect(Validators.memo(null), isNull);
    });
    test('500자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.memo('가' * 501), isNotNull);
    });
  });

  group('Validators.productName', () {
    test('정상 상품명은 null을 반환한다', () {
      expect(Validators.productName('BG65'), isNull);
    });
    test('빈 문자열이면 에러 메시지를 반환한다', () {
      expect(Validators.productName(''), isNotNull);
    });
    test('50자 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.productName('가' * 51), isNotNull);
    });
  });

  group('Validators.quantity', () {
    test('정상 수량은 null을 반환한다', () {
      expect(Validators.quantity('10'), isNull);
      expect(Validators.quantity('0'), isNull);
      expect(Validators.quantity('9999'), isNull);
    });
    test('null이면 에러 메시지를 반환한다', () {
      expect(Validators.quantity(null), isNotNull);
    });
    test('숫자가 아니면 에러 메시지를 반환한다', () {
      expect(Validators.quantity('abc'), isNotNull);
    });
    test('음수이면 에러 메시지를 반환한다', () {
      expect(Validators.quantity('-1'), isNotNull);
    });
    test('9999 초과이면 에러 메시지를 반환한다', () {
      expect(Validators.quantity('10000'), isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/validators_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/core/utils/validators.dart

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.isEmpty) return '이름을 입력해주세요';
    if (value.length < 2) return '이름은 2자 이상 입력해주세요';
    if (value.length > 20) return '이름은 20자 이하로 입력해주세요';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return '연락처를 입력해주세요';
    final raw = value.replaceAll('-', '');
    if (!RegExp(r'^010\d{8}$').hasMatch(raw)) {
      return '올바른 연락처 형식이 아닙니다 (010-XXXX-XXXX)';
    }
    return null;
  }

  static String? shopName(String? value) {
    if (value == null || value.isEmpty) return '샵 이름을 입력해주세요';
    if (value.length > 50) return '샵 이름은 50자 이하로 입력해주세요';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 200) return '소개글은 200자 이하로 입력해주세요';
    return null;
  }

  static String? postTitle(String? value) {
    if (value == null || value.isEmpty) return '제목을 입력해주세요';
    if (value.length > 100) return '제목은 100자 이하로 입력해주세요';
    return null;
  }

  static String? postContent(String? value) {
    if (value == null || value.isEmpty) return '내용을 입력해주세요';
    if (value.length > 2000) return '내용은 2000자 이하로 입력해주세요';
    return null;
  }

  static String? memo(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 500) return '메모는 500자 이하로 입력해주세요';
    return null;
  }

  static String? productName(String? value) {
    if (value == null || value.isEmpty) return '상품명을 입력해주세요';
    if (value.length > 50) return '상품명은 50자 이하로 입력해주세요';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.isEmpty) return '수량을 입력해주세요';
    final number = int.tryParse(value);
    if (number == null) return '숫자를 입력해주세요';
    if (number < 0) return '수량은 0 이상이어야 합니다';
    if (number > 9999) return '수량은 9999 이하로 입력해주세요';
    return null;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/core/utils/validators_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/core/utils/validators.dart test/core/utils/validators_test.dart
git commit -m "feat: M10 유효성 검증 모듈 (Validators)"
```

---

### Task 1.5: M11 포맷 유틸리티

**Files:**
- Create: `lib/core/utils/formatters.dart`
- Test: `test/core/utils/formatters_test.dart`

**Step 1: Write the failing test**

```dart
// test/core/utils/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/utils/formatters.dart';

void main() {
  group('Formatters.relativeTime', () {
    test('1분 미만이면 "방금 전"을 반환한다', () {
      final thirtySecondsAgo = DateTime.now().subtract(const Duration(seconds: 30));
      expect(Formatters.relativeTime(thirtySecondsAgo), '방금 전');
    });

    test('1시간 미만이면 "N분 전"을 반환한다', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(Formatters.relativeTime(fiveMinutesAgo), '5분 전');
    });

    test('24시간 미만이면 "N시간 전"을 반환한다', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      expect(Formatters.relativeTime(twoHoursAgo), '2시간 전');
    });

    test('24시간 이상이면 "N일 전"을 반환한다', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(Formatters.relativeTime(threeDaysAgo), '3일 전');
    });
  });

  group('Formatters.dateTime', () {
    test('MM/DD HH:mm 형식으로 반환한다', () {
      expect(Formatters.dateTime(DateTime(2026, 1, 15, 14, 30)), '01/15 14:30');
    });

    test('한 자리 월/일에 0을 패딩한다', () {
      expect(Formatters.dateTime(DateTime(2026, 3, 5, 9, 5)), '03/05 09:05');
    });
  });

  group('Formatters.date', () {
    test('YYYY.MM.DD 형식으로 반환한다', () {
      expect(Formatters.date(DateTime(2026, 1, 15)), '2026.01.15');
    });
  });

  group('Formatters.phone', () {
    test('11자리 숫자에 하이픈을 삽입한다', () {
      expect(Formatters.phone('01012345678'), '010-1234-5678');
    });

    test('이미 하이픈이 있으면 그대로 반환한다', () {
      expect(Formatters.phone('010-1234-5678'), '010-1234-5678');
    });

    test('형식이 맞지 않으면 원본을 반환한다', () {
      expect(Formatters.phone('1234'), '1234');
    });
  });

  group('Formatters.phoneRaw', () {
    test('하이픈을 제거한다', () {
      expect(Formatters.phoneRaw('010-1234-5678'), '01012345678');
    });

    test('하이픈이 없으면 그대로 반환한다', () {
      expect(Formatters.phoneRaw('01012345678'), '01012345678');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/formatters_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/core/utils/formatters.dart

class Formatters {
  Formatters._();

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  static String dateTime(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m/$d $h:$min';
  }

  static String date(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  static String phone(String phone) {
    final raw = phone.replaceAll('-', '');
    if (raw.length == 11 && raw.startsWith('010')) {
      return '${raw.substring(0, 3)}-${raw.substring(3, 7)}-${raw.substring(7)}';
    }
    return phone;
  }

  static String phoneRaw(String phone) {
    return phone.replaceAll('-', '');
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/core/utils/formatters_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/core/utils/formatters.dart test/core/utils/formatters_test.dart
git commit -m "feat: M11 포맷 유틸리티 모듈 (Formatters)"
```

---

## Phase 6: 콘텐츠 관리 (게시글)

### Task 6.1: Post Create (게시글 작성 — 사장님)

#### 6.1.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/owner/post_create/post_create_state.dart`**

```dart
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/models/enums.dart';

part 'post_create_state.freezed.dart';

@freezed
class PostCreateState with _$PostCreateState {
  const PostCreateState._();

  const factory PostCreateState({
    PostCategory? category,
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<File> images,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    @Default(false) bool isSubmitting,
    String? categoryError,
    String? titleError,
    String? contentError,
    String? dateError,
    AppException? error,
  }) = _PostCreateState;

  bool get isFormValid {
    if (category == null) return false;
    if (title.trim().isEmpty) return false;
    if (content.trim().isEmpty) return false;
    if (category == PostCategory.event) {
      if (eventStartDate == null || eventEndDate == null) return false;
    }
    return true;
  }

  bool get hasContent =>
      category != null ||
      title.isNotEmpty ||
      content.isNotEmpty ||
      images.isNotEmpty;

  bool get isEventCategory => category == PostCategory.event;
}
```

**파일: `lib/screens/owner/post_create/post_create_notifier.dart`**

```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/core/utils/validators.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_state.dart';

class PostCreateNotifier extends Notifier<PostCreateState> {
  late final PostRepository _postRepo;
  late final StorageRepository _storageRepo;
  late final String _shopId;

  @override
  PostCreateState build() {
    _postRepo = ref.watch(postRepositoryProvider);
    _storageRepo = ref.watch(storageRepositoryProvider);
    final shop = ref.watch(shopByOwnerProvider).valueOrNull;
    _shopId = shop?.id ?? '';
    return const PostCreateState();
  }

  void setCategory(PostCategory category) {
    if (category == PostCategory.notice) {
      state = state.copyWith(
        category: category, categoryError: null,
        eventStartDate: null, eventEndDate: null, dateError: null,
      );
    } else {
      state = state.copyWith(category: category, categoryError: null);
    }
  }

  void setTitle(String title) =>
      state = state.copyWith(title: title, titleError: null);

  void setContent(String content) =>
      state = state.copyWith(content: content, contentError: null);

  void addImage(File file) {
    if (state.images.length >= 5) return;
    state = state.copyWith(images: [...state.images, file]);
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.images.length) return;
    final updated = List<File>.from(state.images)..removeAt(index);
    state = state.copyWith(images: updated);
  }

  void setEventStartDate(DateTime date) =>
      state = state.copyWith(eventStartDate: date, dateError: null);

  void setEventEndDate(DateTime date) =>
      state = state.copyWith(eventEndDate: date, dateError: null);

  bool _validate() {
    bool valid = true;
    if (state.category == null) {
      state = state.copyWith(categoryError: '카테고리를 선택해 주세요');
      valid = false;
    }
    final titleErr = Validators.postTitle(state.title);
    if (titleErr != null) {
      state = state.copyWith(titleError: titleErr);
      valid = false;
    }
    final contentErr = Validators.postContent(state.content);
    if (contentErr != null) {
      state = state.copyWith(contentError: contentErr);
      valid = false;
    }
    if (state.isEventCategory) {
      if (state.eventStartDate == null || state.eventEndDate == null) {
        state = state.copyWith(dateError: '이벤트 기간을 설정해 주세요');
        valid = false;
      } else if (state.eventEndDate!.isBefore(state.eventStartDate!)) {
        state = state.copyWith(dateError: '종료일은 시작일 이후여야 합니다');
        valid = false;
      }
    }
    return valid;
  }

  Future<bool> submit() async {
    if (!_validate()) return false;
    if (_shopId.isEmpty) return false;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      List<String> imageUrls = [];
      if (state.images.isNotEmpty) {
        imageUrls = await Future.wait(
          state.images.map((f) => _storageRepo.uploadImage('post-images', f)),
        );
      }
      await _postRepo.create(
        shopId: _shopId,
        category: state.category!,
        title: state.title.trim(),
        content: state.content.trim(),
        images: imageUrls,
        eventStartDate: state.eventStartDate,
        eventEndDate: state.eventEndDate,
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: ErrorHandler.handle(e));
      return false;
    }
  }
}

final postCreateNotifierProvider =
    NotifierProvider<PostCreateNotifier, PostCreateState>(
  PostCreateNotifier.new,
);
```

**파일: `test/screens/owner/post_create/post_create_notifier_test.dart`**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_notifier.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures.dart';

class MockPostRepository extends Mock implements PostRepository {}
class MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late MockPostRepository mockPostRepo;
  late MockStorageRepository mockStorageRepo;
  late ProviderContainer container;

  setUp(() {
    mockPostRepo = MockPostRepository();
    mockStorageRepo = MockStorageRepository();
    registerFallbackValue(PostCategory.notice);
    registerFallbackValue(File(''));

    when(() => mockStorageRepo.uploadImage(any(), any()))
        .thenAnswer((_) async => 'https://example.com/image.jpg');
    when(() => mockPostRepo.create(
      shopId: any(named: 'shopId'), category: any(named: 'category'),
      title: any(named: 'title'), content: any(named: 'content'),
      images: any(named: 'images'),
      eventStartDate: any(named: 'eventStartDate'),
      eventEndDate: any(named: 'eventEndDate'),
    )).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(mockPostRepo),
      storageRepositoryProvider.overrideWithValue(mockStorageRepo),
      shopByOwnerProvider.overrideWith((_) => AsyncData(testShop)),
    ]);
  });

  tearDown(() => container.dispose());

  group('PostCreateNotifier', () {
    test('초기 상태는 빈 폼이다', () {
      final state = container.read(postCreateNotifierProvider);
      expect(state.category, null);
      expect(state.title, '');
      expect(state.isFormValid, false);
      expect(state.hasContent, false);
    });

    test('카테고리 선택 시 상태를 갱신한다', () {
      container.read(postCreateNotifierProvider.notifier)
          .setCategory(PostCategory.notice);
      expect(container.read(postCreateNotifierProvider).category,
          PostCategory.notice);
    });

    test('이벤트→공지 전환 시 날짜 필드를 초기화한다', () {
      final n = container.read(postCreateNotifierProvider.notifier);
      n.setCategory(PostCategory.event);
      n.setEventStartDate(DateTime(2026, 3, 1));
      n.setEventEndDate(DateTime(2026, 3, 31));
      n.setCategory(PostCategory.notice);
      final s = container.read(postCreateNotifierProvider);
      expect(s.eventStartDate, null);
      expect(s.eventEndDate, null);
    });

    test('이미지 추가는 최대 5장까지 허용한다', () {
      final n = container.read(postCreateNotifierProvider.notifier);
      for (int i = 0; i < 7; i++) n.addImage(File('img$i.jpg'));
      expect(container.read(postCreateNotifierProvider).images.length, 5);
    });

    test('isFormValid는 필수 필드 완료 시 true를 반환한다', () {
      final n = container.read(postCreateNotifierProvider.notifier);
      n.setCategory(PostCategory.notice);
      n.setTitle('테스트 제목');
      n.setContent('테스트 내용');
      expect(container.read(postCreateNotifierProvider).isFormValid, true);
    });

    test('submit 성공 시 이미지 업로드 후 게시글을 등록한다', () async {
      final n = container.read(postCreateNotifierProvider.notifier);
      n.setCategory(PostCategory.notice);
      n.setTitle('공지 제목');
      n.setContent('공지 내용입니다');
      n.addImage(File('test.jpg'));
      final result = await n.submit();
      expect(result, true);
      verify(() => mockStorageRepo.uploadImage('post-images', any())).called(1);
    });

    test('submit 실패 시 에러 상태를 설정한다', () async {
      when(() => mockPostRepo.create(
        shopId: any(named: 'shopId'), category: any(named: 'category'),
        title: any(named: 'title'), content: any(named: 'content'),
        images: any(named: 'images'),
        eventStartDate: any(named: 'eventStartDate'),
        eventEndDate: any(named: 'eventEndDate'),
      )).thenThrow(Exception('서버 오류'));
      final n = container.read(postCreateNotifierProvider.notifier);
      n.setCategory(PostCategory.notice);
      n.setTitle('제목');
      n.setContent('내용');
      expect(await n.submit(), false);
      expect(container.read(postCreateNotifierProvider).error, isNotNull);
    });

    test('이벤트 종료일이 시작일보다 이전이면 검증 실패한다', () async {
      final n = container.read(postCreateNotifierProvider.notifier);
      n.setCategory(PostCategory.event);
      n.setTitle('이벤트');
      n.setContent('내용');
      n.setEventStartDate(DateTime(2026, 3, 31));
      n.setEventEndDate(DateTime(2026, 3, 1));
      expect(await n.submit(), false);
      expect(container.read(postCreateNotifierProvider).dateError,
          '종료일은 시작일 이후여야 합니다');
    });
  });
}
```

**커밋 메시지**: `feat: 게시글 작성 상태 관리 및 Notifier 구현`

---

#### 6.1.2 게시글 작성 화면 위젯 구현

**파일: `lib/screens/owner/post_create/post_create_screen.dart`**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/core/utils/formatters.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_notifier.dart';
import 'package:gut_alarm/widgets/confirm_dialog.dart';
import 'package:gut_alarm/widgets/toast.dart';
import 'package:image_picker/image_picker.dart';

class PostCreateScreen extends ConsumerStatefulWidget {
  const PostCreateScreen({super.key});
  @override
  ConsumerState<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends ConsumerState<PostCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(postCreateNotifierProvider);
    if (!state.hasContent) return true;
    final result = await ConfirmDialog.show(context,
      title: '나가시겠습니까?',
      message: '작성 중인 내용이 있습니다. 나가시겠습니까?',
      confirmText: '나가기', cancelText: '취소');
    return result ?? false;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt), title: const Text('카메라'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
      ])),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
    if (picked != null) {
      ref.read(postCreateNotifierProvider.notifier).addImage(File(picked.path));
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(postCreateNotifierProvider.notifier).submit();
    if (success && mounted) {
      AppToast.show(context, '게시글이 등록되었습니다');
      context.pop();
    } else if (!success && mounted) {
      final s = ref.read(postCreateNotifierProvider);
      if (s.error != null) AppToast.showError(context, s.error!.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCreateNotifierProvider);
    final notifier = ref.read(postCreateNotifierProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop() && mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('게시글 작성'), backgroundColor: Colors.white),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 카테고리 선택
            const Text('카테고리', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              ChoiceChip(label: const Text('공지사항'),
                selected: state.category == PostCategory.notice,
                selectedColor: const Color(0xFFDCFCE7),
                onSelected: (_) => notifier.setCategory(PostCategory.notice)),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('이벤트'),
                selected: state.category == PostCategory.event,
                selectedColor: const Color(0xFFDCFCE7),
                onSelected: (_) => notifier.setCategory(PostCategory.event)),
            ]),
            if (state.categoryError != null)
              Padding(padding: const EdgeInsets.only(top: 4),
                child: Text(state.categoryError!, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)))),
            const SizedBox(height: 20),
            // 제목
            TextField(controller: _titleController, maxLength: 100,
              decoration: InputDecoration(labelText: '제목', errorText: state.titleError,
                border: const OutlineInputBorder()),
              onChanged: notifier.setTitle),
            const SizedBox(height: 16),
            // 내용
            TextField(controller: _contentController, maxLength: 2000, maxLines: 8,
              decoration: InputDecoration(labelText: '내용', errorText: state.contentError,
                border: const OutlineInputBorder(), alignLabelWithHint: true),
              onChanged: notifier.setContent),
            const SizedBox(height: 16),
            // 이미지
            const Text('이미지 첨부', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
              if (state.images.length < 5)
                GestureDetector(onTap: state.isSubmitting ? null : _pickImage,
                  child: Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.camera_alt, color: Color(0xFF94A3B8)),
                      Text('${state.images.length}/5',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ]))),
              ...state.images.asMap().entries.map((e) => Stack(children: [
                Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover))),
                Positioned(top: 4, right: 12,
                  child: GestureDetector(onTap: () => notifier.removeImage(e.key),
                    child: Container(padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white)))),
              ])),
            ])),
            // 이벤트 기간
            if (state.isEventCategory) ...[
              const SizedBox(height: 16),
              const Text('이벤트 기간', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: context,
                      initialDate: state.eventStartDate ?? DateTime.now(),
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) notifier.setEventStartDate(d);
                  },
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(state.eventStartDate != null
                        ? Formatters.date(state.eventStartDate!) : '시작일')))),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~')),
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: context,
                      initialDate: state.eventEndDate ?? DateTime.now(),
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) notifier.setEventEndDate(d);
                  },
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(state.eventEndDate != null
                        ? Formatters.date(state.eventEndDate!) : '종료일')))),
              ]),
              if (state.dateError != null)
                Padding(padding: const EdgeInsets.only(top: 4),
                  child: Text(state.dateError!, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)))),
            ],
          ]),
        ),
        bottomNavigationBar: SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: double.infinity, height: 56,
            child: FilledButton(
              onPressed: state.isFormValid && !state.isSubmitting ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: state.isFormValid ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: state.isSubmitting
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('등록',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))))),
      ),
    );
  }
}
```

**파일: `test/screens/owner/post_create/post_create_screen_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_notifier.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_screen.dart';
import 'package:gut_alarm/screens/owner/post_create/post_create_state.dart';
import '../../../helpers/test_app.dart';

void main() {
  group('PostCreateScreen', () {
    testWidgets('초기 상태에서 빈 폼과 비활성 등록 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(createTestApp(
        overrides: [postCreateNotifierProvider.overrideWith(
          () => _Fake(const PostCreateState()))],
        child: const PostCreateScreen()));
      expect(find.text('게시글 작성'), findsOneWidget);
      expect(find.text('등록'), findsOneWidget);
    });

    testWidgets('이벤트 카테고리 선택 시 기간 입력 영역을 표시한다', (tester) async {
      await tester.pumpWidget(createTestApp(
        overrides: [postCreateNotifierProvider.overrideWith(
          () => _Fake(const PostCreateState(category: PostCategory.event)))],
        child: const PostCreateScreen()));
      expect(find.text('이벤트 기간'), findsOneWidget);
    });

    testWidgets('등록 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      await tester.pumpWidget(createTestApp(
        overrides: [postCreateNotifierProvider.overrideWith(
          () => _Fake(const PostCreateState(
            category: PostCategory.notice, title: '제목', content: '내용', isSubmitting: true)))],
        child: const PostCreateScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _Fake extends PostCreateNotifier {
  final PostCreateState _s;
  _Fake(this._s);
  @override
  PostCreateState build() => _s;
}
```

**커밋 메시지**: `feat: 게시글 작성 화면 위젯 구현`

---

### Task 6.2: Post List (게시글 목록 — 고객)

#### 6.2.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/customer/post_list/post_list_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/models/post.dart';

part 'post_list_state.freezed.dart';

@freezed
class PostListState with _$PostListState {
  const factory PostListState({
    @Default([]) List<Post> noticePosts,
    @Default([]) List<Post> eventPosts,
    @Default(true) bool isLoading,
    AppException? error,
  }) = _PostListState;
}
```

**파일: `lib/screens/customer/post_list/post_list_notifier.dart`**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/screens/customer/post_list/post_list_state.dart';

class PostListNotifier extends FamilyAsyncNotifier<PostListState, String> {
  late final PostRepository _postRepo;

  @override
  Future<PostListState> build(String shopId) async {
    _postRepo = ref.watch(postRepositoryProvider);
    return _loadPosts(shopId);
  }

  Future<PostListState> _loadPosts(String shopId) async {
    final results = await Future.wait([
      _postRepo.getByShopAndCategory(shopId, PostCategory.notice),
      _postRepo.getByShopAndCategory(shopId, PostCategory.event),
    ]);
    return PostListState(noticePosts: results[0], eventPosts: results[1], isLoading: false);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadPosts(arg));
  }
}

final postListProvider =
    AsyncNotifierProvider.family<PostListNotifier, PostListState, String>(PostListNotifier.new);
```

**파일: `test/screens/customer/post_list/post_list_notifier_test.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/models/post.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/screens/customer/post_list/post_list_notifier.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepo;
  late ProviderContainer container;

  setUp(() {
    mockPostRepo = MockPostRepository();
    registerFallbackValue(PostCategory.notice);
    when(() => mockPostRepo.getByShopAndCategory('shop-1', PostCategory.notice))
        .thenAnswer((_) async => [Post(id: 'p1', shopId: 'shop-1',
          category: PostCategory.notice, title: '공지', content: '내용',
          images: [], createdAt: DateTime(2026, 2, 24))]);
    when(() => mockPostRepo.getByShopAndCategory('shop-1', PostCategory.event))
        .thenAnswer((_) async => []);
    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(mockPostRepo),
    ]);
  });

  tearDown(() => container.dispose());

  group('PostListNotifier', () {
    test('초기 로드 시 공지사항과 이벤트 목록을 동시에 가져온다', () async {
      final state = await container.read(postListProvider('shop-1').future);
      expect(state.noticePosts.length, 1);
      expect(state.eventPosts, isEmpty);
    });

    test('로드 실패 시 AsyncError 상태가 된다', () async {
      when(() => mockPostRepo.getByShopAndCategory('err', PostCategory.notice))
          .thenThrow(Exception('오류'));
      when(() => mockPostRepo.getByShopAndCategory('err', PostCategory.event))
          .thenThrow(Exception('오류'));
      expect(() => container.read(postListProvider('err').future),
          throwsA(isA<Exception>()));
    });
  });
}
```

**커밋 메시지**: `feat: 게시글 목록 상태 관리 및 Notifier 구현`

---

#### 6.2.2 게시글 목록 화면 위젯 구현

**파일: `lib/screens/customer/post_list/post_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/core/utils/formatters.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/models/post.dart';
import 'package:gut_alarm/screens/customer/post_list/post_list_notifier.dart';
import 'package:gut_alarm/widgets/empty_state.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';

class PostListScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String? initialCategory;
  const PostListScreen({super.key, required this.shopId, this.initialCategory});
  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this,
      initialIndex: widget.initialCategory == 'event' ? 1 : 0);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(postListProvider(widget.shopId));
    return Scaffold(
      appBar: AppBar(title: const Text('게시판'), backgroundColor: Colors.white,
        bottom: TabBar(controller: _tabController,
          labelColor: const Color(0xFF16A34A),
          indicatorColor: const Color(0xFF16A34A),
          tabs: const [Tab(text: '공지사항'), Tab(text: '이벤트')])),
      body: asyncState.when(
        loading: () => ListView.builder(padding: const EdgeInsets.all(16), itemCount: 3,
          itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12),
            child: SkeletonShimmer(height: 120, borderRadius: 16))),
        error: (e, _) => ErrorView(message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.read(postListProvider(widget.shopId).notifier).refresh()),
        data: (state) => TabBarView(controller: _tabController, children: [
          _PostListView(posts: state.noticePosts),
          _PostListView(posts: state.eventPosts),
        ]),
      ),
    );
  }
}

class _PostListView extends StatelessWidget {
  final List<Post> posts;
  const _PostListView({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const EmptyState(icon: Icons.article_outlined, message: '등록된 게시글이 없습니다');
    }
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: posts.length,
      itemBuilder: (ctx, i) {
        final post = posts[i];
        return Card(margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          child: InkWell(onTap: () => ctx.push('/customer/post/${post.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.category == PostCategory.notice
                        ? const Color(0xFFDBEAFE) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(post.category == PostCategory.notice ? '공지' : '이벤트',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: post.category == PostCategory.notice
                          ? const Color(0xFF1E40AF) : const Color(0xFF92400E)))),
                const SizedBox(height: 8),
                Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(post.content, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(Formatters.date(post.createdAt),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ]))));
      });
  }
}
```

**커밋 메시지**: `feat: 게시글 목록 화면 위젯 구현`

---

### Task 6.3: Post Detail (게시글 상세 — 고객)

#### 6.3.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/customer/post_detail/post_detail_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/models/post.dart';

part 'post_detail_state.freezed.dart';

@freezed
class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    Post? post,
    @Default(true) bool isLoading,
    AppException? error,
  }) = _PostDetailState;
}
```

**파일: `lib/screens/customer/post_detail/post_detail_notifier.dart`**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/screens/customer/post_detail/post_detail_state.dart';

class PostDetailNotifier extends FamilyAsyncNotifier<PostDetailState, String> {
  late final PostRepository _postRepo;

  @override
  Future<PostDetailState> build(String postId) async {
    _postRepo = ref.watch(postRepositoryProvider);
    final post = await _postRepo.getById(postId);
    return PostDetailState(post: post, isLoading: false);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final post = await _postRepo.getById(arg);
      return PostDetailState(post: post, isLoading: false);
    });
  }
}

final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailNotifier, PostDetailState, String>(PostDetailNotifier.new);
```

**파일: `test/screens/customer/post_detail/post_detail_notifier_test.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/models/post.dart';
import 'package:gut_alarm/repositories/post_repository.dart';
import 'package:gut_alarm/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepo;
  late ProviderContainer container;
  final testPost = Post(id: 'p1', shopId: 's1', category: PostCategory.notice,
    title: '공지', content: '내용', images: ['https://img.com/1.jpg'],
    createdAt: DateTime(2026, 2, 24));

  setUp(() {
    mockPostRepo = MockPostRepository();
    when(() => mockPostRepo.getById('p1')).thenAnswer((_) async => testPost);
    container = ProviderContainer(overrides: [
      postRepositoryProvider.overrideWithValue(mockPostRepo)]);
  });

  tearDown(() => container.dispose());

  test('초기 로드 시 게시글 상세를 가져온다', () async {
    final state = await container.read(postDetailProvider('p1').future);
    expect(state.post!.title, '공지');
    expect(state.post!.images.length, 1);
  });

  test('로드 실패 시 AsyncError', () async {
    when(() => mockPostRepo.getById('err')).thenThrow(Exception('오류'));
    expect(() => container.read(postDetailProvider('err').future),
        throwsA(isA<Exception>()));
  });
}
```

**커밋 메시지**: `feat: 게시글 상세 상태 관리 및 Notifier 구현`

---

#### 6.3.2 게시글 상세 화면 위젯 구현

**파일: `lib/screens/customer/post_detail/post_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/utils/formatters.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/models/post.dart';
import 'package:gut_alarm/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(postDetailProvider(postId));
    return Scaffold(
      appBar: AppBar(title: const Text('게시글'), backgroundColor: Colors.white),
      body: asyncState.when(
        loading: () => const Padding(padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonShimmer(width: 60, height: 24, borderRadius: 4),
            SizedBox(height: 12),
            SkeletonShimmer(width: double.infinity, height: 28, borderRadius: 4),
            SizedBox(height: 24),
            SkeletonShimmer(width: double.infinity, height: 200, borderRadius: 8),
          ])),
        error: (e, _) => ErrorView(message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.read(postDetailProvider(postId).notifier).retry()),
        data: (state) {
          if (state.post == null) return const ErrorView(message: '게시글을 찾을 수 없습니다');
          return _Content(post: state.post!);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Post post;
  const _Content({required this.post});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 카테고리 뱃지
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: post.category == PostCategory.notice ? const Color(0xFFDBEAFE) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(4)),
          child: Text(post.category == PostCategory.notice ? '공지' : '이벤트',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: post.category == PostCategory.notice ? const Color(0xFF1E40AF) : const Color(0xFF92400E)))),
        const SizedBox(height: 12),
        Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          const Text('관리자', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Text(Formatters.date(post.createdAt), style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
        ]),
        if (post.category == PostCategory.event && post.eventStartDate != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
            child: Text('${Formatters.date(post.eventStartDate!)} ~ ${Formatters.date(post.eventEndDate!)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
        ],
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 16),
        Text(post.content, style: const TextStyle(fontSize: 16, height: 1.6)),
        if (post.images.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...post.images.map((url) => Padding(padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) =>
                Scaffold(backgroundColor: Colors.black,
                  appBar: AppBar(backgroundColor: Colors.black),
                  body: InteractiveViewer(child: Center(child: Image.network(url)))))),
              child: ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.network(url, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFFF1F5F9),
                    child: const Center(child: Icon(Icons.broken_image)))))))),
        ],
      ]));
  }
}
```

**커밋 메시지**: `feat: 게시글 상세 화면 위젯 구현`

---

## Phase 7: 재고/알림

### Task 7.1: Inventory Manage (재고 관리 — 사장님)

#### 7.1.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/owner/inventory_manage/inventory_manage_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/models/inventory_item.dart';

part 'inventory_manage_state.freezed.dart';

@freezed
class InventoryManageState with _$InventoryManageState {
  const factory InventoryManageState({
    @Default([]) List<InventoryItem> items,
    @Default(true) bool isLoading,
    AppException? error,
    @Default(false) bool isSaving,
    String? deletingItemId,
  }) = _InventoryManageState;
}
```

**파일: `lib/screens/owner/inventory_manage/inventory_manage_notifier.dart`**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/repositories/inventory_repository.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/screens/owner/inventory_manage/inventory_manage_state.dart';

class InventoryManageNotifier extends AsyncNotifier<InventoryManageState> {
  late final InventoryRepository _inventoryRepo;
  late final StorageRepository _storageRepo;
  late final String _shopId;

  @override
  Future<InventoryManageState> build() async {
    _inventoryRepo = ref.watch(inventoryRepositoryProvider);
    _storageRepo = ref.watch(storageRepositoryProvider);
    final shop = await ref.watch(shopByOwnerProvider.future);
    _shopId = shop.id;
    return loadItems();
  }

  Future<InventoryManageState> loadItems() async {
    final items = await _inventoryRepo.getByShop(_shopId);
    return InventoryManageState(items: items, isLoading: false);
  }

  Future<void> addItem({
    required String name, required String category,
    required int quantity, File? imageFile,
  }) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(isSaving: true));
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageRepo.uploadImage('inventory-images', imageFile);
      }
      await _inventoryRepo.create(
        shopId: _shopId, name: name, category: category,
        quantity: quantity, imageUrl: imageUrl);
      final items = await _inventoryRepo.getByShop(_shopId);
      state = AsyncData(prev.copyWith(items: items, isSaving: false));
    } catch (e) {
      state = AsyncData(prev.copyWith(isSaving: false, error: ErrorHandler.handle(e)));
    }
  }

  Future<void> updateItem({
    required String itemId, required String name, required String category,
    required int quantity, File? imageFile, bool imageChanged = false,
  }) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(isSaving: true));
    try {
      String? imageUrl;
      if (imageChanged && imageFile != null) {
        imageUrl = await _storageRepo.uploadImage('inventory-images', imageFile);
      }
      await _inventoryRepo.update(
        id: itemId, name: name, category: category,
        quantity: quantity, imageUrl: imageChanged ? imageUrl : null);
      final items = await _inventoryRepo.getByShop(_shopId);
      state = AsyncData(prev.copyWith(items: items, isSaving: false));
    } catch (e) {
      state = AsyncData(prev.copyWith(isSaving: false, error: ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteItem(String itemId) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(deletingItemId: itemId));
    try {
      await _inventoryRepo.delete(itemId);
      final updated = prev.items.where((i) => i.id != itemId).toList();
      state = AsyncData(prev.copyWith(items: updated, deletingItemId: null));
    } catch (e) {
      state = AsyncData(prev.copyWith(deletingItemId: null, error: ErrorHandler.handle(e)));
    }
  }
}

final inventoryManageProvider =
    AsyncNotifierProvider<InventoryManageNotifier, InventoryManageState>(InventoryManageNotifier.new);
```

**파일: `test/screens/owner/inventory_manage/inventory_manage_notifier_test.dart`**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/inventory_item.dart';
import 'package:gut_alarm/repositories/inventory_repository.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/screens/owner/inventory_manage/inventory_manage_notifier.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}
class MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late MockInventoryRepository mockInvRepo;
  late MockStorageRepository mockStorageRepo;
  late ProviderContainer container;

  final testItem = InventoryItem(id: 'inv-1', shopId: 'shop-1', name: '라켓A',
    category: '라켓', quantity: 5, createdAt: DateTime(2026, 2, 24));

  setUp(() {
    mockInvRepo = MockInventoryRepository();
    mockStorageRepo = MockStorageRepository();
    registerFallbackValue(File(''));

    when(() => mockInvRepo.getByShop(any())).thenAnswer((_) async => [testItem]);
    when(() => mockInvRepo.create(shopId: any(named: 'shopId'), name: any(named: 'name'),
      category: any(named: 'category'), quantity: any(named: 'quantity'),
      imageUrl: any(named: 'imageUrl'))).thenAnswer((_) async {});
    when(() => mockInvRepo.update(id: any(named: 'id'), name: any(named: 'name'),
      category: any(named: 'category'), quantity: any(named: 'quantity'),
      imageUrl: any(named: 'imageUrl'))).thenAnswer((_) async {});
    when(() => mockInvRepo.delete(any())).thenAnswer((_) async {});
    when(() => mockStorageRepo.uploadImage(any(), any()))
        .thenAnswer((_) async => 'https://img.com/inv.jpg');

    container = ProviderContainer(overrides: [
      inventoryRepositoryProvider.overrideWithValue(mockInvRepo),
      storageRepositoryProvider.overrideWithValue(mockStorageRepo),
      shopByOwnerProvider.overrideWith((_) => AsyncData(testShop)),
    ]);
  });

  tearDown(() => container.dispose());

  group('InventoryManageNotifier', () {
    test('초기 로드 시 상품 목록을 가져온다', () async {
      final state = await container.read(inventoryManageProvider.future);
      expect(state.items.length, 1);
      expect(state.items.first.name, '라켓A');
    });

    test('addItem 호출 시 상품을 추가하고 목록을 갱신한다', () async {
      await container.read(inventoryManageProvider.future);
      final notifier = container.read(inventoryManageProvider.notifier);
      await notifier.addItem(name: '셔틀콕', category: '악세서리', quantity: 10);
      verify(() => mockInvRepo.create(shopId: any(named: 'shopId'),
        name: '셔틀콕', category: '악세서리', quantity: 10,
        imageUrl: any(named: 'imageUrl'))).called(1);
    });

    test('deleteItem 호출 시 상품을 삭제한다', () async {
      await container.read(inventoryManageProvider.future);
      final notifier = container.read(inventoryManageProvider.notifier);
      await notifier.deleteItem('inv-1');
      verify(() => mockInvRepo.delete('inv-1')).called(1);
    });
  });
}
```

**커밋 메시지**: `feat: 재고 관리 상태 관리 및 Notifier 구현`

---

#### 7.1.2 재고 관리 화면 위젯 구현

**파일: `lib/screens/owner/inventory_manage/inventory_manage_screen.dart`**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/models/inventory_item.dart';
import 'package:gut_alarm/screens/owner/inventory_manage/inventory_manage_notifier.dart';
import 'package:gut_alarm/widgets/confirm_dialog.dart';
import 'package:gut_alarm/widgets/empty_state.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';
import 'package:gut_alarm/widgets/toast.dart';
import 'package:image_picker/image_picker.dart';

class InventoryManageScreen extends ConsumerWidget {
  const InventoryManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(inventoryManageProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('재고 관리'), backgroundColor: Colors.white),
      body: asyncState.when(
        loading: () => GridView.builder(padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8),
          itemCount: 4, itemBuilder: (_, __) => const SkeletonShimmer(borderRadius: 16)),
        error: (e, _) => ErrorView(message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.invalidate(inventoryManageProvider)),
        data: (state) {
          if (state.items.isEmpty) {
            return const EmptyState(icon: Icons.inventory_2,
              message: '등록된 상품이 없습니다',
              subMessage: "'+' 버튼으로 상품을 등록하세요");
          }
          return GridView.builder(padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8),
            itemCount: state.items.length,
            itemBuilder: (ctx, i) => _ProductCard(
              item: state.items[i],
              isDeleting: state.deletingItemId == state.items[i].id,
              onTap: () => _showEditSheet(ctx, ref, state.items[i]),
              onLongPress: () => _confirmDelete(ctx, ref, state.items[i]),
            ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _InventoryFormSheet(
        onSave: (name, category, quantity, imageFile) async {
          await ref.read(inventoryManageProvider.notifier)
              .addItem(name: name, category: category, quantity: quantity, imageFile: imageFile);
          if (context.mounted) {
            Navigator.pop(context);
            AppToast.show(context, '저장되었습니다');
          }
        }));
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, InventoryItem item) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _InventoryFormSheet(item: item,
        onSave: (name, category, quantity, imageFile) async {
          await ref.read(inventoryManageProvider.notifier).updateItem(
            itemId: item.id, name: name, category: category,
            quantity: quantity, imageFile: imageFile, imageChanged: imageFile != null);
          if (context.mounted) {
            Navigator.pop(context);
            AppToast.show(context, '저장되었습니다');
          }
        }));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, InventoryItem item) async {
    final confirmed = await ConfirmDialog.show(context,
      title: '상품 삭제', message: "'${item.name}'을(를) 삭제하시겠습니까?",
      confirmText: '삭제', cancelText: '취소');
    if (confirmed == true) {
      await ref.read(inventoryManageProvider.notifier).deleteItem(item.id);
      if (context.mounted) AppToast.show(context, '삭제되었습니다');
    }
  }
}

class _ProductCard extends StatelessWidget {
  final InventoryItem item;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _ProductCard({required this.item, required this.isDeleting,
    required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, onLongPress: onLongPress,
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: const Color(0xFFF1F5F9),
              image: item.imageUrl != null ? DecorationImage(
                image: NetworkImage(item.imageUrl!), fit: BoxFit.cover) : null),
            child: item.imageUrl == null
                ? const Center(child: Icon(Icons.inventory_2, size: 40, color: Color(0xFF94A3B8))) : null)),
          Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(item.category, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text('${item.quantity}개', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ])),
          if (isDeleting) const LinearProgressIndicator(),
        ])));
  }
}

class _InventoryFormSheet extends StatefulWidget {
  final InventoryItem? item;
  final Future<void> Function(String name, String category, int quantity, File? imageFile) onSave;
  const _InventoryFormSheet({this.item, required this.onSave});
  @override
  State<_InventoryFormSheet> createState() => _InventoryFormSheetState();
}

class _InventoryFormSheetState extends State<_InventoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  String _category = '라켓';
  File? _imageFile;
  bool _saving = false;

  static const categories = ['라켓', '상의', '하의', '가방', '신발', '악세서리'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name ?? '');
    _qtyCtrl = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    if (widget.item != null) _category = widget.item!.category;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _qtyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.item == null ? '상품 추가' : '상품 수정',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(controller: _nameCtrl,
          decoration: const InputDecoration(labelText: '상품명', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _category,
          decoration: const InputDecoration(labelText: '카테고리', border: OutlineInputBorder()),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v!)),
        const SizedBox(height: 12),
        TextField(controller: _qtyCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '수량', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _imageFile = File(picked.path));
          },
          icon: const Icon(Icons.image), label: Text(_imageFile != null ? '이미지 선택됨' : '이미지 선택')),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 48,
          child: FilledButton(
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              await widget.onSave(_nameCtrl.text, _category,
                int.tryParse(_qtyCtrl.text) ?? 0, _imageFile);
              if (mounted) setState(() => _saving = false);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
            child: _saving
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('저장', style: TextStyle(color: Colors.white)))),
      ]));
  }
}
```

**커밋 메시지**: `feat: 재고 관리 화면 위젯 구현`

---

### Task 7.2: Notifications (알림 — 고객)

#### 7.2.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/customer/notifications/notifications_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/models/notification_item.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default([]) List<NotificationItem> notifications,
    @Default(true) bool isLoading,
    AppException? error,
    @Default(false) bool isRefreshing,
  }) = _NotificationsState;
}
```

**파일: `lib/screens/customer/notifications/notifications_notifier.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/notification_repository.dart';
import 'package:gut_alarm/screens/customer/notifications/notifications_state.dart';

class NotificationsNotifier extends AsyncNotifier<NotificationsState> {
  late final NotificationRepository _notiRepo;
  late final String _userId;

  @override
  Future<NotificationsState> build() async {
    _notiRepo = ref.watch(notificationRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    _userId = user?.id ?? '';
    if (_userId.isEmpty) return const NotificationsState(isLoading: false);
    return _loadNotifications();
  }

  Future<NotificationsState> _loadNotifications() async {
    final notifications = await _notiRepo.getByUser(_userId);
    // 전체 읽음 처리 (실패해도 무시)
    _notiRepo.markAllAsRead(_userId).catchError((_) {});
    return NotificationsState(notifications: notifications, isLoading: false);
  }

  Future<void> refresh() async {
    final prev = state.valueOrNull;
    if (prev != null) state = AsyncData(prev.copyWith(isRefreshing: true));
    try {
      final notifications = await _notiRepo.getByUser(_userId);
      state = AsyncData(NotificationsState(notifications: notifications, isRefreshing: false));
    } catch (e) {
      if (prev != null) state = AsyncData(prev.copyWith(isRefreshing: false, error: ErrorHandler.handle(e)));
    }
  }

  void navigateToOrder(String orderId, GoRouter router) {
    router.push('/customer/order/$orderId');
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationsState>(NotificationsNotifier.new);
```

**파일: `test/screens/customer/notifications/notifications_notifier_test.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/models/notification_item.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/notification_repository.dart';
import 'package:gut_alarm/screens/customer/notifications/notifications_notifier.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockNotiRepo;
  late ProviderContainer container;

  final testNoti = NotificationItem(id: 'n1', userId: 'u1',
    type: NotificationType.statusChanged, title: '상태 변경',
    body: '작업이 완료되었습니다', orderId: 'order-1',
    isRead: false, createdAt: DateTime(2026, 2, 24));

  setUp(() {
    mockNotiRepo = MockNotificationRepository();
    when(() => mockNotiRepo.getByUser(any())).thenAnswer((_) async => [testNoti]);
    when(() => mockNotiRepo.markAllAsRead(any())).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      notificationRepositoryProvider.overrideWithValue(mockNotiRepo),
      currentUserProvider.overrideWithValue(testUser),
    ]);
  });

  tearDown(() => container.dispose());

  group('NotificationsNotifier', () {
    test('초기 로드 시 알림 목록을 가져오고 전체 읽음 처리한다', () async {
      final state = await container.read(notificationsProvider.future);
      expect(state.notifications.length, 1);
      expect(state.notifications.first.title, '상태 변경');
      verify(() => mockNotiRepo.markAllAsRead(any())).called(1);
    });

    test('알림 0건 시 빈 리스트를 반환한다', () async {
      when(() => mockNotiRepo.getByUser(any())).thenAnswer((_) async => []);
      container.invalidate(notificationsProvider);
      final state = await container.read(notificationsProvider.future);
      expect(state.notifications, isEmpty);
    });
  });
}
```

**커밋 메시지**: `feat: 알림 상태 관리 및 Notifier 구현`

---

#### 7.2.2 알림 화면 위젯 구현

**파일: `lib/screens/customer/notifications/notifications_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/core/utils/formatters.dart';
import 'package:gut_alarm/models/enums.dart';
import 'package:gut_alarm/models/notification_item.dart';
import 'package:gut_alarm/screens/customer/notifications/notifications_notifier.dart';
import 'package:gut_alarm/widgets/empty_state.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('알림'), backgroundColor: Colors.white),
      body: asyncState.when(
        loading: () => ListView.builder(itemCount: 5,
          itemBuilder: (_, __) => const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonShimmer(height: 72, borderRadius: 12))),
        error: (e, _) => ErrorView(message: '알림을 불러올 수 없습니다',
          onRetry: () => ref.invalidate(notificationsProvider)),
        data: (state) {
          if (state.notifications.isEmpty) {
            return const EmptyState(icon: Icons.notifications_none, message: '알림이 없습니다');
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.builder(itemCount: state.notifications.length,
              itemBuilder: (ctx, i) => _NotificationTile(
                item: state.notifications[i],
                onTap: () {
                  if (state.notifications[i].orderId != null) {
                    ctx.push('/customer/order/${state.notifications[i].orderId}');
                  }
                })));
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  IconData get _icon => switch (item.type) {
    NotificationType.statusChanged => Icons.sync,
    NotificationType.completed => Icons.check_circle,
    NotificationType.announcement => Icons.campaign,
    _ => Icons.notifications,
  };

  Color get _iconColor => switch (item.type) {
    NotificationType.statusChanged => const Color(0xFF3B82F6),
    NotificationType.completed => const Color(0xFF22C55E),
    NotificationType.announcement => const Color(0xFFEAB308),
    _ => const Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.orderId != null ? onTap : null,
      leading: CircleAvatar(backgroundColor: _iconColor.withOpacity(0.1),
        child: Icon(_icon, color: _iconColor, size: 20)),
      title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(item.body, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(Formatters.relativeTime(item.createdAt),
        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
    );
  }
}
```

**커밋 메시지**: `feat: 알림 화면 위젯 구현`

---

## Phase 8: 설정/프로필

### Task 8.1: Profile Edit (프로필 수정 — 고객)

#### 8.1.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/customer/profile_edit/profile_edit_state.dart`**

```dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_state.freezed.dart';

enum ProfileEditStatus { idle, saving, error }

@freezed
class ProfileEditState with _$ProfileEditState {
  const ProfileEditState._();

  const factory ProfileEditState({
    @Default('') String name,
    @Default('') String phone,
    String? profileImageUrl,
    File? newImageFile,
    @Default('') String originalName,
    @Default('') String originalPhone,
    String? originalImageUrl,
    @Default(ProfileEditStatus.idle) ProfileEditStatus status,
    String? nameError,
    String? phoneError,
  }) = _ProfileEditState;

  bool get hasChanges =>
      name != originalName || phone != originalPhone || newImageFile != null;
}
```

**파일: `lib/screens/customer/profile_edit/profile_edit_notifier.dart`**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/core/utils/validators.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/screens/customer/profile_edit/profile_edit_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditNotifier extends AsyncNotifier<ProfileEditState> {
  late final UserRepository _userRepo;
  late final StorageRepository _storageRepo;

  @override
  Future<ProfileEditState> build() async {
    _userRepo = ref.watch(userRepositoryProvider);
    _storageRepo = ref.watch(storageRepositoryProvider);
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) throw Exception('인증 정보 없음');

    final user = await _userRepo.getById(authUser.id);
    return ProfileEditState(
      name: user.name, phone: user.phone,
      profileImageUrl: user.profileImageUrl,
      originalName: user.name, originalPhone: user.phone,
      originalImageUrl: user.profileImageUrl);
  }

  void updateName(String value) {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(name: value, nameError: null));
  }

  void validateName() {
    final prev = state.valueOrNull;
    if (prev == null) return;
    final err = Validators.name(prev.name);
    state = AsyncData(prev.copyWith(nameError: err));
  }

  void updatePhone(String value) {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(phone: value, phoneError: null));
  }

  void validatePhone() {
    final prev = state.valueOrNull;
    if (prev == null) return;
    final err = Validators.phone(prev.phone);
    state = AsyncData(prev.copyWith(phoneError: err));
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 512, imageQuality: 80);
    if (picked == null) return;
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(newImageFile: File(picked.path)));
  }

  Future<bool> save() async {
    final prev = state.valueOrNull;
    if (prev == null) return false;

    // 유효성 검증
    final nameErr = Validators.name(prev.name);
    final phoneErr = Validators.phone(prev.phone);
    if (nameErr != null || phoneErr != null) {
      state = AsyncData(prev.copyWith(nameError: nameErr, phoneError: phoneErr));
      return false;
    }

    state = AsyncData(prev.copyWith(status: ProfileEditStatus.saving));
    try {
      String? newImageUrl = prev.profileImageUrl;
      if (prev.newImageFile != null) {
        newImageUrl = await _storageRepo.uploadImage('profile-images', prev.newImageFile!);
      }
      final authUser = ref.read(currentUserProvider);
      await _userRepo.update(id: authUser!.id, name: prev.name,
        phone: prev.phone, profileImageUrl: newImageUrl);
      state = AsyncData(prev.copyWith(status: ProfileEditStatus.idle,
        profileImageUrl: newImageUrl, newImageFile: null,
        originalName: prev.name, originalPhone: prev.phone, originalImageUrl: newImageUrl));
      return true;
    } catch (e) {
      state = AsyncData(prev.copyWith(status: ProfileEditStatus.error));
      return false;
    }
  }
}

final profileEditNotifierProvider =
    AsyncNotifierProvider<ProfileEditNotifier, ProfileEditState>(ProfileEditNotifier.new);

final hasChangesProvider = Provider<bool>((ref) {
  final state = ref.watch(profileEditNotifierProvider).valueOrNull;
  return state?.hasChanges ?? false;
});
```

**파일: `test/screens/customer/profile_edit/profile_edit_notifier_test.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/storage_repository.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/screens/customer/profile_edit/profile_edit_notifier.dart';
import 'package:gut_alarm/screens/customer/profile_edit/profile_edit_state.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late MockUserRepository mockUserRepo;
  late ProviderContainer container;

  setUp(() {
    mockUserRepo = MockUserRepository();
    when(() => mockUserRepo.getById(any())).thenAnswer((_) async => testUserModel);
    when(() => mockUserRepo.update(id: any(named: 'id'), name: any(named: 'name'),
      phone: any(named: 'phone'), profileImageUrl: any(named: 'profileImageUrl')))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepo),
      storageRepositoryProvider.overrideWithValue(MockStorageRepository()),
      currentUserProvider.overrideWithValue(testAuthUser),
    ]);
  });

  tearDown(() => container.dispose());

  group('ProfileEditNotifier', () {
    test('초기 로드 시 사용자 정보를 가져온다', () async {
      final state = await container.read(profileEditNotifierProvider.future);
      expect(state.name, testUserModel.name);
      expect(state.phone, testUserModel.phone);
      expect(state.hasChanges, false);
    });

    test('이름 변경 시 hasChanges가 true이다', () async {
      await container.read(profileEditNotifierProvider.future);
      container.read(profileEditNotifierProvider.notifier).updateName('새이름');
      final state = container.read(profileEditNotifierProvider).valueOrNull;
      expect(state?.hasChanges, true);
    });

    test('save 성공 시 원본 데이터를 갱신한다', () async {
      await container.read(profileEditNotifierProvider.future);
      final notifier = container.read(profileEditNotifierProvider.notifier);
      notifier.updateName('새이름');
      final result = await notifier.save();
      expect(result, true);
      verify(() => mockUserRepo.update(
        id: any(named: 'id'), name: '새이름',
        phone: any(named: 'phone'), profileImageUrl: any(named: 'profileImageUrl'))).called(1);
    });
  });
}
```

**커밋 메시지**: `feat: 프로필 수정 상태 관리 및 Notifier 구현`

---

#### 8.1.2 프로필 수정 화면 위젯 구현

**파일: `lib/screens/customer/profile_edit/profile_edit_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/screens/customer/profile_edit/profile_edit_notifier.dart';
import 'package:gut_alarm/screens/customer/profile_edit/profile_edit_state.dart';
import 'package:gut_alarm/widgets/confirm_dialog.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/phone_input_field.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';
import 'package:gut_alarm/widgets/toast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileEditNotifierProvider);
    final hasChanges = ref.watch(hasChangesProvider);
    final email = ref.watch(currentUserProvider)?.email ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!hasChanges) { if (context.mounted) context.pop(); return; }
        final result = await ConfirmDialog.show(context,
          title: '나가시겠습니까?', message: '변경사항이 저장되지 않습니다. 나가시겠습니까?',
          confirmText: '나가기', cancelText: '취소');
        if (result == true && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('프로필 수정'), backgroundColor: Colors.white),
        body: asyncState.when(
          loading: () => const Padding(padding: EdgeInsets.all(16),
            child: Column(children: [
              SkeletonShimmer(width: 80, height: 80, borderRadius: 40),
              SizedBox(height: 24),
              SkeletonShimmer(height: 56, borderRadius: 8),
              SizedBox(height: 16),
              SkeletonShimmer(height: 56, borderRadius: 8),
            ])),
          error: (e, _) => ErrorView(message: '프로필을 불러올 수 없습니다',
            onRetry: () => ref.invalidate(profileEditNotifierProvider)),
          data: (state) => _buildForm(context, ref, state, email),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext ctx, WidgetRef ref, ProfileEditState state, String email) {
    final notifier = ref.read(profileEditNotifierProvider.notifier);
    return Column(children: [
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 프로필 이미지
          Stack(alignment: Alignment.bottomRight, children: [
            CircleAvatar(radius: 40, backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: state.newImageFile != null
                  ? FileImage(state.newImageFile!) as ImageProvider
                  : (state.profileImageUrl != null ? NetworkImage(state.profileImageUrl!) : null),
              child: state.profileImageUrl == null && state.newImageFile == null
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF94A3B8)) : null),
            GestureDetector(
              onTap: () async {
                final source = await showModalBottomSheet<ImageSource>(context: ctx,
                  builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(leading: const Icon(Icons.camera_alt), title: const Text('카메라'),
                      onTap: () => Navigator.pop(c, ImageSource.camera)),
                    ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리'),
                      onTap: () => Navigator.pop(c, ImageSource.gallery)),
                  ])));
                if (source != null) notifier.pickImage(source);
              },
              child: Container(padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
          ]),
          const SizedBox(height: 24),
          // 이름
          TextFormField(initialValue: state.name,
            decoration: InputDecoration(labelText: '이름', errorText: state.nameError,
              border: const OutlineInputBorder()),
            onChanged: notifier.updateName,
            onEditingComplete: notifier.validateName),
          const SizedBox(height: 16),
          // 연락처
          PhoneInputField(initialValue: state.phone, errorText: state.phoneError,
            onChanged: notifier.updatePhone,
            onEditingComplete: notifier.validatePhone),
          const SizedBox(height: 16),
          // 이메일 (읽기전용)
          TextFormField(initialValue: email, enabled: false,
            decoration: InputDecoration(labelText: '이메일',
              border: const OutlineInputBorder(),
              fillColor: const Color(0xFFF1F5F9), filled: true)),
        ]))),
      // 저장 버튼
      SafeArea(child: Padding(padding: const EdgeInsets.all(16),
        child: SizedBox(width: double.infinity, height: 56,
          child: FilledButton(
            onPressed: state.hasChanges && state.status != ProfileEditStatus.saving
                ? () async {
                    final success = await notifier.save();
                    if (success && ctx.mounted) {
                      AppToast.show(ctx, '프로필이 수정되었습니다');
                      ctx.pop();
                    } else if (!success && ctx.mounted) {
                      AppToast.showError(ctx, '프로필 수정에 실패했습니다');
                    }
                  } : null,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: state.status == ProfileEditStatus.saving
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))))),
    ]);
  }
}
```

**커밋 메시지**: `feat: 프로필 수정 화면 위젯 구현`

---

### Task 8.2: Shop Settings (샵 설정 — 사장님)

#### 8.2.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/owner/shop_settings/shop_settings_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/core/error/app_exception.dart';

part 'shop_settings_state.freezed.dart';

@freezed
class ShopSettingsState with _$ShopSettingsState {
  const ShopSettingsState._();

  const factory ShopSettingsState({
    @Default('') String shopName,
    @Default('') String shopAddress,
    double? shopLatitude,
    double? shopLongitude,
    @Default('') String shopPhone,
    @Default('') String shopDescription,
    @Default('') String ownerName,
    @Default('') String ownerPhone,
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool hasChanges,
    AppException? error,
    String? shopNameError,
    String? shopPhoneError,
    String? shopAddressError,
    String? ownerNameError,
    String? ownerPhoneError,
  }) = _ShopSettingsState;

  bool get hasCoordinates => shopLatitude != null && shopLongitude != null;
}
```

**파일: `lib/screens/owner/shop_settings/shop_settings_notifier.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/core/utils/validators.dart';
import 'package:gut_alarm/models/shop.dart';
import 'package:gut_alarm/models/user.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/screens/owner/shop_settings/shop_settings_state.dart';

class ShopSettingsNotifier extends AsyncNotifier<ShopSettingsState> {
  late final ShopRepository _shopRepo;
  late final UserRepository _userRepo;
  Shop? _originalShop;
  User? _originalOwner;

  @override
  Future<ShopSettingsState> build() async {
    _shopRepo = ref.watch(shopRepositoryProvider);
    _userRepo = ref.watch(userRepositoryProvider);
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) throw Exception('인증 정보 없음');

    final results = await Future.wait([
      _shopRepo.getByOwner(authUser.id),
      _userRepo.getById(authUser.id),
    ]);
    _originalShop = results[0] as Shop;
    _originalOwner = results[1] as User;

    return ShopSettingsState(
      shopName: _originalShop!.name, shopAddress: _originalShop!.address,
      shopLatitude: _originalShop!.latitude, shopLongitude: _originalShop!.longitude,
      shopPhone: _originalShop!.phone, shopDescription: _originalShop!.description ?? '',
      ownerName: _originalOwner!.name, ownerPhone: _originalOwner!.phone,
      isLoading: false);
  }

  void _updateAndCheckChanges(ShopSettingsState newState) {
    final changed = newState.shopName != _originalShop?.name ||
        newState.shopAddress != _originalShop?.address ||
        newState.shopPhone != _originalShop?.phone ||
        newState.shopDescription != (_originalShop?.description ?? '') ||
        newState.ownerName != _originalOwner?.name ||
        newState.ownerPhone != _originalOwner?.phone;
    state = AsyncData(newState.copyWith(hasChanges: changed));
  }

  void setShopName(String v) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(shopName: v, shopNameError: null)); }
  void setShopAddress(String addr, double lat, double lng) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(shopAddress: addr, shopLatitude: lat, shopLongitude: lng, shopAddressError: null)); }
  void setShopPhone(String v) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(shopPhone: v, shopPhoneError: null)); }
  void setShopDescription(String v) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(shopDescription: v)); }
  void setOwnerName(String v) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(ownerName: v, ownerNameError: null)); }
  void setOwnerPhone(String v) { final p = state.valueOrNull; if (p != null) _updateAndCheckChanges(p.copyWith(ownerPhone: v, ownerPhoneError: null)); }

  Future<bool> save() async {
    final prev = state.valueOrNull;
    if (prev == null) return false;

    // 유효성 검증
    String? sne = Validators.shopName(prev.shopName);
    String? spe = Validators.phone(prev.shopPhone);
    String? sae = prev.shopAddress.isEmpty ? '주소를 입력해 주세요' : null;
    String? one = Validators.name(prev.ownerName);
    String? ope = Validators.phone(prev.ownerPhone);
    if (sne != null || spe != null || sae != null || one != null || ope != null) {
      state = AsyncData(prev.copyWith(shopNameError: sne, shopPhoneError: spe,
        shopAddressError: sae, ownerNameError: one, ownerPhoneError: ope));
      return false;
    }

    state = AsyncData(prev.copyWith(isSaving: true));
    try {
      await Future.wait([
        _shopRepo.update(id: _originalShop!.id, name: prev.shopName,
          address: prev.shopAddress, latitude: prev.shopLatitude!,
          longitude: prev.shopLongitude!, phone: prev.shopPhone,
          description: prev.shopDescription),
        _userRepo.update(id: _originalOwner!.id, name: prev.ownerName, phone: prev.ownerPhone),
      ]);
      _originalShop = _originalShop!.copyWith(name: prev.shopName, address: prev.shopAddress,
        latitude: prev.shopLatitude!, longitude: prev.shopLongitude!,
        phone: prev.shopPhone, description: prev.shopDescription);
      _originalOwner = _originalOwner!.copyWith(name: prev.ownerName, phone: prev.ownerPhone);
      state = AsyncData(prev.copyWith(isSaving: false, hasChanges: false));
      return true;
    } catch (e) {
      state = AsyncData(prev.copyWith(isSaving: false, error: ErrorHandler.handle(e)));
      return false;
    }
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final shopSettingsNotifierProvider =
    AsyncNotifierProvider<ShopSettingsNotifier, ShopSettingsState>(ShopSettingsNotifier.new);
```

**커밋 메시지**: `feat: 샵 설정 상태 관리 및 Notifier 구현`

---

### Task 8.3: My Page (마이페이지 — 고객)

#### 8.3.1 상태 클래스 및 Notifier 구현

**파일: `lib/screens/customer/mypage/mypage_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mypage_state.freezed.dart';

@freezed
class MypageState with _$MypageState {
  const factory MypageState({
    @Default('') String userName,
    @Default('') String userPhone,
    String? userEmail,
    String? profileImageUrl,
    @Default(true) bool pushEnabled,
    @Default('') String appVersion,
    @Default(false) bool isTogglingPush,
    @Default(false) bool isLoggingOut,
  }) = _MypageState;
}
```

**파일: `lib/screens/customer/mypage/mypage_notifier.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/core/error/error_handler.dart';
import 'package:gut_alarm/providers/auth_provider.dart';
import 'package:gut_alarm/repositories/auth_repository.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/screens/customer/mypage/mypage_state.dart';
import 'package:gut_alarm/services/fcm_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MypageNotifier extends AsyncNotifier<MypageState> {
  late final UserRepository _userRepo;
  late final AuthRepository _authRepo;
  late final FcmService _fcmService;

  @override
  Future<MypageState> build() async {
    _userRepo = ref.watch(userRepositoryProvider);
    _authRepo = ref.watch(authRepositoryProvider);
    _fcmService = ref.watch(fcmServiceProvider);
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) throw Exception('인증 정보 없음');

    final user = await _userRepo.getById(authUser.id);
    final packageInfo = await PackageInfo.fromPlatform();

    return MypageState(
      userName: user.name, userPhone: user.phone,
      userEmail: authUser.email, profileImageUrl: user.profileImageUrl,
      pushEnabled: user.fcmToken != null && user.fcmToken!.isNotEmpty,
      appVersion: 'v${packageInfo.version}');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> togglePushNotification(bool enabled) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(isTogglingPush: true));
    try {
      final authUser = ref.read(currentUserProvider);
      if (enabled) {
        await _fcmService.saveTokenToDb(authUser!.id);
      } else {
        await _userRepo.update(id: authUser!.id, fcmToken: null);
      }
      state = AsyncData(prev.copyWith(pushEnabled: enabled, isTogglingPush: false));
    } catch (e) {
      state = AsyncData(prev.copyWith(isTogglingPush: false));
    }
  }

  Future<bool> logout() async {
    final prev = state.valueOrNull;
    if (prev == null) return false;
    state = AsyncData(prev.copyWith(isLoggingOut: true));
    try {
      await _authRepo.signOut();
      return true;
    } catch (e) {
      state = AsyncData(prev.copyWith(isLoggingOut: false));
      return false;
    }
  }
}

final mypageNotifierProvider =
    AsyncNotifierProvider<MypageNotifier, MypageState>(MypageNotifier.new);
```

**커밋 메시지**: `feat: 마이페이지 상태 관리 및 Notifier 구현`

---

#### 8.3.2 마이페이지 화면 위젯 구현

**파일: `lib/screens/customer/mypage/mypage_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/screens/customer/mypage/mypage_notifier.dart';
import 'package:gut_alarm/widgets/confirm_dialog.dart';
import 'package:gut_alarm/widgets/error_view.dart';
import 'package:gut_alarm/widgets/skeleton_shimmer.dart';
import 'package:gut_alarm/widgets/toast.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mypageNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), backgroundColor: Colors.white),
      body: asyncState.when(
        loading: () => const Padding(padding: EdgeInsets.all(16),
          child: Column(children: [
            SkeletonShimmer(width: 80, height: 80, borderRadius: 40),
            SizedBox(height: 16),
            SkeletonShimmer(height: 20, borderRadius: 4),
          ])),
        error: (e, _) => ErrorView(message: '프로필을 불러올 수 없습니다',
          onRetry: () => ref.read(mypageNotifierProvider.notifier).refresh()),
        data: (state) => ListView(padding: const EdgeInsets.all(16), children: [
          // 프로필 섹션
          Center(child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: state.profileImageUrl != null
                  ? NetworkImage(state.profileImageUrl!) : null,
              child: state.profileImageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF94A3B8)) : null),
            const SizedBox(height: 12),
            Text(state.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(state.userPhone, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            if (state.userEmail != null) ...[
              const SizedBox(height: 2),
              Text(state.userEmail!, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
            ],
          ])),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/customer/profile-edit'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: Colors.black),
            child: const Text('프로필 수정')),
          const SizedBox(height: 24),
          const Divider(),
          // 푸시 알림 토글
          SwitchListTile(
            title: const Text('푸시 알림'),
            subtitle: const Text('작업 상태 변경 알림을 받습니다'),
            value: state.pushEnabled,
            onChanged: state.isTogglingPush ? null : (v) =>
                ref.read(mypageNotifierProvider.notifier).togglePushNotification(v),
            activeColor: const Color(0xFF16A34A)),
          const Divider(),
          // 앱 버전
          ListTile(title: const Text('앱 버전'), trailing: Text(state.appVersion,
            style: const TextStyle(color: Color(0xFF94A3B8)))),
          const Divider(),
          // 로그아웃
          ListTile(
            title: const Text('로그아웃', style: TextStyle(color: Color(0xFFEF4444))),
            trailing: state.isLoggingOut
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout, color: Color(0xFFEF4444)),
            onTap: state.isLoggingOut ? null : () async {
              final confirmed = await ConfirmDialog.show(context,
                title: '로그아웃', message: '로그아웃 하시겠습니까?',
                confirmText: '로그아웃', cancelText: '취소');
              if (confirmed != true) return;
              final success = await ref.read(mypageNotifierProvider.notifier).logout();
              if (success && context.mounted) {
                context.go('/login');
              } else if (!success && context.mounted) {
                AppToast.showError(context, '로그아웃에 실패했습니다');
              }
            }),
        ]),
      ),
    );
  }
}
```

**커밋 메시지**: `feat: 마이페이지 화면 위젯 구현`

---

## Phase 9: 통합 및 마무리

### Task 9.1: Supabase Edge Function (FCM 푸시 알림)

#### 9.1.1 Edge Function 구현

**파일: `supabase/functions/send-push/index.ts`**

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!;

interface PushPayload {
  user_id: string;
  title: string;
  body: string;
  order_id?: string;
  type: string;
}

serve(async (req: Request) => {
  try {
    const payload: PushPayload = await req.json();
    const { user_id, title, body, order_id, type } = payload;

    // Supabase 클라이언트로 사용자의 FCM 토큰 조회
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: user, error } = await supabase
      .from('users')
      .select('fcm_token')
      .eq('id', user_id)
      .single();

    if (error || !user?.fcm_token) {
      return new Response(JSON.stringify({ success: false, reason: 'no_token' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } });
    }

    // FCM 전송
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${FCM_SERVER_KEY}`,
      },
      body: JSON.stringify({
        to: user.fcm_token,
        notification: { title, body },
        data: { order_id: order_id ?? '', type },
      }),
    });

    const fcmResult = await fcmResponse.json();

    // notifications 테이블에 기록
    await supabase.from('notifications').insert({
      user_id, type, title, body, order_id: order_id ?? null, is_read: false,
    });

    return new Response(JSON.stringify({ success: true, fcm: fcmResult }),
      { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ success: false, error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
```

**배포 명령어:**

```bash
supabase functions deploy send-push --project-ref <project-ref>
supabase secrets set FCM_SERVER_KEY=<your-fcm-server-key>
```

**커밋 메시지**: `feat: FCM 푸시 알림 Edge Function 구현`

---

### Task 9.2: Database Trigger (주문 상태 변경 시 자동 푸시)

**파일: `supabase/migrations/20260224_order_status_trigger.sql`**

```sql
-- 주문 상태 변경 시 고객에게 푸시 알림을 보내는 트리거
CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  _member_user_id UUID;
  _notification_title TEXT;
  _notification_body TEXT;
  _notification_type TEXT;
BEGIN
  -- 상태가 실제로 변경된 경우만 처리
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  -- 주문의 회원 → 사용자 ID 조회
  SELECT m.user_id INTO _member_user_id
  FROM members m WHERE m.id = NEW.member_id;

  IF _member_user_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- 상태별 알림 메시지
  CASE NEW.status
    WHEN 'in_progress' THEN
      _notification_title := '작업이 시작되었습니다';
      _notification_body := '거트 작업이 진행 중입니다.';
      _notification_type := 'status_changed';
    WHEN 'completed' THEN
      _notification_title := '작업이 완료되었습니다';
      _notification_body := '거트 작업이 완료되었습니다. 픽업해 주세요!';
      _notification_type := 'completed';
    ELSE
      RETURN NEW;
  END CASE;

  -- Edge Function 호출 (비동기)
  PERFORM net.http_post(
    url := current_setting('app.settings.supabase_url') || '/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := jsonb_build_object(
      'user_id', _member_user_id,
      'title', _notification_title,
      'body', _notification_body,
      'order_id', NEW.id,
      'type', _notification_type
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_order_status_change
  AFTER UPDATE OF status ON orders
  FOR EACH ROW
  EXECUTE FUNCTION notify_order_status_change();
```

**커밋 메시지**: `feat: 주문 상태 변경 시 자동 푸시 알림 트리거 구현`

---

### Task 9.3: Integration Tests

**파일: `integration_test/app_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gut_alarm/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: 전체 앱 플로우', () {
    testWidgets('스플래시 → 로그인 화면 표시', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // 비로그인 상태에서 로그인 화면으로 이동 확인
      expect(find.text('카카오로 시작하기'), findsOneWidget);
    });
  });
}
```

**파일: `integration_test/post_flow_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gut_alarm/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: 게시글 플로우', () {
    testWidgets('사장님: 게시글 작성 → 등록 → 목록 확인', (tester) async {
      // 사전 조건: 사장님 계정으로 로그인된 상태 (테스트 환경 설정 필요)
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 게시글 작성 화면 진입 (네비게이션 경로는 실제 앱에 맞게 조정)
      // 공지사항 칩 선택
      // 제목/내용 입력
      // 등록 버튼 탭
      // 성공 토스트 확인
    });
  });
}
```

**커밋 메시지**: `test: 통합 테스트 기본 구조 구현`

---

### Task 9.4: Deep Link Handling

**파일: `lib/app/router.dart`** (딥링크 설정 추가)

```dart
// router.dart의 GoRouter 설정에 딥링크 라우트 추가

// 앱 링크 스킴: gutarim://
// 주문 상세 딥링크: gutarim://order/{orderId}
// 알림에서 주문 상세로 이동: FCM data의 order_id를 이용

GoRoute(
  path: '/customer/order/:orderId',
  name: 'customer-order-detail',
  builder: (context, state) {
    final orderId = state.pathParameters['orderId']!;
    return OrderDetailScreen(orderId: orderId);
  },
),
```

**파일: `lib/services/fcm_service.dart`** (FCM 메시지 수신 시 딥링크 처리)

```dart
// FCM onMessageOpenedApp 핸들러에서 딥링크 처리
void _handleMessage(RemoteMessage message) {
  final orderId = message.data['order_id'];
  if (orderId != null && orderId.isNotEmpty) {
    // GoRouter를 통해 주문 상세 화면으로 이동
    ref.read(routerProvider).push('/customer/order/$orderId');
  }
}
```

**커밋 메시지**: `feat: FCM 딥링크 처리 구현`

---
