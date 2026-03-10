import 'package:badminton_app/providers/location_provider.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_screen.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:badminton_app/services/location_service.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockLocationService extends Mock
    implements LocationService {}

class FakeShopSearchNotifier extends ShopSearchNotifier {
  final ShopSearchState _initialState;

  FakeShopSearchNotifier(this._initialState);

  @override
  ShopSearchState build() => _initialState;

  @override
  Future<void> loadNearbyShops({
    double swLat = 33.0,
    double swLng = 124.0,
    double neLat = 39.0,
    double neLng = 132.0,
  }) async {}

  @override
  Future<void> checkAndRequestPermission() async {}
}

void main() {
  late MockLocationService mockLocationService;

  Widget createApp({
    required ShopSearchState state,
  }) {
    return ProviderScope(
      overrides: [
        shopSearchNotifierProvider.overrideWith(
          () => FakeShopSearchNotifier(state),
        ),
        locationServiceProvider
            .overrideWithValue(mockLocationService),
      ],
      child: const MaterialApp(
        home: ShopSearchScreen(),
      ),
    );
  }

  setUp(() {
    mockLocationService = MockLocationService();
    when(() => mockLocationService.checkPermission())
        .thenAnswer((_) async => false);
    when(() => mockLocationService.requestPermission())
        .thenAnswer((_) async => false);
    when(() => mockLocationService.openSettings())
        .thenAnswer((_) async => true);
    MapPreview.usePlaceholder = true;
    shopSearchUsePlaceholder = true;
  });

  tearDown(() {
    MapPreview.usePlaceholder = false;
    shopSearchUsePlaceholder = false;
  });

  group('ShopSearchScreen', () {
    testWidgets(
      'AppBar에 "주변 샵" 타이틀이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              isLoading: true,
              hasLocationPermission: true,
            ),
          ),
        );
        expect(find.text('주변 샵'), findsOneWidget);
      },
    );

    testWidgets(
      '뷰 전환 토글에 "지도"와 "리스트"가 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              isLoading: true,
              hasLocationPermission: true,
            ),
          ),
        );
        expect(find.text('지도'), findsOneWidget);
        expect(find.text('리스트'), findsOneWidget);
      },
    );

    testWidgets(
      '로딩 중일 때 LoadingIndicator를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              isLoading: true,
              hasLocationPermission: true,
              viewMode: ShopSearchViewMode.list,
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
            state: const ShopSearchState(
              error: '주변 샵을 불러올 수 없습니다',
              hasLocationPermission: true,
              viewMode: ShopSearchViewMode.list,
            ),
          ),
        );
        expect(
          find.text('주변 샵을 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '빈 상태에서 안내 메시지를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              hasLocationPermission: true,
              viewMode: ShopSearchViewMode.list,
            ),
          ),
        );
        expect(
          find.text('주변에 등록된 샵이 없습니다'),
          findsOneWidget,
        );
        expect(
          find.text('다른 지역을 탐색해 보세요'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '리스트 뷰에서 샵 카드에 이름, 주소, 작업 현황이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: ShopSearchState(
              hasLocationPermission: true,
              viewMode: ShopSearchViewMode.list,
              shops: [testShop],
              orderCounts: {
                testShop.id: const ShopOrderCounts(
                  receivedCount: 2,
                  inProgressCount: 1,
                ),
              },
            ),
          ),
        );
        expect(
          find.text(testShop.name),
          findsOneWidget,
        );
        expect(
          find.text(testShop.address),
          findsOneWidget,
        );
        expect(
          find.text('접수 2건'),
          findsOneWidget,
        );
        expect(
          find.text('작업중 1건'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '하단 네비게이션 4탭이 표시된다 (샵검색 탭 활성)',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              hasLocationPermission: true,
            ),
          ),
        );
        expect(
          find.byType(CustomerBottomNav),
          findsOneWidget,
        );
        expect(find.text('샵검색'), findsOneWidget);
      },
    );

    testWidgets(
      '위치 권한 미허용 시 안내 화면을 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const ShopSearchState(
              hasLocationPermission: false,
            ),
          ),
        );
        expect(
          find.text('위치 권한이 필요합니다'),
          findsOneWidget,
        );
        expect(
          find.text('권한 허용하기'),
          findsOneWidget,
        );
        expect(
          find.text('설정으로 이동'),
          findsOneWidget,
        );
      },
    );
  });
}
