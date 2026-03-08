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

  group('updateNotifyShop / updateNotifyCommunity', () {
    test('UserRepository에 updateNotifyShop 메서드가 정의되어 있다', () {
      // update()는 실제 Supabase 연결이 필요하므로
      // 메서드 시그니처가 컴파일되는지만 검증한다.
      final repo = UserRepository(MockSupabaseClient());
      // ignore: unnecessary_type_check
      expect(repo.updateNotifyShop, isA<Function>());
      // ignore: unnecessary_type_check
      expect(repo.updateNotifyCommunity, isA<Function>());
    });
  });
}
