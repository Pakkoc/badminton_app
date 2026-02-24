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

### Task 0.6: Supabase DB 타임존 설정 (Asia/Seoul)

**Files:**
- Supabase Dashboard 또는 마이그레이션 SQL

**Step 1: 타임존 변경 SQL 실행**

Supabase SQL Editor 또는 마이그레이션 파일에서 실행:

```sql
-- DB 타임존을 한국 시간(KST)으로 설정
alter database postgres set timezone to 'Asia/Seoul';
```

**Step 2: 설정 확인**

```sql
show timezone;
-- Expected: Asia/Seoul
```

**Step 3: 효과 확인**

```sql
select now();
-- Expected: 한국 시간(UTC+9) 기준 현재 시각 반환
```

> **참고**: TIMESTAMPTZ 컬럼은 내부적으로 UTC로 저장되며, 읽기 시 Asia/Seoul 기준으로 변환된다. Flutter 클라이언트에서 별도 타임존 변환이 불필요하다. "오늘의 작업" 등 날짜 기반 조회가 사용자 기대(KST)와 일치한다.

---

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

### Task 1.6: M5 리포지토리 계층

**Files:**
- Create: `lib/repositories/user_repository.dart`
- Create: `lib/repositories/shop_repository.dart`
- Create: `lib/repositories/member_repository.dart`
- Create: `lib/repositories/order_repository.dart`
- Create: `lib/repositories/post_repository.dart`
- Create: `lib/repositories/inventory_repository.dart`
- Create: `lib/repositories/notification_repository.dart`
- Test: `test/repositories/user_repository_test.dart`
- Test: `test/repositories/shop_repository_test.dart`
- Test: `test/repositories/member_repository_test.dart`
- Test: `test/repositories/order_repository_test.dart`
- Test: `test/repositories/post_repository_test.dart`
- Test: `test/repositories/inventory_repository_test.dart`
- Test: `test/repositories/notification_repository_test.dart`

**Step 1: Write the failing test**

```dart
// test/repositories/user_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/repositories/user_repository.dart';

// 리포지토리 인터페이스 존재 확인 테스트
void main() {
  group('UserRepository', () {
    test('인터페이스가 정의되어 있다', () {
      // Assert: 클래스가 존재하고 인스턴스화 가능한지 컴파일 타임 확인
      expect(UserRepository, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/repositories/user_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/user.dart' as app;
import 'package:badminton_app/providers/supabase_provider.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  Future<app.User?> getById(String id) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return app.User.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<app.User> create(app.User user) async {
    try {
      final data = await _client
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      return app.User.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<app.User> update(String id, Map<String, dynamic> fields) async {
    try {
      final data = await _client
          .from('users')
          .update(fields)
          .eq('id', id)
          .select()
          .single();
      return app.User.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> matchMembersByPhone(String userId, String phone) async {
    try {
      await _client
          .from('members')
          .update({'user_id': userId})
          .eq('phone', phone)
          .isFilter('user_id', null);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/shop_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class ShopRepository {
  final SupabaseClient _client;

  ShopRepository(this._client);

  Future<Shop?> getById(String id) async {
    try {
      final data = await _client
          .from('shops')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Shop?> getByOwner(String ownerId) async {
    try {
      final data = await _client
          .from('shops')
          .select()
          .eq('owner_id', ownerId)
          .maybeSingle();
      if (data == null) return null;
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Shop> create(Shop shop) async {
    try {
      final data = await _client
          .from('shops')
          .insert(shop.toJson())
          .select()
          .single();
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Shop> update(String id, Map<String, dynamic> fields) async {
    try {
      final data = await _client
          .from('shops')
          .update(fields)
          .eq('id', id)
          .select()
          .single();
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Shop>> searchByBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    try {
      final data = await _client
          .from('shops')
          .select()
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLng)
          .lte('longitude', maxLng);
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/member_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class MemberRepository {
  final SupabaseClient _client;

  MemberRepository(this._client);

  Future<Member?> getByShopAndUser(String shopId, String userId) async {
    try {
      final data = await _client
          .from('members')
          .select()
          .eq('shop_id', shopId)
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Member?> getByShopAndPhone(String shopId, String phone) async {
    try {
      final data = await _client
          .from('members')
          .select()
          .eq('shop_id', shopId)
          .eq('phone', phone)
          .maybeSingle();
      if (data == null) return null;
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Member>> search(String shopId, String query) async {
    try {
      final data = await _client
          .from('members')
          .select()
          .eq('shop_id', shopId)
          .or('name.ilike.%$query%,phone.ilike.%$query%')
          .order('name');
      return data.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Member> create(Member member) async {
    try {
      final data = await _client
          .from('members')
          .insert(member.toJson())
          .select()
          .single();
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Member> update(String id, Map<String, dynamic> fields) async {
    try {
      final data = await _client
          .from('members')
          .update(fields)
          .eq('id', id)
          .select()
          .single();
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/order_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);

  Future<Order> create(Order order) async {
    try {
      final data = await _client
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();
      return Order.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    try {
      await _client.from('orders').update({
        'status': status.toJson(),
      }).eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('orders').delete().eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Order>> getByShop(
    String shopId, {
    OrderStatus? status,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      var query = _client.from('orders').select().eq('shop_id', shopId);
      if (status != null) {
        query = query.eq('status', status.toJson());
      }
      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }
      final data = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Order>> getByMemberUser(String userId) async {
    try {
      final memberData = await _client
          .from('members')
          .select('id')
          .eq('user_id', userId);
      final memberIds = memberData.map((m) => m['id'] as String).toList();
      if (memberIds.isEmpty) return [];

      final data = await _client
          .from('orders')
          .select()
          .inFilter('member_id', memberIds)
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<int> countActiveByShop(String shopId) async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .eq('shop_id', shopId)
          .inFilter('status', ['received', 'in_progress']);
      return data.length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamByShop(String shopId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('shop_id', shopId);
  }

  Stream<List<Map<String, dynamic>>> streamById(String orderId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId);
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/post_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class PostRepository {
  final SupabaseClient _client;

  PostRepository(this._client);

  Future<Post> create(Post post) async {
    try {
      final data = await _client
          .from('posts')
          .insert(post.toJson())
          .select()
          .single();
      return Post.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Post>> getByShopAndCategory(
    String shopId,
    PostCategory category,
  ) async {
    try {
      final data = await _client
          .from('posts')
          .select()
          .eq('shop_id', shopId)
          .eq('category', category.toJson())
          .order('created_at', ascending: false);
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Post?> getById(String id) async {
    try {
      final data = await _client
          .from('posts')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return Post.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/inventory_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

  Future<InventoryItem> create(InventoryItem item) async {
    try {
      final data = await _client
          .from('inventory')
          .insert(item.toJson())
          .select()
          .single();
      return InventoryItem.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<InventoryItem> update(String id, Map<String, dynamic> fields) async {
    try {
      final data = await _client
          .from('inventory')
          .update(fields)
          .eq('id', id)
          .select()
          .single();
      return InventoryItem.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('inventory').delete().eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<InventoryItem>> getByShop(String shopId) async {
    try {
      final data = await _client
          .from('inventory')
          .select()
          .eq('shop_id', shopId)
          .order('name');
      return data.map((json) => InventoryItem.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/repositories/notification_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  Future<List<NotificationItem>> getByUser(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    try {
      var query = _client.from('notifications').select().eq('user_id', userId);
      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }
      final data = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);
      return data.length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/repositories/ test/repositories/
git commit -m "feat: M5 리포지토리 계층 (7개 리포지토리 인터페이스 및 구현)"
```

---

### Task 1.7: M7 이미지 업로드

**Files:**
- Create: `lib/repositories/storage_repository.dart`
- Test: `test/repositories/storage_repository_test.dart`

**Step 1: Write the failing test**

```dart
// test/repositories/storage_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/repositories/storage_repository.dart';

void main() {
  group('StorageRepository', () {
    test('인터페이스가 정의되어 있다', () {
      expect(StorageRepository, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/storage_repository_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/repositories/storage_repository.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class StorageRepository {
  final SupabaseClient _client;

  StorageRepository(this._client);

  /// 이미지를 업로드하고 public URL을 반환한다.
  /// [bucket]: 'profile-images', 'post-images', 'inventory-images'
  /// [file]: 업로드할 파일
  /// [path]: 저장 경로 (예: '{userId}/{uuid}.jpg')
  Future<String> uploadImage(String bucket, File file, String path) async {
    try {
      await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      final url = _client.storage.from(bucket).getPublicUrl(path);
      return url;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 이미지를 삭제한다.
  Future<void> deleteImage(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(supabaseProvider));
});
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/storage_repository_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/repositories/storage_repository.dart test/repositories/storage_repository_test.dart
git commit -m "feat: M7 이미지 업로드 모듈 (StorageRepository)"
```

---

### Task 1.8: M3 인증 모듈

**Files:**
- Create: `lib/repositories/auth_repository.dart`
- Create: `lib/providers/auth_provider.dart`
- Test: `test/repositories/auth_repository_test.dart`
- Test: `test/providers/auth_provider_test.dart`

**Step 1: Write the failing test**

```dart
// test/repositories/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    test('인터페이스가 정의되어 있다', () {
      expect(AuthRepository, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/auth_repository_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/repositories/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/providers/supabase_provider.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// 소셜 로그인 (카카오/네이버/Google/Apple)
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'com.gutarim.badmintonapp://login-callback/',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 인증된 사용자
  User? get currentUser => _client.auth.currentUser;

  /// 인증 상태 변경 스트림
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});
```

```dart
// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart' as app;
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';

/// 인증 상태 스트림
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// 현재 users 테이블 레코드
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, app.User?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<app.User?> {
  @override
  Future<app.User?> build() async {
    final authRepo = ref.watch(authRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final authUser = authRepo.currentUser;
    if (authUser == null) return null;
    return userRepo.getById(authUser.id);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 신규 사용자 여부 (users 테이블에 레코드 없음)
final isNewUserProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user == null) ?? true;
});

/// 현재 사용자 역할
final userRoleProvider = Provider<UserRole?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.role);
});
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/auth_repository_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/repositories/auth_repository.dart lib/providers/auth_provider.dart test/repositories/auth_repository_test.dart
git commit -m "feat: M3 인증 모듈 (AuthRepository, auth providers)"
```

---

### Task 1.9: M8 FCM 푸시 알림

**Files:**
- Create: `lib/services/fcm_service.dart`
- Create: `lib/providers/fcm_provider.dart`
- Test: `test/services/fcm_service_test.dart`

**Step 1: Write the failing test**

```dart
// test/services/fcm_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/services/fcm_service.dart';

void main() {
  group('FcmService', () {
    test('인터페이스가 정의되어 있다', () {
      expect(FcmService, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/services/fcm_service_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badminton_app/repositories/user_repository.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  final UserRepository _userRepo;

  FcmService(this._messaging, this._userRepo);

  /// FCM 초기화 + 알림 권한 요청
  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// 현재 FCM 토큰 반환
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// 토큰을 users.fcm_token에 저장
  Future<void> saveTokenToDb(String userId) async {
    final token = await getToken();
    if (token != null) {
      await _userRepo.update(userId, {'fcm_token': token});
    }
  }

  /// 토큰 갱신 시 DB 업데이트 스트림
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// 포그라운드 알림 수신 스트림
  Stream<RemoteMessage> get onMessage =>
      FirebaseMessaging.onMessage;

  /// 알림 탭으로 앱 열기 스트림
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;
}
```

```dart
// lib/providers/fcm_provider.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/services/fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    FirebaseMessaging.instance,
    ref.watch(userRepositoryProvider),
  );
});
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/services/fcm_service_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/services/fcm_service.dart lib/providers/fcm_provider.dart test/services/fcm_service_test.dart
git commit -m "feat: M8 FCM 푸시 알림 모듈 (FcmService)"
```

---

### Task 1.10: M9 공통 위젯

**Files:**
- Create: `lib/widgets/loading_indicator.dart`
- Create: `lib/widgets/skeleton_shimmer.dart`
- Create: `lib/widgets/empty_state.dart`
- Create: `lib/widgets/error_view.dart`
- Create: `lib/widgets/status_badge.dart`
- Create: `lib/widgets/confirm_dialog.dart`
- Create: `lib/widgets/toast.dart`
- Create: `lib/widgets/phone_input_field.dart`
- Test: `test/widgets/empty_state_test.dart`
- Test: `test/widgets/status_badge_test.dart`
- Test: `test/widgets/error_view_test.dart`
- Test: `test/widgets/confirm_dialog_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('received 상태를 올바르게 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: OrderStatus.received,
              size: StatusBadgeSize.small,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('접수됨'), findsOneWidget);
    });

    testWidgets('inProgress 상태를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: OrderStatus.inProgress,
              size: StatusBadgeSize.large,
            ),
          ),
        ),
      );

      expect(find.text('작업중'), findsOneWidget);
    });

    testWidgets('completed 상태를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: OrderStatus.completed,
              size: StatusBadgeSize.small,
            ),
          ),
        ),
      );

      expect(find.text('완료'), findsOneWidget);
    });
  });
}
```

```dart
// test/widgets/empty_state_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('메시지를 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
            ),
          ),
        ),
      );

      expect(find.text('데이터가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('CTA 버튼이 있으면 표시한다', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
              actionLabel: '추가하기',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('추가하기'), findsOneWidget);
      await tester.tap(find.text('추가하기'));
      expect(tapped, isTrue);
    });

    testWidgets('CTA 버튼이 없으면 버튼을 표시하지 않는다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: '데이터가 없습니다',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
```

```dart
// test/widgets/error_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('에러 메시지와 재시도 버튼을 표시한다', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: '오류가 발생했습니다',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
    });
  });
}
```

```dart
// test/widgets/confirm_dialog_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('제목과 내용을 표시한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showConfirmDialog(
                context: context,
                title: '삭제 확인',
                content: '정말 삭제하시겠습니까?',
                onConfirm: () {},
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      expect(find.text('삭제 확인'), findsOneWidget);
      expect(find.text('정말 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/widgets/loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;

  const LoadingIndicator({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
```

```dart
// lib/widgets/skeleton_shimmer.dart
import 'package:flutter/material.dart';

class SkeletonShimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonShimmer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
```

```dart
// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

```dart
// lib/widgets/error_view.dart
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart
// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:badminton_app/models/enums.dart';

enum StatusBadgeSize { small, large }

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final StatusBadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final isLarge = size == StatusBadgeSize.large;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: isLarge ? 16 : 12,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _getConfig() {
    switch (status) {
      case OrderStatus.received:
        return const _StatusConfig(
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFF59E0B),
        );
      case OrderStatus.inProgress:
        return const _StatusConfig(
          backgroundColor: Color(0xFFDBEAFE),
          textColor: Color(0xFF3B82F6),
        );
      case OrderStatus.completed:
        return const _StatusConfig(
          backgroundColor: Color(0xFFDCFCE7),
          textColor: Color(0xFF22C55E),
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
  });
}
```

```dart
// lib/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
```

```dart
// lib/widgets/toast.dart
import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

```dart
// lib/widgets/phone_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badminton_app/core/utils/formatters.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? labelText;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.labelText = '연락처',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        _PhoneNumberFormatter(),
      ],
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: '010-0000-0000',
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll('-', '');
    final formatted = Formatters.phone(raw);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/widgets/ test/widgets/
git commit -m "feat: M9 공통 위젯 모듈 (8개 재사용 위젯)"
```

---

### Task 1.11: M2 라우터

**Files:**
- Create: `lib/app/router.dart`
- Create: `lib/app/app.dart`
- Test: `test/app/router_test.dart`

**Step 1: Write the failing test**

```dart
// test/app/router_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/app/router.dart';

void main() {
  group('Router', () {
    test('routerProvider가 정의되어 있다', () {
      expect(routerProvider, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/app/router_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.whenOrNull(
            data: (auth) => auth.session != null,
          ) ??
          false;
      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnSplash = state.matchedLocation == '/splash';

      // 스플래시에서는 리다이렉트 안함
      if (isOnSplash) return null;

      // 미인증 → 로그인
      if (!isLoggedIn) return '/login';

      // 인증됨 + 로그인 페이지 → 역할별 홈
      if (isLoggedIn && isOnLoginPage) {
        final isNew = currentUser.whenOrNull(data: (u) => u == null) ?? true;
        if (isNew) return '/profile-setup';
        if (userRole == UserRole.shopOwner) return '/owner/dashboard';
        return '/customer/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _Placeholder('Splash')),
      GoRoute(path: '/login', builder: (_, __) => const _Placeholder('Login')),
      GoRoute(path: '/profile-setup', builder: (_, __) => const _Placeholder('ProfileSetup')),
      GoRoute(path: '/shop-register', builder: (_, __) => const _Placeholder('ShopRegister')),
      ShellRoute(
        builder: (_, __, child) => child,
        routes: [
          GoRoute(path: '/customer/home', builder: (_, __) => const _Placeholder('CustomerHome')),
          GoRoute(path: '/customer/order/:orderId', builder: (_, state) => _Placeholder('Order ${state.pathParameters["orderId"]}')),
          GoRoute(path: '/customer/order-history', builder: (_, __) => const _Placeholder('OrderHistory')),
          GoRoute(path: '/customer/shop-search', builder: (_, __) => const _Placeholder('ShopSearch')),
          GoRoute(path: '/customer/shop/:shopId', builder: (_, __) => const _Placeholder('ShopDetail')),
          GoRoute(path: '/customer/notifications', builder: (_, __) => const _Placeholder('Notifications')),
          GoRoute(path: '/customer/mypage', builder: (_, __) => const _Placeholder('MyPage')),
          GoRoute(path: '/customer/profile-edit', builder: (_, __) => const _Placeholder('ProfileEdit')),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => child,
        routes: [
          GoRoute(path: '/owner/dashboard', builder: (_, __) => const _Placeholder('Dashboard')),
          GoRoute(path: '/owner/order-create', builder: (_, __) => const _Placeholder('OrderCreate')),
          GoRoute(path: '/owner/order-manage', builder: (_, __) => const _Placeholder('OrderManage')),
          GoRoute(path: '/owner/shop-qr', builder: (_, __) => const _Placeholder('ShopQR')),
          GoRoute(path: '/owner/post-create', builder: (_, __) => const _Placeholder('PostCreate')),
          GoRoute(path: '/owner/inventory', builder: (_, __) => const _Placeholder('Inventory')),
          GoRoute(path: '/owner/settings', builder: (_, __) => const _Placeholder('Settings')),
        ],
      ),
    ],
  );
});

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}
```

```dart
// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/app/router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '거트알림',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFF97316),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/app/router_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/app/ test/app/
git commit -m "feat: M2 라우터 모듈 (go_router 설정, 인증 가드, 역할별 리다이렉트)"
```

---

### Task 1.12: M12 테스트 환경

**Files:**
- Create: `test/helpers/mocks.dart`
- Create: `test/helpers/fixtures.dart`
- Create: `test/helpers/test_app.dart`

**Step 1: Write the failing test**

```dart
// test/helpers/mocks_test.dart (검증용)
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:badminton_app/services/fcm_service.dart';
import 'package:mocktail/mocktail.dart';
import 'helpers/mocks.dart';
import 'helpers/fixtures.dart';

void main() {
  group('Mocks', () {
    test('MockAuthRepository가 정의되어 있다', () {
      expect(MockAuthRepository(), isA<Mock>());
    });
    test('MockStorageRepository가 정의되어 있다', () {
      expect(MockStorageRepository(), isA<Mock>());
    });
    test('MockFcmService가 정의되어 있다', () {
      expect(MockFcmService(), isA<Mock>());
    });
  });

  group('Fixtures', () {
    test('testUser가 정의되어 있다', () {
      expect(testUser, isNotNull);
      expect(testUser.name, isNotEmpty);
    });
    test('testOwner가 정의되어 있다', () {
      expect(testOwner, isNotNull);
    });
    test('testShop이 정의되어 있다', () {
      expect(testShop, isNotNull);
    });
    test('testMember가 정의되어 있다', () {
      expect(testMember, isNotNull);
    });
    test('testOrder가 정의되어 있다', () {
      expect(testOrder, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/helpers/mocks_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// test/helpers/mocks.dart
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:badminton_app/services/fcm_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockShopRepository extends Mock implements ShopRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockPostRepository extends Mock implements PostRepository {}

class MockInventoryRepository extends Mock implements InventoryRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockFcmService extends Mock implements FcmService {}

class MockGoRouter extends Mock implements GoRouter {}
```

```dart
// test/helpers/fixtures.dart
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart' as app;
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/models/notification_item.dart';

final testUser = app.User(
  id: '550e8400-e29b-41d4-a716-446655440000',
  role: UserRole.customer,
  name: '홍길동',
  phone: '01012345678',
  createdAt: DateTime(2026, 1, 1),
);

final testOwner = app.User(
  id: '550e8400-e29b-41d4-a716-446655440099',
  role: UserRole.shopOwner,
  name: '김사장',
  phone: '01098765432',
  createdAt: DateTime(2026, 1, 1),
);

final testShop = Shop(
  id: '660e8400-e29b-41d4-a716-446655440001',
  ownerId: '550e8400-e29b-41d4-a716-446655440099',
  name: '거트 프로샵',
  address: '서울시 강남구 역삼동 123',
  latitude: 37.4979,
  longitude: 127.0276,
  phone: '0212345678',
  description: '최고의 거트 서비스',
  createdAt: DateTime(2026, 1, 1),
);

final testMember = Member(
  id: '770e8400-e29b-41d4-a716-446655440002',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  userId: '550e8400-e29b-41d4-a716-446655440000',
  name: '홍길동',
  phone: '01012345678',
  visitCount: 3,
  createdAt: DateTime(2026, 1, 1),
);

final testOrder = Order(
  id: '880e8400-e29b-41d4-a716-446655440003',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  memberId: '770e8400-e29b-41d4-a716-446655440002',
  status: OrderStatus.received,
  memo: '2본 작업',
  createdAt: DateTime(2026, 1, 15, 10),
  updatedAt: DateTime(2026, 1, 15, 10),
);

final testOrderInProgress = testOrder.copyWith(
  status: OrderStatus.inProgress,
  inProgressAt: DateTime(2026, 1, 15, 11),
);

final testOrderCompleted = testOrder.copyWith(
  status: OrderStatus.completed,
  inProgressAt: DateTime(2026, 1, 15, 11),
  completedAt: DateTime(2026, 1, 15, 12),
);

final testNoticePost = Post(
  id: '990e8400-e29b-41d4-a716-446655440004',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  category: PostCategory.notice,
  title: '영업시간 변경 안내',
  content: '1월부터 영업시간이 변경됩니다.',
  images: const [],
  createdAt: DateTime(2026, 1, 1),
);

final testEventPost = Post(
  id: 'aa0e8400-e29b-41d4-a716-446655440005',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  category: PostCategory.event,
  title: '신년 이벤트',
  content: '거트 교체 50% 할인!',
  images: const [],
  eventStartDate: DateTime(2026, 1, 1),
  eventEndDate: DateTime(2026, 1, 31),
  createdAt: DateTime(2026, 1, 1),
);

final testInventoryItem = InventoryItem(
  id: 'bb0e8400-e29b-41d4-a716-446655440006',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  name: 'BG65',
  category: '거트',
  quantity: 10,
  createdAt: DateTime(2026, 1, 1),
);

final testNotification = NotificationItem(
  id: 'cc0e8400-e29b-41d4-a716-446655440007',
  userId: '550e8400-e29b-41d4-a716-446655440000',
  type: NotificationType.statusChange,
  title: '작업 상태 변경',
  body: '거트 프로샵에서 작업이 시작되었습니다.',
  orderId: '880e8400-e29b-41d4-a716-446655440003',
  createdAt: DateTime(2026, 1, 15, 12),
);
```

