import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockShopRepository mockShopRepository;
  late ProviderContainer container;

  setUp(() {
    mockShopRepository = MockShopRepository();
    container = ProviderContainer(
      overrides: [
        shopRepositoryProvider.overrideWithValue(mockShopRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopSearchNotifier', () {
    test('초기 상태는 빈 리스트이다', () {
      // Arrange & Act
      final state = container.read(shopSearchNotifierProvider);

      // Assert
      expect(state, const ShopSearchState());
      expect(state.shops, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.searchQuery, '');
    });

    test('searchShops 성공 시 샵 목록을 반환한다', () async {
      // Arrange
      when(() => mockShopRepository.searchByName('거트'))
          .thenAnswer((_) async => [testShop]);

      final notifier = container.read(
        shopSearchNotifierProvider.notifier,
      );

      // Act
      await notifier.searchShops('거트');

      // Assert
      final state = container.read(shopSearchNotifierProvider);
      expect(state.shops, [testShop]);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.searchQuery, '거트');
    });

    test('searchShops 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
      when(() => mockShopRepository.searchByName('거트'))
          .thenThrow(Exception('error'));

      final notifier = container.read(
        shopSearchNotifierProvider.notifier,
      );

      // Act
      await notifier.searchShops('거트');

      // Assert
      final state = container.read(shopSearchNotifierProvider);
      expect(state.shops, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, '샵 검색에 실패했습니다');
    });

    test('loadNearbyShops 성공 시 주변 샵을 반환한다', () async {
      // Arrange
      when(
        () => mockShopRepository.searchByBounds(
          swLat: any(named: 'swLat'),
          swLng: any(named: 'swLng'),
          neLat: any(named: 'neLat'),
          neLng: any(named: 'neLng'),
        ),
      ).thenAnswer((_) async => [testShop]);

      final notifier = container.read(
        shopSearchNotifierProvider.notifier,
      );

      // Act
      await notifier.loadNearbyShops();

      // Assert
      final state = container.read(shopSearchNotifierProvider);
      expect(state.shops, [testShop]);
      expect(state.isLoading, false);
    });

    test('loadNearbyShops 실패 시 에러 메시지를 설정한다', () async {
      // Arrange
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

      // Act
      await notifier.loadNearbyShops();

      // Assert
      final state = container.read(shopSearchNotifierProvider);
      expect(state.error, '주변 샵을 불러올 수 없습니다');
    });
  });
}
