import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/models/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    final json = {
      'id': 'aa0e8400-e29b-41d4-a716-446655440006',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'name': 'BG65',
      'category': '거트',
      'quantity': 50,
      'image_url': 'https://example.com/bg65.jpg',
      'created_at': '2026-01-10T09:00:00.000Z',
    };

    test('fromJson은 JSON에서 InventoryItem 객체를 생성한다', () {
      final item = InventoryItem.fromJson(json);
      expect(item.id, 'aa0e8400-e29b-41d4-a716-446655440006');
      expect(item.name, 'BG65');
      expect(item.category, '거트');
      expect(item.quantity, 50);
    });

    test('toJson은 InventoryItem 객체를 JSON으로 변환한다', () {
      final result = InventoryItem.fromJson(json).toJson();
      expect(result['name'], 'BG65');
      expect(result['quantity'], 50);
    });

    test('category와 image_url이 null일 때 정상 동작한다', () {
      final minimalJson = Map<String, dynamic>.from(json)
        ..remove('category')
        ..remove('image_url');
      final item = InventoryItem.fromJson(minimalJson);
      expect(item.category, isNull);
      expect(item.imageUrl, isNull);
    });

    test('동일한 데이터를 가진 두 InventoryItem은 같다', () {
      expect(
        InventoryItem.fromJson(json),
        equals(InventoryItem.fromJson(json)),
      );
    });
  });
}
