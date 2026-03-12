# Flutter 위젯 패턴 가이드

이 프로젝트의 Flutter 위젯 작성 규칙과 패턴.

---

## 1. 위젯 유형 선택 기준

| 조건 | 위젯 타입 | 예시 |
|------|----------|------|
| Provider 구독 필요 + 로컬 상태 없음 | `ConsumerWidget` | OrderDetailScreen |
| Provider 구독 필요 + 로컬 상태 있음 | `ConsumerStatefulWidget` | CommunityListScreen |
| Provider 불필요 | `StatelessWidget` | StatusBadge, EmptyState |
| Provider 불필요 + 로컬 상태 있음 | `StatefulWidget` | (거의 사용하지 않음) |

**규칙:** Provider 구독이 필요하면 반드시 Consumer 계열 사용. `Consumer()` 위젯으로 감싸는 패턴은 사용하지 않는다.

---

## 2. Private 위젯 분리 원칙

**helper 메서드(\_buildXxx) 대신 private Widget 클래스를 만든다:**

```dart
// ❌ BAD — helper 메서드
class MyScreen extends ConsumerWidget {
  Widget _buildHeader(BuildContext context) { ... }
  Widget _buildBody(BuildContext context) { ... }
}

// ✅ GOOD — private Widget 클래스
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _Header(title: 'Title'),
        _Body(items: items),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) { ... }
}
```

**분리 기준:**
- 위젯 트리가 20줄 이상이면 분리
- 재사용 가능성이 있으면 분리
- 독립적인 상태를 가지면 분리
- 단, 너무 작은 위젯(Text 1개 등)은 분리하지 않음

---

## 3. const 생성자 규칙

```dart
// ✅ 모든 가능한 곳에 const
class _Header extends StatelessWidget {
  const _Header({required this.title});  // const 생성자

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16);    // const 위젯
  }
}

// 사용처에서도 const
const _Header(title: '제목'),
const SizedBox(height: 16),
const Icon(Icons.home),
```

**규칙:**
- `StatelessWidget`은 항상 `const` 생성자
- 리터럴 위젯은 항상 `const` 접두어
- `super.key` 패턴 사용: `const _Header({super.key, required this.title})`
- private 위젯은 `super.key` 생략 가능

---

## 4. 레이아웃 패턴

### 4.1 화면 기본 구조

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: Text('제목', style: Theme.of(context).textTheme.titleLarge),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 컴포넌트들
        ],
      ),
    ),
  );
}
```

### 4.2 리스트 화면

```dart
// 긴 목록은 반드시 ListView.builder
ListView.separated(
  padding: const EdgeInsets.all(16),
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(height: 1),
  itemBuilder: (_, i) => _ItemTile(item: items[i]),
)

// RefreshIndicator로 당겨서 새로고침
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(itemListProvider);
  },
  child: ListView.builder(...),
)
```

### 4.3 3-Way 상태 분기

```dart
// AsyncValue 사용 시
postsAsync.when(
  loading: () => const LoadingIndicator(),
  error: (e, _) => ErrorView(
    message: e.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (posts) => posts.isEmpty
      ? const EmptyState(icon: Icons.article_outlined, message: '데이터 없음')
      : _buildContent(posts),
);

// 수동 상태 사용 시
state.isLoading
    ? const LoadingIndicator()
    : state.error != null
        ? ErrorView(message: state.error!, onRetry: ...)
        : _buildContent(context, state),
```

---

## 5. 스타일링 규칙

### 5.1 테마 사용 (하드코딩 금지)

```dart
// ❌ BAD — 하드코딩
Text('제목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
Container(color: Color(0xFF2563EB))

// ✅ GOOD — Theme.of(context) 사용
Text('제목', style: Theme.of(context).textTheme.titleLarge)
Container(color: Theme.of(context).colorScheme.primary)
```

### 5.2 AppTheme 상수 사용 (상태 색상 등)

```dart
// 상태별 색상은 AppTheme에서 가져옴
Container(color: AppTheme.receivedBackground)
Text('접수됨', style: TextStyle(color: AppTheme.receivedText))

// 투명도는 withValues() 사용 (withOpacity 아님)
color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
```

### 5.3 모서리 둥글기

```dart
BorderRadius.circular(14)   // 버튼, 입력 필드
BorderRadius.circular(20)   // 카드, 다이얼로그, 바텀시트
BorderRadius.circular(999)  // 뱃지, 필터 탭 (원형)
```

### 5.4 간격 상수

```dart
const EdgeInsets.all(16)              // 화면 기본 패딩
const EdgeInsets.symmetric(horizontal: 16, vertical: 14)  // 입력 필드
const SizedBox(height: 16)           // 섹션 간 기본 간격
const SizedBox(height: 24)           // 큰 섹션 간격
const SizedBox(height: 8)            // 작은 요소 간격
```

---

## 6. 네비게이션 패턴

```dart
// go_router context extension 사용
context.go('/customer/home')          // 스택 교체 (탭 전환)
context.push('/customer/order/$id')   // 스택 추가 (상세 화면)
context.pop()                         // 뒤로 가기

// 쿼리 파라미터
context.push('/owner/dashboard/order-create?shopId=$shopId')

// BottomNav에서는 go() 사용 (스택 교체)
onTap: (index) {
  if (index != currentIndex) {
    context.go(_routes[index]);
  }
},
```

---

## 7. 공통 위젯 재사용

프로젝트에 이미 정의된 공통 위젯을 반드시 사용:

| 위젯 | 용도 | 위치 |
|------|------|------|
| `LoadingIndicator` | 로딩 상태 | `lib/widgets/loading_indicator.dart` |
| `ErrorView` | 에러 + 재시도 | `lib/widgets/error_view.dart` |
| `EmptyState` | 빈 데이터 | `lib/widgets/empty_state.dart` |
| `StatusBadge` | 주문 상태 뱃지 | `lib/widgets/status_badge.dart` |
| `ConfirmDialog` | 확인 다이얼로그 | `lib/widgets/confirm_dialog.dart` |
| `AppToast` | 토스트 메시지 | `lib/widgets/app_toast.dart` |
| `PhoneInputField` | 전화번호 입력 | `lib/widgets/phone_input_field.dart` |
| `SkeletonShimmer` | 스켈레톤 로딩 | `lib/widgets/skeleton_shimmer.dart` |
| `CustomerBottomNav` | 고객 하단 탭 | `lib/widgets/customer_bottom_nav.dart` |

**규칙:** 위 위젯이 있으면 직접 만들지 않고 재사용한다.
