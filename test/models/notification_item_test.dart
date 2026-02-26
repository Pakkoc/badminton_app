import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationItem', () {
    final json = {
      'id': 'bb0e8400-e29b-41d4-a716-446655440007',
      'user_id': '550e8400-e29b-41d4-a716-446655440000',
      'type': 'status_change',
      'title': '작업 상태 변경',
      'body': '거트 프로샵에서 작업이 시작되었습니다.',
      'order_id': '880e8400-e29b-41d4-a716-446655440003',
      'is_read': false,
      'created_at': '2026-01-15T11:00:00.000Z',
    };

    test('fromJson은 JSON에서 NotificationItem 객체를 생성한다', () {
      final item = NotificationItem.fromJson(json);
      expect(item.id, 'bb0e8400-e29b-41d4-a716-446655440007');
      expect(item.type, NotificationType.statusChange);
      expect(item.title, '작업 상태 변경');
      expect(item.isRead, false);
    });

    test('toJson은 NotificationItem 객체를 JSON으로 변환한다', () {
      final result = NotificationItem.fromJson(json).toJson();
      expect(result['type'], 'status_change');
      expect(result['is_read'], false);
    });

    test('order_id가 null일 때 정상 동작한다 (공지 알림)', () {
      final noticeJson = {
        'id': 'bb0e8400-e29b-41d4-a716-446655440008',
        'user_id': '550e8400-e29b-41d4-a716-446655440000',
        'type': 'notice',
        'title': '공지사항',
        'body': '새로운 공지가 등록되었습니다.',
        'order_id': null,
        'is_read': false,
        'created_at': '2026-01-20T09:00:00.000Z',
      };
      final item = NotificationItem.fromJson(noticeJson);
      expect(item.orderId, isNull);
      expect(item.type, NotificationType.notice);
    });

    test('동일한 데이터를 가진 두 NotificationItem은 같다', () {
      expect(
        NotificationItem.fromJson(json),
        equals(NotificationItem.fromJson(json)),
      );
    });
  });
}
