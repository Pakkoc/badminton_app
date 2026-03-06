import 'package:badminton_app/models/community_comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityComment', () {
    test('1단 댓글을 생성할 수 있다', () {
      final comment = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'a1',
        content: '댓글 내용',
        createdAt: DateTime(2026, 3, 1),
      );
      expect(comment.parentId, isNull);
      expect(comment.likeCount, 0);
    });

    test('대댓글을 생성할 수 있다', () {
      final reply = CommunityComment(
        id: 'c2',
        postId: 'p1',
        authorId: 'a2',
        parentId: 'c1',
        content: '대댓글',
        createdAt: DateTime(2026, 3, 1),
      );
      expect(reply.parentId, 'c1');
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'c1',
        'post_id': 'p1',
        'author_id': 'a1',
        'parent_id': null,
        'content': '댓글',
        'like_count': 2,
        'created_at': '2026-03-01T00:00:00.000Z',
      };
      final comment = CommunityComment.fromJson(json);
      expect(comment.postId, 'p1');
      expect(comment.likeCount, 2);
    });

    test('JOIN author 객체를 flat하게 변환할 수 있다', () {
      final json = {
        'id': 'c1',
        'post_id': 'p1',
        'author_id': 'a1',
        'parent_id': null,
        'content': '댓글',
        'like_count': 0,
        'created_at': '2026-03-01T00:00:00.000Z',
        'author': {
          'name': '홍길동',
          'profile_image_url': null,
        },
      };
      final comment = CommunityComment.fromJson(json);
      expect(comment.authorName, '홍길동');
      expect(comment.authorProfileImageUrl, isNull);
    });
  });
}
