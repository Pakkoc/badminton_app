import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityReport', () {
    test('게시글 신고를 생성할 수 있다', () {
      final report = CommunityReport(
        id: 'r1',
        reporterId: 'u1',
        postId: 'p1',
        reason: '부적절한 내용',
        status: ReportStatus.pending,
        createdAt: DateTime(2026, 3, 1),
      );
      expect(report.postId, 'p1');
      expect(report.commentId, isNull);
    });

    test('댓글 신고를 생성할 수 있다', () {
      final report = CommunityReport(
        id: 'r2',
        reporterId: 'u1',
        commentId: 'c1',
        reason: '욕설',
        status: ReportStatus.pending,
        createdAt: DateTime(2026, 3, 1),
      );
      expect(report.commentId, 'c1');
      expect(report.postId, isNull);
    });

    test('JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'r1',
        'reporter_id': 'u1',
        'post_id': 'p1',
        'comment_id': null,
        'reason': '스팸',
        'status': 'pending',
        'created_at': '2026-03-01T00:00:00.000Z',
      };
      final report = CommunityReport.fromJson(json);
      expect(report.status, ReportStatus.pending);
    });

    test('resolved 상태를 JSON에서 변환할 수 있다', () {
      final json = {
        'id': 'r2',
        'reporter_id': 'u1',
        'post_id': null,
        'comment_id': 'c1',
        'reason': '욕설',
        'status': 'resolved',
        'created_at': '2026-03-01T00:00:00.000Z',
      };
      final report = CommunityReport.fromJson(json);
      expect(report.status, ReportStatus.resolved);
    });
  });
}
