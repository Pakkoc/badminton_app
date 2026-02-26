import 'dart:async';

import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockOrderRepository extends Mock
    implements OrderRepository {}

class MockShopRepository extends Mock
    implements ShopRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late MockShopRepository mockShopRepository;
  late StreamController<Map<String, dynamic>> streamController;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockShopRepository = MockShopRepository();
    streamController =
        StreamController<Map<String, dynamic>>();
  });

  tearDown(() {
    streamController.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(
          mockOrderRepository,
        ),
        shopRepositoryProvider.overrideWithValue(
          mockShopRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('OrderDetailNotifier', () {
    test('초기 상태는 isLoading이 true이다', () {
      // Arrange
      when(
        () => mockOrderRepository.streamById(any()),
      ).thenAnswer((_) => streamController.stream);

      final container = createContainer();

      // Act
      final state = container.read(
        orderDetailNotifierProvider(testOrderReceived.id),
      );

      // Assert
      expect(state.isLoading, isTrue);
      expect(state.order, isNull);
    });

    test(
      'streamById 이벤트를 받으면 order와 shop이 설정된다',
      () async {
        // Arrange
        when(
          () => mockOrderRepository.streamById(any()),
        ).thenAnswer((_) => streamController.stream);
        when(
          () => mockShopRepository.getById(any()),
        ).thenAnswer((_) async => testShop);

        final container = createContainer();

        // Act - provider 읽기로 build 트리거
        container.read(
          orderDetailNotifierProvider(testOrderReceived.id),
        );

        // 스트림에 데이터 전송
        streamController.add(testOrderReceived.toJson());

        // 비동기 작업이 완료될 때까지 대기
        await Future<void>.delayed(
          const Duration(milliseconds: 100),
        );

        // Assert
        final state = container.read(
          orderDetailNotifierProvider(testOrderReceived.id),
        );
        expect(state.order, isNotNull);
        expect(state.order!.id, testOrderReceived.id);
        expect(state.shop, isNotNull);
        expect(state.shop!.name, testShop.name);
        expect(state.isLoading, isFalse);
      },
    );

    test(
      '스트림 에러 시 error 상태가 된다',
      () async {
        // Arrange
        when(
          () => mockOrderRepository.streamById(any()),
        ).thenAnswer((_) => streamController.stream);

        final container = createContainer();

        // Act
        container.read(
          orderDetailNotifierProvider(testOrderReceived.id),
        );

        streamController.addError(Exception('test error'));

        await Future<void>.delayed(
          const Duration(milliseconds: 100),
        );

        // Assert
        final state = container.read(
          orderDetailNotifierProvider(testOrderReceived.id),
        );
        expect(state.error, '주문 정보를 불러올 수 없습니다');
      },
    );
  });
}
