import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
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

  group('OrderHistoryNotifier', () {
    test('초기 상태는 isLoading이 true이다', () {
      // Arrange
      when(
        () => mockOrderRepository.getByMemberUser(any()),
      ).thenAnswer((_) async => []);

      final container = createContainer(user: testUser);

      // Act
      final state =
          container.read(orderHistoryNotifierProvider);

      // Assert
      expect(state.isLoading, isTrue);
    });

    test(
      'loadHistory가 전체 주문을 가져온다',
      () async {
        // Arrange
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

        // Act
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        // Assert
        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.orders.length, 3);
      },
    );

    test(
      '사용자가 없으면 에러 상태가 된다',
      () async {
        // Arrange
        final container = createContainer();

        // Act
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        // Assert
        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '로그인이 필요합니다');
      },
    );

    test(
      '빈 주문 목록이면 orders가 빈 리스트이다',
      () async {
        // Arrange
        when(
          () =>
              mockOrderRepository.getByMemberUser(any()),
        ).thenAnswer((_) async => []);

        final container = createContainer(user: testUser);

        // Act
        await container
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        // Assert
        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.orders, isEmpty);
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
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory();

        // Assert
        final state =
            container.read(orderHistoryNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, '작업 내역을 불러올 수 없습니다');
      },
    );
  });
}
