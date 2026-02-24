import 'package:badminton_app/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('UserRepository', () {
    late MockSupabaseClient mockClient;
    late UserRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = UserRepository(mockClient);
    });

    // Arrange & Assert: 인스턴스 생성 확인
    test('인스턴스를 생성할 수 있다', () {
      // Assert
      expect(repository, isA<UserRepository>());
    });

    test('SupabaseClient를 생성자로 주입받는다', () {
      // Arrange & Act
      final repo = UserRepository(mockClient);

      // Assert
      expect(repo, isNotNull);
    });
  });

  group('userRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(userRepositoryProvider, isA<Provider<UserRepository>>());
    });
  });
}
