import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/home/customer_home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerHomeNotifierProvider =
    NotifierProvider<CustomerHomeNotifier, CustomerHomeState>(
  CustomerHomeNotifier.new,
);

class CustomerHomeNotifier extends Notifier<CustomerHomeState> {
  @override
  CustomerHomeState build() {
    Future.microtask(loadOrders);
    return const CustomerHomeState(isLoading: true);
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: '로그인이 필요합니다',
        );
        return;
      }

      final orderRepository = ref.read(orderRepositoryProvider);
      final orders = await orderRepository.getByMemberUser(user.id);
      final now = DateTime.now();
      final activeOrders = orders.where((order) {
        if (order.status == OrderStatus.received ||
            order.status == OrderStatus.inProgress) {
          return true;
        }
        if (order.status == OrderStatus.completed &&
            order.completedAt != null) {
          return now.difference(order.completedAt!).inHours < 24;
        }
        return false;
      }).toList();

      // 샵 이름 조회
      final shopRepo = ref.read(shopRepositoryProvider);
      final shopIds =
          activeOrders.map((o) => o.shopId).toSet();
      final shopNames = <String, String>{};
      for (final shopId in shopIds) {
        final shop = await shopRepo.getById(shopId);
        if (shop != null) {
          shopNames[shopId] = shop.name;
        }
      }

      state = CustomerHomeState(
        activeOrders: activeOrders,
        shopNames: shopNames,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '주문 목록을 불러올 수 없습니다',
      );
    }
  }

  Future<void> refresh() async => loadOrders();
}
