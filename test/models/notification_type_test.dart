import 'package:badminton_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationType', () {
    test('commentOnPost를 직렬화한다', () {
      expect(NotificationType.commentOnPost.toJson(), 'comment_on_post');
    });
    test('replyOnComment를 직렬화한다', () {
      expect(NotificationType.replyOnComment.toJson(), 'reply_on_comment');
    });
    test('comment_on_post를 역직렬화한다', () {
      expect(
        NotificationType.fromJson('comment_on_post'),
        NotificationType.commentOnPost,
      );
    });
    test('reply_on_comment를 역직렬화한다', () {
      expect(
        NotificationType.fromJson('reply_on_comment'),
        NotificationType.replyOnComment,
      );
    });
  });
}