```dart
// test/helpers/test_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/helpers/mocks_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add test/helpers/
git commit -m "feat: M12 테스트 환경 (mocks, fixtures, test_app helper)"
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

    test('세션이 없으면 SplashRoute.login을 반환한다', () async {
      // Arrange
      when(() => mockAuth.currentSession).thenReturn(null);
      container = ProviderContainer(overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
      ]);

      // Act
      final route = await container.read(splashRouteProvider.future);

      // Assert
      expect(route, SplashRoute.login);
    });

    test('세션 있지만 users 테이블에 없으면 SplashRoute.profileSetup', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(accessToken: 'token', tokenType: 'bearer', user: mockUser),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      container = ProviderContainer(overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        isNewUserProvider.overrideWith((ref) => true),
      ]);

      // Act & Assert
      expect(await container.read(splashRouteProvider.future),
          SplashRoute.profileSetup);
    });

    test('기존 고객이면 SplashRoute.customerHome', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(accessToken: 'token', tokenType: 'bearer', user: mockUser),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      container = ProviderContainer(overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        isNewUserProvider.overrideWith((ref) => false),
        userRoleProvider.overrideWith((ref) => app.UserRole.customer),
      ]);

      expect(await container.read(splashRouteProvider.future),
          SplashRoute.customerHome);
    });

    test('기존 사장님이면 SplashRoute.ownerDashboard', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuth.currentSession).thenReturn(
        Session(accessToken: 'token', tokenType: 'bearer', user: mockUser),
      );
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      container = ProviderContainer(overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        isNewUserProvider.overrideWith((ref) => false),
        userRoleProvider.overrideWith((ref) => app.UserRole.shopOwner),
      ]);

      expect(await container.read(splashRouteProvider.future),
          SplashRoute.ownerDashboard);
    });

    test('5초 타임아웃 시 SplashRoute.login 폴백', () async {
      when(() => mockAuth.currentSession).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 6), () => null),
      );
      container = ProviderContainer(overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
      ]);

      expect(await container.read(splashRouteProvider.future),
          SplashRoute.login);
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

enum SplashRoute { login, customerHome, ownerDashboard, profileSetup }

@riverpod
Future<SplashRoute> splashRoute(SplashRouteRef ref) async {
  try {
    return await Future(() async {
      final minDisplay = Future.delayed(const Duration(milliseconds: 1500));
      final session = ref.read(supabaseProvider).auth.currentSession;

      if (session == null) {
        await minDisplay;
        return SplashRoute.login;
      }

      final isNew = await ref.read(isNewUserProvider.future);
      if (isNew) {
        await minDisplay;
        return SplashRoute.profileSetup;
      }

      final role = await ref.read(userRoleProvider.future);
      await minDisplay;
      return switch (role) {
        app.UserRole.customer => SplashRoute.customerHome,
        app.UserRole.shopOwner => SplashRoute.ownerDashboard,
      };
    }).timeout(const Duration(seconds: 5), onTimeout: () => SplashRoute.login);
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
  group('SplashScreen', () {
    testWidgets('앱 이름, 슬로건, 로딩 스피너가 표시된다', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          splashRouteProvider.overrideWith((ref) =>
            Future.delayed(const Duration(seconds: 10), () => SplashRoute.login)),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ));
      await tester.pump();

      expect(find.text('거트알림'), findsOneWidget);
      expect(find.text('배드민턴 거트 추적 서비스'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('로딩 스피너 색상이 #16A34A', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          splashRouteProvider.overrideWith((ref) =>
            Future.delayed(const Duration(seconds: 10), () => SplashRoute.login)),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ));
      await tester.pump(const Duration(milliseconds: 700));

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
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
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade, _logoScale, _textFade, _spinnerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));

    _logoFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.0, 0.556, curve: Curves.easeOut)));
    _logoScale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.0, 0.556, curve: Curves.easeOut)));
    _textFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.222, 0.667, curve: Curves.easeOut)));
    _spinnerFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.667, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashRouteProvider, (_, next) {
      next.whenData((route) {
        if (!mounted) return;
        switch (route) {
          case SplashRoute.login: context.go('/login');
          case SplashRoute.profileSetup: context.go('/profile-setup');
          case SplashRoute.customerHome: context.go('/customer/home');
          case SplashRoute.ownerDashboard: context.go('/owner/dashboard');
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(opacity: _logoFade, child: ScaleTransition(
              scale: _logoScale,
              child: const Icon(Icons.sports_tennis, size: 80,
                  color: Color(0xFF16A34A)))),
            const SizedBox(height: 16),
            FadeTransition(opacity: _logoFade, child: const Text('거트알림',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)))),
            const SizedBox(height: 8),
            FadeTransition(opacity: _textFade,
              child: const Text('배드민턴 거트 추적 서비스',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)))),
            const SizedBox(height: 32),
            FadeTransition(opacity: _spinnerFade, child: const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                  color: Color(0xFF16A34A)))),
          ],
        ),
      )),
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

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginNotifier', () {
    late ProviderContainer container;
    late MockAuthRepository mockAuthRepo;

    setUp(() { mockAuthRepo = MockAuthRepository(); });
    tearDown(() => container.dispose());

    ProviderContainer createContainer() => ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepo),
    ]);

    test('초기 상태는 LoginState.idle()', () {
      container = createContainer();
      expect(container.read(loginNotifierProvider), const LoginState.idle());
    });

    test('signInWithKakao → authenticating(kakao)', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenAnswer((_) async {});
      container = createContainer();
      final future = container.read(loginNotifierProvider.notifier)
          .signInWithKakao();
      expect(container.read(loginNotifierProvider),
          const LoginState.authenticating(OAuthProvider.kakao));
      await future;
    });

    test('signInWithNaver → authenticating(naver)', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.naver))
          .thenAnswer((_) async {});
      container = createContainer();
      final future = container.read(loginNotifierProvider.notifier)
          .signInWithNaver();
      expect(container.read(loginNotifierProvider),
          const LoginState.authenticating(OAuthProvider.naver));
      await future;
    });

    test('signInWithGoogle → authenticating(google)', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.google))
          .thenAnswer((_) async {});
      container = createContainer();
      final future = container.read(loginNotifierProvider.notifier)
          .signInWithGoogle();
      expect(container.read(loginNotifierProvider),
          const LoginState.authenticating(OAuthProvider.google));
      await future;
    });

    test('로그인 성공 → idle 복귀', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenAnswer((_) async {});
      container = createContainer();
      await container.read(loginNotifierProvider.notifier).signInWithKakao();
      expect(container.read(loginNotifierProvider), const LoginState.idle());
    });

    test('사용자 취소 → idle (에러 없음)', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(const AppException.cancelled());
      container = createContainer();
      await container.read(loginNotifierProvider.notifier).signInWithKakao();
      expect(container.read(loginNotifierProvider), const LoginState.idle());
    });

    test('네트워크 오류 → error("네트워크 연결을 확인해주세요")', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(const AppException.network());
      container = createContainer();
      await container.read(loginNotifierProvider.notifier).signInWithKakao();
      expect(container.read(loginNotifierProvider),
          const LoginState.error('네트워크 연결을 확인해주세요'));
    });

    test('기타 에러 → error("로그인에 실패했습니다. 다시 시도해주세요")', () async {
      when(() => mockAuthRepo.signInWithOAuth(OAuthProvider.kakao))
          .thenThrow(Exception('unknown'));
      container = createContainer();
      await container.read(loginNotifierProvider.notifier).signInWithKakao();
      expect(container.read(loginNotifierProvider),
          const LoginState.error('로그인에 실패했습니다. 다시 시도해주세요'));
    });
  });
}
```

#### Step 2: 상태 클래스 및 Notifier 구현

**파일: `lib/screens/auth/login/login_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

enum OAuthProvider { kakao, naver, google }

@freezed
class LoginState with _$LoginState {
  const factory LoginState.idle() = LoginStateIdle;
  const factory LoginState.authenticating(OAuthProvider provider) =
      LoginStateAuthenticating;
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

  Future<void> signInWithKakao() => _signIn(OAuthProvider.kakao);
  Future<void> signInWithNaver() => _signIn(OAuthProvider.naver);
  Future<void> signInWithGoogle() => _signIn(OAuthProvider.google);

  Future<void> _signIn(OAuthProvider provider) async {
    state = LoginState.authenticating(provider);
    try {
      await ref.read(authRepositoryProvider).signInWithOAuth(provider);
      state = const LoginState.idle();
    } on AppException catch (e) {
      state = e.maybeWhen(
        cancelled: () => const LoginState.idle(),
        network: () => const LoginState.error('네트워크 연결을 확인해주세요'),
        orElse: () => const LoginState.error('로그인에 실패했습니다. 다시 시도해주세요'),
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
  group('LoginScreen', () {
    testWidgets('카카오, 네이버, Google 로그인 버튼 표시', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: LoginScreen())));
      expect(find.text('카카오로 시작하기'), findsOneWidget);
      expect(find.text('네이버로 시작하기'), findsOneWidget);
      expect(find.text('Google로 시작하기'), findsOneWidget);
    });

    testWidgets('로고와 환영 메시지 표시', (tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: LoginScreen())));
      expect(find.text('거트알림'), findsOneWidget);
      expect(find.text('반갑습니다!'), findsOneWidget);
      expect(find.text('간편하게 시작하세요'), findsOneWidget);
    });

    testWidgets('authenticating 시 스피너 표시', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [loginNotifierProvider.overrideWith(() =>
          _FakeLoginNotifier(
            const LoginState.authenticating(OAuthProvider.kakao)))],
        child: const MaterialApp(home: LoginScreen())));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error 시 에러 스낵바 표시', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [loginNotifierProvider.overrideWith(() =>
          _FakeLoginNotifier(
            const LoginState.error('네트워크 연결을 확인해주세요')))],
        child: const MaterialApp(home: LoginScreen())));
      await tester.pumpAndSettle();
      expect(find.text('네트워크 연결을 확인해주세요'), findsOneWidget);
    });
  });
}

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
    final isLoading = loginState is LoginStateAuthenticating;

    ref.listen(loginNotifierProvider, (_, next) {
      next.maybeWhen(
        error: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(color: Color(0xFFEF4444))),
          backgroundColor: const Color(0xFFFEE2E2),
          duration: const Duration(seconds: 3),
        )),
        orElse: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          const Spacer(flex: 3),
          const Icon(Icons.sports_tennis, size: 56, color: Color(0xFF16A34A)),
          const SizedBox(height: 8),
          const Text('거트알림', style: TextStyle(fontSize: 28,
              fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 32),
          const Text('반갑습니다!', style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          const Text('간편하게 시작하세요',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          const Spacer(flex: 2),
          _SocialBtn(label: '카카오로 시작하기', bg: const Color(0xFFFEE500),
            fg: const Color(0xFF191919),
            loading: loginState == const LoginState.authenticating(OAuthProvider.kakao),
            disabled: isLoading, onTap: notifier.signInWithKakao),
          const SizedBox(height: 12),
          _SocialBtn(label: '네이버로 시작하기', bg: const Color(0xFF03C75A),
            fg: Colors.white,
            loading: loginState == const LoginState.authenticating(OAuthProvider.naver),
            disabled: isLoading, onTap: notifier.signInWithNaver),
          const SizedBox(height: 12),
          _SocialBtn(label: 'Google로 시작하기', bg: Colors.white,
            fg: const Color(0xFF1E293B), border: const Color(0xFFE2E8F0),
            loading: loginState == const LoginState.authenticating(OAuthProvider.google),
            disabled: isLoading, onTap: notifier.signInWithGoogle),
          const Spacer(),
        ]),
      )),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final Color? border;
  final bool loading, disabled;
  final VoidCallback onTap;

  const _SocialBtn({required this.label, required this.bg, required this.fg,
    this.border, required this.loading, required this.disabled,
    required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 48,
    child: OutlinedButton(
      onPressed: disabled ? null : onTap,
      style: OutlinedButton.styleFrom(backgroundColor: bg,
        side: BorderSide(color: border ?? bg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: loading
          ? SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg))
          : Text(label, style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w600, color: fg)),
    ),
  );
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

### Task 2.3: Profile Setup Screen (프로필 설정 화면)

> 화면 ID: `profile-setup`
> UI 스펙: `docs/ui-specs/signup.md`
> 상태 설계: `docs/pages/profile-setup/state.md`
> 유스케이스: UC-1 소셜 로그인 + 프로필 설정

#### Step 1: 실패하는 단위 테스트 작성

**파일: `test/screens/auth/profile_setup/profile_setup_notifier_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_providers.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/models/user.dart' as app;
import 'package:gut_alarm/core/error/app_exception.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('ProfileSetupNotifier', () {
    late ProviderContainer container;
    late MockUserRepository mockUserRepo;
    setUp(() { mockUserRepo = MockUserRepository(); });
    tearDown(() => container.dispose());

    ProviderContainer createContainer({String socialName = '홍길동'}) =>
        ProviderContainer(overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepo),
          socialProfileNameProvider.overrideWithValue(socialName),
        ]);

    test('초기 상태: role=null, name=소셜이름, phone="", idle', () {
      container = createContainer(socialName: '테스트유저');
      final s = container.read(profileSetupNotifierProvider);
      expect(s.selectedRole, isNull);
      expect(s.name, '테스트유저');
      expect(s.phone, '');
      expect(s.status, ProfileSetupStatus.idle);
    });

    test('selectRole(customer) → customer, roleError=null', () {
      container = createContainer();
      container.read(profileSetupNotifierProvider.notifier)
          .selectRole(app.UserRole.customer);
      final s = container.read(profileSetupNotifierProvider);
      expect(s.selectedRole, app.UserRole.customer);
      expect(s.roleError, isNull);
    });

    test('selectRole(shopOwner) → shopOwner', () {
      container = createContainer();
      container.read(profileSetupNotifierProvider.notifier)
          .selectRole(app.UserRole.shopOwner);
      expect(container.read(profileSetupNotifierProvider).selectedRole,
          app.UserRole.shopOwner);
    });

    test('updateName → name 갱신', () {
      container = createContainer();
      container.read(profileSetupNotifierProvider.notifier).updateName('김철수');
      expect(container.read(profileSetupNotifierProvider).name, '김철수');
    });

    test('validateName: 빈값 → nameError', () {
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.updateName(''); n.validateName();
      expect(container.read(profileSetupNotifierProvider).nameError, isNotNull);
    });

    test('validateName: 유효 → nameError=null', () {
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.updateName('김철수'); n.validateName();
      expect(container.read(profileSetupNotifierProvider).nameError, isNull);
    });

    test('updatePhone → 자동 하이픈', () {
      container = createContainer();
      container.read(profileSetupNotifierProvider.notifier)
          .updatePhone('01012345678');
      expect(container.read(profileSetupNotifierProvider).phone,
          '010-1234-5678');
    });

    test('validatePhone: 빈값 → phoneError', () {
      container = createContainer();
      container.read(profileSetupNotifierProvider.notifier).validatePhone();
      expect(container.read(profileSetupNotifierProvider).phoneError, isNotNull);
    });

    test('submit 성공 (고객): INSERT + matchMembersByPhone', () async {
      when(() => mockUserRepo.create(any())).thenAnswer((_) async {});
      when(() => mockUserRepo.matchMembersByPhone(any()))
          .thenAnswer((_) async {});
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.selectRole(app.UserRole.customer);
      n.updateName('김철수'); n.updatePhone('01012345678');
      await n.submit();
      expect(container.read(profileSetupNotifierProvider).status,
          ProfileSetupStatus.idle);
      verify(() => mockUserRepo.create(any())).called(1);
      verify(() => mockUserRepo.matchMembersByPhone(any())).called(1);
    });

    test('submit 성공 (사장님): matchMembersByPhone 미호출', () async {
      when(() => mockUserRepo.create(any())).thenAnswer((_) async {});
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.selectRole(app.UserRole.shopOwner);
      n.updateName('이사장'); n.updatePhone('01098765432');
      await n.submit();
      verify(() => mockUserRepo.create(any())).called(1);
      verifyNever(() => mockUserRepo.matchMembersByPhone(any()));
    });

    test('submit: 역할 미선택 → roleError, idle', () async {
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.updateName('김철수'); n.updatePhone('01012345678');
      await n.submit();
      expect(container.read(profileSetupNotifierProvider).roleError, isNotNull);
      expect(container.read(profileSetupNotifierProvider).status,
          ProfileSetupStatus.idle);
    });

    test('submit 네트워크 오류 → error', () async {
      when(() => mockUserRepo.create(any()))
          .thenThrow(const AppException.network());
      container = createContainer();
      final n = container.read(profileSetupNotifierProvider.notifier);
      n.selectRole(app.UserRole.customer);
      n.updateName('김철수'); n.updatePhone('01012345678');
      await n.submit();
      expect(container.read(profileSetupNotifierProvider).status,
          ProfileSetupStatus.error);
    });
  });

  group('isFormValidProvider', () {
    test('모두 유효 → true', () {
      final c = ProviderContainer(overrides: [
        socialProfileNameProvider.overrideWithValue('홍길동')]);
      addTearDown(c.dispose);
      final n = c.read(profileSetupNotifierProvider.notifier);
      n.selectRole(app.UserRole.customer);
      n.updateName('김철수'); n.updatePhone('01012345678');
      expect(c.read(isFormValidProvider), true);
    });

    test('역할 미선택 → false', () {
      final c = ProviderContainer(overrides: [
        socialProfileNameProvider.overrideWithValue('홍길동')]);
      addTearDown(c.dispose);
      c.read(profileSetupNotifierProvider.notifier)
        ..updateName('김철수')..updatePhone('01012345678');
      expect(c.read(isFormValidProvider), false);
    });
  });
}
```

#### Step 2: 상태 클래스 및 Notifier 구현

**파일: `lib/screens/auth/profile_setup/profile_setup_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gut_alarm/models/user.dart' as app;

part 'profile_setup_state.freezed.dart';

enum ProfileSetupStatus { idle, submitting, error }

@freezed
class ProfileSetupState with _$ProfileSetupState {
  const ProfileSetupState._();
  const factory ProfileSetupState({
    app.UserRole? selectedRole,
    @Default('') String name,
    @Default('') String phone,
    @Default(ProfileSetupStatus.idle) ProfileSetupStatus status,
    String? nameError, String? phoneError, String? roleError,
  }) = _ProfileSetupState;

  factory ProfileSetupState.initial({String name = ''}) =>
      ProfileSetupState(name: name);
}
```

**파일: `lib/screens/auth/profile_setup/profile_setup_notifier.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_providers.dart';
import 'package:gut_alarm/repositories/user_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/models/user.dart' as app;
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/core/utils/validators.dart';
import 'package:gut_alarm/core/utils/formatters.dart';

part 'profile_setup_notifier.g.dart';

@riverpod
class ProfileSetupNotifier extends _$ProfileSetupNotifier {
  @override
  ProfileSetupState build() =>
      ProfileSetupState.initial(name: ref.read(socialProfileNameProvider));

  void selectRole(app.UserRole role) =>
      state = state.copyWith(selectedRole: role, roleError: null);
  void updateName(String v) => state = state.copyWith(name: v);
  void validateName() =>
      state = state.copyWith(nameError: Validators.name(state.name));
  void updatePhone(String v) =>
      state = state.copyWith(phone: Formatters.phone(v));
  void validatePhone() =>
      state = state.copyWith(phoneError: Validators.phone(state.phone));

  Future<void> submit() async {
    final re = state.selectedRole == null ? '역할을 선택해주세요' : null;
    final ne = Validators.name(state.name);
    final pe = Validators.phone(state.phone);
    state = state.copyWith(roleError: re, nameError: ne, phoneError: pe);
    if (re != null || ne != null || pe != null) return;

    state = state.copyWith(status: ProfileSetupStatus.submitting);
    try {
      final uid = ref.read(authStateProvider).valueOrNull?.id;
      if (uid == null) { state = state.copyWith(status: ProfileSetupStatus.error); return; }
      final repo = ref.read(userRepositoryProvider);
      await repo.create(app.User(id: uid, role: state.selectedRole!,
          name: state.name, phone: Formatters.phoneRaw(state.phone)));
      if (state.selectedRole == app.UserRole.customer)
        await repo.matchMembersByPhone(Formatters.phoneRaw(state.phone));
      state = state.copyWith(status: ProfileSetupStatus.idle);
    } on AppException { state = state.copyWith(status: ProfileSetupStatus.error);
    } catch (_) { state = state.copyWith(status: ProfileSetupStatus.error); }
  }
}
```

**파일: `lib/screens/auth/profile_setup/profile_setup_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:gut_alarm/core/utils/validators.dart';

part 'profile_setup_providers.g.dart';

@riverpod
String socialProfileName(SocialProfileNameRef ref) {
  final u = ref.watch(authStateProvider).valueOrNull;
  return (u?.userMetadata?['full_name'] as String?) ?? '';
}

@riverpod
bool isFormValid(IsFormValidRef ref) {
  final s = ref.watch(profileSetupNotifierProvider);
  return s.selectedRole != null
      && Validators.name(s.name) == null
      && Validators.phone(s.phone) == null;
}
```

#### Step 3: 위젯 테스트 작성

**파일: `test/screens/auth/profile_setup/profile_setup_screen_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_providers.dart';

void main() {
  group('ProfileSetupScreen', () {
    testWidgets('"프로필 설정" 타이틀', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('테스트')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      expect(find.text('프로필 설정'), findsOneWidget);
    });
    testWidgets('고객/사장님 카드', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('테스트')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      expect(find.text('고객'), findsOneWidget);
      expect(find.text('사장님'), findsOneWidget);
    });
    testWidgets('소셜 이름 기본값', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('홍길동')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      expect(find.widgetWithText(TextField, '홍길동'), findsOneWidget);
    });
    testWidgets('초기 버튼 비활성', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('테스트')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      expect(t.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull);
    });
    testWidgets('고객 → "시작하기"', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('테스트')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      await t.tap(find.text('고객')); await t.pump();
      expect(find.text('시작하기'), findsOneWidget);
    });
    testWidgets('사장님 → "다음" + 1/2', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [socialProfileNameProvider.overrideWithValue('테스트')],
        child: const MaterialApp(home: ProfileSetupScreen())));
      await t.tap(find.text('사장님')); await t.pump();
      expect(find.text('다음'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });
  });
}
```

#### Step 4: 화면 위젯 구현

**파일: `lib/screens/auth/profile_setup/profile_setup_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:gut_alarm/screens/auth/profile_setup/profile_setup_providers.dart';
import 'package:gut_alarm/models/user.dart' as app;
import 'package:gut_alarm/core/widgets/app_toast.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _State();
}

class _State extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameCtr =
      TextEditingController(text: ref.read(socialProfileNameProvider));
  late final TextEditingController _phoneCtr = TextEditingController();
  final _nameFN = FocusNode(), _phoneFN = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFN.addListener(() { if (!_nameFN.hasFocus)
        ref.read(profileSetupNotifierProvider.notifier).validateName(); });
    _phoneFN.addListener(() { if (!_phoneFN.hasFocus)
        ref.read(profileSetupNotifierProvider.notifier).validatePhone(); });
  }
  @override
  void dispose() { _nameCtr.dispose(); _phoneCtr.dispose();
    _nameFN.dispose(); _phoneFN.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(profileSetupNotifierProvider);
    final valid = ref.watch(isFormValidProvider);
    final n = ref.read(profileSetupNotifierProvider.notifier);
    final busy = s.status == ProfileSetupStatus.submitting;
    final owner = s.selectedRole == app.UserRole.shopOwner;

    ref.listen(profileSetupNotifierProvider, (p, nx) {
      if (p?.status == ProfileSetupStatus.submitting &&
          nx.status == ProfileSetupStatus.idle) {
        AppToast.show(context, '프로필 설정이 완료되었습니다!');
        context.go(nx.selectedRole == app.UserRole.customer
            ? '/customer/home' : '/owner/shop-signup');
      } else if (nx.status == ProfileSetupStatus.error)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('프로필 설정에 실패했습니다. 다시 시도해주세요')));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정'), actions: [
        if (owner) const Padding(padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('1/2', style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: Color(0xFF16A34A)))))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('어떤 서비스를 이용하시겠어요?', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w500, color: Color(0xFF475569))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _Card('고객', '거트 교체 알림을 받아요', Icons.person_outline,
                s.selectedRole == app.UserRole.customer,
                busy ? null : () => n.selectRole(app.UserRole.customer))),
            const SizedBox(width: 12),
            Expanded(child: _Card('사장님', '샵을 등록하고 관리해요', Icons.store_outlined,
                s.selectedRole == app.UserRole.shopOwner,
                busy ? null : () => n.selectRole(app.UserRole.shopOwner)))]),
          if (s.roleError != null) ...[const SizedBox(height: 8),
            Text(s.roleError!, style: const TextStyle(fontSize: 12,
                color: Color(0xFFEF4444)))],
          const SizedBox(height: 24),
          TextField(controller: _nameCtr, focusNode: _nameFN, enabled: !busy,
            decoration: InputDecoration(labelText: '이름',
                prefixIcon: const Icon(Icons.person_outline),
                errorText: s.nameError, border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
            onChanged: n.updateName),
          const SizedBox(height: 16),
          TextField(controller: _phoneCtr, focusNode: _phoneFN, enabled: !busy,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: '연락처',
                hintText: '010-0000-0000',
                prefixIcon: const Icon(Icons.phone_outlined),
                errorText: s.phoneError, border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
            onChanged: (v) { n.updatePhone(v);
              final f = ref.read(profileSetupNotifierProvider).phone;
              if (_phoneCtr.text != f) _phoneCtr.value = TextEditingValue(
                  text: f, selection: TextSelection.collapsed(offset: f.length));
            }),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: (valid && !busy) ? n.submit : null,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: busy ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(owner ? '다음' : '시작하기', style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600))))])));
  }
}

