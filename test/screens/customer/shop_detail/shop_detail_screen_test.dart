import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_screen.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:badminton_app/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class FakeShopDetailNotifier extends ShopDetailNotifier {
  final ShopDetailState _initialState;

  FakeShopDetailNotifier(this._initialState);

  @override
  ShopDetailState build() => _initialState;

  @override
  Future<void> loadShop(String shopId) async {}

  @override
  Future<void> registerMember(String shopId) async {}
}

void main() {
  Widget createApp({
    required ShopDetailState state,
  }) {
    return ProviderScope(
      overrides: [
        shopDetailNotifierProvider.overrideWith(
          () => FakeShopDetailNotifier(state),
        ),
      ],
      child: MaterialApp(
        home: ShopDetailScreen(shopId: testShop.id),
      ),
    );
  }

  setUp(() {
    MapPreview.usePlaceholder = true;
  });

  tearDown(() {
    MapPreview.usePlaceholder = false;
  });

  group('ShopDetailScreen', () {
    testWidgets(
      'AppBar에 "샵 정보" 타이틀이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopDetailState(
              isLoading: true,
            ),
          ),
        );
        expect(find.text('샵 정보'), findsOneWidget);
      },
    );

    testWidgets(
      '로딩 중일 때 LoadingIndicator를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopDetailState(
              isLoading: true,
            ),
          ),
        );
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopDetailState(
              error: '샵 정보를 불러올 수 없습니다',
            ),
          ),
        );
        expect(
          find.text('샵 정보를 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'storefront 아이콘과 샵 이름이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(testShop.name),
          findsOneWidget,
        );
        expect(
          find.byIcon(Icons.storefront),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '소개글이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(testShop.description!),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '"작업 현황" 섹션에 접수/작업중 건수가 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(
              shop: testShop,
              receivedCount: 3,
              inProgressCount: 1,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('작업 현황'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('접수'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('작업중'), findsOneWidget);
      },
    );

    testWidgets(
      '"위치 및 연락처" 섹션에 주소가 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('위치 및 연락처'),
          findsOneWidget,
        );
        expect(
          find.text(testShop.address),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '풀 너비 "길찾기" 버튼이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('길찾기'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3개 탭(공지사항/이벤트/가게 재고)이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        // 탭이 스크롤 아래에 있으므로 드래그
        await tester.drag(
          find.byType(NestedScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(find.text('공지사항'), findsOneWidget);
        expect(find.text('이벤트'), findsOneWidget);
        expect(find.text('가게 재고'), findsOneWidget);
      },
    );

    testWidgets(
      '공지사항이 없을 때 빈 상태 메시지를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(shop: testShop),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(NestedScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('등록된 공지사항이 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '공지사항 목록이 있으면 제목이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopDetailState(
              shop: testShop,
              noticePosts: [testPostNotice],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(NestedScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(testPostNotice.title),
          findsOneWidget,
        );
      },
    );
  });
}
