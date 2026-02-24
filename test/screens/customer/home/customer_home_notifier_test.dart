import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/customer/home/customer_home_notifier.dart';
import 'package:badminton_app/screens/customer/home/customer_home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockOrderRepository extends Mock
    implements OrderRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
  });

  ProviderContainer createContainer({
    User? user,
  }) {
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(
          mockOrderRepository,
        ),
        currentUserProvider.overrideWith(
          (ref) async => user,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CustomerHomeNotifier', () {
    test('초기 상태는 isLoading이 true이다', () {
      // Arrange
      when(
        () => mockOrderRepository.getByMemberUser(any()),
      ).thenAnswer((_) async => []);

      final container = createContainer(user: testUser);

      // Act
      final state =
          container.read(customerHomeNotifierProvider);

      // Assert
      expect(state.isLoading, isTrue);
    });

    test(
      'loadOrders가 활성 주문만 필터링한다',
      () async {
        // Arrange
        final now = DateTime.now();
        final recentCompleted = testOrderCompleted.copyWith(
          completedAt: now.subtract(const Duration(hours: 1)),
        );
        final oldCompleted = testOrderCompleted.copyWith(
          completedAt:
              now.subtract(const Duration(hours: 25)),
        );

        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
            recentCompleted,
            oldCompleted,
          ],
        );

        final container = createContainer(user: testUser);

        // Act
        // build() 내부에서 loadOrders()를 호출하므로 대기
        await container
            .read(customerHomeNotifierProvider.notifier)
            .loadOrders();

        // Assert
        final state =
            container.read(customerHomeNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.activeOrders.length, 3);
        expect(
          state.activeOrders.any(
            (o) => o == oldCompleted,
          ),
          isFalse,
        );
      },
    );

    test(
      '사용자가 없으면 에러 상태가 된다',
      () async {
        // Arrange
        final container = createContainer();

        // Act
        await container
            .read(customerHomeNotifierProvider.notifier)
            .loadOrders();

        // Assert
        final state =
            container.read(customerHomeNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '로그인이 필요합니다');
      },
    );

    test(
      '빈 주문 목록이면 activeOrders가 빈 리스트이다',
      () async {
        // Arrange
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer((_) async => []);

        final container = createContainer(user: testUser);

        // Act
        await container
            .read(customerHomeNotifierProvider.notifier)
            .loadOrders();

        // Assert
        final state =
            container.read(customerHomeNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.activeOrders, isEmpty);
      },
    );

    test(
      '예외 발생 시 에러 상태가 된다',
      () async {
        // Arrange
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenThrow(Exception('test'));

        final container = createContainer(user: testUser);

        // Act
        await container
            .read(customerHomeNotifierProvider.notifier)
            .loadOrders();

        // Assert
        final state =
            container.read(customerHomeNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '주문 목록을 불러올 수 없습니다');
      },
    );

    test(
      'refresh는 loadOrders를 재호출한다',
      () async {
        // Arrange
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer(
          (_) async => [testOrderReceived],
        );

        final container = createContainer(user: testUser);

        // Act
        await container
            .read(customerHomeNotifierProvider.notifier)
            .refresh();

        // Assert
        final state =
            container.read(customerHomeNotifierProvider);
        expect(state.activeOrders.length, 1);
        verify(
          () => mockOrderRepository
              .getByMemberUser(testUser.id),
        ).called(greaterThanOrEqualTo(1));
      },
    );
  });
}
