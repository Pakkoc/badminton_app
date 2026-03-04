# 통합 회원가입 플로우 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 모든 사용자가 고객으로 가입하고, 나중에 샵 사장님으로 추가 등록할 수 있도록 회원가입 플로우를 통합한다.

**Architecture:** 프로필 설정에서 역할 선택을 제거하고 `customer` 고정. `hasShopProvider`와 `activeModeProvider`로 사장님 여부/모드 전환을 관리. 마이페이지에서 샵 등록 및 모드 전환 메뉴 제공.

**Tech Stack:** Flutter, Riverpod 2.6.x, go_router, Supabase, freezed, mocktail

**설계 문서:** `docs/plans/2026-03-04-unified-signup-flow-design.md`

---

## Task 1: DB 마이그레이션 — 기존 shop_owner를 customer로 변경

**Files:**
- Create: Supabase migration via `apply_migration`

**Step 1: 마이그레이션 적용**

```sql
UPDATE users SET role = 'customer' WHERE role = 'shop_owner';
```

**Step 2: Supabase에서 마이그레이션 확인**

Run: Supabase MCP `execute_sql` — `SELECT role, COUNT(*) FROM users GROUP BY role`
Expected: 모든 사용자가 `customer`

**Step 3: 커밋**

```
docs: DB 마이그레이션 — 기존 shop_owner를 customer로 변경
```

---

## Task 2: hasShopProvider + activeModeProvider 추가

**Files:**
- Create: `lib/providers/app_mode_provider.dart`
- Test: `test/providers/app_mode_provider_test.dart`

**Step 1: 실패하는 테스트 작성**

```dart
// test/providers/app_mode_provider_test.dart
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}
class _MockGoTrueClient extends Mock implements GoTrueClient {}
class _MockAuthUser extends Mock implements AuthUser {}
class _MockShopRepository extends Mock implements ShopRepository {}

void main() {
  group('activeModeProvider', () {
    test('초기값은 AppMode.customer이다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(activeModeProvider), AppMode.customer);
    });

    test('모드를 owner로 전환할 수 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeModeProvider.notifier).state = AppMode.owner;
      expect(container.read(activeModeProvider), AppMode.owner);
    });
  });

  group('hasShopProvider', () {
    test('샵이 있으면 true를 반환한다', () async {
      final mockSupabase = _MockSupabaseClient();
      final mockAuth = _MockGoTrueClient();
      final mockAuthUser = _MockAuthUser();
      final mockShopRepo = _MockShopRepository();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
      when(() => mockAuthUser.id).thenReturn('user-1');
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => _fakeShop());

      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(hasShopProvider.future);
      expect(result, isTrue);
    });

    test('샵이 없으면 false를 반환한다', () async {
      final mockSupabase = _MockSupabaseClient();
      final mockAuth = _MockGoTrueClient();
      final mockAuthUser = _MockAuthUser();
      final mockShopRepo = _MockShopRepository();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
      when(() => mockAuthUser.id).thenReturn('user-1');
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(hasShopProvider.future);
      expect(result, isFalse);
    });
  });
}
```

`_fakeShop()` 헬퍼는 `test/helpers/fixtures.dart`에 이미 있는 `testShop` 사용하거나 인라인 생성.

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/providers/app_mode_provider_test.dart`
Expected: FAIL — `app_mode_provider.dart` 파일 없음

**Step 3: 최소 구현**

```dart
// lib/providers/app_mode_provider.dart
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { customer, owner }

final activeModeProvider =
    StateProvider<AppMode>((ref) => AppMode.customer);

final hasShopProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final userId =
      ref.read(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return false;

  final shop =
      await ref.read(shopRepositoryProvider).getByOwner(userId);
  return shop != null;
});
```

**Step 4: 테스트 실행 — 통과 확인**

Run: `flutter test test/providers/app_mode_provider_test.dart`
Expected: ALL PASS

**Step 5: 커밋**

```
feat: hasShopProvider + activeModeProvider 추가
```

---

## Task 3: ProfileSetupNotifier — 역할 선택 제거, customer 고정

**Files:**
- Modify: `lib/screens/auth/profile_setup/profile_setup_state.dart`
- Modify: `lib/screens/auth/profile_setup/profile_setup_notifier.dart`
- Modify: `test/screens/auth/profile_setup/profile_setup_notifier_test.dart`

**Step 1: 테스트 수정 — 역할 선택 없이 customer 고정**

`profile_setup_notifier_test.dart`에서:

- `'역할이 없으면 false를 반환한다'` 테스트 삭제 (역할 선택이 없으므로)
- `'selectRole은 역할을 업데이트한다'` 테스트 삭제
- `'사장님 역할이면 /shop-register를 반환한다'` 테스트 삭제
- `isValid` 테스트에서 `notifier.selectRole(UserRole.customer)` 호출 제거
- `submit` 테스트에서 `notifier.selectRole(...)` 호출 제거
- `submit` 테스트: 항상 `/customer/home` 반환 확인
- `User` 생성 시 `role: UserRole.customer` 고정 확인

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/screens/auth/profile_setup/profile_setup_notifier_test.dart`
Expected: FAIL — notifier에 아직 selectRole 의존

