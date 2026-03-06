import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/screens/community/community_list/community_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityListScreen', () {
    testWidgets('AppBar에 커뮤니티 제목이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      // AppBar 타이틀 + 하단 탭 레이블 둘 다 '커뮤니티'를 표시한다
      expect(find.text('커뮤니티'), findsAtLeastNWidgets(1));
    });

    testWidgets('게시글이 없으면 빈 상태를 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('게시글이 없습니다'), findsOneWidget);
    });

    testWidgets('FAB이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith(
              (_) async => <CommunityPost>[],
            ),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('게시글 목록이 표시된다', (tester) async {
      final posts = [
        CommunityPost(
          id: 'p1',
          authorId: 'u1',
          title: '테스트 게시글',
          content: '내용',
          authorName: '홍길동',
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 3, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityPostListProvider.overrideWith((_) async => posts),
          ],
          child: const MaterialApp(home: CommunityListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('테스트 게시글'), findsOneWidget);
    });
  });
}