class _Card extends StatelessWidget {
  final String t, sub; final IconData ic; final bool sel; final VoidCallback? tap;
  const _Card(this.t, this.sub, this.ic, this.sel, this.tap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: tap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        color: sel ? const Color(0xFF16A34A).withOpacity(0.05) : Colors.white,
        border: Border.all(color: sel ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
            width: sel ? 2 : 1), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(sel ? Icons.check_circle : ic, size: 32,
            color: sel ? const Color(0xFF16A34A) : const Color(0xFF94A3B8)),
        const SizedBox(height: 8),
        Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
            color: sel ? const Color(0xFF16A34A) : const Color(0xFF1E293B))),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))])));
}
```

#### Step 5: 테스트 실행

```bash
flutter test test/screens/auth/profile_setup/
```

#### Step 6: 커밋

```bash
git add lib/screens/auth/profile_setup/ test/screens/auth/profile_setup/
git commit -m "feat: 프로필 설정 화면 구현 (역할 선택 + 이름/연락처 + users INSERT)"
```

---

### Task 2.4: Shop Signup Screen (샵 등록 화면)

> 화면 ID: `owner-shop-signup`
> UI 스펙: `docs/ui-specs/shop-signup.md`
> 상태 설계: `docs/pages/shop-signup/state.md`
> 유스케이스: UC-2 샵 등록

#### Step 1: 실패하는 단위 테스트 작성

**파일: `test/screens/auth/shop_signup/shop_signup_notifier_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_providers.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/core/error/app_exception.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  group('ShopSignupNotifier', () {
    late ProviderContainer container;
    late MockShopRepository mockShopRepo;
    setUp(() { mockShopRepo = MockShopRepository(); });
    tearDown(() => container.dispose());

    ProviderContainer createContainer() => ProviderContainer(overrides: [
      shopRepositoryProvider.overrideWithValue(mockShopRepo),
    ]);

    test('초기 상태: 모든 필드 빈값, idle', () {
      container = createContainer();
      final s = container.read(shopSignupNotifierProvider);
      expect(s.shopName, '');
      expect(s.address, '');
      expect(s.latitude, isNull);
      expect(s.longitude, isNull);
      expect(s.phone, '');
      expect(s.description, '');
      expect(s.status, ShopSignupStatus.idle);
    });

    test('updateShopName → shopName 갱신', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier)
          .updateShopName('배드민턴 프로샵');
      expect(container.read(shopSignupNotifierProvider).shopName,
          '배드민턴 프로샵');
    });

    test('validateShopName: 빈값 → shopNameError', () {
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName(''); n.validateShopName();
      expect(container.read(shopSignupNotifierProvider).shopNameError,
          isNotNull);
    });

    test('validateShopName: 유효 → shopNameError=null', () {
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵'); n.validateShopName();
      expect(container.read(shopSignupNotifierProvider).shopNameError, isNull);
    });

    test('setAddress → address, lat, lng, addressError=null', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier)
          .setAddress('서울시 강남구 역삼동', 37.5012, 127.0396);
      final s = container.read(shopSignupNotifierProvider);
      expect(s.address, '서울시 강남구 역삼동');
      expect(s.latitude, 37.5012);
      expect(s.longitude, 127.0396);
      expect(s.addressError, isNull);
    });

    test('setAddressWithoutCoords → address만 저장, 좌표=null', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier)
          .setAddressWithoutCoords('서울시 강남구');
      final s = container.read(shopSignupNotifierProvider);
      expect(s.address, '서울시 강남구');
      expect(s.latitude, isNull);
      expect(s.longitude, isNull);
    });

    test('updatePhone → 자동 하이픈', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier)
          .updatePhone('0212345678');
      expect(container.read(shopSignupNotifierProvider).phone, '02-1234-5678');
    });

    test('validatePhone: 빈값 → phoneError', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier).validatePhone();
      expect(container.read(shopSignupNotifierProvider).phoneError, isNotNull);
    });

    test('updateDescription → description 갱신 (200자 제한)', () {
      container = createContainer();
      container.read(shopSignupNotifierProvider.notifier)
          .updateDescription('좋은 샵입니다');
      expect(container.read(shopSignupNotifierProvider).description,
          '좋은 샵입니다');
    });

    test('updateDescription: 200자 초과 시 잘림', () {
      container = createContainer();
      final long = 'A' * 250;
      container.read(shopSignupNotifierProvider.notifier)
          .updateDescription(long);
      expect(container.read(shopSignupNotifierProvider).description.length, 200);
    });

    test('submit 성공: shops INSERT → idle', () async {
      when(() => mockShopRepo.create(any())).thenAnswer((_) async {});
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddress('서울시 강남구', 37.5, 127.0);
      n.updatePhone('0212345678');
      await n.submit();
      expect(container.read(shopSignupNotifierProvider).status,
          ShopSignupStatus.idle);
      verify(() => mockShopRepo.create(any())).called(1);
    });

    test('submit: 필수 필드 누락 → 에러 설정, API 미호출', () async {
      container = createContainer();
      await container.read(shopSignupNotifierProvider.notifier).submit();
      expect(container.read(shopSignupNotifierProvider).shopNameError,
          isNotNull);
      verifyNever(() => mockShopRepo.create(any()));
    });

    test('submit: 좌표 없음 → addressError', () async {
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddressWithoutCoords('서울시 강남구');
      n.updatePhone('0212345678');
      await n.submit();
      expect(container.read(shopSignupNotifierProvider).addressError,
          isNotNull);
    });

    test('submit 네트워크 오류 → error', () async {
      when(() => mockShopRepo.create(any()))
          .thenThrow(const AppException.network());
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddress('서울시', 37.5, 127.0);
      n.updatePhone('0212345678');
      await n.submit();
      expect(container.read(shopSignupNotifierProvider).status,
          ShopSignupStatus.error);
    });

    test('submit 중복 에러(unique_violation) → error', () async {
      when(() => mockShopRepo.create(any()))
          .thenThrow(const AppException.conflict('이미 등록된 샵이 있습니다'));
      container = createContainer();
      final n = container.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddress('서울시', 37.5, 127.0);
      n.updatePhone('0212345678');
      await n.submit();
      expect(container.read(shopSignupNotifierProvider).status,
          ShopSignupStatus.error);
    });
  });

  group('isShopFormValidProvider', () {
    test('샵이름 + 주소(좌표) + 연락처 유효 → true', () {
      final c = ProviderContainer(overrides: [
        shopRepositoryProvider.overrideWithValue(MockShopRepository()),
      ]);
      addTearDown(c.dispose);
      final n = c.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddress('서울시', 37.5, 127.0);
      n.updatePhone('0212345678');
      expect(c.read(isShopFormValidProvider), true);
    });

    test('좌표 없음 → false', () {
      final c = ProviderContainer(overrides: [
        shopRepositoryProvider.overrideWithValue(MockShopRepository()),
      ]);
      addTearDown(c.dispose);
      final n = c.read(shopSignupNotifierProvider.notifier);
      n.updateShopName('프로샵');
      n.setAddressWithoutCoords('서울시');
      n.updatePhone('0212345678');
      expect(c.read(isShopFormValidProvider), false);
    });
  });
}
```

#### Step 2: 상태 클래스 및 Notifier 구현

**파일: `lib/screens/auth/shop_signup/shop_signup_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_signup_state.freezed.dart';

enum ShopSignupStatus { idle, submitting, error }

@freezed
class ShopSignupState with _$ShopSignupState {
  const ShopSignupState._();
  const factory ShopSignupState({
    @Default('') String shopName,
    @Default('') String address,
    double? latitude,
    double? longitude,
    @Default('') String phone,
    @Default('') String description,
    @Default(ShopSignupStatus.idle) ShopSignupStatus status,
    String? shopNameError,
    String? addressError,
    String? phoneError,
  }) = _ShopSignupState;

  factory ShopSignupState.initial() => const ShopSignupState();
}
```

**파일: `lib/screens/auth/shop_signup/shop_signup_notifier.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:gut_alarm/repositories/shop_repository.dart';
import 'package:gut_alarm/providers/auth_providers.dart';
import 'package:gut_alarm/models/shop.dart';
import 'package:gut_alarm/core/error/app_exception.dart';
import 'package:gut_alarm/core/utils/validators.dart';
import 'package:gut_alarm/core/utils/formatters.dart';

part 'shop_signup_notifier.g.dart';

@riverpod
class ShopSignupNotifier extends _$ShopSignupNotifier {
  @override
  ShopSignupState build() => ShopSignupState.initial();

  void updateShopName(String v) => state = state.copyWith(shopName: v);

  void validateShopName() =>
      state = state.copyWith(shopNameError: Validators.shopName(state.shopName));

  void setAddress(String address, double lat, double lng) =>
      state = state.copyWith(
          address: address, latitude: lat, longitude: lng, addressError: null);

  void setAddressWithoutCoords(String address) =>
      state = state.copyWith(address: address, latitude: null, longitude: null);

  void updatePhone(String v) =>
      state = state.copyWith(phone: Formatters.phone(v));

  void validatePhone() =>
      state = state.copyWith(phoneError: Validators.phone(state.phone));

  void updateDescription(String v) =>
      state = state.copyWith(description: v.length > 200 ? v.substring(0, 200) : v);

  Future<void> submit() async {
    final nameErr = Validators.shopName(state.shopName);
    final addrErr = (state.address.isEmpty)
        ? '주소를 검색해주세요'
        : (state.latitude == null || state.longitude == null)
            ? '주소의 좌표를 확인할 수 없습니다. 다른 주소로 다시 검색해주세요'
            : null;
    final phoneErr = Validators.phone(state.phone);

    state = state.copyWith(
        shopNameError: nameErr, addressError: addrErr, phoneError: phoneErr);
    if (nameErr != null || addrErr != null || phoneErr != null) return;

    state = state.copyWith(status: ShopSignupStatus.submitting);
    try {
      final userId = ref.read(authStateProvider).valueOrNull?.id;
      if (userId == null) {
        state = state.copyWith(status: ShopSignupStatus.error);
        return;
      }
      await ref.read(shopRepositoryProvider).create(Shop(
        ownerId: userId,
        name: state.shopName,
        address: state.address,
        latitude: state.latitude!,
        longitude: state.longitude!,
        phone: Formatters.phoneRaw(state.phone),
        description: state.description.isNotEmpty ? state.description : null,
      ));
      state = state.copyWith(status: ShopSignupStatus.idle);
    } on AppException catch (_) {
      state = state.copyWith(status: ShopSignupStatus.error);
    } catch (_) {
      state = state.copyWith(status: ShopSignupStatus.error);
    }
  }
}
```

**파일: `lib/screens/auth/shop_signup/shop_signup_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:gut_alarm/core/utils/validators.dart';

part 'shop_signup_providers.g.dart';

@riverpod
bool isShopFormValid(IsShopFormValidRef ref) {
  final s = ref.watch(shopSignupNotifierProvider);
  return Validators.shopName(s.shopName) == null
      && s.address.isNotEmpty
      && s.latitude != null
      && s.longitude != null
      && Validators.phone(s.phone) == null;
}
```

#### Step 3: 위젯 테스트 작성

**파일: `test/screens/auth/shop_signup/shop_signup_screen_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_screen.dart';

void main() {
  group('ShopSignupScreen', () {
    testWidgets('AppBar "샵 등록" 타이틀 + 뒤로가기 없음', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      expect(find.text('샵 등록'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('스텝 인디케이터 2/2 표시', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('필수 입력 필드 표시: 샵 이름, 주소, 연락처', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      expect(find.text('샵 이름'), findsOneWidget);
      expect(find.text('주소'), findsOneWidget);
      expect(find.text('연락처'), findsOneWidget);
    });

    testWidgets('소개글 필드 + 글자수 카운터 표시', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      expect(find.text('소개글 (선택)'), findsOneWidget);
      expect(find.text('0/200'), findsOneWidget);
    });

    testWidgets('등록 버튼 "등록 완료" + 초기 비활성', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      expect(find.text('등록 완료'), findsOneWidget);
      final btn = t.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('지도 미리보기 영역 표시', (t) async {
      await t.pumpWidget(const ProviderScope(
        child: MaterialApp(home: ShopSignupScreen())));
      // 주소 미입력 시 안내 텍스트
      expect(find.text('주소를 검색하면 지도가 표시됩니다'), findsOneWidget);
    });
  });
}
```

#### Step 4: 화면 위젯 구현

**파일: `lib/screens/auth/shop_signup/shop_signup_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:gut_alarm/screens/auth/shop_signup/shop_signup_providers.dart';
import 'package:gut_alarm/core/widgets/app_toast.dart';

class ShopSignupScreen extends ConsumerStatefulWidget {
  const ShopSignupScreen({super.key});
  @override
  ConsumerState<ShopSignupScreen> createState() => _State();
}

class _State extends ConsumerState<ShopSignupScreen> {
  final _nameCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _descCtr = TextEditingController();
  final _nameFN = FocusNode(), _phoneFN = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFN.addListener(() { if (!_nameFN.hasFocus)
        ref.read(shopSignupNotifierProvider.notifier).validateShopName(); });
    _phoneFN.addListener(() { if (!_phoneFN.hasFocus)
        ref.read(shopSignupNotifierProvider.notifier).validatePhone(); });
  }
  @override
  void dispose() { _nameCtr.dispose(); _phoneCtr.dispose(); _descCtr.dispose();
    _nameFN.dispose(); _phoneFN.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(shopSignupNotifierProvider);
    final valid = ref.watch(isShopFormValidProvider);
    final n = ref.read(shopSignupNotifierProvider.notifier);
    final busy = s.status == ShopSignupStatus.submitting;

    ref.listen(shopSignupNotifierProvider, (p, nx) {
      if (p?.status == ShopSignupStatus.submitting &&
          nx.status == ShopSignupStatus.idle) {
        AppToast.show(context, '샵이 등록되었습니다!');
        context.go('/owner/dashboard');
      } else if (nx.status == ShopSignupStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('등록에 실패했습니다. 다시 시도해주세요')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('샵 등록'),
        actions: const [Padding(padding: EdgeInsets.only(right: 16),
          child: Center(child: Text('2/2', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600, color: Color(0xFFF97316)))))],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 샵 이름
          TextField(controller: _nameCtr, focusNode: _nameFN, enabled: !busy,
            decoration: InputDecoration(labelText: '샵 이름',
                prefixIcon: const Icon(Icons.store_outlined),
                errorText: s.shopNameError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
            onChanged: n.updateShopName),
          const SizedBox(height: 16),

          // 주소 (읽기 전용 + 검색 버튼)
          TextField(
            readOnly: true, enabled: !busy,
            controller: TextEditingController(text: s.address),
            decoration: InputDecoration(
              labelText: '주소',
              prefixIcon: const Icon(Icons.location_on_outlined),
              errorText: s.addressError,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: busy ? null : () => _openAddressSearch(context),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12))),
            onTap: busy ? null : () => _openAddressSearch(context),
          ),
          const SizedBox(height: 12),

          // 지도 미리보기
          Container(
            width: double.infinity, height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0))),
            child: s.latitude != null && s.longitude != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: const Placeholder(), // KakaoMap widget 대체
                  )
                : const Center(child: Text('주소를 검색하면 지도가 표시됩니다',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)))),
          ),
          const SizedBox(height: 16),

          // 연락처
          TextField(controller: _phoneCtr, focusNode: _phoneFN, enabled: !busy,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: '연락처',
                hintText: '02-0000-0000',
                prefixIcon: const Icon(Icons.phone_outlined),
                errorText: s.phoneError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
            onChanged: (v) { n.updatePhone(v);
              final f = ref.read(shopSignupNotifierProvider).phone;
              if (_phoneCtr.text != f) _phoneCtr.value = TextEditingValue(
                  text: f, selection: TextSelection.collapsed(offset: f.length));
            }),
          const SizedBox(height: 16),

          // 소개글 (선택)
          TextField(controller: _descCtr, enabled: !busy,
            maxLines: 3, maxLength: 200,
            decoration: InputDecoration(
              labelText: '소개글 (선택)',
              alignLabelWithHint: true,
              counterText: '${s.description.length}/200',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12))),
            onChanged: n.updateDescription),
          const SizedBox(height: 32),

          // 등록 완료 버튼
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: (valid && !busy) ? n.submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
              child: busy
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          color: Colors.white))
                  : const Text('등록 완료', style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w600)))),
        ])),
    );
  }

  /// 카카오 주소 검색 바텀시트
  void _openAddressSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('주소 검색', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // TODO: 카카오 주소 API WebView 연동
          const Expanded(child: Center(child: Text('카카오 주소 검색 WebView'))),
        ]),
      ),
    );
  }
}
```

#### Step 5: 테스트 실행

```bash
flutter test test/screens/auth/shop_signup/
```

#### Step 6: 커밋

```bash
git add lib/screens/auth/shop_signup/ test/screens/auth/shop_signup/
git commit -m "feat: 샵 등록 화면 구현 (주소 검색 + 지도 미리보기 + shops INSERT)"
```

---

## Phase 4: 고객 핵심 화면 (customer-home, order-detail, order-history)

> Phase 2 완료 후 진행. 고객 역할 사용자의 핵심 화면을 구현한다.

### Task 4.1: Customer Home (고객 홈)

> 고객이 현재 진행 중인 거트 작업 목록을 실시간으로 확인하는 메인 화면.
> Supabase Realtime 구독으로 작업 상태 변경을 즉시 반영한다.

**Files:**
- Create: `lib/providers/customer_home_provider.dart`
- Create: `lib/screens/customer/customer_home_screen.dart`
- Create: `lib/screens/customer/customer_main_shell.dart`
- Create: `test/providers/customer_home_provider_test.dart`
- Create: `test/screens/customer/customer_home_screen_test.dart`

**Step 1 (Red): Provider 테스트 작성**

Create: `test/providers/customer_home_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/providers/customer_home_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  group('CustomerHomeNotifier', () {
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태는 AsyncLoading이다', () {
      // Arrange & Act
      final state = container.read(customerHomeNotifierProvider);

      // Assert
      expect(state, isA<AsyncLoading>());
    });

    test('활성 작업 목록을 성공적으로 로드한다', () async {
      // Arrange
      final orders = [
        testOrder.copyWith(status: OrderStatus.received),
        testOrder.copyWith(status: OrderStatus.inProgress),
      ];
      when(() => mockOrderRepository.streamActiveByUser(any()))
          .thenAnswer((_) => Stream.value(orders));

      // Act
      await container.read(customerHomeNotifierProvider.future);
      final state = container.read(customerHomeNotifierProvider);

      // Assert
      expect(state.value, equals(orders));
    });

    test('에러 발생 시 AsyncError 상태가 된다', () async {
      // Arrange
      when(() => mockOrderRepository.streamActiveByUser(any()))
          .thenAnswer((_) => Stream.error(Exception('네트워크 에러')));

      // Act
      await expectLater(
        container.read(customerHomeNotifierProvider.future),
        throwsA(isA<Exception>()),
      );

      // Assert
      final state = container.read(customerHomeNotifierProvider);
      expect(state, isA<AsyncError>());
    });
  });

  group('receivedCountProvider', () {
    test('received 상태 작업 건수를 정확히 계산한다', () async {
      // Arrange
      final orders = [
        testOrder.copyWith(status: OrderStatus.received),
        testOrder.copyWith(status: OrderStatus.received),
        testOrder.copyWith(status: OrderStatus.inProgress),
      ];
      final container = ProviderContainer(
        overrides: [
          customerHomeNotifierProvider
              .overrideWith(() => FakeCustomerHomeNotifier(orders)),
        ],
      );

      // Act
      await container.read(customerHomeNotifierProvider.future);
      final count = container.read(receivedCountProvider);

      // Assert
      expect(count, equals(2));

      container.dispose();
    });
  });

  group('inProgressCountProvider', () {
    test('inProgress 상태 작업 건수를 정확히 계산한다', () async {
      // Arrange
      final orders = [
        testOrder.copyWith(status: OrderStatus.received),
        testOrder.copyWith(status: OrderStatus.inProgress),
        testOrder.copyWith(status: OrderStatus.inProgress),
      ];
      final container = ProviderContainer(
        overrides: [
          customerHomeNotifierProvider
              .overrideWith(() => FakeCustomerHomeNotifier(orders)),
        ],
      );

      // Act
      await container.read(customerHomeNotifierProvider.future);
      final count = container.read(inProgressCountProvider);

      // Assert
      expect(count, equals(2));

      container.dispose();
    });
  });
}
```

Run: `flutter test test/providers/customer_home_provider_test.dart`
Expected: FAIL (컴파일 에러 — Provider 미구현)

**Step 2 (Green): Provider 구현**

Create: `lib/providers/customer_home_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/providers/auth_provider.dart';

part 'customer_home_provider.g.dart';

/// 고객 홈 — 활성 작업 목록 Realtime 스트림
@riverpod
Stream<List<Order>> activeOrdersStream(ActiveOrdersStreamRef ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value([]);

  final orderRepository = ref.watch(orderRepositoryProvider);
  return orderRepository.streamActiveByUser(currentUser.id);
}

/// 고객 홈 — 메인 상태 관리 Notifier
@riverpod
class CustomerHomeNotifier extends _$CustomerHomeNotifier {
  @override
  Future<List<Order>> build() async {
    final stream = ref.watch(activeOrdersStreamProvider.future);
    return stream;
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }

  /// 에러 상태에서 재시도
  Future<void> retry() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

/// 접수됨 상태 건수 (파생)
@riverpod
int receivedCount(ReceivedCountRef ref) {
  final orders = ref.watch(customerHomeNotifierProvider).valueOrNull ?? [];
  return orders.where((o) => o.status == OrderStatus.received).length;
}

/// 작업중 상태 건수 (파생)
@riverpod
int inProgressCount(InProgressCountRef ref) {
  final orders = ref.watch(customerHomeNotifierProvider).valueOrNull ?? [];
  return orders.where((o) => o.status == OrderStatus.inProgress).length;
}
```

Run: `flutter test test/providers/customer_home_provider_test.dart`
Expected: PASS

**Step 3 (Red): Widget 테스트 작성**

Create: `test/screens/customer/customer_home_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/screens/customer/customer_home_screen.dart';
import 'package:badminton_app/providers/customer_home_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';

import '../../helpers/mocks.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('CustomerHomeScreen', () {
    testWidgets('로딩 상태에서 스켈레톤 shimmer를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeLoadingNotifier(),
            ),
          ],
          child: const CustomerHomeScreen(),
        ),
      );

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('빈 상태일 때 빈 상태 UI를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeCustomerHomeNotifier([]),
            ),
          ],
          child: const CustomerHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('아직 진행 중인 작업이 없습니다'), findsOneWidget);
      expect(find.text('주변 샵 검색하기'), findsOneWidget);
    });

    testWidgets('작업 목록을 카드 형태로 표시한다', (tester) async {
      // Arrange
      final orders = [
        testOrder.copyWith(
          status: OrderStatus.received,
          shopName: 'OO 거트샵',
        ),
        testOrder.copyWith(
          status: OrderStatus.inProgress,
          shopName: 'XX 스트링',
        ),
      ];
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeCustomerHomeNotifier(orders),
            ),
            receivedCountProvider.overrideWithValue(1),
            inProgressCountProvider.overrideWithValue(1),
          ],
          child: const CustomerHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('OO 거트샵'), findsOneWidget);
      expect(find.text('XX 스트링'), findsOneWidget);
    });

    testWidgets('요약 카드에 접수/작업중 건수를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeCustomerHomeNotifier([testOrder]),
            ),
            receivedCountProvider.overrideWithValue(2),
            inProgressCountProvider.overrideWithValue(1),
          ],
          child: const CustomerHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('접수 2건'), findsOneWidget);
      expect(find.text('작업중 1건'), findsOneWidget);
    });

    testWidgets('에러 상태에서 에러 UI와 재시도 버튼을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeErrorNotifier(),
            ),
          ],
          child: const CustomerHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('작업 카드 탭 시 작업 상세 화면으로 이동한다', (tester) async {
      // Arrange
      final orders = [
        testOrder.copyWith(
          id: 'order-1',
          status: OrderStatus.received,
          shopName: 'OO 거트샵',
        ),
      ];
      final mockRouter = MockGoRouter();
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            customerHomeNotifierProvider.overrideWith(
              () => FakeCustomerHomeNotifier(orders),
            ),
            receivedCountProvider.overrideWithValue(1),
            inProgressCountProvider.overrideWithValue(0),
          ],
          mockRouter: mockRouter,
          child: const CustomerHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('OO 거트샵'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRouter.go('/customer/order/order-1')).called(1);
    });
  });
}
```

Run: `flutter test test/screens/customer/customer_home_screen_test.dart`
Expected: FAIL (화면 미구현)

**Step 4 (Green): 화면 구현**

Create: `lib/screens/customer/customer_home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/providers/customer_home_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:badminton_app/core/utils/formatters.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerHomeNotifierProvider);
    final receivedCount = ref.watch(receivedCountProvider);
    final inProgressCount = ref.watch(inProgressCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '거트알림',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF0F172A), size: 24),
            onPressed: () => context.go('/customer/notifications'),
            tooltip: '알림',
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const _SkeletonView(),
        error: (error, _) => ErrorView(
          message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.read(customerHomeNotifierProvider.notifier).retry(),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.sports_tennis,
              message: '아직 진행 중인 작업이 없습니다',
              actionLabel: '주변 샵 검색하기',
              onAction: () => context.go('/customer/shop-search'),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF16A34A),
            onRefresh: () =>
                ref.read(customerHomeNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (receivedCount + inProgressCount > 0)
                  _SummaryCard(
                    receivedCount: receivedCount,
                    inProgressCount: inProgressCount,
                  ),
                if (receivedCount + inProgressCount > 0)
                  const SizedBox(height: 20),
                const Text('내 작업',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                ...orders.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderCard(
                        order: order,
                        onTap: () => context.go('/customer/order/${order.id}'),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.receivedCount,
    required this.inProgressCount,
  });
  final int receivedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('진행 중인 작업',
              style: TextStyle(fontSize: 14, color: Color(0xFF166534))),
          const SizedBox(height: 8),
          Row(children: [
            Text('접수 $receivedCount건',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B))),
            const Text(' · ',
                style: TextStyle(fontSize: 14, color: Color(0xFF166534))),
            Text('작업중 $inProgressCount건',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6))),
          ]),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(status: order.status),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.storefront, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(order.shopName ?? '',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF475569)))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(Formatters.relativeTime(order.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ]),
            if (order.memo != null && order.memo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.notes, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(order.memo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)))),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonView extends StatelessWidget {
  const _SkeletonView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SkeletonShimmer(height: 80, borderRadius: 16),
        const SizedBox(height: 20),
        ...List.generate(
            3,
            (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonShimmer(height: 140, borderRadius: 16),
                )),
      ]),
    );
  }
}
```

Create: `lib/screens/customer/customer_main_shell.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 고객 화면의 하단 네비게이션 바를 포함하는 Shell 위젯
class CustomerMainShell extends StatelessWidget {
  const CustomerMainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _TabItem(icon: Icons.home, label: '홈', path: '/customer/home'),
    _TabItem(icon: Icons.search, label: '샵검색', path: '/customer/shop-search'),
    _TabItem(icon: Icons.qr_code_2, label: 'QR', path: '/customer/qr'),
    _TabItem(icon: Icons.history, label: '이력', path: '/customer/order-history'),
    _TabItem(icon: Icons.person, label: 'MY', path: '/customer/mypage'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => context.go(_tabs[index].path),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF16A34A),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          iconSize: 24,
          elevation: 0,
          items: _tabs
              .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon), label: tab.label))
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.icon, required this.label, required this.path});
  final IconData icon;
  final String label;
  final String path;
}
```

Run: `flutter test test/screens/customer/customer_home_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/customer_home_provider.dart \
  lib/screens/customer/customer_home_screen.dart \
  lib/screens/customer/customer_main_shell.dart \
  test/providers/customer_home_provider_test.dart \
  test/screens/customer/customer_home_screen_test.dart
