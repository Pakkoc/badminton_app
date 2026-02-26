import 'package:badminton_app/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_screen.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('PostDetailScreen', () {
    testWidgets(
      '로딩 중일 때 로딩 인디케이터가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _LoadingNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostNotice.id,
                shopId: testShop.id,
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

    testWidgets(
      '게시글 제목이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _LoadedNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostNotice.id,
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.text(testPostNotice.title),
          findsAny,
        );
      },
    );

    testWidgets(
      '게시글 내용이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _LoadedNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostNotice.id,
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.text(testPostNotice.content),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '카테고리 뱃지가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _LoadedNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostNotice.id,
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text('공지사항'), findsOneWidget);
      },
    );

    testWidgets(
      '이벤트 게시글이면 기간이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _EventNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostEvent.id,
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.textContaining('2026.03.01'),
          findsOneWidget,
        );
        expect(
          find.textContaining('2026.03.31'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '에러 발생 시 에러 화면이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              postDetailNotifierProvider.overrideWith(
                _ErrorNotifier.new,
              ),
            ],
            child: MaterialApp(
              home: PostDetailScreen(
                postId: testPostNotice.id,
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(
          find.text('게시글을 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );
  });
}

class _LoadingNotifier extends PostDetailNotifier {
  @override
  PostDetailState build() =>
      const PostDetailState(isLoading: true);
}

class _LoadedNotifier extends PostDetailNotifier {
  @override
  PostDetailState build() => PostDetailState(
        post: testPostNotice,
      );
}

class _EventNotifier extends PostDetailNotifier {
  @override
  PostDetailState build() => PostDetailState(
        post: testPostEvent,
      );
}

class _ErrorNotifier extends PostDetailNotifier {
  @override
  PostDetailState build() => const PostDetailState(
        error: '게시글을 불러올 수 없습니다',
      );
}
