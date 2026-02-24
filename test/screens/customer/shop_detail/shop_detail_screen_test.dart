import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_screen.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('ShopDetailScreen', () {
    testWidgets(
      '로딩 중일 때 로딩 인디케이터가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopDetailNotifierProvider.overrideWith(
                () => _LoadingNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(
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
      '샵 정보가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopDetailNotifierProvider.overrideWith(
                () => _LoadedNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(testShop.name), findsOneWidget);
        expect(find.text(testShop.address), findsOneWidget);
      },
    );

    testWidgets(
      '회원 등록 버튼이 미등록 시 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopDetailNotifierProvider.overrideWith(
                () => _NotMemberNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('회원 등록'), findsOneWidget);
      },
    );

    testWidgets(
      '등록된 회원이면 안내 문구가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopDetailNotifierProvider.overrideWith(
                () => _LoadedNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('등록된 회원입니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '탭바에 공지사항과 이벤트 탭이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopDetailNotifierProvider.overrideWith(
                () => _LoadedNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(
                shopId: testShop.id,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('공지사항'), findsOneWidget);
        expect(find.text('이벤트'), findsOneWidget);
      },
    );
  });
}

class _LoadingNotifier extends ShopDetailNotifier {
  @override
  ShopDetailState build() =>
      const ShopDetailState(isLoading: true);
}

class _LoadedNotifier extends ShopDetailNotifier {
  @override
  ShopDetailState build() => ShopDetailState(
        shop: testShop,
        isMember: true,
        noticePosts: [testPostNotice],
        eventPosts: [testPostEvent],
      );
}

class _NotMemberNotifier extends ShopDetailNotifier {
  @override
  ShopDetailState build() => ShopDetailState(
        shop: testShop,
        isMember: false,
      );
}
