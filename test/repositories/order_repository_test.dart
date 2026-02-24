import 'package:badminton_app/repositories/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('OrderRepository', () {
    late MockSupabaseClient mockClient;
    late OrderRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = OrderRepository(mockClient);
    });

    // Arrange & Assert: 인스턴스 생성 확인
    test('인스턴스를 생성할 수 있다', () {
      // Assert
      expect(repository, isA<OrderRepository>());
    });

    test('SupabaseClient를 생성자로 주입받는다', () {
      // Arrange & Act
      final repo = OrderRepository(mockClient);

      // Assert
      expect(repo, isNotNull);
    });
  });

  group('orderRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        orderRepositoryProvider,
        isA<Provider<OrderRepository>>(),
      );
    });
  });
}