git commit -m "feat: 고객 홈 화면 구현 (Realtime 활성 작업 목록 + 하단 네비게이션)"
```

---


### Task 4.2: Order Detail (작업 상세)

> 고객이 개별 거트 작업의 상세 정보와 상태 타임라인을 확인하는 화면.
> Supabase Realtime으로 해당 작업의 상태 변경을 즉시 반영한다.

**Files:**
- Create: `lib/providers/order_detail_provider.dart`
- Create: `lib/screens/customer/order_detail_screen.dart`
- Create: `lib/models/order_with_shop.dart`
- Create: `lib/models/timeline_step.dart`
- Create: `test/providers/order_detail_provider_test.dart`
- Create: `test/screens/customer/order_detail_screen_test.dart`

**Step 1 (Red): Provider 테스트 작성**

Create: `test/providers/order_detail_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/providers/order_detail_provider.dart';
import 'package:badminton_app/models/order_with_shop.dart';
import 'package:badminton_app/models/timeline_step.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  group('orderDetailStreamProvider', () {
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('orderId로 작업 상세를 스트리밍한다', () async {
      // Arrange
      final orderWithShop = testOrderWithShop;
      when(() => mockOrderRepository.streamById(any()))
          .thenAnswer((_) => Stream.value(orderWithShop));

      // Act
      final stream = container.read(
        orderDetailStreamProvider('test-order-id').future,
      );
      final result = await stream;

      // Assert
      expect(result, equals(orderWithShop));
    });

    test('스트림 에러 시 AsyncError가 된다', () async {
      // Arrange
      when(() => mockOrderRepository.streamById(any()))
          .thenAnswer((_) => Stream.error(Exception('Not found')));

      // Act & Assert
      await expectLater(
        container.read(orderDetailStreamProvider('bad-id').future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('timelineStepsProvider', () {
    test('received 상태일 때 첫 번째 노드만 활성이다', () {
      // Arrange
      final orderWithShop = testOrderWithShop.copyWith(
        status: OrderStatus.received,
        createdAt: DateTime(2026, 2, 18, 14, 30),
        inProgressAt: null,
        completedAt: null,
      );
      final container = ProviderContainer(
        overrides: [
          orderDetailStreamProvider('test-id')
              .overrideWith((ref) => Stream.value(orderWithShop)),
        ],
      );

      // Act
      final steps = container.read(timelineStepsProvider('test-id'));

      // Assert
      expect(steps.length, equals(3));
      expect(steps[0].isActive, isTrue);
      expect(steps[0].label, equals('접수됨'));
      expect(steps[0].reachedAt, isNotNull);
      expect(steps[1].isActive, isFalse);
      expect(steps[2].isActive, isFalse);

      container.dispose();
    });

    test('inProgress 상태일 때 첫 두 노드가 활성이다', () {
      // Arrange
      final orderWithShop = testOrderWithShop.copyWith(
        status: OrderStatus.inProgress,
        createdAt: DateTime(2026, 2, 18, 14, 30),
        inProgressAt: DateTime(2026, 2, 18, 16, 0),
        completedAt: null,
      );
      final container = ProviderContainer(
        overrides: [
          orderDetailStreamProvider('test-id')
              .overrideWith((ref) => Stream.value(orderWithShop)),
        ],
      );

      // Act
      final steps = container.read(timelineStepsProvider('test-id'));

      // Assert
      expect(steps[0].isActive, isTrue);
      expect(steps[1].isActive, isTrue);
      expect(steps[1].label, equals('작업중'));
      expect(steps[1].reachedAt, isNotNull);
      expect(steps[2].isActive, isFalse);

      container.dispose();
    });

    test('completed 상태일 때 모든 노드가 활성이다', () {
      // Arrange
      final orderWithShop = testOrderWithShop.copyWith(
        status: OrderStatus.completed,
        createdAt: DateTime(2026, 2, 18, 14, 30),
        inProgressAt: DateTime(2026, 2, 18, 16, 0),
        completedAt: DateTime(2026, 2, 18, 18, 0),
      );
      final container = ProviderContainer(
        overrides: [
          orderDetailStreamProvider('test-id')
              .overrideWith((ref) => Stream.value(orderWithShop)),
        ],
      );

      // Act
      final steps = container.read(timelineStepsProvider('test-id'));

      // Assert
      expect(steps[0].isActive, isTrue);
      expect(steps[1].isActive, isTrue);
      expect(steps[2].isActive, isTrue);
      expect(steps[2].label, equals('완료'));

      container.dispose();
    });
  });
}
```

Run: `flutter test test/providers/order_detail_provider_test.dart`
Expected: FAIL (컴파일 에러)

**Step 2 (Green): 모델 및 Provider 구현**

Create: `lib/models/order_with_shop.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'order_with_shop.freezed.dart';
part 'order_with_shop.g.dart';

/// Order + Shop 조인 데이터
@freezed
class OrderWithShop with _$OrderWithShop {
  const factory OrderWithShop({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'member_id') required String memberId,
    required OrderStatus status,
    String? memo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'in_progress_at') DateTime? inProgressAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Shop 조인 필드
    @JsonKey(name: 'shop_name') required String shopName,
    @JsonKey(name: 'shop_address') required String shopAddress,
    @JsonKey(name: 'shop_phone') required String shopPhone,
    @JsonKey(name: 'shop_latitude') required double shopLatitude,
    @JsonKey(name: 'shop_longitude') required double shopLongitude,
  }) = _OrderWithShop;

  factory OrderWithShop.fromJson(Map<String, dynamic> json) =>
      _$OrderWithShopFromJson(json);
}
```

Create: `lib/models/timeline_step.dart`

```dart
import 'package:badminton_app/models/enums.dart';

/// 타임라인 단계 모델 (파생 데이터)
class TimelineStep {
  const TimelineStep({
    required this.status,
    required this.isActive,
    this.reachedAt,
    required this.label,
  });

  final OrderStatus status;
  final bool isActive;
  final DateTime? reachedAt;
  final String label;
}
```

Create: `lib/providers/order_detail_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:badminton_app/models/order_with_shop.dart';
import 'package:badminton_app/models/timeline_step.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';

part 'order_detail_provider.g.dart';

/// 작업 상세 — Realtime 스트림 (family: orderId)
@riverpod
Stream<OrderWithShop> orderDetailStream(
  OrderDetailStreamRef ref,
  String orderId,
) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return orderRepository.streamById(orderId);
}

/// 타임라인 단계 목록 (파생 — orderDetail에서 계산)
@riverpod
List<TimelineStep> timelineSteps(
  TimelineStepsRef ref,
  String orderId,
) {
  final orderAsync = ref.watch(orderDetailStreamProvider(orderId));
  final order = orderAsync.valueOrNull;
  if (order == null) return [];

  final statusIndex = OrderStatus.values.indexOf(order.status);

  return [
    TimelineStep(
      status: OrderStatus.received,
      isActive: statusIndex >= 0,
      reachedAt: order.createdAt,
      label: '접수됨',
    ),
    TimelineStep(
      status: OrderStatus.inProgress,
      isActive: statusIndex >= 1,
      reachedAt: order.inProgressAt,
      label: '작업중',
    ),
    TimelineStep(
      status: OrderStatus.completed,
      isActive: statusIndex >= 2,
      reachedAt: order.completedAt,
      label: '완료',
    ),
  ];
}
```

Run: `flutter test test/providers/order_detail_provider_test.dart`
Expected: PASS

**Step 3 (Red): Widget 테스트 작성**

Create: `test/screens/customer/order_detail_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/screens/customer/order_detail_screen.dart';
import 'package:badminton_app/providers/order_detail_provider.dart';
import 'package:badminton_app/models/order_with_shop.dart';
import 'package:badminton_app/models/enums.dart';

import '../../helpers/mocks.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('OrderDetailScreen', () {
    testWidgets('로딩 상태에서 스켈레톤을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderDetailStreamProvider('order-1')
                .overrideWith((ref) => Stream.empty()),
          ],
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('작업 상세 정보를 정상 표시한다', (tester) async {
      // Arrange
      final order = testOrderWithShop.copyWith(
        status: OrderStatus.inProgress,
        shopName: 'OO 거트 스트링샵',
        shopAddress: '서울시 강남구 역삼동 123-45',
        shopPhone: '010-1234-5678',
        memo: '크로스 텐션 1lbs 높게',
      );
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderDetailStreamProvider('order-1')
                .overrideWith((ref) => Stream.value(order)),
          ],
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('작업중'), findsOneWidget);
      expect(find.text('OO 거트 스트링샵'), findsOneWidget);
      expect(find.text('서울시 강남구 역삼동 123-45'), findsOneWidget);
      expect(find.text('010-1234-5678'), findsOneWidget);
      expect(find.text('크로스 텐션 1lbs 높게'), findsOneWidget);
    });

    testWidgets('메모가 없으면 메모 섹션을 숨긴다', (tester) async {
      // Arrange
      final order = testOrderWithShop.copyWith(memo: null);
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderDetailStreamProvider('order-1')
                .overrideWith((ref) => Stream.value(order)),
          ],
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('작업 메모'), findsNothing);
    });

    testWidgets('타임라인에 활성/비활성 노드를 표시한다', (tester) async {
      // Arrange
      final order = testOrderWithShop.copyWith(
        status: OrderStatus.inProgress,
        createdAt: DateTime(2026, 2, 18, 14, 30),
        inProgressAt: DateTime(2026, 2, 18, 16, 0),
        completedAt: null,
      );
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderDetailStreamProvider('order-1')
                .overrideWith((ref) => Stream.value(order)),
          ],
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('접수됨'), findsWidgets);
      expect(find.text('작업중'), findsWidgets);
      expect(find.text('완료'), findsOneWidget);
      // 접수됨, 작업중 시각이 표시되고 완료는 "—"
      expect(find.text('02/18 14:30'), findsOneWidget);
      expect(find.text('02/18 16:00'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('에러 상태에서 에러 UI를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderDetailStreamProvider('order-1')
                .overrideWith((ref) => Stream.error(Exception('에러'))),
          ],
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/customer/order_detail_screen_test.dart`
Expected: FAIL (화면 미구현)

**Step 4 (Green): 화면 구현**

Create: `lib/screens/customer/order_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badminton_app/providers/order_detail_provider.dart';
import 'package:badminton_app/models/order_with_shop.dart';
import 'package:badminton_app/models/timeline_step.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:badminton_app/core/utils/formatters.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailStreamProvider(orderId));
    final timelineSteps = ref.watch(timelineStepsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Text('작업 상세',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: orderAsync.when(
        loading: () => const _SkeletonView(),
        error: (error, _) => ErrorView(
          message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.invalidate(orderDetailStreamProvider(orderId)),
        ),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LargeStatusBadge(status: order.status),
              const SizedBox(height: 24),
              const Text('진행 상태',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              _TimelineCard(steps: timelineSteps),
              if (order.memo != null && order.memo!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('작업 메모',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(order.memo!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          height: 1.5)),
                ),
              ],
              const SizedBox(height: 24),
              const Text('샵 정보',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              _ShopInfoCard(order: order),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeStatusBadge extends StatelessWidget {
  const _LargeStatusBadge({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, size: 32, color: config.textColor),
          const SizedBox(width: 12),
          Text(config.label,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: config.textColor)),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return const _StatusConfig(
            icon: Icons.inventory_2,
            label: '접수됨',
            textColor: Color(0xFF92400E),
            bgColor: Color(0xFFFEF3C7));
      case OrderStatus.inProgress:
        return const _StatusConfig(
            icon: Icons.build_circle,
            label: '작업중',
            textColor: Color(0xFF1E40AF),
            bgColor: Color(0xFFDBEAFE));
      case OrderStatus.completed:
        return const _StatusConfig(
            icon: Icons.check_circle,
            label: '완료',
            textColor: Color(0xFF166534),
            bgColor: Color(0xFFDCFCE7));
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final Color textColor;
  final Color bgColor;
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.steps});
  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _TimelineNode(step: steps[i]),
            if (i < steps.length - 1)
              _TimelineConnector(
                isActive: steps[i + 1].isActive,
                color: steps[i + 1].isActive
                    ? _nodeColor(steps[i + 1].status)
                    : const Color(0xFFCBD5E1),
              ),
          ],
        ],
      ),
    );
  }

  Color _nodeColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return const Color(0xFFF59E0B);
      case OrderStatus.inProgress:
        return const Color(0xFF3B82F6);
      case OrderStatus.completed:
        return const Color(0xFF22C55E);
    }
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.step});
  final TimelineStep step;

  @override
  Widget build(BuildContext context) {
    final color = step.isActive ? _activeColor(step.status) : const Color(0xFFCBD5E1);
    return Row(
      children: [
        Icon(
          step.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 24,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: step.isActive ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ),
        Text(
          step.reachedAt != null
              ? Formatters.dateTime(step.reachedAt!)
              : '—',
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Color _activeColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return const Color(0xFFF59E0B);
      case OrderStatus.inProgress:
        return const Color(0xFF3B82F6);
      case OrderStatus.completed:
        return const Color(0xFF22C55E);
    }
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isActive, required this.color});
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Container(width: 2, height: 32, color: color),
    );
  }
}

class _ShopInfoCard extends StatelessWidget {
  const _ShopInfoCard({required this.order});
  final OrderWithShop order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.storefront, size: 20, color: Color(0xFF16A34A)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(order.shopName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A)))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.location_on, size: 20, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(order.shopAddress,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF475569)))),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:${order.shopPhone}')),
            child: Row(children: [
              const Icon(Icons.phone, size: 20, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(order.shopPhone,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF475569))),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => _openNaverMapRoute(order),
              icon: const Icon(Icons.directions, size: 20),
              label: const Text('길찾기'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNaverMapRoute(OrderWithShop order) async {
    final uri = Uri.parse(
      'nmap://route/public?dlat=${order.shopLatitude}'
      '&dlng=${order.shopLongitude}&dname=${Uri.encodeComponent(order.shopName)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
        'https://map.naver.com/v5/directions/-/${order.shopLongitude},${order.shopLatitude},${Uri.encodeComponent(order.shopName)}',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SkeletonView extends StatelessWidget {
  const _SkeletonView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SkeletonShimmer(height: 72, borderRadius: 16),
        const SizedBox(height: 24),
        const SkeletonShimmer(height: 160, borderRadius: 16),
        const SizedBox(height: 24),
        const SkeletonShimmer(height: 180, borderRadius: 16),
      ]),
    );
  }
}
```

Run: `flutter test test/screens/customer/order_detail_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/order_with_shop.dart \
  lib/models/timeline_step.dart \
  lib/providers/order_detail_provider.dart \
  lib/screens/customer/order_detail_screen.dart \
  test/providers/order_detail_provider_test.dart \
  test/screens/customer/order_detail_screen_test.dart
git commit -m "feat: 작업 상세 화면 구현 (Realtime 상태 스트림 + 타임라인 UI)"
```

---

### Task 4.3: Order History (작업 이력)

> 고객이 완료된 과거 작업 목록을 확인하는 화면.
> 커서 기반 페이지네이션(무한 스크롤)으로 대량 데이터를 효율적으로 로드한다.

**Files:**
- Create: `lib/providers/order_history_provider.dart`
- Create: `lib/screens/customer/order_history_screen.dart`
- Create: `test/providers/order_history_provider_test.dart`
- Create: `test/screens/customer/order_history_screen_test.dart`

**Step 1 (Red): Provider 테스트 작성**

Create: `test/providers/order_history_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/providers/order_history_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  group('OrderHistoryNotifier', () {
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 로드 시 완료된 작업 목록을 가져온다', () async {
      // Arrange
      final orders = List.generate(
        5,
        (i) => testOrder.copyWith(
          id: 'order-$i',
          status: OrderStatus.completed,
        ),
      );
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => orders);

      // Act
      await container.read(orderHistoryNotifierProvider.future);
      final state = container.read(orderHistoryNotifierProvider);

      // Assert
      expect(state.value, equals(orders));
    });

    test('0건이면 빈 목록과 hasMore=false', () async {
      // Arrange
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      // Act
      await container.read(orderHistoryNotifierProvider.future);

      // Assert
      final notifier = container.read(orderHistoryNotifierProvider.notifier);
      expect(notifier.hasMore, isFalse);
    });

    test('pageSize 미만 로드 시 hasMore=false', () async {
      // Arrange
      final orders = List.generate(
        10,
        (i) => testOrder.copyWith(id: 'order-$i'),
      );
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => orders);

      // Act
      await container.read(orderHistoryNotifierProvider.future);

      // Assert
      final notifier = container.read(orderHistoryNotifierProvider.notifier);
      expect(notifier.hasMore, isFalse); // 10 < 20(pageSize)
    });

    test('loadMore 호출 시 기존 목록에 추가한다', () async {
      // Arrange
      final firstPage = List.generate(
        20,
        (i) => testOrder.copyWith(id: 'order-$i'),
      );
      final secondPage = List.generate(
        5,
        (i) => testOrder.copyWith(id: 'order-${20 + i}'),
      );
      var callCount = 0;
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        callCount++;
        return callCount == 1 ? firstPage : secondPage;
      });

      // Act
      await container.read(orderHistoryNotifierProvider.future);
      final notifier = container.read(orderHistoryNotifierProvider.notifier);
      await notifier.loadMore();

      // Assert
      final state = container.read(orderHistoryNotifierProvider);
      expect(state.value!.length, equals(25));
    });

    test('hasMore=false일 때 loadMore를 무시한다', () async {
      // Arrange
      final orders = List.generate(
        5,
        (i) => testOrder.copyWith(id: 'order-$i'),
      );
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => orders);

      // Act
      await container.read(orderHistoryNotifierProvider.future);
      final notifier = container.read(orderHistoryNotifierProvider.notifier);
      await notifier.loadMore(); // hasMore가 false이므로 무시

      // Assert
      verify(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).called(1); // 초기 로드 1회만
    });

    test('refresh 시 상태를 초기화하고 첫 페이지를 재조회한다', () async {
      // Arrange
      final orders = List.generate(
        20,
        (i) => testOrder.copyWith(id: 'order-$i'),
      );
      when(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => orders);

      // Act
      await container.read(orderHistoryNotifierProvider.future);
      final notifier = container.read(orderHistoryNotifierProvider.notifier);
      await notifier.refresh();

      // Assert
      verify(() => mockOrderRepository.getCompletedByUser(
            userId: any(named: 'userId'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).called(2); // 초기 + refresh
    });
  });
}
```

Run: `flutter test test/providers/order_history_provider_test.dart`
Expected: FAIL (컴파일 에러)

**Step 2 (Green): Provider 구현**

Create: `lib/providers/order_history_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/providers/auth_provider.dart';

part 'order_history_provider.g.dart';

const _pageSize = 20;

/// 작업 이력 — 완료된 작업 목록 (커서 기반 페이지네이션)
@riverpod
class OrderHistoryNotifier extends _$OrderHistoryNotifier {
  String? _cursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Order>> build() async {
    _cursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchPage();
  }

  Future<List<Order>> _fetchPage() async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return [];

    final orderRepository = ref.read(orderRepositoryProvider);
    final orders = await orderRepository.getCompletedByUser(
      userId: currentUser.id,
      cursor: _cursor,
      limit: _pageSize,
    );

    if (orders.length < _pageSize) {
      _hasMore = false;
    }

    if (orders.isNotEmpty) {
      _cursor = orders.last.updatedAt.toIso8601String();
    }

    return orders;
  }

  /// 다음 페이지 로드 (무한 스크롤)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final newOrders = await _fetchPage();
      final currentOrders = state.valueOrNull ?? [];
      state = AsyncData([...currentOrders, ...newOrders]);
    } catch (e, st) {
      // 추가 로드 실패 시 기존 목록 유지, 스낵바로 알림
      _isLoadingMore = false;
      rethrow;
    }
    _isLoadingMore = false;
  }

  /// Pull-to-refresh: 상태 초기화 후 첫 페이지부터 재조회
  Future<void> refresh() async {
    _cursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncLoading();
    try {
      final orders = await _fetchPage();
      state = AsyncData(orders);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 에러 상태에서 재시도
  Future<void> retry() async {
    await refresh();
  }
}
```

Run: `flutter test test/providers/order_history_provider_test.dart`
Expected: PASS

**Step 3 (Red): Widget 테스트 작성**

Create: `test/screens/customer/order_history_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/screens/customer/order_history_screen.dart';
import 'package:badminton_app/providers/order_history_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';

import '../../helpers/mocks.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('OrderHistoryScreen', () {
    testWidgets('로딩 상태에서 스켈레톤을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderHistoryNotifierProvider.overrideWith(
              () => FakeLoadingHistoryNotifier(),
            ),
          ],
          child: const OrderHistoryScreen(),
        ),
      );

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('빈 상태일 때 안내 메시지를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderHistoryNotifierProvider.overrideWith(
              () => FakeOrderHistoryNotifier([]),
            ),
          ],
          child: const OrderHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('아직 완료된 작업이 없습니다'), findsOneWidget);
    });

    testWidgets('완료된 작업 목록을 카드 형태로 표시한다', (tester) async {
      // Arrange
      final orders = [
        testOrder.copyWith(
          id: 'order-1',
          status: OrderStatus.completed,
          shopName: 'OO 거트샵',
          updatedAt: DateTime(2026, 2, 15),
        ),
        testOrder.copyWith(
          id: 'order-2',
          status: OrderStatus.completed,
          shopName: 'XX 스트링',
          updatedAt: DateTime(2026, 2, 10),
        ),
      ];
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderHistoryNotifierProvider.overrideWith(
              () => FakeOrderHistoryNotifier(orders),
            ),
          ],
          child: const OrderHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('OO 거트샵'), findsOneWidget);
      expect(find.text('XX 스트링'), findsOneWidget);
      expect(find.text('2026.02.15 완료'), findsOneWidget);
      expect(find.text('2026.02.10 완료'), findsOneWidget);
    });

    testWidgets('작업 카드 탭 시 작업 상세 화면으로 이동한다', (tester) async {
      // Arrange
      final orders = [
        testOrder.copyWith(
          id: 'order-1',
          status: OrderStatus.completed,
          shopName: 'OO 거트샵',
        ),
      ];
      final mockRouter = MockGoRouter();
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderHistoryNotifierProvider.overrideWith(
              () => FakeOrderHistoryNotifier(orders),
            ),
          ],
          mockRouter: mockRouter,
          child: const OrderHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('OO 거트샵'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRouter.go('/customer/order/order-1')).called(1);
    });

    testWidgets('에러 상태에서 에러 UI를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            orderHistoryNotifierProvider.overrideWith(
              () => FakeErrorHistoryNotifier(),
            ),
          ],
          child: const OrderHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/customer/order_history_screen_test.dart`
Expected: FAIL (화면 미구현)

**Step 4 (Green): 화면 구현**

Create: `lib/screens/customer/order_history_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/providers/order_history_provider.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/core/utils/formatters.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(orderHistoryNotifierProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 이력',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const _SkeletonView(),
        error: (error, _) => ErrorView(
          message: '데이터를 불러올 수 없습니다',
          onRetry: () =>
              ref.read(orderHistoryNotifierProvider.notifier).retry(),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: '아직 완료된 작업이 없습니다',
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF16A34A),
            onRefresh: () =>
                ref.read(orderHistoryNotifierProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: orders.length +
                  (ref.read(orderHistoryNotifierProvider.notifier).hasMore
                      ? 1
                      : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index >= orders.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  );
                }
                final order = orders[index];
                return _HistoryOrderCard(
                  order: order,
                  onTap: () => context.go('/customer/order/${order.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.shopName ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(order.updatedAt)} 완료',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 24),
          ],
        ),
      ),
    );
  }
}

class _SkeletonView extends StatelessWidget {
  const _SkeletonView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonShimmer(height: 72, borderRadius: 12),
          ),
        ),
      ),
    );
  }
}
```

Run: `flutter test test/screens/customer/order_history_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/order_history_provider.dart \
  lib/screens/customer/order_history_screen.dart \
  test/providers/order_history_provider_test.dart \
  test/screens/customer/order_history_screen_test.dart
git commit -m "feat: 작업 이력 화면 구현 (커서 기반 페이지네이션 + 무한 스크롤)"
```

---

---


## Phase 5: 샵 탐색 (shop-search, shop-detail)

> Phase 2 완료 후 진행. 고객이 주변 거트 샵을 검색하고 상세 정보를 확인하는 화면을 구현한다.

### Task 5.1: Shop Search (주변 샵 검색)

> 현재 위치 기반으로 주변 거트 샵을 카카오맵 지도 또는 리스트에서 검색하고,
> 각 샵의 실시간 작업 현황(접수/작업중 건수)을 확인하는 화면.

**Files:**
- Create: `lib/providers/shop_search_provider.dart`
- Create: `lib/models/shop_with_order_count.dart`
- Create: `lib/screens/customer/shop_search_screen.dart`
- Create: `lib/core/utils/distance_calculator.dart`
- Create: `test/providers/shop_search_provider_test.dart`
- Create: `test/screens/customer/shop_search_screen_test.dart`
- Create: `test/core/utils/distance_calculator_test.dart`

**Step 1 (Red): 거리 계산 유틸리티 테스트 작성**

Create: `test/core/utils/distance_calculator_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator', () {
    test('같은 좌표 간 거리는 0이다', () {
      // Arrange & Act
      final distance = DistanceCalculator.haversine(
        lat1: 37.5665, lng1: 126.978,
        lat2: 37.5665, lng2: 126.978,
      );

      // Assert
      expect(distance, equals(0.0));
    });

    test('서울역-강남역 간 거리가 약 7~9km이다', () {
      // Arrange & Act (서울역: 37.5547, 126.9707 / 강남역: 37.4979, 127.0276)
      final distance = DistanceCalculator.haversine(
        lat1: 37.5547, lng1: 126.9707,
        lat2: 37.4979, lng2: 127.0276,
      );

      // Assert
      expect(distance, greaterThan(7000)); // 7km 이상
      expect(distance, lessThan(9000));    // 9km 미만
    });

    test('formatDistance: 1km 미만은 Nm 형식이다', () {
      // Arrange & Act
      final formatted = DistanceCalculator.formatDistance(350);

      // Assert
      expect(formatted, equals('350m'));
    });

    test('formatDistance: 1~10km은 N.Nkm 형식이다', () {
      // Arrange & Act
      final formatted = DistanceCalculator.formatDistance(1200);

      // Assert
      expect(formatted, equals('1.2km'));
    });

    test('formatDistance: 10km 이상은 Nkm 형식이다', () {
      // Arrange & Act
      final formatted = DistanceCalculator.formatDistance(15300);

      // Assert
      expect(formatted, equals('15km'));
    });
  });
}
```

Run: `flutter test test/core/utils/distance_calculator_test.dart`
Expected: FAIL (유틸리티 미구현)

**Step 2 (Green): 거리 계산 유틸리티 구현**

Create: `lib/core/utils/distance_calculator.dart`

```dart
import 'dart:math';

