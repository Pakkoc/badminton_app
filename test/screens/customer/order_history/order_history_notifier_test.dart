import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockOrderRepository extends Mock
    implements OrderRepository {}

class MockShopRepository extends Mock
    implements ShopRepository {}

class MockUserRepository extends Mock
    implements UserRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late MockShopRepository mockShopRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockShopRepository = MockShopRepository();
    mockUserRepository = MockUserRepository();
    when(
      () => mockShopRepository.getById(any()),
    ).thenAnswer((_) async => testShop);
    when(
      () => mockUserRepository.getById(testUser.id),
    ).thenAnswer((_) async => testUser);
  });

  ProviderContainer createContainer({
    User? user,
  }) {
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(
          mockOrderRepository,
        ),
        shopRepositoryProvider.overrideWithValue(
          mockShopRepository,
        ),
        userRepositoryProvider.overrideWithValue(
          mockUserRepository,
        ),
        currentAuthUserIdProvider.overrideWithValue(
          user?.id,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('OrderHistoryNotifier', () {
    test('초기 상태는 isLoading이 true이다', () {
      when(
        () => mockOrderRepository.getByMemberUser(any()),
      ).thenAnswer((_) async => []);

      final container = createContainer(user: testUser);
      final state =
          container.read(orderHistoryNotifierProvider);
      expect(state.isLoading, isTrue);
    });

    test(
      'loadHistory가 완료된 주문만 필터링한다',
      () async {
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
            testOrderCompleted,
          ],
        );

        final container = createContainer(user: testUser);
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.orders.length, 1);
        expect(
          state.orders.first.status,
          OrderStatus.completed,
        );
      },
    );

    test(
      'loadHistory가 샵 이름을 함께 조회한다',
      () async {
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer(
          (_) async => [testOrderCompleted],
        );

        final container = createContainer(user: testUser);
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        final state =
            container.read(orderHistoryNotifierProvider);
        expect(
          state.shopNames[testOrderCompleted.shopId],
          testShop.name,
        );
      },
    );

    test(
      '사용자가 없으면 에러 상태가 된다',
      () async {
        final container = createContainer();
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '로그인이 필요합니다');
      },
    );

    test(
      '빈 주문 목록이면 orders가 빈 리스트이다',
      () async {
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer((_) async => []);

        final container = createContainer(user: testUser);
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.orders, isEmpty);
      },
    );

    test(
      '예외 발생 시 에러 상태가 된다',
      () async {
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenThrow(Exception('test'));

        final container = createContainer(user: testUser);
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '작업 이력을 불러올 수 없습니다');
      },
    );
  });
}
