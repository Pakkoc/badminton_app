import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/community/community_detail/community_detail_screen.dart';
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
  group('CommunityDetailScreen', () {
    testWidgets('게시글을 찾을 수 없을 때 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => null,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('게시글을 찾을 수 없습니다'), findsOneWidget);
    });

    testWidgets('게시글 제목이 표시된다', (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '테스트 제목',
        content: '테스트 내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('테스트 제목'), findsOneWidget);
      expect(find.text('테스트 내용'), findsOneWidget);
    });

    testWidgets('AppBar에 게시글 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => null,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('게시글'), findsOneWidget);
    });

    testWidgets('댓글에 프로필 아바타가 표시된다', (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      final comment = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u2',
        content: '테스트 댓글',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [comment],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('게시글 작성자 댓글에 작성자 배지가 표시된다', (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      // 게시글 작성자(u1)가 단 댓글
      final comment = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u1',
        content: '작성자 댓글',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [comment],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      // '· 작성자' 배지가 렌더링되는지 확인
      expect(
        find.text('· 작성자', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('대댓글이 있으면 답글 더보기 버튼이 표시된다', (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      final parent = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u2',
        content: '부모 댓글',
        createdAt: DateTime(2026, 3, 1),
      );
      final reply = CommunityComment(
        id: 'c2',
        postId: 'p1',
        authorId: 'u3',
        parentId: 'c1',
        content: '대댓글',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [parent, reply],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('답글'), findsWidgets);
      expect(find.textContaining('더보기'), findsOneWidget);
    });

    testWidgets('대댓글이 있을 때 답글 더보기 버튼이 들여쓰기되어 표시된다',
        (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      final parent = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u2',
        content: '부모 댓글',
        createdAt: DateTime(2026, 3, 1),
      );
      final reply = CommunityComment(
        id: 'c2',
        postId: 'p1',
        authorId: 'u3',
        parentId: 'c1',
        content: '대댓글',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [parent, reply],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      // 대댓글이 있으면 답글 더보기 토글 버튼이 표시된다
      expect(find.textContaining('더보기'), findsOneWidget);
    });

    testWidgets('대댓글 없는 댓글에는 답글 토글이 표시되지 않는다',
        (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      final comment = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u2',
        content: '단독 댓글',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [comment],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      // 대댓글 없으면 답글 토글 버튼이 없음
      expect(find.textContaining('더보기'), findsNothing);
    });

    testWidgets('답글 더보기를 누르면 대댓글이 표시된다', (tester) async {
      final post = CommunityPost(
        id: 'p1',
        authorId: 'u1',
        title: '제목',
        content: '내용',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
      final parent = CommunityComment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u2',
        content: '부모 댓글',
        createdAt: DateTime(2026, 3, 1),
      );
      final reply = CommunityComment(
        id: 'c2',
        postId: 'p1',
        authorId: 'u3',
        parentId: 'c1',
        content: '대댓글 내용',
        createdAt: DateTime(2026, 3, 1),
      );

      await tester.pumpWidget(
        _wrap(
          [
            communityPostDetailProvider('p1').overrideWith(
              (_) async => post,
            ),
            communityCommentsProvider('p1').overrideWith(
              (_) async => [parent, reply],
            ),
            communityPostLikeStatusProvider(
              (userId: '', postId: 'p1'),
            ).overrideWith((_) async => false),
          ],
          const CommunityDetailScreen(postId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();

      // 접힌 상태: 대댓글 내용 미표시
      expect(find.text('대댓글 내용'), findsNothing);

      // 더보기 버튼 탭
      await tester.tap(find.textContaining('더보기'));
      await tester.pumpAndSettle();

      // 펼침 상태: 대댓글 표시
      expect(find.text('대댓글 내용'), findsOneWidget);
    });
  });
}
