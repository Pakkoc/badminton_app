import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final user = User.fromJson(json);

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
      expect(
        result['profile_image_url'],
        'https://example.com/img.jpg',
      );
    });

    test('notify_shop와 notify_community 필드를 파싱한다', () {
      final jsonWithNotify = {
        ...json,
        'notify_shop': false,
        'notify_community': false,
      };
      final user = User.fromJson(jsonWithNotify);

      expect(user.notifyShop, false);
      expect(user.notifyCommunity, false);
    });

    test('notify 필드가 없을 때 기본값 true를 사용한다', () {
      final user = User.fromJson(json);

      expect(user.notifyShop, true);
      expect(user.notifyCommunity, true);
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