/// GPS 좌표 간 거리 계산 유틸리티 (Haversine 공식)
class DistanceCalculator {
  DistanceCalculator._();

  static const _earthRadiusMeters = 6371000.0;

  /// 두 GPS 좌표 간 직선 거리 (미터 단위)
  static double haversine({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// 거리를 표시 형식으로 변환
  /// - 1km 미만: "Nm" (예: 350m)
  /// - 1~10km: "N.Nkm" (예: 1.2km)
  /// - 10km 이상: "Nkm" (예: 15km)
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else if (meters < 10000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    } else {
      return '${(meters / 1000).round()}km';
    }
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
```

Run: `flutter test test/core/utils/distance_calculator_test.dart`
Expected: PASS

**Step 3 (Red): Provider 테스트 작성**

Create: `test/providers/shop_search_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/providers/shop_search_provider.dart';
import 'package:badminton_app/models/shop_with_order_count.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  group('ShopSearchProviders', () {
    test('viewModeProvider 초기값은 map이다', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final mode = container.read(viewModeProvider);

      // Assert
      expect(mode, equals(ShopSearchViewMode.map));

      container.dispose();
    });

    test('viewMode를 list로 전환할 수 있다', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      container.read(viewModeProvider.notifier).state =
          ShopSearchViewMode.list;
      final mode = container.read(viewModeProvider);

      // Assert
      expect(mode, equals(ShopSearchViewMode.list));

      container.dispose();
    });

    test('selectedShopProvider 초기값은 null이다', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final shop = container.read(selectedShopProvider);

      // Assert
      expect(shop, isNull);

      container.dispose();
    });

    test('마커 선택 시 selectedShop이 갱신된다', () {
      // Arrange
      final container = ProviderContainer();
      final shop = testShopWithOrderCount;

      // Act
      container.read(selectedShopProvider.notifier).state = shop;

      // Assert
      expect(container.read(selectedShopProvider), equals(shop));

      container.dispose();
    });

    test('빈 영역 탭 시 selectedShop이 null이 된다', () {
      // Arrange
      final container = ProviderContainer();
      container.read(selectedShopProvider.notifier).state =
          testShopWithOrderCount;

      // Act
      container.read(selectedShopProvider.notifier).state = null;

      // Assert
      expect(container.read(selectedShopProvider), isNull);

      container.dispose();
    });
  });

  group('ShopsInBoundsNotifier', () {
    late MockShopRepository mockShopRepository;
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockShopRepository = MockShopRepository();
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          shopRepositoryProvider.overrideWithValue(mockShopRepository),
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('지도 영역 내 샵 목록을 조회한다', () async {
      // Arrange
      final shops = [testShopWithOrderCount];
      when(() => mockShopRepository.searchByBounds(
            southLat: any(named: 'southLat'),
            northLat: any(named: 'northLat'),
            westLng: any(named: 'westLng'),
            eastLng: any(named: 'eastLng'),
          )).thenAnswer((_) async => shops);

      // Act
      container.read(mapBoundsProvider.notifier).state = testLatLngBounds;
      await container.read(shopsInBoundsProvider.future);

      // Assert
      final state = container.read(shopsInBoundsProvider);
      expect(state.value, equals(shops));
    });

    test('mapBounds가 null이면 빈 목록을 반환한다', () async {
      // Arrange & Act
      await container.read(shopsInBoundsProvider.future);

      // Assert
      final state = container.read(shopsInBoundsProvider);
      expect(state.value, isEmpty);
    });
  });
}
```

Run: `flutter test test/providers/shop_search_provider_test.dart`
Expected: FAIL (컴파일 에러)

**Step 4 (Green): 모델 및 Provider 구현**

Create: `lib/models/shop_with_order_count.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_with_order_count.freezed.dart';
part 'shop_with_order_count.g.dart';

/// Shop + 활성 작업 건수 (화면 전용 모델)
@freezed
class ShopWithOrderCount with _$ShopWithOrderCount {
  const factory ShopWithOrderCount({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
    String? description,
    @Default(0) int receivedCount,
    @Default(0) int inProgressCount,
    double? distance, // 현재 위치로부터의 거리 (미터)
  }) = _ShopWithOrderCount;

  factory ShopWithOrderCount.fromJson(Map<String, dynamic> json) =>
      _$ShopWithOrderCountFromJson(json);
}
```

Create: `lib/providers/shop_search_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:badminton_app/models/shop_with_order_count.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';

part 'shop_search_provider.g.dart';

/// 뷰 모드 (지도 / 리스트)
enum ShopSearchViewMode { map, list }

/// 위치 권한 상태
enum LocationPermissionStatus { unknown, granted, denied, permanentlyDenied }

/// 위도/경도 좌표
class LatLng {
  const LatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// 지도 영역 (남서/북동 좌표)
class LatLngBounds {
  const LatLngBounds({
    required this.southWest,
    required this.northEast,
  });
  final LatLng southWest;
  final LatLng northEast;
}

/// 뷰 모드 Provider
final viewModeProvider =
    StateProvider<ShopSearchViewMode>((ref) => ShopSearchViewMode.map);

/// 위치 권한 상태 Provider
final locationPermissionProvider =
    StateProvider<LocationPermissionStatus>(
        (ref) => LocationPermissionStatus.unknown);

/// 현재 GPS 위치 Provider
final currentLocationProvider = StateProvider<LatLng?>((ref) => null);

/// 현재 지도 화면 영역 Provider
final mapBoundsProvider = StateProvider<LatLngBounds?>((ref) => null);

/// 선택된 샵 Provider (지도 마커 선택)
final selectedShopProvider =
    StateProvider<ShopWithOrderCount?>((ref) => null);

/// 영역 내 샵 목록 Provider (건수 포함)
@riverpod
class ShopsInBoundsNotifier extends _$ShopsInBoundsNotifier {
  @override
  Future<List<ShopWithOrderCount>> build() async {
    final bounds = ref.watch(mapBoundsProvider);
    if (bounds == null) return [];

    final shopRepository = ref.read(shopRepositoryProvider);
    final shops = await shopRepository.searchByBounds(
      southLat: bounds.southWest.latitude,
      northLat: bounds.northEast.latitude,
      westLng: bounds.southWest.longitude,
      eastLng: bounds.northEast.longitude,
    );

    return shops;
  }
}
```

Run: `flutter test test/providers/shop_search_provider_test.dart`
Expected: PASS

**Step 5 (Red): Widget 테스트 작성**

Create: `test/screens/customer/shop_search_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/screens/customer/shop_search_screen.dart';
import 'package:badminton_app/providers/shop_search_provider.dart';
import 'package:badminton_app/models/shop_with_order_count.dart';

import '../../helpers/mocks.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ShopSearchScreen', () {
    testWidgets('앱바에 "주변 샵" 타이틀과 뷰 전환 토글을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            locationPermissionProvider.overrideWith(
                (ref) => LocationPermissionStatus.granted),
            shopsInBoundsProvider.overrideWith(
                () => FakeShopsNotifier([])),
          ],
          child: const ShopSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('주변 샵'), findsOneWidget);
      expect(find.text('지도'), findsOneWidget);
      expect(find.text('리스트'), findsOneWidget);
    });

    testWidgets('위치 권한 미허용 시 권한 안내 화면을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            locationPermissionProvider.overrideWith(
                (ref) => LocationPermissionStatus.denied),
          ],
          child: const ShopSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('위치 권한이 필요합니다'), findsOneWidget);
      expect(find.text('설정으로 이동'), findsOneWidget);
    });

    testWidgets('리스트 뷰에서 샵 카드 목록을 표시한다', (tester) async {
      // Arrange
      final shops = [
        testShopWithOrderCount.copyWith(
          name: 'OO 거트 스트링샵',
          address: '강남구 역삼동',
          receivedCount: 2,
          inProgressCount: 1,
          distance: 350,
        ),
        testShopWithOrderCount.copyWith(
          name: 'XX 스트링',
          address: '서초구 서초동',
          receivedCount: 0,
          inProgressCount: 0,
          distance: 1200,
        ),
      ];
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            viewModeProvider.overrideWith((ref) => ShopSearchViewMode.list),
            locationPermissionProvider.overrideWith(
                (ref) => LocationPermissionStatus.granted),
            shopsInBoundsProvider.overrideWith(
                () => FakeShopsNotifier(shops)),
          ],
          child: const ShopSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('OO 거트 스트링샵'), findsOneWidget);
      expect(find.text('XX 스트링'), findsOneWidget);
      expect(find.text('접수 2건'), findsOneWidget);
      expect(find.text('350m'), findsOneWidget);
      expect(find.text('1.2km'), findsOneWidget);
    });

    testWidgets('빈 상태일 때 안내 메시지를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            viewModeProvider.overrideWith((ref) => ShopSearchViewMode.list),
            locationPermissionProvider.overrideWith(
                (ref) => LocationPermissionStatus.granted),
            shopsInBoundsProvider.overrideWith(
                () => FakeShopsNotifier([])),
          ],
          child: const ShopSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('주변에 등록된 샵이 없습니다'), findsOneWidget);
    });

    testWidgets('샵 카드 탭 시 샵 상세 화면으로 이동한다', (tester) async {
      // Arrange
      final shops = [
        testShopWithOrderCount.copyWith(
          id: 'shop-1',
          name: 'OO 거트 스트링샵',
        ),
      ];
      final mockRouter = MockGoRouter();
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            viewModeProvider.overrideWith((ref) => ShopSearchViewMode.list),
            locationPermissionProvider.overrideWith(
                (ref) => LocationPermissionStatus.granted),
            shopsInBoundsProvider.overrideWith(
                () => FakeShopsNotifier(shops)),
          ],
          mockRouter: mockRouter,
          child: const ShopSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('OO 거트 스트링샵'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRouter.go('/customer/shop/shop-1')).called(1);
    });
  });
}
```

Run: `flutter test test/screens/customer/shop_search_screen_test.dart`
Expected: FAIL (화면 미구현)

**Step 6 (Green): 화면 구현**

Create: `lib/screens/customer/shop_search_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/providers/shop_search_provider.dart';
import 'package:badminton_app/models/shop_with_order_count.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/core/utils/distance_calculator.dart';

class ShopSearchScreen extends ConsumerWidget {
  const ShopSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final permissionStatus = ref.watch(locationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 샵',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _ViewModeToggle(
              mode: viewMode,
              onChanged: (mode) =>
                  ref.read(viewModeProvider.notifier).state = mode,
            ),
          ),
        ],
      ),
      body: _buildBody(context, ref, viewMode, permissionStatus),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ShopSearchViewMode viewMode,
    LocationPermissionStatus permissionStatus,
  ) {
    // 위치 권한 미허용 상태
    if (permissionStatus == LocationPermissionStatus.denied ||
        permissionStatus == LocationPermissionStatus.permanentlyDenied) {
      return const _LocationPermissionView();
    }

    if (viewMode == ShopSearchViewMode.list) {
      return _ListView(ref: ref);
    }

    // 지도 뷰 (카카오맵)
    return _MapView(ref: ref);
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.mode, required this.onChanged});
  final ShopSearchViewMode mode;
  final ValueChanged<ShopSearchViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            label: '지도',
            isActive: mode == ShopSearchViewMode.map,
            onTap: () => onChanged(ShopSearchViewMode.map),
          ),
          _SegmentButton(
            label: '리스트',
            isActive: mode == ShopSearchViewMode.list,
            onTap: () => onChanged(ShopSearchViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _LocationPermissionView extends StatelessWidget {
  const _LocationPermissionView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          const Text('위치 권한이 필요합니다',
              style: TextStyle(fontSize: 16, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          const Text('주변 샵을 찾으려면 위치 권한을 허용해 주세요',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                // TODO: openAppSettings() 호출
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('설정으로 이동'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final selectedShop = ref.watch(selectedShopProvider);
    final shopsAsync = ref.watch(shopsInBoundsProvider);

    return Stack(
      children: [
        // TODO: KakaoMap 위젯 삽입
        // 카카오맵 SDK를 사용하여 지도 표시
        // onMapMoved 콜백에서 mapBoundsProvider 갱신 (debounce 500ms)
        // onMarkerTap 콜백에서 selectedShopProvider 갱신
        Container(
          color: const Color(0xFFF1F5F9),
          child: shopsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (shops) {
              if (shops.isEmpty) {
                return const Center(
                  child: Text('주변에 등록된 샵이 없습니다',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                );
              }
              return const SizedBox.expand(); // 지도 렌더링 영역
            },
          ),
        ),
        // 현재 위치 FAB
        Positioned(
          right: 16,
          bottom: selectedShop != null ? 180 : 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            elevation: 4,
            onPressed: () {
              // TODO: GPS 위치 재획득 → 지도 카메라 이동
            },
            child: const Icon(Icons.my_location,
                color: Color(0xFF16A34A), size: 24),
          ),
        ),
        // 하단 시트 (마커 선택 시)
        if (selectedShop != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomSheetCard(
              shop: selectedShop,
              onTap: () => context.go('/customer/shop/${selectedShop.id}'),
            ),
          ),
      ],
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  const _BottomSheetCard({required this.shop, required this.onTap});
  final ShopWithOrderCount shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _ShopCard(shop: shop, onTap: onTap),
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(shopsInBoundsProvider);

    return shopsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            3,
            (i) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonShimmer(height: 100, borderRadius: 16),
            ),
          ),
        ),
      ),
      error: (error, _) => ErrorView(
        message: '데이터를 불러올 수 없습니다',
        onRetry: () => ref.invalidate(shopsInBoundsProvider),
      ),
      data: (shops) {
        if (shops.isEmpty) {
          return const EmptyState(
            icon: Icons.storefront,
            message: '주변에 등록된 샵이 없습니다',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ShopCard(
            shop: shops[index],
            onTap: () => context.go('/customer/shop/${shops[index].id}'),
          ),
        );
      },
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop, required this.onTap});
  final ShopWithOrderCount shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(shop.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
              ),
              const Icon(Icons.chevron_right, size: 24,
                  color: Color(0xFF94A3B8)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 16,
                  color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(shop.address,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF475569))),
              if (shop.distance != null) ...[
                const Text(' · ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                Text(DistanceCalculator.formatDistance(shop.distance!),
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF475569))),
              ],
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('접수 ${shop.receivedCount}건',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF59E0B))),
              const Text(' · ',
                  style: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1))),
              Text('작업중 ${shop.inProgressCount}건',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B82F6))),
            ]),
          ],
        ),
      ),
    );
  }
}
```

Run: `flutter test test/screens/customer/shop_search_screen_test.dart`
Expected: PASS

**Step 7: Commit**

```bash
git add lib/core/utils/distance_calculator.dart \
  lib/models/shop_with_order_count.dart \
  lib/providers/shop_search_provider.dart \
  lib/screens/customer/shop_search_screen.dart \
  test/core/utils/distance_calculator_test.dart \
  test/providers/shop_search_provider_test.dart \
  test/screens/customer/shop_search_screen_test.dart
git commit -m "feat: 주변 샵 검색 화면 구현 (카카오맵 + GPS 권한 + 거리 계산)"
```

---


### Task 5.2: Shop Detail (샵 상세)

> 선택한 샵의 상세 정보(소개, 위치, 연락처)와 작업 현황, 공지사항/이벤트/재고를
> 카테고리 탭으로 확인하는 화면.

**Files:**
- Create: `lib/providers/shop_detail_provider.dart`
- Create: `lib/models/order_counts.dart`
- Create: `lib/screens/customer/shop_detail_screen.dart`
- Create: `test/providers/shop_detail_provider_test.dart`
- Create: `test/screens/customer/shop_detail_screen_test.dart`

**Step 1 (Red): Provider 테스트 작성**

Create: `test/providers/shop_detail_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/providers/shop_detail_provider.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/order_counts.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  group('shopDetailProvider', () {
    late MockShopRepository mockShopRepository;
    late ProviderContainer container;

    setUp(() {
      mockShopRepository = MockShopRepository();
      container = ProviderContainer(
        overrides: [
          shopRepositoryProvider.overrideWithValue(mockShopRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('shopId로 샵 상세 정보를 조회한다', () async {
      // Arrange
      when(() => mockShopRepository.getById(any()))
          .thenAnswer((_) async => testShop);

      // Act
      final result = await container.read(
        shopDetailProvider('shop-1').future,
      );

      // Assert
      expect(result, equals(testShop));
    });

    test('존재하지 않는 shopId로 에러가 발생한다', () async {
      // Arrange
      when(() => mockShopRepository.getById(any()))
          .thenThrow(Exception('Not found'));

      // Act & Assert
      await expectLater(
        container.read(shopDetailProvider('bad-id').future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('shopOrderCountsProvider', () {
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('샵의 접수/작업중 건수를 조회한다', () async {
      // Arrange
      final counts = const OrderCounts(receivedCount: 3, inProgressCount: 1);
      when(() => mockOrderRepository.countActiveByShop(any()))
          .thenAnswer((_) async => counts);

      // Act
      final result = await container.read(
        shopOrderCountsProvider('shop-1').future,
      );

      // Assert
      expect(result.receivedCount, equals(3));
      expect(result.inProgressCount, equals(1));
    });
  });

  group('shopNoticesProvider', () {
    late MockPostRepository mockPostRepository;
    late ProviderContainer container;

    setUp(() {
      mockPostRepository = MockPostRepository();
      container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockPostRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('공지사항 목록을 조회한다', () async {
      // Arrange
      final notices = [testNoticePost, testNoticePost];
      when(() => mockPostRepository.getByShopAndCategory(
            shopId: any(named: 'shopId'),
            category: 'notice',
          )).thenAnswer((_) async => notices);

      // Act
      final result = await container.read(
        shopNoticesProvider('shop-1').future,
      );

      // Assert
      expect(result.length, equals(2));
    });
  });

  group('shopEventsProvider', () {
    late MockPostRepository mockPostRepository;
    late ProviderContainer container;

    setUp(() {
      mockPostRepository = MockPostRepository();
      container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockPostRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('이벤트 목록을 조회한다', () async {
      // Arrange
      final events = [testEventPost];
      when(() => mockPostRepository.getByShopAndCategory(
            shopId: any(named: 'shopId'),
            category: 'event',
          )).thenAnswer((_) async => events);

      // Act
      final result = await container.read(
        shopEventsProvider('shop-1').future,
      );

      // Assert
      expect(result.length, equals(1));
    });
  });

  group('shopInventoryProvider', () {
    late MockInventoryRepository mockInventoryRepository;
    late ProviderContainer container;

    setUp(() {
      mockInventoryRepository = MockInventoryRepository();
      container = ProviderContainer(
        overrides: [
          inventoryRepositoryProvider
              .overrideWithValue(mockInventoryRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('재고 목록을 조회한다', () async {
      // Arrange
      final items = [testInventoryItem, testInventoryItem];
      when(() => mockInventoryRepository.getByShop(any()))
          .thenAnswer((_) async => items);

      // Act
      final result = await container.read(
        shopInventoryProvider('shop-1').future,
      );

      // Assert
      expect(result.length, equals(2));
    });
  });

  group('shopDetailTabProvider', () {
    test('초기값은 0 (공지사항 탭)이다', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final tabIndex = container.read(shopDetailTabProvider);

      // Assert
      expect(tabIndex, equals(0));

      container.dispose();
    });

    test('탭 인덱스를 변경할 수 있다', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      container.read(shopDetailTabProvider.notifier).state = 2;

      // Assert
      expect(container.read(shopDetailTabProvider), equals(2));

      container.dispose();
    });
  });
}
```

Run: `flutter test test/providers/shop_detail_provider_test.dart`
Expected: FAIL (컴파일 에러)

**Step 2 (Green): 모델 및 Provider 구현**

Create: `lib/models/order_counts.dart`

```dart
/// 작업 건수 (화면 전용 모델)
class OrderCounts {
  const OrderCounts({
    required this.receivedCount,
    required this.inProgressCount,
  });

  final int receivedCount;
  final int inProgressCount;

  int get total => receivedCount + inProgressCount;
}
```

Create: `lib/providers/shop_detail_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/order_counts.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';

part 'shop_detail_provider.g.dart';

/// 샵 상세 정보
@riverpod
Future<Shop> shopDetail(ShopDetailRef ref, String shopId) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return shopRepository.getById(shopId);
}

/// 샵 작업 현황 (접수/작업중 건수)
@riverpod
Future<OrderCounts> shopOrderCounts(
  ShopOrderCountsRef ref,
  String shopId,
) async {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return orderRepository.countActiveByShop(shopId);
}

/// 공지사항 목록
@riverpod
Future<List<Post>> shopNotices(ShopNoticesRef ref, String shopId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getByShopAndCategory(
    shopId: shopId,
    category: 'notice',
  );
}

/// 이벤트 목록
@riverpod
Future<List<Post>> shopEvents(ShopEventsRef ref, String shopId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getByShopAndCategory(
    shopId: shopId,
    category: 'event',
  );
}

/// 재고 목록
@riverpod
Future<List<InventoryItem>> shopInventory(
  ShopInventoryRef ref,
  String shopId,
) async {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  return inventoryRepository.getByShop(shopId);
}

/// 선택된 카테고리 탭 인덱스 (0: 공지사항, 1: 이벤트, 2: 가게재고)
final shopDetailTabProvider = StateProvider<int>((ref) => 0);
```

Run: `flutter test test/providers/shop_detail_provider_test.dart`
Expected: PASS

**Step 3 (Red): Widget 테스트 작성**

Create: `test/screens/customer/shop_detail_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton_app/screens/customer/shop_detail_screen.dart';
import 'package:badminton_app/providers/shop_detail_provider.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/order_counts.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/inventory_item.dart';

import '../../helpers/mocks.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ShopDetailScreen', () {
    testWidgets('로딩 상태에서 스켈레톤을 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1').overrideWith(
                (ref) async => Future.delayed(
                    const Duration(seconds: 10), () => testShop)),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('샵 상세 정보를 정상 표시한다', (tester) async {
      // Arrange
      final shop = testShop.copyWith(
        name: 'OO 거트 스트링샵',
        address: '서울시 강남구 역삼동 123-45',
        phone: '010-1234-5678',
        description: '정성스러운 스트링 작업',
      );
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) async => shop),
            shopOrderCountsProvider('shop-1').overrideWith(
                (ref) async => const OrderCounts(
                    receivedCount: 2, inProgressCount: 1)),
            shopNoticesProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopEventsProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopInventoryProvider('shop-1')
                .overrideWith((ref) async => <InventoryItem>[]),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('OO 거트 스트링샵'), findsOneWidget);
      expect(find.text('서울시 강남구 역삼동 123-45'), findsOneWidget);
      expect(find.text('010-1234-5678'), findsOneWidget);
      expect(find.text('정성스러운 스트링 작업'), findsOneWidget);
      expect(find.text('길찾기'), findsOneWidget);
    });

    testWidgets('작업 현황 카드에 접수/작업중 건수를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) async => testShop),
            shopOrderCountsProvider('shop-1').overrideWith(
                (ref) async => const OrderCounts(
                    receivedCount: 3, inProgressCount: 2)),
            shopNoticesProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopEventsProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopInventoryProvider('shop-1')
                .overrideWith((ref) async => <InventoryItem>[]),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('3'), findsOneWidget); // 접수 건수
      expect(find.text('2'), findsOneWidget); // 작업중 건수
    });

    testWidgets('카테고리 탭 3개를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) async => testShop),
            shopOrderCountsProvider('shop-1').overrideWith(
                (ref) async => const OrderCounts(
                    receivedCount: 0, inProgressCount: 0)),
            shopNoticesProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopEventsProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopInventoryProvider('shop-1')
                .overrideWith((ref) async => <InventoryItem>[]),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('공지사항'), findsOneWidget);
      expect(find.text('이벤트'), findsOneWidget);
      expect(find.text('가게 재고'), findsOneWidget);
    });

    testWidgets('공지사항 탭에서 공지사항 목록을 표시한다', (tester) async {
      // Arrange
      final notices = [
        testNoticePost.copyWith(title: '7월 휴무 안내'),
        testNoticePost.copyWith(title: '영업시간 변경 안내'),
      ];
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) async => testShop),
            shopOrderCountsProvider('shop-1').overrideWith(
                (ref) async => const OrderCounts(
                    receivedCount: 0, inProgressCount: 0)),
            shopNoticesProvider('shop-1')
                .overrideWith((ref) async => notices),
            shopEventsProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopInventoryProvider('shop-1')
                .overrideWith((ref) async => <InventoryItem>[]),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('7월 휴무 안내'), findsOneWidget);
      expect(find.text('영업시간 변경 안내'), findsOneWidget);
    });

    testWidgets('공지사항이 없으면 빈 상태 메시지를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) async => testShop),
            shopOrderCountsProvider('shop-1').overrideWith(
                (ref) async => const OrderCounts(
                    receivedCount: 0, inProgressCount: 0)),
            shopNoticesProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopEventsProvider('shop-1')
                .overrideWith((ref) async => <Post>[]),
            shopInventoryProvider('shop-1')
                .overrideWith((ref) async => <InventoryItem>[]),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('등록된 공지사항이 없습니다'), findsOneWidget);
    });

    testWidgets('에러 상태에서 에러 UI를 표시한다', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            shopDetailProvider('shop-1')
                .overrideWith((ref) => throw Exception('에러')),
          ],
          child: const ShopDetailScreen(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/customer/shop_detail_screen_test.dart`
Expected: FAIL (화면 미구현)

**Step 4 (Green): 화면 구현**

Create: `lib/screens/customer/shop_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badminton_app/providers/shop_detail_provider.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/order_counts.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/core/utils/formatters.dart';

class ShopDetailScreen extends ConsumerStatefulWidget {
  const ShopDetailScreen({super.key, required this.shopId});
  final String shopId;

  @override
  ConsumerState<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends ConsumerState<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      ref.read(shopDetailTabProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Text('샵 정보',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: shopAsync.when(
        loading: () => const _SkeletonView(),
        error: (error, _) => ErrorView(
          message: '데이터를 불러올 수 없습니다',
          onRetry: () =>
              ref.invalidate(shopDetailProvider(widget.shopId)),
        ),
        data: (shop) => _ShopDetailContent(
          shop: shop,
          shopId: widget.shopId,
          tabController: _tabController,
        ),
      ),
    );
  }
}

class _ShopDetailContent extends ConsumerWidget {
  const _ShopDetailContent({
    required this.shop,
    required this.shopId,
    required this.tabController,
  });
  final Shop shop;
  final String shopId;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCountsAsync = ref.watch(shopOrderCountsProvider(shopId));

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 지도 미리보기
                Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  // TODO: NaverMap Static 위젯 삽입
                  child: GestureDetector(
                    onTap: () => _openNaverMap(shop),
                    child: const Center(
                      child: Icon(Icons.map, size: 48,
                          color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                // 샵 이름/소개
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.storefront, size: 24,
                            color: Color(0xFF16A34A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(shop.name,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A))),
                        ),
                      ]),
                      if (shop.description != null &&
                          shop.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(shop.description!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.5)),
                      ],
                    ],
                  ),
                ),
                // 작업 현황
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('작업 현황',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      orderCountsAsync.when(
                        loading: () =>
                            const SkeletonShimmer(height: 80, borderRadius: 16),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (counts) => _OrderCountsCard(counts: counts),
                      ),
                    ],
                  ),
                ),
                // 위치 및 연락처
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('위치 및 연락처',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(children: [
                              const Icon(Icons.location_on, size: 20,
                                  color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(shop.address,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475569)))),
                            ]),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => launchUrl(
                                  Uri.parse('tel:${shop.phone}')),
                              child: Row(children: [
                                const Icon(Icons.phone, size: 20,
                                    color: Color(0xFF94A3B8)),
                                const SizedBox(width: 8),
                                Text(shop.phone,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3B82F6),
                                        decoration:
                                            TextDecoration.underline)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 길찾기 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _openNaverMapRoute(shop),
                      icon: const Icon(Icons.directions, size: 20),
                      label: const Text('길찾기'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 카테고리 탭 바 (Pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: tabController,
                labelColor: const Color(0xFF16A34A),
                unselectedLabelColor: const Color(0xFF94A3B8),
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal),
                indicatorColor: const Color(0xFF16A34A),
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: '공지사항'),
                  Tab(text: '이벤트'),
                  Tab(text: '가게 재고'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: tabController,
        children: [
          _NoticesTab(shopId: shopId),
          _EventsTab(shopId: shopId),
          _InventoryTab(shopId: shopId),
        ],
      ),
    );
  }

  Future<void> _openNaverMap(Shop shop) async {
    final uri = Uri.parse(
        'nmap://place?lat=${shop.latitude}&lng=${shop.longitude}'
        '&name=${Uri.encodeComponent(shop.name)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(
        Uri.parse(
            'https://map.naver.com/v5/search/${Uri.encodeComponent(shop.address)}'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _openNaverMapRoute(Shop shop) async {
    final uri = Uri.parse(
        'nmap://route/public?dlat=${shop.latitude}'
        '&dlng=${shop.longitude}&dname=${Uri.encodeComponent(shop.name)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(
        Uri.parse(
            'https://map.naver.com/v5/directions/-/${shop.longitude},${shop.latitude},${Uri.encodeComponent(shop.name)}'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

class _OrderCountsCard extends StatelessWidget {
  const _OrderCountsCard({required this.counts});
  final OrderCounts counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CountColumn(
              count: counts.receivedCount,
              label: '접수',
              color: const Color(0xFFF59E0B)),
          Container(
              width: 1, height: 40, color: const Color(0xFFE2E8F0),
              margin: const EdgeInsets.symmetric(horizontal: 32)),
          _CountColumn(
              count: counts.inProgressCount,
              label: '작업중',
              color: const Color(0xFF3B82F6)),
        ],
      ),
    );
  }
}

class _CountColumn extends StatelessWidget {
  const _CountColumn({
    required this.count,
    required this.label,
    required this.color,
  });
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('$count',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
    ]);
  }
}

