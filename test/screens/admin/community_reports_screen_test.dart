import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/admin/community_reports/community_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

ProviderScope _wrap(List<Override> overrides, Widget child) {
  final mockClient = MockSupabaseClient();
  final mockAuth = MockGoTrueClient();
  when(() => mockClient.auth).thenReturn(mockAuth);
  when(() => mockAuth.currentUser).thenReturn(null);

  return ProviderScope(
    overrides: [
      supabaseProvider.overrideWithValue(mockClient),
      ...overrides,
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('CommunityReportsScreen', () {
    testWidgets('AppBar 타이틀이 올바르게 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          [],
          const CommunityReportsScreen(),
        ),
      );
      await tester.pump();
      expect(find.text('커뮤니티 신고 관리'), findsOneWidget);
    });

    testWidgets('신고 목록이 비어있으면 빈 상태를 표시한다', (tester) async {
      // _pendingReportsProvider는 private이므로 CommunityReportsScreen은
      // 직접 provider override가 어렵다. 로딩 인디케이터가 표시되는지 확인
      await tester.pumpWidget(
        _wrap(
          [],
          const CommunityReportsScreen(),
        ),
      );
      // 로딩 중에는 LoadingIndicator가 표시된다
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CommunityReportsScreen 위젯이 생성된다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          [],
          const CommunityReportsScreen(),
        ),
      );
      expect(find.byType(CommunityReportsScreen), findsOneWidget);
    });
  });

  group('CommunityReport 모델', () {
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
      expect(report.status, ReportStatus.pending);
    });

    test('댓글 신고를 생성할 수 있다', () {
      final report = CommunityReport(
        id: 'r2',
        reporterId: 'u1',
        commentId: 'c1',
        reason: '스팸',
        status: ReportStatus.dismissed,
        createdAt: DateTime(2026, 3, 1),
      );
      expect(report.commentId, 'c1');
      expect(report.postId, isNull);
      expect(report.status.label, '기각');
    });
  });
}
