import 'package:badminton_app/repositories/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('PostRepository', () {
    late MockSupabaseClient mockClient;
    late PostRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = PostRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<PostRepository>());
    });

    test('SupabaseClient를 생성자로 주입받는다', () {
      expect(repository.client, equals(mockClient));
    });
  });

  group('postRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(postRepositoryProvider, isA<Provider<PostRepository>>());
    });
  });
}
