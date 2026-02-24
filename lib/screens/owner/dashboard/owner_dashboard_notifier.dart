import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownerDashboardNotifierProvider = StateNotifierProvider<
    OwnerDashboardNotifier, OwnerDashboardState>(
  (ref) => OwnerDashboardNotifier(
    shopRepository: ref.watch(shopRepositoryProvider),
    orderRepository: ref.watch(orderRepositoryProvider),
  ),
);

class OwnerDashboardNotifier
    extends StateNotifier<OwnerDashboardState> {
  final ShopRepository _shopRepository;
  final OrderRepository _orderRepository;

  OwnerDashboardNotifier({
    required ShopRepository shopRepository,
    required OrderRepository orderRepository,
  })  : _shopRepository = shopRepository,
        _orderRepository = orderRepository,
        super(const OwnerDashboardState());

  Future<void> loadDashboard(String ownerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop = await _shopRepository.getByOwner(ownerId);
      if (shop == null) {
        state = state.copyWith(
          isLoading: false,
          error: '등록된 매장이 없습니다',
        );
        return;
      }

      final orders =
          await _orderRepository.getByShop(shop.id);

      final receivedCount = orders
          .where((o) => o.status == OrderStatus.received)
          .length;
      final inProgressCount = orders
          .where((o) => o.status == OrderStatus.inProgress)
          .length;
      final completedCount = orders
          .where((o) => o.status == OrderStatus.completed)
          .length;

      final recentOrders = orders.take(5).toList();

      state = state.copyWith(
        isLoading: false,
        shopName: shop.name,
        shopId: shop.id,
        receivedCount: receivedCount,
        inProgressCount: inProgressCount,
        completedCount: completedCount,
        recentOrders: recentOrders,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    }
  }

  Future<void> changeOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      await _orderRepository.updateStatus(
        orderId,
        newStatus.toJson(),
      );
      if (state.shopId != null) {
        final orders =
            await _orderRepository.getByShop(state.shopId!);

        final receivedCount = orders
            .where((o) => o.status == OrderStatus.received)
            .length;
        final inProgressCount = orders
            .where(
                (o) => o.status == OrderStatus.inProgress)
            .length;
        final completedCount = orders
            .where((o) => o.status == OrderStatus.completed)
            .length;

        state = state.copyWith(
          receivedCount: receivedCount,
          inProgressCount: inProgressCount,
          completedCount: completedCount,
          recentOrders: orders.take(5).toList(),
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }
}
