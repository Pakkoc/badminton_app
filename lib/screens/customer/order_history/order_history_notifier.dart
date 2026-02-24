import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
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
      final orders =
          await orderRepository.getByMemberUser(user.id);

      state = OrderHistoryState(orders: orders);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '작업 내역을 불러올 수 없습니다',
      );
    }
  }
}
