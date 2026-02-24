import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderManageNotifierProvider = StateNotifierProvider<
    OrderManageNotifier, OrderManageState>(
  (ref) => OrderManageNotifier(
    orderRepository: ref.watch(orderRepositoryProvider),
  ),
);

class OrderManageNotifier
    extends StateNotifier<OrderManageState> {
  final OrderRepository _orderRepository;
  String? _shopId;

  OrderManageNotifier({
    required OrderRepository orderRepository,
  })  : _orderRepository = orderRepository,
        super(const OrderManageState());

  Future<void> loadOrders(String shopId) async {
    _shopId = shopId;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders =
          await _orderRepository.getByShop(shopId);
      state = state.copyWith(
        isLoading: false,
        orders: orders,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    }
  }

  void filterByStatus(OrderStatus? status) {
    state = state.copyWith(selectedFilter: status);
  }

  Future<void> changeStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      await _orderRepository.updateStatus(
        orderId,
        newStatus.toJson(),
      );
      if (_shopId != null) {
        await loadOrders(_shopId!);
      }
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.delete(orderId);
      if (_shopId != null) {
        await loadOrders(_shopId!);
      }
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }
}
