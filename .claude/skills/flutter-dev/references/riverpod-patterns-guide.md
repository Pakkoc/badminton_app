# Riverpod 2.6.x 패턴 가이드

이 프로젝트의 Riverpod 상태 관리 패턴과 규칙.

---

## 1. Provider 유형 선택 매트릭스

| 데이터 특성 | Provider 유형 | 예시 |
|-------------|-------------|------|
| 싱글턴 인스턴스 | `Provider` | repositoryProvider |
| 동기 파생 값 | `Provider` | currentAuthUserIdProvider |
| 비동기 단일 조회 | `FutureProvider` | currentUserProvider |
| 비동기 + 파라미터 | `FutureProvider.family` | postDetailProvider(id) |
| 비동기 + 자동 해제 | `FutureProvider.autoDispose` | searchProvider |
| 실시간 스트림 | `StreamProvider` | authStateProvider |
| 복잡한 상태 + 액션 | `NotifierProvider` | communityCreateNotifier |
| 복잡한 상태 + 파라미터 | `NotifierProvider.family` | orderDetailNotifier(id) |

---

## 2. Provider 명명 규칙

```dart
// Repository — *RepositoryProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) { ... });

// 단순 값 — *Provider (설명적 이름)
final currentUserProvider = FutureProvider<User?>((ref) async { ... });
final currentAuthUserIdProvider = Provider<String?>((ref) { ... });

// Notifier — *NotifierProvider
final communityCreateNotifierProvider =
    NotifierProvider<CommunityCreateNotifier, CommunityCreateState>(...);

// Family — *Provider (파라미터 타입 명시 불필요)
final communityPostDetailProvider =
    FutureProvider.autoDispose.family<CommunityPost?, String>(...);

// Stream — *Provider 또는 *StreamProvider
final authStateProvider = StreamProvider<AuthState>((ref) { ... });
```

---

## 3. Notifier 패턴 (폼/복잡한 상태)

### 3.1 기본 Notifier 구조

```dart
// 1. freezed 상태 정의
@freezed
class MyFormState with _$MyFormState {
  const factory MyFormState({
    @Default('') String title,
    @Default('') String content,
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MyFormState;
}

// 2. Notifier 구현
final myFormNotifierProvider =
    NotifierProvider<MyFormNotifier, MyFormState>(
  MyFormNotifier.new,
);

class MyFormNotifier extends Notifier<MyFormState> {
  @override
  MyFormState build() => const MyFormState();

  void updateTitle(String title) {
    state = state.copyWith(title: title, errorMessage: null);
  }

  Future<bool> submit() async {
    // 유효성 검증
    final error = Validators.postTitle(state.title);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(myRepositoryProvider);
      await repo.create(title: state.title, content: state.content);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return false;
    }
  }
}
```

### 3.2 Family Notifier (파라미터 기반)

```dart
final orderDetailNotifierProvider = NotifierProvider.family<
    OrderDetailNotifier, OrderDetailState, String>(
  OrderDetailNotifier.new,
);

class OrderDetailNotifier extends FamilyNotifier<OrderDetailState, String> {
  @override
  OrderDetailState build(String arg) {
    // arg = orderId
    ref.onDispose(() => _subscription?.cancel());
    Future.microtask(() => loadOrder(arg));
    return const OrderDetailState(isLoading: true);
  }
}
```

### 3.3 실시간 스트림 구독 (Notifier 내부)

```dart
class MyNotifier extends FamilyNotifier<MyState, String> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  MyState build(String arg) {
    ref.onDispose(() => _subscription?.cancel());  // 구독 해제 필수
    Future.microtask(() => _subscribe(arg));
    return const MyState(isLoading: true);
  }

  Future<void> _subscribe(String id) async {
    _subscription?.cancel();
    _subscription = ref.read(repositoryProvider)
        .streamById(id)
        .listen(
          (data) { state = MyState(data: MyModel.fromJson(data)); },
          onError: (Object e) {
            state = state.copyWith(
              isLoading: false,
              error: e is AppException ? e.userMessage : '오류 발생',
            );
          },
        );
  }
}
```

