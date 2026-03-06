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
  });
}