**Step 3: State 수정**

`profile_setup_state.dart`에서 `selectedRole` 필드 제거:

```dart
@freezed
class ProfileSetupState with _$ProfileSetupState {
  const factory ProfileSetupState({
    @Default('') String name,
    @Default('') String phone,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ProfileSetupState;
}
```

**Step 4: Notifier 수정**

`profile_setup_notifier.dart`에서:

- `selectRole` 메서드 제거
- `isValid`에서 `state.selectedRole != null` 조건 제거
- `submit()`에서 `role: state.selectedRole!` → `role: UserRole.customer` 고정
- `submit()` 반환값: 항상 `'/customer/home'`

```dart
bool get isValid =>
    Validators.name(state.name) == null &&
    Validators.phone(state.phone) == null;

Future<String?> submit() async {
  if (!isValid) return null;

  state = state.copyWith(isSubmitting: true, errorMessage: null);

  try {
    final userId =
        ref.read(supabaseProvider).auth.currentUser!.id;
    final user = User(
      id: userId,
      role: UserRole.customer,
      name: state.name,
      phone: state.phone,
      createdAt: DateTime.now(),
    );

    await ref.read(userRepositoryProvider).create(user);
    await ref
        .read(userRepositoryProvider)
        .matchMembersByPhone(state.phone, userId);

    return '/customer/home';
  } on AppException catch (e) {
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: e.userMessage,
    );
    return null;
  } catch (e) {
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: '알 수 없는 오류가 발생했습니다',
    );
    return null;
  }
}
```

**Step 5: freezed 코드 재생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 6: 테스트 실행 — 통과 확인**

Run: `flutter test test/screens/auth/profile_setup/profile_setup_notifier_test.dart`
Expected: ALL PASS

**Step 7: 커밋**

```
refactor: ProfileSetupNotifier에서 역할 선택 제거, customer 고정
```

---

## Task 4: ProfileSetupScreen — 역할 선택 UI 제거

**Files:**
- Modify: `lib/screens/auth/profile_setup/profile_setup_screen.dart`

**Step 1: Screen 수정**

- 역할 선택 `Row` (lines 64-88) 제거 — `_RoleCard` 2개 포함
- `_RoleCard` 클래스 전체 삭제 (lines 157-210)
- 버튼 텍스트 조건 제거: `state.selectedRole == UserRole.shopOwner ? '다음' : '시작하기'` → `'시작하기'` 고정
- `import enums.dart` 제거 (불필요)

**Step 2: 테스트 실행**

Run: `flutter test test/screens/auth/profile_setup/`
Expected: ALL PASS

**Step 3: 커밋**

```
style: ProfileSetupScreen에서 역할 선택 UI 제거
```

---

## Task 5: Splash 라우팅 단순화

**Files:**
- Modify: `lib/screens/auth/splash/splash_providers.dart`

**Step 1: `_resolveRoute` 수정**

lines 89-100의 역할 기반 분기를 제거하고 항상 `customerHome` 반환:

```dart
// 기존: user.role == UserRole.shopOwner 분기
// 변경: 항상 customerHome
return SplashRoute.customerHome;
```

`SplashRoute` enum에서 `ownerDashboard`, `shopRegister` 제거 가능하나,
라우터에서 사용하는 경우 확인 필요. 사용하지 않으면 삭제.

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/screens/auth/splash/splash_providers.dart`
Expected: No issues found

**Step 3: 관련 테스트 수정 및 통과 확인**

Run: `flutter test test/screens/auth/splash/`

**Step 4: 커밋**

```
refactor: Splash 라우팅에서 역할 기반 분기 제거, 항상 고객 홈으로
```

---

## Task 6: 마이페이지에 샵 등록/모드 전환 메뉴 추가

**Files:**
- Modify: `lib/screens/customer/mypage/mypage_screen.dart`

**Step 1: 실패하는 테스트 작성**

`test/screens/customer/mypage/mypage_screen_test.dart`에 추가:

- `'샵 미등록이면 "샵 사장님 등록" 메뉴가 표시된다'`
- `'샵 등록 완료이면 "사장님 모드 전환" 메뉴가 표시된다'`

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/screens/customer/mypage/`
Expected: FAIL

