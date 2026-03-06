import 'package:badminton_app/screens/community/community_create/community_create_notifier.dart';
import 'package:badminton_app/screens/community/community_create/community_create_screen.dart';
import 'package:badminton_app/screens/community/community_create/community_create_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityCreateScreen', () {
    testWidgets('게시글 작성 모드: 제목이 올바르게 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityCreateNotifierProvider
                .overrideWith(() => _FakeNotifier()),
          ],
          child: const MaterialApp(home: CommunityCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('게시글 작성'), findsOneWidget);
    });

    testWidgets('게시글 수정 모드: AppBar에 수정 제목이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityCreateNotifierProvider
                .overrideWith(() => _FakeNotifier()),
          ],
          child: const MaterialApp(
            home: CommunityCreateScreen(postId: 'post-1'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('게시글 수정'), findsOneWidget);
    });

    testWidgets('완료 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityCreateNotifierProvider
                .overrideWith(() => _FakeNotifier()),
          ],
          child: const MaterialApp(home: CommunityCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('제목, 내용 입력 필드가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityCreateNotifierProvider
                .overrideWith(() => _FakeNotifier()),
          ],
          child: const MaterialApp(home: CommunityCreateScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });
  });
}

class _FakeNotifier extends CommunityCreateNotifier {
  @override
  CommunityCreateState build() => const CommunityCreateState();

  @override
  Future<void> loadPost(String postId) async {}
}