---

## 4. ref 사용 규칙

### ref.watch() vs ref.read()

```dart
// ✅ build()에서 구독 — ref.watch()
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(myNotifierProvider);  // 변경 시 리빌드
  final user = ref.watch(currentUserProvider);  // 변경 시 리빌드
}

// ✅ 이벤트 핸들러에서 조회 — ref.read()
onPressed: () {
  ref.read(myNotifierProvider.notifier).submit();  // 1회 조회
}

// ✅ Notifier 내부에서 다른 Provider 접근 — ref.read()
Future<void> submit() async {
  final repo = ref.read(repositoryProvider);  // Notifier에서는 read
}

// ❌ BAD — build()에서 ref.read()
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.read(myNotifierProvider);  // 구독 안 됨!
}

// ❌ BAD — 이벤트에서 ref.watch()
onPressed: () {
  ref.watch(provider);  // 이벤트에서 watch 금지
}
```

### ref.invalidate() — 캐시 무효화

```dart
// Pull-to-refresh
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(itemListProvider);  // 캐시 무효화 → 자동 재조회
  },
)

// 데이터 변경 후 목록 갱신
await repo.create(...);
ref.invalidate(itemListProvider);
```

---

## 5. freezed 상태 모델 규칙

```dart
@freezed
class MyState with _$MyState {
  const factory MyState({
    // 로딩 플래그
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,

    // 데이터 (nullable = 아직 로드 안 됨)
    MyModel? data,
    List<MyModel>? items,

    // 폼 입력값 (기본값 필수)
    @Default('') String title,
    @Default('') String content,

    // 에러 (nullable = 에러 없음)
    String? errorMessage,
    String? error,
  }) = _MyState;
}
```

**규칙:**
- 로딩 플래그: `@Default(false)`
- 폼 입력값: `@Default('')` 또는 `@Default([])`
- 에러: `String?` (null = 에러 없음)
- 데이터: `MyModel?` (null = 아직 로드 안 됨)

---

## 6. Repository → Provider 연결 패턴

```dart
// 1. Repository 인스턴스 (Provider)
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MyRepository(ref.watch(supabaseProvider));
});

// 2. 목록 조회 (FutureProvider)
final myItemListProvider = FutureProvider<List<MyItem>>((ref) async {
  final repo = ref.watch(myRepositoryProvider);
  return repo.getAll();
});

// 3. 상세 조회 (FutureProvider.family)
final myItemDetailProvider =
    FutureProvider.autoDispose.family<MyItem?, String>((ref, id) async {
  final repo = ref.watch(myRepositoryProvider);
  return repo.getById(id);
});

// 4. 검색 (FutureProvider.autoDispose.family)
final mySearchProvider =
    FutureProvider.autoDispose.family<List<MyItem>, String>((ref, query) async {
  final repo = ref.watch(myRepositoryProvider);
  return repo.search(query);
});
```

---

## 7. 에러 처리 패턴

```dart
// Repository에서
try {
  final data = await client.from('table').select().single();
  return MyModel.fromJson(data);
} catch (e) {
  throw ErrorHandler.handle(e);  // → AppException 변환
}

// Notifier에서
try {
  await repo.create(...);
  return true;
} on AppException catch (e) {
  state = state.copyWith(
    isSubmitting: false,
    errorMessage: e.userMessage,  // 사용자 친화적 메시지
  );
  return false;
}

// UI에서
ErrorView(
  message: state.error!,
  onRetry: () => ref.read(provider.notifier).reload(),
)
```

**규칙:**
- Repository: `catch (e) → throw ErrorHandler.handle(e)`
- Notifier: `on AppException catch (e) → state.copyWith(errorMessage: e.userMessage)`
- UI: `ErrorView` 공통 위젯 사용
