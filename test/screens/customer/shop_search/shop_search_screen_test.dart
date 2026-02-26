import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_screen.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('ShopSearchScreen', () {
    Widget createApp({
      ShopSearchState initialState = const ShopSearchState(),
    }) {
      return ProviderScope(
        overrides: [
          shopSearchNotifierProvider.overrideWith(
            ShopSearchNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: ShopSearchScreen(),
        ),
      );
    }

    testWidgets(
      'AppBar에 "샵 검색" 텍스트가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(find.text('샵 검색'), findsOneWidget);
      },
    );

    testWidgets(
      '검색 필드가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(
          find.byType(TextField),
          findsOneWidget,
        );
        expect(
          find.text('샵 이름을 검색하세요'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '빈 상태에서 EmptyState가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createApp());

        // Assert
        expect(
          find.text('검색 결과가 없습니다'),
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
              shopSearchNotifierProvider.overrideWith(
                _LoadingShopSearchNotifier.new,
              ),
            ],
            child: const MaterialApp(
              home: ShopSearchScreen(),
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

class _LoadingShopSearchNotifier extends ShopSearchNotifier {
  @override
  ShopSearchState build() =>
      const ShopSearchState(isLoading: true);
}
