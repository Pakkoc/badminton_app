import 'package:badminton_app/models/community_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityPost', () {
    test('인스턴스를 생성할 수 있다', () {
      final post = CommunityPost(
        id: 'test-id',
        authorId: 'author-id',
        title: '테스트 제목',
        content: '테스트 내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      expect(post.id, 'test-id');
      expect(post.title, '테스트 제목');
      expect(post.images, isEmpty);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'test-id',
        'author_id': 'author-id',
        'title': '제목',
        'content': '내용',
        'images': ['img1.jpg'],
        'like_count': 5,
        'comment_count': 3,
        'created_at': '2026-03-01T00:00:00.000Z',
        'updated_at': '2026-03-01T00:00:00.000Z',
      };
      final post = CommunityPost.fromJson(json);
      expect(post.authorId, 'author-id');
      expect(post.likeCount, 5);
      expect(post.images, ['img1.jpg']);
    });

    test('authorName은 nullable이다', () {
      final post = CommunityPost(
        id: 'id',
        authorId: 'aid',
        title: 't',
        content: 'c',
        authorName: '홍길동',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      expect(post.authorName, '홍길동');
    });

    test('JOIN author 객체를 flat하게 변환할 수 있다', () {
      final json = {
        'id': 'test-id',
        'author_id': 'author-id',
        'title': '제목',
        'content': '내용',
        'images': <String>[],
        'like_count': 0,
        'comment_count': 0,
        'created_at': '2026-03-01T00:00:00.000Z',
        'updated_at': '2026-03-01T00:00:00.000Z',
        'author': {
          'name': '홍길동',
          'profile_image_url': 'https://example.com/avatar.jpg',
        },
      };
      final post = CommunityPost.fromJson(json);
      expect(post.authorName, '홍길동');
      expect(
        post.authorProfileImageUrl,
        'https://example.com/avatar.jpg',
      );
    });
  });
}
