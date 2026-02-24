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
