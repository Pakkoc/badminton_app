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

  group('resolveParentId', () {
    late MockSupabaseClient mockClient;
    late CommunityCommentRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = CommunityCommentRepository(mockClient);
    });

    test('1단 댓글에 답글 시 parent_id를 그대로 유지한다', () {
      // Arrange
      const rootId = 'root-comment-id';

      // Act
      final resolved = repository.resolveParentId(
        targetCommentId: rootId,
        targetCommentParentId: null,
      );

      // Assert
      expect(resolved, rootId);
    });

    test('대댓글에 답글 시 parent_id를 루트 댓글로 보정한다', () {
      // Arrange
      const rootId = 'root-comment-id';
      const replyId = 'reply-comment-id';

      // Act
      final resolved = repository.resolveParentId(
        targetCommentId: replyId,
        targetCommentParentId: rootId,
      );

      // Assert
      expect(resolved, rootId);
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
