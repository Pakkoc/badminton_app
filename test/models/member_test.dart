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
      expect(
        member.shopId,
        '660e8400-e29b-41d4-a716-446655440001',
      );
      expect(
        member.userId,
        '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(member.name, '홍길동');
      expect(member.visitCount, 5);
    });

    test('toJson은 Member 객체를 JSON으로 변환한다', () {
      final result = Member.fromJson(json).toJson();
      expect(
        result['shop_id'],
        '660e8400-e29b-41d4-a716-446655440001',
      );
      expect(result['visit_count'], 5);
    });

    test('user_id가 null일 때 정상 동작한다 (앱 미가입 고객)', () {
      final offlineJson = Map<String, dynamic>.from(json)
        ..['user_id'] = null;
      expect(Member.fromJson(offlineJson).userId, isNull);
    });

    test('memo가 null일 때 정상 동작한다', () {
      final noMemoJson = Map<String, dynamic>.from(json)
        ..remove('memo');
      expect(Member.fromJson(noMemoJson).memo, isNull);
    });
  });
}
