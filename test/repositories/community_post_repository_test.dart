import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityPostRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityPostRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityPostRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityPostRepository>());
    });

    test('client를 생성자로 주입받는다', () {
      expect(repository.client, equals(mockClient));
    });

    test('getAll 메서드가 정의되어 있다', () {
      expect(repository.getAll, isA<Function>());
    });

    test('getById 메서드가 정의되어 있다', () {
      expect(repository.getById, isA<Function>());
    });

    test('create 메서드가 정의되어 있다', () {
      expect(repository.create, isA<Function>());
    });

    test('update 메서드가 정의되어 있다', () {
      expect(repository.update, isA<Function>());
    });

    test('delete 메서드가 정의되어 있다', () {
      expect(repository.delete, isA<Function>());
    });

    test('search 메서드가 정의되어 있다', () {
      expect(repository.search, isA<Function>());
    });
  });

  group('communityPostRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(
        communityPostRepositoryProvider,
        isA<Provider<CommunityPostRepository>>(),
      );
    });
  });
}
