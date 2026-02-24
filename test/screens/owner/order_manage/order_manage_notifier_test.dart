import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockOrderRepository extends Mock
    implements OrderRepository {}

void main() {
  late MockOrderRepository mockOrderRepo;
  late OrderManageNotifier notifier;

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    notifier = OrderManageNotifier(
      orderRepository: mockOrderRepo,
    );
  });

  group('OrderManageNotifier', () {
    group('loadOrders', () {
      test('주문 목록을 로드한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
          ],
        );

        // Act
        await notifier.loadOrders(testShop.id);

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.orders.length, 2);
      });

      test('에러 발생 시 에러 메시지를 설정한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(any()))
            .thenThrow(AppException.server());

        // Act
        await notifier.loadOrders(testShop.id);

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
      });
    });

    group('filterByStatus', () {
      test('상태 필터를 설정한다', () {
        // Act
        notifier.filterByStatus(OrderStatus.received);

        // Assert
        expect(
          notifier.state.selectedFilter,
          OrderStatus.received,
        );
      });

      test('null 필터로 전체 표시한다', () {
        // Arrange
        notifier.filterByStatus(OrderStatus.received);

        // Act
        notifier.filterByStatus(null);

        // Assert
        expect(notifier.state.selectedFilter, isNull);
      });
    });

    group('filteredOrders', () {
      test('필터가 없으면 전체 주문을 반환한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
            testOrderCompleted,
          ],
        );
        await notifier.loadOrders(testShop.id);

        // Assert
        expect(notifier.state.filteredOrders.length, 3);
      });

      test('필터가 있으면 해당 상태만 반환한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
            testOrderCompleted,
          ],
        );
        await notifier.loadOrders(testShop.id);

        // Act
        notifier.filterByStatus(OrderStatus.received);

        // Assert
        expect(notifier.state.filteredOrders.length, 1);
        expect(
          notifier.state.filteredOrders.first.status,
          OrderStatus.received,
        );
      });
    });

    group('changeStatus', () {
      test('주문 상태를 변경하고 목록을 갱신한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [testOrderReceived],
        );
        await notifier.loadOrders(testShop.id);

        when(
          () => mockOrderRepo.updateStatus(
            testOrderReceived.id,
            OrderStatus.inProgress.toJson(),
          ),
        ).thenAnswer((_) async => testOrderInProgress);
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [testOrderInProgress],
        );

        // Act
        await notifier.changeStatus(
          testOrderReceived.id,
          OrderStatus.inProgress,
        );

        // Assert
        expect(
          notifier.state.orders.first.status,
          OrderStatus.inProgress,
        );
      });
    });

    group('deleteOrder', () {
      test('주문을 삭제하고 목록을 갱신한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [testOrderReceived],
        );
        await notifier.loadOrders(testShop.id);

        when(
          () =>
              mockOrderRepo.delete(testOrderReceived.id),
        ).thenAnswer((_) async {});
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer((_) async => []);

        // Act
        await notifier.deleteOrder(testOrderReceived.id);

        // Assert
        expect(notifier.state.orders, isEmpty);
      });

      test('삭제 에러 시 에러 메시지를 설정한다', () async {
        // Arrange
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [testOrderReceived],
        );
        await notifier.loadOrders(testShop.id);

        when(
          () =>
              mockOrderRepo.delete(testOrderReceived.id),
        ).thenThrow(AppException.server());

        // Act
        await notifier.deleteOrder(testOrderReceived.id);

        // Assert
        expect(notifier.state.error, isNotNull);
      });
    });
  });
}