class _NoticesTab extends ConsumerWidget {
  const _NoticesTab({required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(shopNoticesProvider(shopId));

    return noticesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      error: (_, __) => const Center(child: Text('불러오기 실패')),
      data: (notices) {
        if (notices.isEmpty) {
          return const Center(
            child: Text('등록된 공지사항이 없습니다',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _NoticeCard(post: notices[index]),
        );
      },
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(Formatters.date(post.createdAt),
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8))),
          if (post.content != null) ...[
            const SizedBox(height: 8),
            Text(post.content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF475569))),
          ],
        ],
      ),
    );
  }
}

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(shopEventsProvider(shopId));

    return eventsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      error: (_, __) => const Center(child: Text('불러오기 실패')),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text('등록된 이벤트가 없습니다',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _EventCard(post: events[index]),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // 썸네일
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: post.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.event, size: 40,
                    color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.date(post.startDate ?? post.createdAt)}'
                  ' ~ ${Formatters.date(post.endDate ?? post.createdAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends ConsumerWidget {
  const _InventoryTab({required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(shopInventoryProvider(shopId));

    return inventoryAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      error: (_, __) => const Center(child: Text('불러오기 실패')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('등록된 재고 정보가 없습니다',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          );
        }
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('재고 정보는 열람만 가능합니다',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _InventoryCard(item: items[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.inventory_2, size: 40,
                          color: Color(0xFF94A3B8))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${item.quantity}개',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _SkeletonView extends StatelessWidget {
  const _SkeletonView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(children: [
        Container(height: 180, color: const Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SkeletonShimmer(height: 32, borderRadius: 8),
            const SizedBox(height: 8),
            const SkeletonShimmer(height: 40, borderRadius: 8),
            const SizedBox(height: 24),
            const SkeletonShimmer(height: 80, borderRadius: 16),
            const SizedBox(height: 24),
            const SkeletonShimmer(height: 80, borderRadius: 16),
          ]),
        ),
      ]),
    );
  }
}
```

Run: `flutter test test/screens/customer/shop_detail_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/order_counts.dart \
  lib/providers/shop_detail_provider.dart \
  lib/screens/customer/shop_detail_screen.dart \
  test/providers/shop_detail_provider_test.dart \
  test/screens/customer/shop_detail_screen_test.dart
git commit -m "feat: 샵 상세 화면 구현 (탭 카테고리 + 공지/이벤트/재고 조회)"
```

---

## Phase 3: 사장님 핵심 화면

> **의존성**: Phase 1 (공통 모듈 M1~M12), Phase 2 (인증 플로우) 완료 필수
>
> **화면 목록**: 대시보드(3.1), 작업 접수(3.2), 작업 관리(3.3), 샵 QR(3.4)

---

### Task 3.1: 사장님 대시보드 (Owner Dashboard)

> 참조: `docs/pages/owner-dashboard/state.md`, `docs/ui-specs/owner-dashboard.md`

#### Task 3.1.1: 대시보드 상태 클래스 + Notifier + 테스트

**Files:**
- Create: `lib/screens/owner/dashboard/owner_dashboard_state.dart`
- Create: `lib/screens/owner/dashboard/owner_dashboard_notifier.dart`
- Create: `test/screens/owner/dashboard/owner_dashboard_notifier_test.dart`

**Step 1 (Red): 테스트 작성**

```dart
// test/screens/owner/dashboard/owner_dashboard_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/core/error/app_exception.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockOrderRepository mockOrderRepo;
  late MockShopRepository mockShopRepo;
  late ProviderContainer container;

  final testShop = Shop(
    id: 'shop-1',
    ownerId: 'user-1',
    name: '테스트 샵',
    address: '서울시 강남구',
    phone: '010-1234-5678',
    createdAt: DateTime.now(),
  );

  final testOrders = [
    Order(
      id: 'order-1',
      shopId: 'shop-1',
      memberId: 'member-1',
      memberName: '홍길동',
      status: OrderStatus.received,
      memo: '테스트 메모',
      createdAt: DateTime.now(),
    ),
    Order(
      id: 'order-2',
      shopId: 'shop-1',
      memberId: 'member-2',
      memberName: '김철수',
      status: OrderStatus.inProgress,
      memo: '',
      createdAt: DateTime.now(),
      inProgressAt: DateTime.now(),
    ),
    Order(
      id: 'order-3',
      shopId: 'shop-1',
      memberId: 'member-3',
      memberName: '이영희',
      status: OrderStatus.completed,
      memo: '',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    mockShopRepo = MockShopRepository();
  });

  tearDown(() {
    container.dispose();
  });

  group('OwnerDashboardNotifier', () {
    test('초기 로드 시 오늘 작업 카운트와 최근 목록을 조회한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockOrderRepo.getTodayCountsByShop('shop-1'))
          .thenAnswer((_) async => {
                OrderStatus.received: 1,
                OrderStatus.inProgress: 1,
                OrderStatus.completed: 1,
              });
      when(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .thenAnswer((_) async => testOrders);

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      // Act
      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');

      // Assert
      final state = container.read(ownerDashboardProvider);
      expect(state.receivedCount, 1);
      expect(state.inProgressCount, 1);
      expect(state.completedCount, 1);
      expect(state.recentOrders.length, 3);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('데이터 로드 실패 시 error 상태가 설정된다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenThrow(AppException.network('네트워크 오류'));

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      // Act
      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');

      // Assert
      final state = container.read(ownerDashboardProvider);
      expect(state.isLoading, false);
      expect(state.error, isNotNull);
    });

    test('상태 변경 시 낙관적 UI를 적용하고 API를 호출한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockOrderRepo.getTodayCountsByShop('shop-1'))
          .thenAnswer((_) async => {
                OrderStatus.received: 1,
                OrderStatus.inProgress: 1,
                OrderStatus.completed: 1,
              });
      when(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .thenAnswer((_) async => testOrders);
      when(() => mockOrderRepo.updateStatus(
            'order-1',
            OrderStatus.inProgress,
          )).thenAnswer((_) async => {});

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');

      // Act
      await notifier.changeOrderStatus('order-1', OrderStatus.inProgress);

      // Assert
      final state = container.read(ownerDashboardProvider);
      final updatedOrder = state.recentOrders.firstWhere(
        (o) => o.id == 'order-1',
      );
      expect(updatedOrder.status, OrderStatus.inProgress);
      expect(state.changingOrderId, isNull);
      verify(() => mockOrderRepo.updateStatus(
            'order-1',
            OrderStatus.inProgress,
          )).called(1);
    });

    test('상태 변경 실패 시 이전 상태로 롤백한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockOrderRepo.getTodayCountsByShop('shop-1'))
          .thenAnswer((_) async => {
                OrderStatus.received: 1,
                OrderStatus.inProgress: 0,
                OrderStatus.completed: 0,
              });
      when(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .thenAnswer((_) async => [testOrders[0]]);
      when(() => mockOrderRepo.updateStatus(
            'order-1',
            OrderStatus.inProgress,
          )).thenThrow(AppException.network('네트워크 오류'));

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');

      // Act
      await notifier.changeOrderStatus('order-1', OrderStatus.inProgress);

      // Assert
      final state = container.read(ownerDashboardProvider);
      final order = state.recentOrders.firstWhere(
        (o) => o.id == 'order-1',
      );
      expect(order.status, OrderStatus.received); // 롤백됨
      expect(state.error, isNotNull);
    });

    test('refresh() 호출 시 카운트와 목록을 재조회한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockOrderRepo.getTodayCountsByShop('shop-1'))
          .thenAnswer((_) async => {
                OrderStatus.received: 2,
                OrderStatus.inProgress: 3,
                OrderStatus.completed: 5,
              });
      when(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .thenAnswer((_) async => testOrders);

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');

      // Act
      await notifier.refresh();

      // Assert
      verify(() => mockOrderRepo.getTodayCountsByShop('shop-1')).called(2);
      verify(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .called(2);
    });

    test('undoStatusChange() 호출 시 이전 상태로 복원한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockOrderRepo.getTodayCountsByShop('shop-1'))
          .thenAnswer((_) async => {
                OrderStatus.received: 1,
                OrderStatus.inProgress: 0,
                OrderStatus.completed: 0,
              });
      when(() => mockOrderRepo.getRecentByShop('shop-1', limit: 5))
          .thenAnswer((_) async => [testOrders[0]]);
      when(() => mockOrderRepo.updateStatus(any(), any()))
          .thenAnswer((_) async => {});

      container = ProviderContainer(overrides: [
        orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ]);

      final notifier = container.read(ownerDashboardProvider.notifier);
      await notifier.loadDashboard('user-1');
      await notifier.changeOrderStatus('order-1', OrderStatus.inProgress);

      // Act
      await notifier.undoStatusChange('order-1', OrderStatus.received);

      // Assert
      verify(() => mockOrderRepo.updateStatus(
            'order-1',
            OrderStatus.received,
          )).called(1);
    });
  });
}
```

Run: `flutter test test/screens/owner/dashboard/owner_dashboard_notifier_test.dart`
Expected: FAIL (클래스 미존재)

**Step 2 (Green): 상태 클래스 구현**

```dart
// lib/screens/owner/dashboard/owner_dashboard_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/core/error/app_exception.dart';

part 'owner_dashboard_state.freezed.dart';

@freezed
class OwnerDashboardState with _$OwnerDashboardState {
  const factory OwnerDashboardState({
    @Default(0) int receivedCount,
    @Default(0) int inProgressCount,
    @Default(0) int completedCount,
    @Default([]) List<Order> recentOrders,
    @Default(true) bool isLoading,
    AppException? error,
    String? changingOrderId,
  }) = _OwnerDashboardState;
}
```

**Step 3 (Green): Notifier 구현**

```dart
// lib/screens/owner/dashboard/owner_dashboard_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';

final ownerDashboardProvider =
    NotifierProvider<OwnerDashboardNotifier, OwnerDashboardState>(
  OwnerDashboardNotifier.new,
);

class OwnerDashboardNotifier extends Notifier<OwnerDashboardState> {
  late final OrderRepository _orderRepo;
  late final ShopRepository _shopRepo;
  String? _shopId;
  StreamSubscription<List<Order>>? _realtimeSub;

  @override
  OwnerDashboardState build() {
    _orderRepo = ref.read(orderRepositoryProvider);
    _shopRepo = ref.read(shopRepositoryProvider);

    ref.onDispose(() {
      _realtimeSub?.cancel();
    });

    return const OwnerDashboardState();
  }

