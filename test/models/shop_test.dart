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
      expect(
        shop.ownerId,
        '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(shop.name, '거트 프로샵');
      expect(shop.latitude, 37.4979);
      expect(shop.longitude, 127.0276);
    });

    test('toJson은 Shop 객체를 JSON으로 변환한다', () {
      final result = Shop.fromJson(json).toJson();
      expect(
        result['owner_id'],
        '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(result['latitude'], 37.4979);
    });

    test('description이 null일 때 정상 동작한다', () {
      final minimalJson = Map<String, dynamic>.from(json)
        ..remove('description');
      expect(Shop.fromJson(minimalJson).description, isNull);
    });

    test('동일한 데이터를 가진 두 Shop은 같다', () {
      expect(Shop.fromJson(json), equals(Shop.fromJson(json)));
    });
  });
}
