import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('CommunityCommentRepository', () {
    late MockSupabaseClient mockClient;
    late CommunityCommentRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityCommentRepository(mockClient);
    });

    test('인스턴스를 생성할 수 있다', () {
      expect(repository, isA<CommunityCommentRepository>());
    });

    test('getByPostId 메서드가 정의되어 있다', () {
      expect(repository.getByPostId, isA<Function>());
    });

    test('create 메서드가 정의되어 있다', () {
      expect(repository.create, isA<Function>());
    });

    test('delete 메서드가 정의되어 있다', () {
      expect(repository.delete, isA<Function>());
    });
  });

  group('communityCommentRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      expect(
        communityCommentRepositoryProvider,
        isA<Provider<CommunityCommentRepository>>(),
      );
    });
  });
}
