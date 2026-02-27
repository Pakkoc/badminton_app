import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderHistoryNotifierProvider =
    NotifierProvider<OrderHistoryNotifier, OrderHistoryState>(
  OrderHistoryNotifier.new,
);

class OrderHistoryNotifier extends Notifier<OrderHistoryState> {
  @override
  OrderHistoryState build() {
    Future.microtask(loadHistory);
    return const OrderHistoryState(isLoading: true);
  }

  Future<void> loadHistory() async {
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
      final allOrders =
          await orderRepository.getByMemberUser(user.id);

      final completedOrders = allOrders
          .where((o) => o.status == OrderStatus.completed)
          .toList()
        ..sort((a, b) =>
            b.updatedAt.compareTo(a.updatedAt));

      // 샵 이름 조회
      final shopRepo = ref.read(shopRepositoryProvider);
      final shopIds =
          completedOrders.map((o) => o.shopId).toSet();
      final shopNames = <String, String>{};
      for (final shopId in shopIds) {
        final shop = await shopRepo.getById(shopId);
        if (shop != null) {
          shopNames[shopId] = shop.name;
        }
      }

      state = OrderHistoryState(
        orders: completedOrders,
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
        error: '작업 이력을 불러올 수 없습니다',
      );
    }
  }
}