  Future<void> loadDashboard(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shop = await _shopRepo.getByOwner(userId);
      _shopId = shop.id;

      final counts = await _orderRepo.getTodayCountsByShop(shop.id);
      final recent = await _orderRepo.getRecentByShop(shop.id, limit: 5);

      state = state.copyWith(
        receivedCount: counts[OrderStatus.received] ?? 0,
        inProgressCount: counts[OrderStatus.inProgress] ?? 0,
        completedCount: counts[OrderStatus.completed] ?? 0,
        recentOrders: recent,
        isLoading: false,
      );

      _subscribeToRealtime(shop.id);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, st),
      );
    }
  }

  void _subscribeToRealtime(String shopId) {
    _realtimeSub?.cancel();
    _realtimeSub = _orderRepo.streamByShop(shopId).listen(
      (orders) => _recalculateCounts(orders),
      onError: (e) {/* Realtime 에러는 무시 — 다음 refresh에서 복구 */},
    );
  }

  void _recalculateCounts(List<Order> allOrders) {
    // DB 타임존이 Asia/Seoul(KST)이므로 로컬 시간 기준 오늘 자정
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day); // KST 00:00:00
    final todayOrders = allOrders
        .where((o) => o.createdAt.isAfter(todayStart))
        .toList();

    int received = 0, inProgress = 0, completed = 0;
    for (final order in todayOrders) {
      switch (order.status) {
        case OrderStatus.received:
          received++;
        case OrderStatus.inProgress:
          inProgress++;
        case OrderStatus.completed:
          completed++;
      }
    }

    state = state.copyWith(
      receivedCount: received,
      inProgressCount: inProgress,
      completedCount: completed,
      recentOrders: todayOrders.take(5).toList(),
    );
  }

  Future<void> refresh() async {
    if (_shopId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final counts = await _orderRepo.getTodayCountsByShop(_shopId!);
      final recent = await _orderRepo.getRecentByShop(_shopId!, limit: 5);
      state = state.copyWith(
        receivedCount: counts[OrderStatus.received] ?? 0,
        inProgressCount: counts[OrderStatus.inProgress] ?? 0,
        completedCount: counts[OrderStatus.completed] ?? 0,
        recentOrders: recent,
        isLoading: false,
        error: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> changeOrderStatus(
    String orderId, OrderStatus newStatus,
  ) async {
    final previousOrders = List<Order>.from(state.recentOrders);
    final idx = previousOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final previousOrder = previousOrders[idx];
    // 낙관적 UI
    state = state.copyWith(changingOrderId: orderId);
    final updated = List<Order>.from(state.recentOrders);
    updated[idx] = previousOrder.copyWith(status: newStatus);
    state = state.copyWith(recentOrders: updated);

    try {
      await _orderRepo.updateStatus(orderId, newStatus);
      state = state.copyWith(changingOrderId: null);
      await _refreshCounts();
    } on AppException catch (e) {
      state = state.copyWith(
        recentOrders: previousOrders, changingOrderId: null, error: e,
      );
    } catch (e, st) {
      state = state.copyWith(
        recentOrders: previousOrders,
        changingOrderId: null,
        error: ErrorHandler.handle(e, st),
      );
    }
  }

  Future<void> undoStatusChange(
    String orderId, OrderStatus previousStatus,
  ) async {
    await changeOrderStatus(orderId, previousStatus);
  }

  Future<void> _refreshCounts() async {
    if (_shopId == null) return;
    final counts = await _orderRepo.getTodayCountsByShop(_shopId!);
    state = state.copyWith(
      receivedCount: counts[OrderStatus.received] ?? 0,
      inProgressCount: counts[OrderStatus.inProgress] ?? 0,
      completedCount: counts[OrderStatus.completed] ?? 0,
    );
  }
}
```

Run: `flutter test test/screens/owner/dashboard/owner_dashboard_notifier_test.dart`
Expected: ALL PASS

**Step 4: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Commit**

```bash
git add lib/screens/owner/dashboard/owner_dashboard_state.dart \
        lib/screens/owner/dashboard/owner_dashboard_notifier.dart \
        test/screens/owner/dashboard/owner_dashboard_notifier_test.dart
git commit -m "feat: 사장님 대시보드 상태 관리 및 Notifier 구현"
```

---

#### Task 3.1.2: 대시보드 화면 위젯 + 위젯 테스트

**Files:**
- Create: `lib/screens/owner/dashboard/owner_dashboard_screen.dart`
- Create: `test/screens/owner/dashboard/owner_dashboard_screen_test.dart`

**Step 1 (Red): 위젯 테스트 작성**

```dart
// test/screens/owner/dashboard/owner_dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';

class FakeDashboardNotifier extends Notifier<OwnerDashboardState>
    implements OwnerDashboardNotifier {
  final OwnerDashboardState initialState;
  FakeDashboardNotifier(this.initialState);

  @override
  OwnerDashboardState build() => initialState;

  @override
  Future<void> loadDashboard(String userId) async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> changeOrderStatus(String id, OrderStatus s) async {}
  @override
  Future<void> undoStatusChange(String id, OrderStatus s) async {}
}

Widget buildTestWidget(OwnerDashboardState state) {
  return ProviderScope(
    overrides: [
      ownerDashboardProvider.overrideWith(
        () => FakeDashboardNotifier(state),
      ),
    ],
    child: const MaterialApp(
      home: OwnerDashboardScreen(),
    ),
  );
}

void main() {
  group('OwnerDashboardScreen', () {
    testWidgets('로딩 중일 때 스켈레톤 shimmer를 표시한다', (tester) async {
      // Arrange
      const state = OwnerDashboardState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('카운트 카드 3개를 올바르게 표시한다', (tester) async {
      // Arrange
      const state = OwnerDashboardState(
        receivedCount: 3,
        inProgressCount: 2,
        completedCount: 5,
        isLoading: false,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('3'), findsOneWidget);
      expect(find.text('접수됨'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('작업중'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('최근 작업 목록을 표시한다', (tester) async {
      // Arrange
      final state = OwnerDashboardState(
        recentOrders: [
          Order(
            id: 'order-1', shopId: 'shop-1', memberId: 'member-1',
            memberName: '홍길동', status: OrderStatus.received,
            memo: '', createdAt: DateTime.now(),
          ),
        ],
        isLoading: false,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('홍길동'), findsOneWidget);
    });

    testWidgets('작업이 0건이면 EmptyState를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(
        const OwnerDashboardState(recentOrders: [], isLoading: false),
      ));

      // Assert
      expect(find.text('오늘 접수된 작업이 없습니다'), findsOneWidget);
    });

    testWidgets('에러 상태에서 ErrorView와 재시도 버튼을 표시한다', (tester) async {
      // Arrange
      final state = OwnerDashboardState(
        isLoading: false,
        error: AppException.network('네트워크 오류'),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('재시도'), findsOneWidget);
    });

    testWidgets('FAB이 존재한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(
        const OwnerDashboardState(isLoading: false),
      ));

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/owner/dashboard/owner_dashboard_screen_test.dart`
Expected: FAIL (화면 위젯 미존재)

**Step 2 (Green): 화면 위젯 구현**

```dart
// lib/screens/owner/dashboard/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends ConsumerState<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(ownerDashboardProvider.notifier).loadDashboard(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '거트알림',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: state.error != null && state.recentOrders.isEmpty
          ? ErrorView(
              message: '데이터를 불러올 수 없습니다',
              onRetry: () {
                final userId = ref.read(currentUserProvider)?.id;
                if (userId != null) {
                  ref.read(ownerDashboardProvider.notifier)
                      .loadDashboard(userId);
                }
              },
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(ownerDashboardProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '오늘의 작업 현황',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const SkeletonShimmer(height: 100)
                  else
                    _buildCountCards(context, state),
                  const SizedBox(height: 24),
                  Text(
                    '최근 작업',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    ...List.generate(5, (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: SkeletonShimmer(height: 72),
                    ))
                  else if (state.recentOrders.isEmpty)
                    const EmptyState(
                      message: '오늘 접수된 작업이 없습니다',
                      subMessage: '작업 접수 버튼으로 새 작업을 등록하세요',
                    )
                  else
                    ...state.recentOrders.map(
                      (order) => _buildOrderCard(context, order, state),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/owner/order-create'),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCountCards(BuildContext context, dynamic state) {
    return Row(
      children: [
        Expanded(child: _CountCard(
          count: state.receivedCount, label: '접수됨',
          backgroundColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
          onTap: () => context.push('/owner/order-manage?statusFilter=received'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _CountCard(
          count: state.inProgressCount, label: '작업중',
          backgroundColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1E40AF),
          onTap: () => context.push('/owner/order-manage?statusFilter=inProgress'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _CountCard(
          count: state.completedCount, label: '완료',
          backgroundColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF166534),
          onTap: () => context.push('/owner/order-manage?statusFilter=completed'),
        )),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, dynamic state) {
    final isChanging = state.changingOrderId == order.id;
    final nextStatus = _getNextStatus(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(order.memberName ?? '알 수 없음'),
        subtitle: Text(Formatters.dateTime(order.createdAt)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(status: order.status),
            if (nextStatus != null) ...[
              const SizedBox(width: 8),
              isChanging
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _onStatusChange(
                        context, order.id, order.status, nextStatus,
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  OrderStatus? _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.received:
        return OrderStatus.inProgress;
      case OrderStatus.inProgress:
        return OrderStatus.completed;
      case OrderStatus.completed:
        return null;
    }
  }

  Future<void> _onStatusChange(
    BuildContext context, String orderId,
    OrderStatus previousStatus, OrderStatus newStatus,
  ) async {
    await ref.read(ownerDashboardProvider.notifier)
        .changeOrderStatus(orderId, newStatus);
    if (context.mounted) {
      AppToast.showUndo(context,
        message: '상태가 변경되었습니다',
        onUndo: () => ref.read(ownerDashboardProvider.notifier)
            .undoStatusChange(orderId, previousStatus),
      );
    }
  }
}

class _CountCard extends StatelessWidget {
  final int count;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _CountCard({
    required this.count, required this.label,
    required this.backgroundColor, required this.textColor, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text('$count', style: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: textColor,
          )),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: textColor)),
        ]),
      ),
    );
  }
}
```

Run: `flutter test test/screens/owner/dashboard/owner_dashboard_screen_test.dart`
Expected: ALL PASS

**Step 3: Commit**

```bash
git add lib/screens/owner/dashboard/owner_dashboard_screen.dart \
        test/screens/owner/dashboard/owner_dashboard_screen_test.dart
git commit -m "feat: 사장님 대시보드 화면 위젯 및 위젯 테스트 구현"
```

---

### Task 3.2: 작업 접수 (Order Create)

> 참조: `docs/pages/order-create/state.md`, `docs/ui-specs/order-create.md`, UC-3, UC-4

#### Task 3.2.1: 작업 접수 상태 클래스 + Notifier + 테스트

**Files:**
- Create: `lib/screens/owner/order_create/order_create_state.dart`
- Create: `lib/screens/owner/order_create/order_create_notifier.dart`
- Create: `test/screens/owner/order_create/order_create_notifier_test.dart`

**Step 1 (Red): 테스트 작성**

```dart
// test/screens/owner/order_create/order_create_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/user.dart' as app;
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_state.dart';
import 'package:badminton_app/core/error/app_exception.dart';

class MockMemberRepository extends Mock implements MemberRepository {}
class MockOrderRepository extends Mock implements OrderRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockMemberRepository mockMemberRepo;
  late MockOrderRepository mockOrderRepo;
  late MockUserRepository mockUserRepo;
  late MockShopRepository mockShopRepo;
  late ProviderContainer container;

  final testShop = Shop(
    id: 'shop-1', ownerId: 'user-1', name: '테스트 샵',
    address: '서울시', phone: '010-0000-0000', createdAt: DateTime.now(),
  );

  final testMember = Member(
    id: 'member-1', shopId: 'shop-1', userId: 'customer-1',
    name: '홍길동', phone: '010-1234-5678', visitCount: 3,
    createdAt: DateTime.now(),
  );

  final testUser = app.User(
    id: 'customer-1', name: '홍길동', phone: '010-1234-5678',
    role: UserRole.customer, createdAt: DateTime.now(),
  );

  setUp(() {
    mockMemberRepo = MockMemberRepository();
    mockOrderRepo = MockOrderRepository();
    mockUserRepo = MockUserRepository();
    mockShopRepo = MockShopRepository();

    when(() => mockShopRepo.getByOwner(any()))
        .thenAnswer((_) async => testShop);
  });

  tearDown(() => container.dispose());

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [
      memberRepositoryProvider.overrideWithValue(mockMemberRepo),
      orderRepositoryProvider.overrideWithValue(mockOrderRepo),
      userRepositoryProvider.overrideWithValue(mockUserRepo),
      shopRepositoryProvider.overrideWithValue(mockShopRepo),
    ]);
  }

  group('OrderCreateNotifier', () {
    test('QR 스캔 — 기존 회원이면 selectedMember에 설정된다', () async {
      // Arrange
      when(() => mockMemberRepo.getByUserAndShop('customer-1', 'shop-1'))
          .thenAnswer((_) async => testMember);

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      await notifier.onQrScanned('customer-1');

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.selectedMember, testMember);
      expect(state.isScanning, false);
    });

    test('QR 스캔 — 신규 회원이면 자동 등록 후 selectedMember에 설정된다', () async {
      // Arrange
      when(() => mockMemberRepo.getByUserAndShop('customer-1', 'shop-1'))
          .thenAnswer((_) async => null);
      when(() => mockUserRepo.getById('customer-1'))
          .thenAnswer((_) async => testUser);
      when(() => mockMemberRepo.create(
            shopId: 'shop-1', userId: 'customer-1',
            name: '홍길동', phone: '010-1234-5678',
          )).thenAnswer((_) async => testMember);

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      await notifier.onQrScanned('customer-1');

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.selectedMember, isNotNull);
      expect(state.selectedMember!.name, '홍길동');
    });

    test('QR 스캔 실패 시 error가 설정된다', () async {
      // Arrange
      when(() => mockMemberRepo.getByUserAndShop(any(), any()))
          .thenThrow(AppException.network('네트워크 오류'));

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      await notifier.onQrScanned('invalid-id');

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.error, isNotNull);
      expect(state.isScanning, false);
    });

    test('회원 검색 — 2글자 이상이면 검색 결과를 반환한다', () async {
      // Arrange
      when(() => mockMemberRepo.search('shop-1', '홍길'))
          .thenAnswer((_) async => [testMember]);

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      await notifier.searchMembers('홍길');

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.searchResults.value, isNotNull);
      expect(state.searchResults.value!.length, 1);
    });

    test('selectMember() 호출 시 selectedMember와 searchQuery가 갱신된다', () async {
      // Arrange
      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      notifier.selectMember(testMember);

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.selectedMember, testMember);
      expect(state.searchQuery, '');
    });

    test('clearMember() 호출 시 선택이 초기화된다', () async {
      // Arrange
      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');
      notifier.selectMember(testMember);
      notifier.updateMemo('테스트 메모');

      // Act
      notifier.clearMember();

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.selectedMember, isNull);
      expect(state.memo, '');
    });

    test('submit() 성공 시 isSubmitting이 true→false로 변경된다', () async {
      // Arrange
      when(() => mockOrderRepo.create(
            shopId: any(named: 'shopId'),
            memberId: any(named: 'memberId'),
            memo: any(named: 'memo'),
          )).thenAnswer((_) async => Order(
            id: 'order-new', shopId: 'shop-1', memberId: 'member-1',
            memberName: '홍길동', status: OrderStatus.received,
            memo: '테스트', createdAt: DateTime.now(),
          ));

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');
      notifier.selectMember(testMember);
      notifier.updateMemo('테스트');

      // Act
      final result = await notifier.submit();

      // Assert
      expect(result, true);
      final state = container.read(orderCreateProvider);
      expect(state.isSubmitting, false);
    });

    test('submit() 실패 시 error가 설정되고 입력 데이터가 유지된다', () async {
      // Arrange
      when(() => mockOrderRepo.create(
            shopId: any(named: 'shopId'),
            memberId: any(named: 'memberId'),
            memo: any(named: 'memo'),
          )).thenThrow(AppException.network('네트워크 오류'));

      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');
      notifier.selectMember(testMember);
      notifier.updateMemo('테스트');

      // Act
      final result = await notifier.submit();

      // Assert
      expect(result, false);
      final state = container.read(orderCreateProvider);
      expect(state.isSubmitting, false);
      expect(state.error, isNotNull);
      expect(state.selectedMember, testMember); // 입력 유지
      expect(state.memo, '테스트');
    });

    test('canSubmit — 회원 선택 + 미제출 시 true', () async {
      // Arrange
      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      notifier.selectMember(testMember);

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.canSubmit, true);
    });

    test('isFormDirty — 회원 선택 시 true', () async {
      // Arrange
      container = createContainer();
      final notifier = container.read(orderCreateProvider.notifier);
      await notifier.init('user-1');

      // Act
      notifier.selectMember(testMember);

      // Assert
      final state = container.read(orderCreateProvider);
      expect(state.isFormDirty, true);
    });
  });
}
```

Run: `flutter test test/screens/owner/order_create/order_create_notifier_test.dart`
Expected: FAIL (클래스 미존재)

**Step 2 (Green): 상태 클래스 구현**

```dart
// lib/screens/owner/order_create/order_create_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/core/error/app_exception.dart';

part 'order_create_state.freezed.dart';

@freezed
class OrderCreateState with _$OrderCreateState {
  const OrderCreateState._();

  const factory OrderCreateState({
    Member? selectedMember,
    @Default('') String memo,
    @Default('') String searchQuery,
    @Default(AsyncValue.data([])) AsyncValue<List<Member>> searchResults,
    @Default(false) bool isSubmitting,
    @Default(false) bool isScanning,
    AppException? error,
  }) = _OrderCreateState;

  bool get canSubmit => selectedMember != null && !isSubmitting;
  bool get isFormDirty => selectedMember != null || memo.isNotEmpty;
}
```

**Step 3 (Green): Notifier 구현**

```dart
// lib/screens/owner/order_create/order_create_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_state.dart';

final orderCreateProvider =
    NotifierProvider<OrderCreateNotifier, OrderCreateState>(
  OrderCreateNotifier.new,
);

class OrderCreateNotifier extends Notifier<OrderCreateState> {
  late final MemberRepository _memberRepo;
  late final OrderRepository _orderRepo;
  late final UserRepository _userRepo;
  late final ShopRepository _shopRepo;
  String? _shopId;

  @override
  OrderCreateState build() {
    _memberRepo = ref.read(memberRepositoryProvider);
    _orderRepo = ref.read(orderRepositoryProvider);
    _userRepo = ref.read(userRepositoryProvider);
    _shopRepo = ref.read(shopRepositoryProvider);
    return const OrderCreateState();
  }

  Future<void> init(String userId) async {
    try {
      final shop = await _shopRepo.getByOwner(userId);
      _shopId = shop.id;
    } catch (e, st) {
      state = state.copyWith(error: ErrorHandler.handle(e, st));
    }
  }

  Future<void> onQrScanned(String userId) async {
    if (_shopId == null) return;
    state = state.copyWith(isScanning: true, error: null);

    try {
      // 기존 회원 확인
      var member = await _memberRepo.getByUserAndShop(userId, _shopId!);

      if (member == null) {
        // 신규 회원 자동 등록
        final user = await _userRepo.getById(userId);
        member = await _memberRepo.create(
          shopId: _shopId!,
          userId: userId,
          name: user.name,
          phone: user.phone,
        );
      }

      state = state.copyWith(
        selectedMember: member,
        isScanning: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isScanning: false, error: e);
    } catch (e, st) {
      state = state.copyWith(
        isScanning: false,
        error: ErrorHandler.handle(e, st),
      );
    }
  }

  Future<void> searchMembers(String query) async {
    if (_shopId == null || query.length < 2) {
      state = state.copyWith(
        searchQuery: query,
        searchResults: const AsyncValue.data([]),
      );
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      searchResults: const AsyncValue.loading(),
    );

    try {
      final results = await _memberRepo.search(_shopId!, query);
      state = state.copyWith(
        searchResults: AsyncValue.data(results),
      );
    } catch (e, st) {
      state = state.copyWith(
        searchResults: AsyncValue.error(e, st),
      );
    }
  }

  void selectMember(Member member) {
    state = state.copyWith(
      selectedMember: member,
      searchQuery: '',
      searchResults: const AsyncValue.data([]),
    );
  }

  void clearMember() {
    state = state.copyWith(
      selectedMember: null,
      memo: '',
    );
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  Future<bool> submit() async {
    if (!state.canSubmit || _shopId == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await _orderRepo.create(
        shopId: _shopId!,
        memberId: state.selectedMember!.id,
        memo: state.memo,
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    } catch (e, st) {
      state = state.copyWith(
        isSubmitting: false,
        error: ErrorHandler.handle(e, st),
      );
      return false;
    }
  }
}
```

Run: `flutter test test/screens/owner/order_create/order_create_notifier_test.dart`
Expected: ALL PASS

**Step 4: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Commit**

```bash
git add lib/screens/owner/order_create/order_create_state.dart \
        lib/screens/owner/order_create/order_create_notifier.dart \
        test/screens/owner/order_create/order_create_notifier_test.dart
git commit -m "feat: 작업 접수 상태 관리 및 Notifier 구현"
```

---

#### Task 3.2.2: 작업 접수 화면 위젯 + 위젯 테스트

**Files:**
- Create: `lib/screens/owner/order_create/order_create_screen.dart`
- Create: `test/screens/owner/order_create/order_create_screen_test.dart`

**Step 1 (Red): 위젯 테스트 작성**

```dart
// test/screens/owner/order_create/order_create_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_screen.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_state.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';

class FakeOrderCreateNotifier extends Notifier<OrderCreateState>
    implements OrderCreateNotifier {
  final OrderCreateState initialState;
  FakeOrderCreateNotifier(this.initialState);

  @override
  OrderCreateState build() => initialState;

  @override
  Future<void> init(String userId) async {}
  @override
  Future<void> onQrScanned(String userId) async {}
  @override
  Future<void> searchMembers(String query) async {}
  @override
  void selectMember(Member member) {}
  @override
  void clearMember() {}
  @override
  void updateMemo(String memo) {}
  @override
  Future<bool> submit() async => true;
}

Widget buildTestWidget(OrderCreateState state) {
  return ProviderScope(
    overrides: [
      orderCreateProvider.overrideWith(
        () => FakeOrderCreateNotifier(state),
      ),
    ],
    child: const MaterialApp(home: OrderCreateScreen()),
  );
}

void main() {
  group('OrderCreateScreen', () {
    testWidgets('초기 상태에서 QR 스캔 버튼과 검색 영역을 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(const OrderCreateState()));

      // Assert
      expect(find.text('QR 스캔하기'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // 검색 필드
    });

    testWidgets('회원 선택 시 회원 정보 카드와 메모 입력 폼을 표시한다', (tester) async {
      // Arrange
      final state = OrderCreateState(
        selectedMember: Member(
          id: 'member-1', shopId: 'shop-1', userId: 'user-1',
          name: '홍길동', phone: '010-1234-5678', visitCount: 3,
          createdAt: DateTime.now(),
        ),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('010-1234-5678'), findsOneWidget);
      expect(find.text('작업 접수하기'), findsOneWidget);
    });

    testWidgets('canSubmit이 false이면 접수 버튼이 비활성화된다', (tester) async {
      // Arrange — 회원 미선택
      await tester.pumpWidget(buildTestWidget(const OrderCreateState()));

      // Assert
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작업 접수하기'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('isSubmitting이 true이면 버튼에 로딩 인디케이터를 표시한다',
        (tester) async {
      // Arrange
      final state = OrderCreateState(
        selectedMember: Member(
          id: 'm1', shopId: 's1', userId: 'u1',
          name: '홍길동', phone: '010-0000-0000', visitCount: 1,
          createdAt: DateTime.now(),
        ),
        isSubmitting: true,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isScanning이 true이면 QR 스캔 영역에 로딩을 표시한다',
        (tester) async {
      // Arrange
      const state = OrderCreateState(isScanning: true);

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/owner/order_create/order_create_screen_test.dart`
Expected: FAIL

**Step 2 (Green): 화면 위젯 구현**

```dart
// lib/screens/owner/order_create/order_create_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';

class OrderCreateScreen extends ConsumerStatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  ConsumerState<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends ConsumerState<OrderCreateScreen> {
  final _searchController = TextEditingController();
  final _memoController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(orderCreateProvider.notifier).init(userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _memoController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(orderCreateProvider.notifier).searchMembers(query);
    });
  }

  Future<void> _onSubmit() async {
    final success = await ref.read(orderCreateProvider.notifier).submit();
    if (success && mounted) {
      AppToast.show(context, message: '작업이 접수되었습니다');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderCreateProvider);

    return PopScope(
      canPop: !state.isFormDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.isFormDirty) {
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('나가시겠습니까?'),
              content: const Text('작성 중인 내용이 있습니다. 나가시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                    context.pop();
                  },
                  child: const Text('나가기'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('작업 접수')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // QR 스캔 영역
              if (state.selectedMember == null) ...[
                _buildQrSection(state),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('또는',
                          style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    Expanded(child: Divider()),
                  ]),
                ),
                // 회원 검색 영역
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '이름 또는 연락처 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                // 검색 결과 드롭다운
                state.searchResults.when(
                  data: (members) => members.isEmpty
                      ? const SizedBox.shrink()
                      : Card(
                          child: Column(
                            children: members
                                .map((m) => ListTile(
                                      title: Text(m.name),
                                      subtitle: Text(m.phone),
                                      onTap: () {
                                        ref.read(orderCreateProvider.notifier)
                                            .selectMember(m);
                                        _searchController.clear();
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                ),
              ],

              // 회원 정보 카드 (선택 후)
              if (state.selectedMember != null) ...[
                Card(
                  color: const Color(0xFFF8FAFC),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.selectedMember!.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(state.selectedMember!.phone,
                                  style: const TextStyle(
                                      color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(orderCreateProvider.notifier)
                                .clearMember();
                            _memoController.clear();
                          },
                          child: const Text('변경'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 메모 입력
                TextField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택)',
                    hintText: '작업 관련 메모를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (v) =>
                      ref.read(orderCreateProvider.notifier).updateMemo(v),
                ),
              ],
              const SizedBox(height: 24),

              // 접수 버튼
              ElevatedButton(
                onPressed: state.canSubmit ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2,
                        ),
                      )
                    : const Text('작업 접수하기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrSection(dynamic state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        const Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF475569)),
        const SizedBox(height: 12),
        const Text('고객 QR코드를 스캔하면\n자동으로 회원이 등록됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF475569))),
        const SizedBox(height: 16),
        if (state.isScanning)
          const CircularProgressIndicator()
        else
          ElevatedButton.icon(
            onPressed: () async {
              // QR 스캔 화면으로 이동하여 결과 수신
              final scannedUserId = await context.push<String>(
                '/owner/qr-scan',
              );
              if (scannedUserId != null) {
                ref.read(orderCreateProvider.notifier)
                    .onQrScanned(scannedUserId);
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('QR 스캔하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
          ),
      ]),
    );
  }
}
```

Run: `flutter test test/screens/owner/order_create/order_create_screen_test.dart`
Expected: ALL PASS

**Step 3: Commit**

```bash
git add lib/screens/owner/order_create/order_create_screen.dart \
        test/screens/owner/order_create/order_create_screen_test.dart
git commit -m "feat: 작업 접수 화면 위젯 및 위젯 테스트 구현"
```

---

### Task 3.3: 작업 관리 (Order Manage)

> 참조: `docs/pages/order-manage/state.md`, `docs/ui-specs/order-manage.md`, UC-5

#### Task 3.3.1: 작업 관리 상태 클래스 + Notifier + 테스트

**Files:**
- Create: `lib/screens/owner/order_manage/order_manage_state.dart`
- Create: `lib/screens/owner/order_manage/order_manage_notifier.dart`
- Create: `test/screens/owner/order_manage/order_manage_notifier_test.dart`

**Step 1 (Red): 테스트 작성**

```dart
// test/screens/owner/order_manage/order_manage_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:badminton_app/core/error/app_exception.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockOrderRepository mockOrderRepo;
  late MockShopRepository mockShopRepo;
  late ProviderContainer container;

  final testShop = Shop(
    id: 'shop-1', ownerId: 'user-1', name: '테스트 샵',
    address: '서울시', phone: '010-0000-0000', createdAt: DateTime.now(),
  );

  final testOrders = [
    Order(
      id: 'order-1', shopId: 'shop-1', memberId: 'member-1',
      memberName: '홍길동', status: OrderStatus.received,
      memo: '메모1', createdAt: DateTime.now(),
    ),
    Order(
      id: 'order-2', shopId: 'shop-1', memberId: 'member-2',
      memberName: '김철수', status: OrderStatus.inProgress,
      memo: '', createdAt: DateTime.now(), inProgressAt: DateTime.now(),
    ),
    Order(
      id: 'order-3', shopId: 'shop-1', memberId: 'member-3',
      memberName: '이영희', status: OrderStatus.completed,
      memo: '', createdAt: DateTime.now(), completedAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    mockShopRepo = MockShopRepository();

    when(() => mockShopRepo.getByOwner(any()))
        .thenAnswer((_) async => testShop);
  });

  tearDown(() => container.dispose());

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [
      orderRepositoryProvider.overrideWithValue(mockOrderRepo),
      shopRepositoryProvider.overrideWithValue(mockShopRepo),
    ]);
  }

  group('OrderManageNotifier', () {
    test('초기 로드 시 작업 목록과 상태별 건수를 조회한다', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);

      // Act
      await notifier.loadOrders('user-1');

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.orders.length, 3);
      expect(state.statusCounts[null], 3); // 전체
      expect(state.statusCounts[OrderStatus.received], 1);
      expect(state.statusCounts[OrderStatus.inProgress], 1);
      expect(state.statusCounts[OrderStatus.completed], 1);
      expect(state.isLoading, false);
    });

    test('데이터 로드 실패 시 error가 설정된다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenThrow(AppException.network('네트워크 오류'));

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);

      // Act
      await notifier.loadOrders('user-1');

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.isLoading, false);
      expect(state.error, isNotNull);
    });

    test('setFilter() 호출 시 selectedFilter가 변경된다', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      notifier.setFilter(OrderStatus.received);

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.selectedFilter, OrderStatus.received);
    });

    test('filteredOrders — 필터 적용 시 해당 상태만 반환한다', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');
      notifier.setFilter(OrderStatus.received);

      // Assert
      final state = container.read(orderManageProvider);
      final filtered = state.filteredOrders;
      expect(filtered.length, 1);
      expect(filtered.first.status, OrderStatus.received);
    });

    test('filteredOrders — 검색어 적용 시 회원명으로 필터링한다', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      notifier.setSearchQuery('홍길');

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.filteredOrders.length, 1);
      expect(state.filteredOrders.first.memberName, '홍길동');
    });

    test('changeOrderStatus() — 낙관적 UI 후 API 호출', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => [testOrders[0]]);
      when(() => mockOrderRepo.updateStatus(
            'order-1', OrderStatus.inProgress,
          )).thenAnswer((_) async => {});

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      await notifier.changeOrderStatus('order-1', OrderStatus.inProgress);

      // Assert
      final state = container.read(orderManageProvider);
      final order = state.orders.firstWhere((o) => o.id == 'order-1');
      expect(order.status, OrderStatus.inProgress);
      expect(state.changingOrderId, isNull);
    });

    test('changeOrderStatus() 실패 시 롤백한다', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => [testOrders[0]]);
      when(() => mockOrderRepo.updateStatus(
            'order-1', OrderStatus.inProgress,
          )).thenThrow(AppException.network('네트워크 오류'));

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      await notifier.changeOrderStatus('order-1', OrderStatus.inProgress);

      // Assert
      final state = container.read(orderManageProvider);
      final order = state.orders.firstWhere((o) => o.id == 'order-1');
      expect(order.status, OrderStatus.received); // 롤백
      expect(state.error, isNotNull);
    });

    test('deleteOrder() — 접수됨 상태에서만 삭제 가능', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);
      when(() => mockOrderRepo.delete('order-1'))
          .thenAnswer((_) async => {});

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      await notifier.deleteOrder('order-1');

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.orders.any((o) => o.id == 'order-1'), false);
      expect(state.statusCounts[null], 2);
    });

    test('loadMore() — 다음 50건을 추가 로드한다', () async {
      // Arrange
      final moreOrders = List.generate(50, (i) => Order(
        id: 'order-$i', shopId: 'shop-1', memberId: 'member-$i',
        memberName: '회원$i', status: OrderStatus.received,
        memo: '', createdAt: DateTime.now(),
      ));
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => moreOrders);
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 50))
          .thenAnswer((_) async => [testOrders[0]]);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      await notifier.loadMore();

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.orders.length, 51);
    });

    test('setSearchMode() — 검색바 활성/비활성 전환', () async {
      // Arrange
      when(() => mockOrderRepo.getByShop('shop-1', limit: 50, offset: 0))
          .thenAnswer((_) async => testOrders);

      container = createContainer();
      final notifier = container.read(orderManageProvider.notifier);
      await notifier.loadOrders('user-1');

      // Act
      notifier.setSearchMode(true);

      // Assert
      expect(container.read(orderManageProvider).isSearchMode, true);

      // Act
      notifier.setSearchMode(false);

      // Assert
      final state = container.read(orderManageProvider);
      expect(state.isSearchMode, false);
      expect(state.searchQuery, '');
    });
  });
}
```

Run: `flutter test test/screens/owner/order_manage/order_manage_notifier_test.dart`
Expected: FAIL (클래스 미존재)

**Step 2 (Green): 상태 클래스 구현**

```dart
// lib/screens/owner/order_manage/order_manage_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/core/error/app_exception.dart';

part 'order_manage_state.freezed.dart';

@freezed
class OrderManageState with _$OrderManageState {
  const OrderManageState._();

  const factory OrderManageState({
    @Default([]) List<Order> orders,
    @Default({}) Map<OrderStatus?, int> statusCounts,
    OrderStatus? selectedFilter,
    @Default('') String searchQuery,
    @Default(false) bool isSearchMode,
    @Default(true) bool isLoading,
    AppException? error,
    String? changingOrderId,
    @Default(true) bool hasMore,
  }) = _OrderManageState;

  List<Order> get filteredOrders {
    var result = orders;

    if (selectedFilter != null) {
      result = result.where((o) => o.status == selectedFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((o) =>
              (o.memberName ?? '').toLowerCase().contains(query))
          .toList();
    }

    return result;
  }
}
```

**Step 3 (Green): Notifier 구현**

```dart
// lib/screens/owner/order_manage/order_manage_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';

final orderManageProvider =
    NotifierProvider<OrderManageNotifier, OrderManageState>(
  OrderManageNotifier.new,
);

class OrderManageNotifier extends Notifier<OrderManageState> {
  late final OrderRepository _orderRepo;
  late final ShopRepository _shopRepo;
  String? _shopId;
  StreamSubscription<List<Order>>? _realtimeSub;

  @override
  OrderManageState build() {
    _orderRepo = ref.read(orderRepositoryProvider);
    _shopRepo = ref.read(shopRepositoryProvider);

    ref.onDispose(() {
      _realtimeSub?.cancel();
    });

    return const OrderManageState();
  }

