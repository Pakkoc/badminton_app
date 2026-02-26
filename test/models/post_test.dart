import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Post', () {
    final json = {
      'id': '990e8400-e29b-41d4-a716-446655440004',
      'shop_id': '660e8400-e29b-41d4-a716-446655440001',
      'category': 'notice',
      'title': '영업시간 변경 안내',
      'content': '이번 주부터 영업시간이 변경됩니다.',
      'images': ['https://example.com/img1.jpg'],
      'event_start_date': null,
      'event_end_date': null,
      'created_at': '2026-01-20T09:00:00.000Z',
    };

    test('fromJson은 JSON에서 Post 객체를 생성한다', () {
      final post = Post.fromJson(json);
      expect(post.id, '990e8400-e29b-41d4-a716-446655440004');
      expect(post.category, PostCategory.notice);
      expect(post.title, '영업시간 변경 안내');
      expect(post.images, hasLength(1));
    });

    test('toJson은 Post 객체를 JSON으로 변환한다', () {
      final result = Post.fromJson(json).toJson();
      expect(result['category'], 'notice');
      expect(result['title'], '영업시간 변경 안내');
    });

    test('이벤트 카테고리는 날짜를 포함한다', () {
      final eventJson = {
        'id': '990e8400-e29b-41d4-a716-446655440005',
        'shop_id': '660e8400-e29b-41d4-a716-446655440001',
        'category': 'event',
        'title': '봄맞이 할인',
        'content': '거트 교체 20% 할인!',
        'images': <String>[],
        'event_start_date': '2026-03-01',
        'event_end_date': '2026-03-31',
        'created_at': '2026-02-20T09:00:00.000Z',
      };
      final post = Post.fromJson(eventJson);
      expect(post.category, PostCategory.event);
      expect(post.eventStartDate, isNotNull);
      expect(post.eventEndDate, isNotNull);
    });

    test('동일한 데이터를 가진 두 Post는 같다', () {
      expect(Post.fromJson(json), equals(Post.fromJson(json)));
    });
  });
}
