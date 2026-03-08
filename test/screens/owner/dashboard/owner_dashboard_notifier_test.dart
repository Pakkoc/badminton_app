import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockShopRepository extends Mock
    implements ShopRepository {}

class MockOrderRepository extends Mock
    implements OrderRepository {}

class MockMemberRepository extends Mock
    implements MemberRepository {}

void main() {
  late MockShopRepository mockShopRepo;
  late MockOrderRepository mockOrderRepo;
  late MockMemberRepository mockMemberRepo;
  late OwnerDashboardNotifier notifier;

  setUp(() {
    mockShopRepo = MockShopRepository();
    mockOrderRepo = MockOrderRepository();
    mockMemberRepo = MockMemberRepository();
    notifier = OwnerDashboardNotifier(
      shopRepository: mockShopRepo,
      orderRepository: mockOrderRepo,
      memberRepository: mockMemberRepo,
    );
  });

  group('OwnerDashboardNotifier', () {
    group('loadDashboard', () {
      test('초기 상태는 isLoading=true이다', () {
        // Assert
        expect(notifier.state.isLoading, isTrue);
      });

      test('매장이 없으면 에러 메시지를 설정한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => null);

        // Act
        await notifier.loadDashboard(testOwner.id);

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(
          notifier.state.error,
          '등록된 매장이 없습니다',
        );
      });

      test('매장과 주문을 로드하고 카운트를 계산한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(testOwner.id))
            .thenAnswer((_) async => testShop);
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [
            testOrderReceived,
            testOrderInProgress,
            testOrderCompleted,
          ],
        );
        when(() => mockOrderRepo.streamByShop(testShop.id))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockMemberRepo.getByShop(testShop.id))
            .thenAnswer((_) async => [testMember]);

        // Act
        await notifier.loadDashboard(testOwner.id);

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.shopName, testShop.name);
        expect(notifier.state.shopId, testShop.id);
        expect(notifier.state.receivedCount, 1);
        expect(notifier.state.inProgressCount, 1);
        expect(notifier.state.completedCount, 1);
        expect(notifier.state.recentOrders.length, 3);
      });

      test('최근 작업은 최대 5건만 반환한다', () async {
        // Arrange
        final orders = List.generate(
          7,
          (i) => testOrderReceived.copyWith(id: 'order-$i'),
        );
        when(() => mockShopRepo.getByOwner(testOwner.id))
            .thenAnswer((_) async => testShop);
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer((_) async => orders);
        when(() => mockOrderRepo.streamByShop(testShop.id))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockMemberRepo.getByShop(testShop.id))
            .thenAnswer((_) async => [testMember]);

        // Act
        await notifier.loadDashboard(testOwner.id);

        // Assert
        expect(notifier.state.recentOrders.length, 5);
      });

      test('에러 발생 시 에러 메시지를 설정한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenThrow(AppException.server());

        // Act
        await notifier.loadDashboard(testOwner.id);

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
      });
    });

    group('changeOrderStatus', () {
      test('주문 상태를 변경하고 목록을 갱신한다', () async {
        // Arrange — 먼저 대시보드 로드
        when(() => mockShopRepo.getByOwner(testOwner.id))
            .thenAnswer((_) async => testShop);
        when(() => mockOrderRepo.getByShop(testShop.id))
            .thenAnswer(
          (_) async => [testOrderReceived],
        );
        when(() => mockOrderRepo.streamByShop(testShop.id))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockMemberRepo.getByShop(testShop.id))
            .thenAnswer((_) async => [testMember]);
        await notifier.loadDashboard(testOwner.id);

        // 상태 변경 후 재조회
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
        await notifier.changeOrderStatus(
          testOrderReceived.id,
          OrderStatus.inProgress,
        );

        // Assert
        expect(notifier.state.receivedCount, 0);
        expect(notifier.state.inProgressCount, 1);
      });
    });
  });
}
