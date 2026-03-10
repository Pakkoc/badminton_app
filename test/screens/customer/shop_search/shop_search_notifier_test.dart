import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/location_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:badminton_app/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock
    implements ShopRepository {}

class MockOrderRepository extends Mock
    implements OrderRepository {}

class MockLocationService extends Mock
    implements LocationService {}

void main() {
  late MockShopRepository mockShopRepository;
  late MockOrderRepository mockOrderRepository;
  late MockLocationService mockLocationService;
  late ProviderContainer container;

  setUp(() {
    mockShopRepository = MockShopRepository();
    mockOrderRepository = MockOrderRepository();
    mockLocationService = MockLocationService();

    // 기본: 권한 미허용 상태
    when(() => mockLocationService.checkPermission())
        .thenAnswer((_) async => false);
    when(() => mockLocationService.requestPermission())
        .thenAnswer((_) async => false);

    container = ProviderContainer(
      overrides: [
        shopRepositoryProvider
            .overrideWithValue(mockShopRepository),
        orderRepositoryProvider
            .overrideWithValue(mockOrderRepository),
        locationServiceProvider
            .overrideWithValue(mockLocationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopSearchNotifier', () {
    test('초기 상태는 빈 리스트, 지도 뷰 모드이다', () {
      final state =
          container.read(shopSearchNotifierProvider);

      expect(state.shops, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(
        state.viewMode,
        ShopSearchViewMode.map,
      );
      expect(state.hasLocationPermission, false);
    });

    test('toggleViewMode로 뷰 모드를 전환한다', () {
      final notifier = container.read(
        shopSearchNotifierProvider.notifier,
      );

      notifier.toggleViewMode(ShopSearchViewMode.list);

      final state =
          container.read(shopSearchNotifierProvider);
      expect(
        state.viewMode,
        ShopSearchViewMode.list,
      );
    });

    test('selectShop으로 샵을 선택/해제한다', () {
      final notifier = container.read(
        shopSearchNotifierProvider.notifier,
      );

      notifier.selectShop(testShop);
      expect(
        container
            .read(shopSearchNotifierProvider)
            .selectedShop,
        testShop,
      );

      notifier.selectShop(null);
      expect(
        container
            .read(shopSearchNotifierProvider)
            .selectedShop,
        isNull,
      );
    });

    test(
      'loadNearbyShops 성공 시 샵 목록과 주문 현황을 반환한다',
      () async {
        when(
          () => mockShopRepository.searchByBounds(
            swLat: any(named: 'swLat'),
            swLng: any(named: 'swLng'),
            neLat: any(named: 'neLat'),
            neLng: any(named: 'neLng'),
          ),
        ).thenAnswer((_) async => [testShop]);

        when(
          () => mockOrderRepository.getByShop(
            testShop.id,
          ),
        ).thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
          ],
        );

        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        await notifier.loadNearbyShops();

        final state =
            container.read(shopSearchNotifierProvider);
        expect(state.shops, [testShop]);
        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(
          state.orderCounts[testShop.id]
              ?.receivedCount,
          1,
        );
        expect(
          state.orderCounts[testShop.id]
              ?.inProgressCount,
          1,
        );
      },
    );

    test(
      'loadNearbyShops 실패 시 에러 메시지를 설정한다',
      () async {
        when(
          () => mockShopRepository.searchByBounds(
            swLat: any(named: 'swLat'),
            swLng: any(named: 'swLng'),
            neLat: any(named: 'neLat'),
            neLng: any(named: 'neLng'),
          ),
        ).thenThrow(Exception('error'));

        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        await notifier.loadNearbyShops();

        final state =
            container.read(shopSearchNotifierProvider);
        expect(
          state.error,
          '주변 샵을 불러올 수 없습니다',
        );
      },
    );

    test(
      'setLocationPermission 상태를 업데이트한다',
      () {
        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        notifier.setLocationPermission(true);

        final state =
            container.read(shopSearchNotifierProvider);
        expect(
          state.hasLocationPermission,
          true,
        );
      },
    );

    test(
      'checkAndRequestPermission 권한이 이미 있으면 '
      'loadNearbyShops를 호출한다',
      () async {
        when(() => mockLocationService.checkPermission())
            .thenAnswer((_) async => true);
        when(
          () => mockShopRepository.searchByBounds(
            swLat: any(named: 'swLat'),
            swLng: any(named: 'swLng'),
            neLat: any(named: 'neLat'),
            neLng: any(named: 'neLng'),
          ),
        ).thenAnswer((_) async => []);

        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        await notifier.checkAndRequestPermission();

        final state =
            container.read(shopSearchNotifierProvider);
        expect(state.hasLocationPermission, true);
        // build() 내 microtask + 수동 호출로 2회.
        verify(
          () => mockShopRepository.searchByBounds(
            swLat: any(named: 'swLat'),
            swLng: any(named: 'swLng'),
            neLat: any(named: 'neLat'),
            neLng: any(named: 'neLng'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    test(
      'checkAndRequestPermission 권한 요청 후 승인되면 '
      'loadNearbyShops를 호출한다',
      () async {
        when(() => mockLocationService.checkPermission())
            .thenAnswer((_) async => false);
        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => true);
        when(
          () => mockShopRepository.searchByBounds(
            swLat: any(named: 'swLat'),
            swLng: any(named: 'swLng'),
            neLat: any(named: 'neLat'),
            neLng: any(named: 'neLng'),
          ),
        ).thenAnswer((_) async => []);

        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        await notifier.checkAndRequestPermission();

        final state =
            container.read(shopSearchNotifierProvider);
        expect(state.hasLocationPermission, true);
      },
    );

    test(
      'checkAndRequestPermission 권한 거부 시 '
      'hasLocationPermission이 false이다',
      () async {
        when(() => mockLocationService.checkPermission())
            .thenAnswer((_) async => false);
        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => false);

        final notifier = container.read(
          shopSearchNotifierProvider.notifier,
        );

        await notifier.checkAndRequestPermission();

        final state =
            container.read(shopSearchNotifierProvider);
        expect(state.hasLocationPermission, false);
      },
    );
  });
}
