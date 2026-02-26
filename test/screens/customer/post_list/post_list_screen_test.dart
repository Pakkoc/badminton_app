import 'package:badminton_app/screens/customer/post_list/post_list_notifier.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_screen.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('PostListScreen', () {
    testWidgets(
      'AppBar에 카테고리명이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postListNotifierProvider.overrideWith(
                PostListNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostListScreen(
                shopId: testShop.id,
                category: 'notice',
                categoryLabel: '공지사항',
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('공지사항'), findsOneWidget);
      },
    );

    testWidgets(
      '빈 상태에서 EmptyState가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postListNotifierProvider.overrideWith(
                _EmptyNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostListScreen(
                shopId: testShop.id,
                category: 'notice',
                categoryLabel: '공지사항',
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.text('등록된 게시글이 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '게시글이 있으면 목록이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postListNotifierProvider.overrideWith(
                _WithPostsNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostListScreen(
                shopId: testShop.id,
                category: 'notice',
                categoryLabel: '공지사항',
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.text(testPostNotice.title),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '로딩 중일 때 로딩 인디케이터가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postListNotifierProvider.overrideWith(
                _LoadingNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostListScreen(
                shopId: testShop.id,
                category: 'notice',
                categoryLabel: '공지사항',
              ),
            ),
          ),
        );

        // Assert
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );
  });
}

class _EmptyNotifier extends PostListNotifier {
  @override
  PostListState build() => const PostListState();

  @override
  Future<void> loadPosts(
    String shopId,
    String category,
  ) async {}
}

class _WithPostsNotifier extends PostListNotifier {
  @override
  PostListState build() => PostListState(
        posts: [testPostNotice],
      );

  @override
  Future<void> loadPosts(
    String shopId,
    String category,
  ) async {}
}

class _LoadingNotifier extends PostListNotifier {
  @override
  PostListState build() =>
      const PostListState(isLoading: true);

  @override
  Future<void> loadPosts(
    String shopId,
    String category,
  ) async {}
}