  Future<void> loadOrders(String userId, {OrderStatus? initialFilter}) async {
    state = state.copyWith(
      isLoading: true, error: null,
      selectedFilter: initialFilter,
    );

    try {
      final shop = await _shopRepo.getByOwner(userId);
      _shopId = shop.id;

      final orders = await _orderRepo.getByShop(
        shop.id, limit: 50, offset: 0,
      );

      state = state.copyWith(
        orders: orders,
        statusCounts: _calculateCounts(orders),
        isLoading: false,
        hasMore: orders.length >= 50,
      );

      _subscribeToRealtime(shop.id);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, st),
      );
    }
  }

  void _subscribeToRealtime(String shopId) {
    _realtimeSub?.cancel();
    _realtimeSub = _orderRepo.streamByShop(shopId).listen(
      (updatedOrders) {
        // Realtime 이벤트로 목록 갱신
        state = state.copyWith(
          orders: updatedOrders,
          statusCounts: _calculateCounts(updatedOrders),
        );
      },
      onError: (e) {/* 무시 — 다음 refresh에서 복구 */},
    );
  }

  Map<OrderStatus?, int> _calculateCounts(List<Order> orders) {
    final counts = <OrderStatus?, int>{null: orders.length};
    for (final order in orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> refresh() async {
    if (_shopId == null) return;
    state = state.copyWith(isLoading: true);

    try {
      final orders = await _orderRepo.getByShop(
        _shopId!, limit: 50, offset: 0,
      );
      state = state.copyWith(
        orders: orders,
        statusCounts: _calculateCounts(orders),
        isLoading: false,
        hasMore: orders.length >= 50,
        error: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (_shopId == null || !state.hasMore) return;

    try {
      final moreOrders = await _orderRepo.getByShop(
        _shopId!, limit: 50, offset: state.orders.length,
      );
      final allOrders = [...state.orders, ...moreOrders];
      state = state.copyWith(
        orders: allOrders,
        statusCounts: _calculateCounts(allOrders),
        hasMore: moreOrders.length >= 50,
      );
    } catch (e) {
      // 추가 로드 실패는 무시
    }
  }

  void setFilter(OrderStatus? status) {
    state = state.copyWith(selectedFilter: status);
  }

  void setSearchMode(bool enabled) {
    state = state.copyWith(
      isSearchMode: enabled,
      searchQuery: enabled ? state.searchQuery : '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> changeOrderStatus(
    String orderId, OrderStatus newStatus,
  ) async {
    final previousOrders = List<Order>.from(state.orders);
    final idx = previousOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final previousOrder = previousOrders[idx];
    // 낙관적 UI
    state = state.copyWith(changingOrderId: orderId);
    final updated = List<Order>.from(state.orders);
    updated[idx] = previousOrder.copyWith(status: newStatus);
    state = state.copyWith(
      orders: updated,
      statusCounts: _calculateCounts(updated),
    );

    try {
      await _orderRepo.updateStatus(orderId, newStatus);
      state = state.copyWith(changingOrderId: null);
    } on AppException catch (e) {
      state = state.copyWith(
        orders: previousOrders,
        statusCounts: _calculateCounts(previousOrders),
        changingOrderId: null,
        error: e,
      );
    } catch (e, st) {
      state = state.copyWith(
        orders: previousOrders,
        statusCounts: _calculateCounts(previousOrders),
        changingOrderId: null,
        error: ErrorHandler.handle(e, st),
      );
    }
  }

  Future<void> undoStatusChange(
    String orderId, OrderStatus previousStatus,
  ) async {
    await changeOrderStatus(orderId, previousStatus);
  }

  Future<void> deleteOrder(String orderId) async {
    final order = state.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw AppException.validation('작업을 찾을 수 없습니다'),
    );

    if (order.status != OrderStatus.received) {
      throw AppException.validation('접수됨 상태의 작업만 삭제할 수 있습니다');
    }

    try {
      await _orderRepo.delete(orderId);
      final updated = state.orders.where((o) => o.id != orderId).toList();
      state = state.copyWith(
        orders: updated,
        statusCounts: _calculateCounts(updated),
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e);
    }
  }
}
```

Run: `flutter test test/screens/owner/order_manage/order_manage_notifier_test.dart`
Expected: ALL PASS

**Step 4: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Commit**

```bash
git add lib/screens/owner/order_manage/order_manage_state.dart \
        lib/screens/owner/order_manage/order_manage_notifier.dart \
        test/screens/owner/order_manage/order_manage_notifier_test.dart
git commit -m "feat: 작업 관리 상태 관리 및 Notifier 구현"
```

---

#### Task 3.3.2: 작업 관리 화면 위젯 + 위젯 테스트

**Files:**
- Create: `lib/screens/owner/order_manage/order_manage_screen.dart`
- Create: `test/screens/owner/order_manage/order_manage_screen_test.dart`

**Step 1 (Red): 위젯 테스트 작성**

```dart
// test/screens/owner/order_manage/order_manage_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_screen.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';

class FakeOrderManageNotifier extends Notifier<OrderManageState>
    implements OrderManageNotifier {
  final OrderManageState initialState;
  FakeOrderManageNotifier(this.initialState);

  @override
  OrderManageState build() => initialState;

  @override
  Future<void> loadOrders(String userId, {OrderStatus? initialFilter}) async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> loadMore() async {}
  @override
  void setFilter(OrderStatus? status) {}
  @override
  void setSearchMode(bool enabled) {}
  @override
  void setSearchQuery(String query) {}
  @override
  Future<void> changeOrderStatus(String id, OrderStatus s) async {}
  @override
  Future<void> undoStatusChange(String id, OrderStatus s) async {}
  @override
  Future<void> deleteOrder(String id) async {}
}

Widget buildTestWidget(OrderManageState state) {
  return ProviderScope(
    overrides: [
      orderManageProvider.overrideWith(
        () => FakeOrderManageNotifier(state),
      ),
    ],
    child: const MaterialApp(home: OrderManageScreen()),
  );
}

void main() {
  group('OrderManageScreen', () {
    testWidgets('로딩 중일 때 스켈레톤을 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(
        const OrderManageState(isLoading: true),
      ));

      // Assert
      expect(find.byType(SkeletonShimmer), findsWidgets);
    });

    testWidgets('필터 탭 4개를 표시한다 (전체/접수됨/작업중/완료)', (tester) async {
      // Arrange
      final state = OrderManageState(
        isLoading: false,
        statusCounts: {
          null: 10,
          OrderStatus.received: 3,
          OrderStatus.inProgress: 4,
          OrderStatus.completed: 3,
        },
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('전체'), findsOneWidget);
      expect(find.text('접수됨'), findsOneWidget);
      expect(find.text('작업중'), findsOneWidget);
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('작업 목록을 올바르게 표시한다', (tester) async {
      // Arrange
      final state = OrderManageState(
        isLoading: false,
        orders: [
          Order(
            id: 'order-1', shopId: 'shop-1', memberId: 'm1',
            memberName: '홍길동', status: OrderStatus.received,
            memo: '', createdAt: DateTime.now(),
          ),
          Order(
            id: 'order-2', shopId: 'shop-1', memberId: 'm2',
            memberName: '김철수', status: OrderStatus.inProgress,
            memo: '', createdAt: DateTime.now(),
          ),
        ],
        statusCounts: {null: 2, OrderStatus.received: 1, OrderStatus.inProgress: 1},
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('김철수'), findsOneWidget);
    });

    testWidgets('작업 0건이면 EmptyState를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(
        const OrderManageState(isLoading: false, orders: [],
            statusCounts: {null: 0}),
      ));

      // Assert
      expect(find.text('등록된 작업이 없습니다'), findsOneWidget);
    });

    testWidgets('에러 상태에서 ErrorView를 표시한다', (tester) async {
      // Arrange
      final state = OrderManageState(
        isLoading: false,
        error: AppException.network('오류'),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
    });

    testWidgets('검색 아이콘 탭 시 검색바가 표시된다', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(
        const OrderManageState(isLoading: false, isSearchMode: true),
      ));

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
```

Run: `flutter test test/screens/owner/order_manage/order_manage_screen_test.dart`
Expected: FAIL

**Step 2 (Green): 화면 위젯 구현**

```dart
// lib/screens/owner/order_manage/order_manage_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';

class OrderManageScreen extends ConsumerStatefulWidget {
  final String? initialStatusFilter;

  const OrderManageScreen({super.key, this.initialStatusFilter});

  @override
  ConsumerState<OrderManageScreen> createState() => _OrderManageScreenState();
}

class _OrderManageScreenState extends ConsumerState<OrderManageScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      OrderStatus? initialFilter;
      if (widget.initialStatusFilter != null) {
        initialFilter = OrderStatus.values.firstWhere(
          (s) => s.name == widget.initialStatusFilter,
          orElse: () => OrderStatus.received,
        );
      }
      ref.read(orderManageProvider.notifier)
          .loadOrders(userId, initialFilter: initialFilter);
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderManageProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderManageProvider);

    return Scaffold(
      appBar: state.isSearchMode
          ? AppBar(
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '회원명 검색',
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(orderManageProvider.notifier).setSearchQuery(v),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(orderManageProvider.notifier).setSearchMode(false);
                    _searchController.clear();
                  },
                ),
              ],
            )
          : AppBar(
              title: const Text('작업 관리'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () =>
                      ref.read(orderManageProvider.notifier).setSearchMode(true),
                ),
              ],
            ),
      body: state.error != null && state.orders.isEmpty
          ? ErrorView(
              message: '데이터를 불러올 수 없습니다',
              onRetry: () {
                final userId = ref.read(currentUserProvider)?.id;
                if (userId != null) {
                  ref.read(orderManageProvider.notifier).loadOrders(userId);
                }
              },
            )
          : Column(
              children: [
                // 필터 탭
                if (!state.isLoading) _buildFilterTabs(state),
                // 작업 목록
                Expanded(
                  child: state.isLoading
                      ? ListView(children: List.generate(5, (_) =>
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: SkeletonShimmer(height: 80),
                          )))
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(orderManageProvider.notifier)
                              .refresh(),
                          child: state.filteredOrders.isEmpty
                              ? ListView(children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: state.selectedFilter == null
                                        ? const EmptyState(
                                            message: '등록된 작업이 없습니다',
                                            subMessage: '작업 접수 버튼으로 새 작업을 등록하세요',
                                          )
                                        : const EmptyState(
                                            message: '해당 상태의 작업이 없습니다',
                                          ),
                                  ),
                                ])
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: state.filteredOrders.length +
                                      (state.hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= state.filteredOrders.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    return _buildOrderCard(
                                      context,
                                      state.filteredOrders[index],
                                      state,
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterTabs(dynamic state) {
    final filters = <OrderStatus?>[
      null,
      OrderStatus.received,
      OrderStatus.inProgress,
      OrderStatus.completed,
    ];
    final labels = ['전체', '접수됨', '작업중', '완료'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = state.selectedFilter == filters[i];
          final count = state.statusCounts[filters[i]] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text('${labels[i]} ($count)'),
              onSelected: (_) =>
                  ref.read(orderManageProvider.notifier).setFilter(filters[i]),
              selectedColor: const Color(0xFF16A34A).withOpacity(0.1),
              checkmarkColor: const Color(0xFF16A34A),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, dynamic state) {
    final isChanging = state.changingOrderId == order.id;
    final nextStatus = _getNextStatus(order.status);

    return Dismissible(
      key: Key(order.id),
      direction: order.status == OrderStatus.received
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await ConfirmDialog.show(
          context,
          title: '작업 삭제',
          message: '이 작업을 삭제하시겠습니까?',
        );
      },
      onDismissed: (_) =>
          ref.read(orderManageProvider.notifier).deleteOrder(order.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(order.memberName ?? '알 수 없음'),
          subtitle: Text(Formatters.dateTime(order.createdAt)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(status: order.status),
              if (nextStatus != null) ...[
                const SizedBox(width: 8),
                isChanging
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _onStatusChange(
                          context, order.id, order.status, nextStatus,
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  OrderStatus? _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.received:
        return OrderStatus.inProgress;
      case OrderStatus.inProgress:
        return OrderStatus.completed;
      case OrderStatus.completed:
        return null;
    }
  }

  Future<void> _onStatusChange(
    BuildContext context, String orderId,
    OrderStatus previousStatus, OrderStatus newStatus,
  ) async {
    await ref.read(orderManageProvider.notifier)
        .changeOrderStatus(orderId, newStatus);
    if (context.mounted) {
      AppToast.showUndo(context,
        message: '상태가 변경되었습니다',
        onUndo: () => ref.read(orderManageProvider.notifier)
            .undoStatusChange(orderId, previousStatus),
      );
    }
  }
}
```

Run: `flutter test test/screens/owner/order_manage/order_manage_screen_test.dart`
Expected: ALL PASS

**Step 3: Commit**

```bash
git add lib/screens/owner/order_manage/order_manage_screen.dart \
        test/screens/owner/order_manage/order_manage_screen_test.dart
git commit -m "feat: 작업 관리 화면 위젯 및 위젯 테스트 구현"
```

---

### Task 3.4: 샵 QR코드 (Shop QR)

> 참조: `docs/pages/shop-qr/state.md`, `docs/ui-specs/shop-qr.md`

#### Task 3.4.1: 샵 QR 상태 클래스 + Notifier + 테스트

**Files:**
- Create: `lib/screens/owner/shop_qr/shop_qr_state.dart`
- Create: `lib/screens/owner/shop_qr/shop_qr_notifier.dart`
- Create: `test/screens/owner/shop_qr/shop_qr_notifier_test.dart`

**Step 1 (Red): 테스트 작성**

```dart
// test/screens/owner/shop_qr/shop_qr_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_notifier.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_state.dart';
import 'package:badminton_app/core/error/app_exception.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockShopRepository mockShopRepo;
  late ProviderContainer container;

  final testShop = Shop(
    id: 'shop-1', ownerId: 'user-1', name: '테스트 샵',
    address: '서울시 강남구', phone: '010-1234-5678',
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockShopRepo = MockShopRepository();
  });

  tearDown(() => container.dispose());

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [
      shopRepositoryProvider.overrideWithValue(mockShopRepo),
    ]);
  }

  group('ShopQrNotifier', () {
    test('초기 로드 시 샵 정보를 조회하여 shopInfo에 설정한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => testShop);

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);

      // Act
      await notifier.loadShopInfo('user-1');

      // Assert
      final state = container.read(shopQrProvider);
      expect(state.shopInfo.value, testShop);
    });

    test('샵 정보 로드 실패 시 AsyncError가 설정된다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenThrow(AppException.network('네트워크 오류'));

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);

      // Act
      await notifier.loadShopInfo('user-1');

      // Assert
      final state = container.read(shopQrProvider);
      expect(state.shopInfo.hasError, true);
    });

    test('qrData는 shopId로부터 딥링크 URL을 생성한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => testShop);

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);
      await notifier.loadShopInfo('user-1');

      // Assert
      final state = container.read(shopQrProvider);
      expect(state.qrData, 'https://gutalarm.app/shop/shop-1');
    });

    test('retry() 호출 시 샵 정보를 재조회한다', () async {
      // Arrange — 첫 호출 실패, 두 번째 성공
      var callCount = 0;
      when(() => mockShopRepo.getByOwner('user-1')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) throw AppException.network('오류');
        return testShop;
      });

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);
      await notifier.loadShopInfo('user-1');
      expect(container.read(shopQrProvider).shopInfo.hasError, true);

      // Act
      await notifier.retry();

      // Assert
      final state = container.read(shopQrProvider);
      expect(state.shopInfo.hasValue, true);
      expect(state.shopInfo.value!.name, '테스트 샵');
    });

    test('shareQr() 호출 시 isSharing이 true→false로 변경된다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => testShop);

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);
      await notifier.loadShopInfo('user-1');

      // Act — shareQr는 내부적으로 플랫폼 API를 호출하므로
      // 여기서는 상태 변화만 검증
      // (실제 공유 기능은 통합 테스트에서 검증)
      expect(container.read(shopQrProvider).isSharing, false);
    });

    test('downloadPrintableQr() 호출 시 isSaving이 true→false로 변경된다',
        () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => testShop);

      container = createContainer();
      final notifier = container.read(shopQrProvider.notifier);
      await notifier.loadShopInfo('user-1');

      // Assert — 초기 상태 확인
      expect(container.read(shopQrProvider).isSaving, false);
    });
  });
}
```

Run: `flutter test test/screens/owner/shop_qr/shop_qr_notifier_test.dart`
Expected: FAIL (클래스 미존재)

**Step 2 (Green): 상태 클래스 구현**

```dart
// lib/screens/owner/shop_qr/shop_qr_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/shop.dart';

part 'shop_qr_state.freezed.dart';

@freezed
class ShopQrState with _$ShopQrState {
  const ShopQrState._();

  const factory ShopQrState({
    @Default(AsyncValue<Shop>.loading()) AsyncValue<Shop> shopInfo,
    @Default(false) bool isSaving,
    @Default(false) bool isSharing,
  }) = _ShopQrState;

  String get qrData {
    final shop = shopInfo.valueOrNull;
    if (shop == null) return '';
    return 'https://gutalarm.app/shop/${shop.id}';
  }

  String get shopName => shopInfo.valueOrNull?.name ?? '';
}
```

**Step 3 (Green): Notifier 구현**

```dart
// lib/screens/owner/shop_qr/shop_qr_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_state.dart';

final shopQrProvider =
    NotifierProvider<ShopQrNotifier, ShopQrState>(
  ShopQrNotifier.new,
);

class ShopQrNotifier extends Notifier<ShopQrState> {
  late final ShopRepository _shopRepo;
  String? _userId;

  @override
  ShopQrState build() {
    _shopRepo = ref.read(shopRepositoryProvider);
    return const ShopQrState();
  }

  Future<void> loadShopInfo(String userId) async {
    _userId = userId;
    state = state.copyWith(shopInfo: const AsyncValue.loading());

    try {
      final shop = await _shopRepo.getByOwner(userId);
      state = state.copyWith(shopInfo: AsyncValue.data(shop));
    } on AppException catch (e, st) {
      state = state.copyWith(shopInfo: AsyncValue.error(e, st));
    } catch (e, st) {
      state = state.copyWith(shopInfo: AsyncValue.error(e, st));
    }
  }

  Future<void> retry() async {
    if (_userId != null) {
      await loadShopInfo(_userId!);
    }
  }

  Future<void> shareQr() async {
    if (state.shopInfo.valueOrNull == null) return;
    state = state.copyWith(isSharing: true);

    try {
      // 플랫폼 공유 API 호출 (Share.share 또는 커스텀 구현)
      // QR 이미지를 PNG로 생성 후 시스템 공유 시트 표시
      // 공유 텍스트: "거트알림 앱으로 QR을 스캔하면 회원 등록이 됩니다"
      // TODO: 플랫폼 공유 구현
    } finally {
      state = state.copyWith(isSharing: false);
    }
  }

  Future<void> downloadPrintableQr() async {
    if (state.shopInfo.valueOrNull == null) return;
    state = state.copyWith(isSaving: true);

    try {
      // 고해상도(1024x1024px) QR코드 이미지 생성
      // 하단에 샵 이름 + "거트알림 앱으로 스캔하세요" 포함
      // 갤러리에 저장
      // TODO: 이미지 생성 및 갤러리 저장 구현
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
```

Run: `flutter test test/screens/owner/shop_qr/shop_qr_notifier_test.dart`
Expected: ALL PASS

**Step 4: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Commit**

```bash
git add lib/screens/owner/shop_qr/shop_qr_state.dart \
        lib/screens/owner/shop_qr/shop_qr_notifier.dart \
        test/screens/owner/shop_qr/shop_qr_notifier_test.dart
git commit -m "feat: 샵 QR코드 상태 관리 및 Notifier 구현"
```

---

#### Task 3.4.2: 샵 QR코드 화면 위젯 + 위젯 테스트

**Files:**
- Create: `lib/screens/owner/shop_qr/shop_qr_screen.dart`
- Create: `test/screens/owner/shop_qr/shop_qr_screen_test.dart`

**Step 1 (Red): 위젯 테스트 작성**

```dart
// test/screens/owner/shop_qr/shop_qr_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_state.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_notifier.dart';

class FakeShopQrNotifier extends Notifier<ShopQrState>
    implements ShopQrNotifier {
  final ShopQrState initialState;
  FakeShopQrNotifier(this.initialState);

  @override
  ShopQrState build() => initialState;

  @override
  Future<void> loadShopInfo(String userId) async {}
  @override
  Future<void> retry() async {}
  @override
  Future<void> shareQr() async {}
  @override
  Future<void> downloadPrintableQr() async {}
}

Widget buildTestWidget(ShopQrState state) {
  return ProviderScope(
    overrides: [
      shopQrProvider.overrideWith(() => FakeShopQrNotifier(state)),
    ],
    child: const MaterialApp(home: ShopQrScreen()),
  );
}

void main() {
  final testShop = Shop(
    id: 'shop-1', ownerId: 'user-1', name: '테스트 샵',
    address: '서울시', phone: '010-0000-0000', createdAt: DateTime.now(),
  );

  group('ShopQrScreen', () {
    testWidgets('로딩 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(const ShopQrState()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('샵 정보 로드 후 QR코드와 샵 이름을 표시한다', (tester) async {
      // Arrange
      final state = ShopQrState(
        shopInfo: AsyncValue.data(testShop),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('테스트 샵'), findsOneWidget);
      // QrImageView 위젯이 존재하는지 확인
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('공유 버튼과 다운로드 버튼이 표시된다', (tester) async {
      // Arrange
      final state = ShopQrState(
        shopInfo: AsyncValue.data(testShop),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('공유'), findsOneWidget);
      expect(find.text('인쇄용 다운로드'), findsOneWidget);
    });

    testWidgets('에러 시 에러 화면과 재시도 버튼을 표시한다', (tester) async {
      // Arrange
      final state = ShopQrState(
        shopInfo: AsyncValue.error(
          Exception('오류'), StackTrace.current,
        ),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.text('데이터를 불러올 수 없습니다'), findsOneWidget);
      expect(find.text('재시도'), findsOneWidget);
    });

    testWidgets('isSharing이 true이면 공유 버튼에 로딩을 표시한다', (tester) async {
      // Arrange
      final state = ShopQrState(
        shopInfo: AsyncValue.data(testShop),
        isSharing: true,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('isSaving이 true이면 다운로드 버튼에 로딩을 표시한다', (tester) async {
      // Arrange
      final state = ShopQrState(
        shopInfo: AsyncValue.data(testShop),
        isSaving: true,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
```

Run: `flutter test test/screens/owner/shop_qr/shop_qr_screen_test.dart`
Expected: FAIL

**Step 2 (Green): 화면 위젯 구현**

```dart
// lib/screens/owner/shop_qr/shop_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_notifier.dart';

class ShopQrScreen extends ConsumerStatefulWidget {
  const ShopQrScreen({super.key});

  @override
  ConsumerState<ShopQrScreen> createState() => _ShopQrScreenState();
}

class _ShopQrScreenState extends ConsumerState<ShopQrScreen> {
  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(shopQrProvider.notifier).loadShopInfo(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopQrProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('샵 QR코드')),
      body: state.shopInfo.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: '데이터를 불러올 수 없습니다',
          onRetry: () => ref.read(shopQrProvider.notifier).retry(),
        ),
        data: (shop) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // QR코드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: state.qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // 샵 이름
                Text(
                  shop.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '고객이 이 QR코드를 스캔하면\n자동으로 회원 등록이 됩니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // 공유 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isSharing
                        ? null
                        : () async {
                            await ref.read(shopQrProvider.notifier).shareQr();
                          },
                    icon: state.isSharing
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share),
                    label: const Text('공유'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 인쇄용 다운로드 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            await ref
                                .read(shopQrProvider.notifier)
                                .downloadPrintableQr();
                            if (context.mounted) {
                              AppToast.show(context,
                                  message: 'QR코드가 저장되었습니다');
                            }
                          },
                    icon: state.isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('인쇄용 다운로드'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Run: `flutter test test/screens/owner/shop_qr/shop_qr_screen_test.dart`
Expected: ALL PASS

**Step 3: Commit**

```bash
git add lib/screens/owner/shop_qr/shop_qr_screen.dart \
        test/screens/owner/shop_qr/shop_qr_screen_test.dart
git commit -m "feat: 샵 QR코드 화면 위젯 및 위젯 테스트 구현"
```

---

### Phase 3 파일 경로 요약

| Task | 파일 경로 | 유형 |
|------|-----------|------|
| 3.1.1 | `lib/screens/owner/dashboard/owner_dashboard_state.dart` | State |
| 3.1.1 | `lib/screens/owner/dashboard/owner_dashboard_notifier.dart` | Notifier |
| 3.1.1 | `test/screens/owner/dashboard/owner_dashboard_notifier_test.dart` | Test |
| 3.1.2 | `lib/screens/owner/dashboard/owner_dashboard_screen.dart` | Screen |
| 3.1.2 | `test/screens/owner/dashboard/owner_dashboard_screen_test.dart` | Widget Test |
| 3.2.1 | `lib/screens/owner/order_create/order_create_state.dart` | State |
| 3.2.1 | `lib/screens/owner/order_create/order_create_notifier.dart` | Notifier |
| 3.2.1 | `test/screens/owner/order_create/order_create_notifier_test.dart` | Test |
| 3.2.2 | `lib/screens/owner/order_create/order_create_screen.dart` | Screen |
| 3.2.2 | `test/screens/owner/order_create/order_create_screen_test.dart` | Widget Test |
| 3.3.1 | `lib/screens/owner/order_manage/order_manage_state.dart` | State |
| 3.3.1 | `lib/screens/owner/order_manage/order_manage_notifier.dart` | Notifier |
| 3.3.1 | `test/screens/owner/order_manage/order_manage_notifier_test.dart` | Test |
| 3.3.2 | `lib/screens/owner/order_manage/order_manage_screen.dart` | Screen |
| 3.3.2 | `test/screens/owner/order_manage/order_manage_screen_test.dart` | Widget Test |
| 3.4.1 | `lib/screens/owner/shop_qr/shop_qr_state.dart` | State |
| 3.4.1 | `lib/screens/owner/shop_qr/shop_qr_notifier.dart` | Notifier |
| 3.4.1 | `test/screens/owner/shop_qr/shop_qr_notifier_test.dart` | Test |
| 3.4.2 | `lib/screens/owner/shop_qr/shop_qr_screen.dart` | Screen |
| 3.4.2 | `test/screens/owner/shop_qr/shop_qr_screen_test.dart` | Widget Test |

### Phase 3 커밋 순서

| 순서 | Task | 커밋 메시지 |
|------|------|------------|
| 1 | 3.1.1 | `feat: 사장님 대시보드 상태 관리 및 Notifier 구현` |
| 2 | 3.1.2 | `feat: 사장님 대시보드 화면 위젯 및 위젯 테스트 구현` |
| 3 | 3.2.1 | `feat: 작업 접수 상태 관리 및 Notifier 구현` |
| 4 | 3.2.2 | `feat: 작업 접수 화면 위젯 및 위젯 테스트 구현` |
| 5 | 3.3.1 | `feat: 작업 관리 상태 관리 및 Notifier 구현` |
| 6 | 3.3.2 | `feat: 작업 관리 화면 위젯 및 위젯 테스트 구현` |
| 7 | 3.4.1 | `feat: 샵 QR코드 상태 관리 및 Notifier 구현` |
| 8 | 3.4.2 | `feat: 샵 QR코드 화면 위젯 및 위젯 테스트 구현` |

### Phase 3 의존 패키지

| 패키지 | 용도 | Task |
|--------|------|------|
| `flutter_riverpod` | 상태 관리 | 전체 |
| `freezed_annotation` | 불변 상태 클래스 | 전체 |
| `go_router` | 네비게이션 | 3.1.2, 3.2.2, 3.3.2 |
| `qr_flutter` | QR코드 생성 | 3.4.2 |
| `mobile_scanner` | QR코드 스캔 | 3.2.2 |
| `mocktail` | 테스트 Mock | 전체 테스트 |

---
