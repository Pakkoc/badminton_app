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
