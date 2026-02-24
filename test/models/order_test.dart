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
      final order = GutOrder.fromJson(json);
      expect(order.id, '880e8400-e29b-41d4-a716-446655440003');
      expect(order.status, OrderStatus.received);
      expect(order.memo, '2본 작업');
      expect(order.inProgressAt, isNull);
    });

    test('toJson은 Order 객체를 JSON으로 변환한다', () {
      final result = GutOrder.fromJson(json).toJson();
      expect(result['status'], 'received');
      expect(
        result['shop_id'],
        '660e8400-e29b-41d4-a716-446655440001',
      );
    });

    test('in_progress 상태의 Order를 파싱한다', () {
      final ipJson = Map<String, dynamic>.from(json)
        ..['status'] = 'in_progress'
        ..['in_progress_at'] = '2026-01-15T11:00:00.000Z';
      final order = GutOrder.fromJson(ipJson);
      expect(order.status, OrderStatus.inProgress);
      expect(order.inProgressAt, isA<DateTime>());
    });

    test('completed 상태의 Order를 파싱한다', () {
      final cJson = Map<String, dynamic>.from(json)
        ..['status'] = 'completed'
        ..['in_progress_at'] = '2026-01-15T11:00:00.000Z'
        ..['completed_at'] = '2026-01-15T12:00:00.000Z';
      final order = GutOrder.fromJson(cJson);
      expect(order.status, OrderStatus.completed);
      expect(order.completedAt, isA<DateTime>());
    });

    test('동일한 데이터를 가진 두 Order는 같다', () {
      expect(
        GutOrder.fromJson(json),
        equals(GutOrder.fromJson(json)),
      );
    });
  });
}
