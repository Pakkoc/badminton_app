import 'package:badminton_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(
        OrderStatus.fromJson('in_progress'),
        OrderStatus.inProgress,
      );
      expect(
        OrderStatus.fromJson('completed'),
        OrderStatus.completed,
      );
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
      expect(
        NotificationType.statusChange.toJson(),
        'status_change',
      );
      expect(NotificationType.completion.toJson(), 'completion');
      expect(NotificationType.notice.toJson(), 'notice');
      expect(NotificationType.receipt.toJson(), 'receipt');
    });

    test('fromJson은 snake_case 문자열에서 enum을 반환한다', () {
      expect(
        NotificationType.fromJson('status_change'),
        NotificationType.statusChange,
      );
      expect(
        NotificationType.fromJson('completion'),
        NotificationType.completion,
      );
      expect(
        NotificationType.fromJson('notice'),
        NotificationType.notice,
      );
      expect(
        NotificationType.fromJson('receipt'),
        NotificationType.receipt,
      );
    });
  });
}