**Step 3: 마이페이지 UI 수정**

`mypage_screen.dart`에 `hasShopProvider` watch 추가:

- `_SettingsCard` 아래에 새로운 `_ShopModeCard` 위젯 삽입
- `hasShopProvider`가 `true`면: "사장님 모드 전환" (`swap_horiz` 아이콘)
  - 탭 시: `activeModeProvider`를 `AppMode.owner`로 설정 후 `context.go('/owner/dashboard')`
- `hasShopProvider`가 `false`면: "샵 사장님 등록" (`storefront` 아이콘)
  - 탭 시: `context.push('/shop-register')`

import 추가:
```dart
import 'package:badminton_app/providers/app_mode_provider.dart';
```

**Step 4: 테스트 실행 — 통과 확인**

Run: `flutter test test/screens/customer/mypage/`
Expected: ALL PASS

**Step 5: 커밋**

```
feat: 마이페이지에 샵 등록/모드 전환 메뉴 추가
```

---

## Task 7: 사장님 설정에 "고객 모드 전환" 메뉴 추가

**Files:**
- Modify: `lib/screens/owner/shop_settings/shop_settings_screen.dart`

**Step 1: Shop Settings 화면에 메뉴 추가**

기존 설정 항목 목록에 "고객 모드 전환" 항목 추가:
- 아이콘: `swap_horiz`
- 탭 시: `activeModeProvider`를 `AppMode.customer`로 설정 후 `context.go('/customer/home')`

import 추가:
```dart
import 'package:badminton_app/providers/app_mode_provider.dart';
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/screens/owner/shop_settings/`
Expected: No issues found

**Step 3: 커밋**

```
feat: 사장님 설정에 "고객 모드 전환" 메뉴 추가
```

---

## Task 8: 라우터 — shop-register 접근 권한 변경

**Files:**
- Modify: `lib/app/router.dart`

**Step 1: /shop-register 라우트 확인**

현재 `/shop-register`는 이미 공개 접근 가능. 변경 불필요할 수 있으나,
이미 샵이 있는 사용자가 접근 시 `/owner/dashboard`로 리다이렉트하는 가드 추가:

```dart
GoRoute(
  path: '/shop-register',
  redirect: (context, state) async {
    final hasShop = await ref.read(hasShopProvider.future);
    return hasShop ? '/owner/dashboard' : null;
  },
  builder: (context, state) => const ShopSignupScreen(),
),
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/app/router.dart`
Expected: No issues found

**Step 3: 커밋**

```
feat: shop-register에 이미 샵 보유 시 리다이렉트 가드 추가
```

---

## Task 9: 전체 테스트 통과 확인

**Step 1: 전체 테스트 실행**

Run: `flutter test`
Expected: ALL PASS (기존 392개 + 새 테스트)

**Step 2: 실패 테스트 수정**

역할 선택 관련 기존 테스트가 실패하면 수정.

**Step 3: 커밋**

```
test: 통합 회원가입 플로우 전체 테스트 통과
```

---

## Task 10: Pencil 디자인 + UI 스펙 동기화

**Files:**
- Modify: `design/app_desing.pen` — 프로필 설정 화면, 마이페이지 화면
- Modify: `docs/ui-specs/profile-setup.md`
- Modify: `docs/ui-specs/mypage.md`

**Step 1: Pencil 프로필 설정 화면에서 역할 선택 카드 제거**

Pencil MCP 도구로 프로필 설정 화면의 역할 선택 UI 삭제.

**Step 2: Pencil 마이페이지에 샵 등록/모드 전환 메뉴 추가**

Pencil MCP 도구로 마이페이지 화면에 메뉴 추가.

**Step 3: UI 스펙 문서 업데이트**

`profile-setup.md`: 역할 선택 관련 컴포넌트/필드 제거
`mypage.md`: 샵 등록/모드 전환 메뉴 추가

**Step 4: /design-sync 실행**

**Step 5: 커밋**

```
docs: 통합 회원가입 플로우 Pencil 디자인 + UI 스펙 동기화
```

---

## 실행 순서 의존성

```
Task 1 (DB 마이그레이션)
  ↓
Task 2 (Provider 추가)
  ↓
Task 3 (Notifier 수정) → Task 4 (Screen UI 수정)
  ↓
Task 5 (Splash 단순화)
  ↓
Task 6 (마이페이지 메뉴) → Task 7 (사장님 설정 메뉴)
  ↓
Task 8 (라우터 가드)
  ↓
Task 9 (전체 테스트)
  ↓
Task 10 (디자인/스펙 동기화)
```
