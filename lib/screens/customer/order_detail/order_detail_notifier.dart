import 'dart:async';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderDetailNotifierProvider = NotifierProvider.family<
    OrderDetailNotifier, OrderDetailState, String>(
  OrderDetailNotifier.new,
);

class OrderDetailNotifier
    extends FamilyNotifier<OrderDetailState, String> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  OrderDetailState build(String arg) {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    Future.microtask(() => loadOrder(arg));
    return const OrderDetailState(isLoading: true);
  }

  Future<void> loadOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orderRepository = ref.read(orderRepositoryProvider);
      final shopRepository = ref.read(shopRepositoryProvider);

      // 초기 로딩은 stream의 첫 번째 이벤트로 처리
      _subscription?.cancel();
      _subscription = orderRepository
          .streamById(orderId)
          .listen(
        (data) async {
          final order = GutOrder.fromJson(data);
          final shop =
              await shopRepository.getById(order.shopId);
          state = OrderDetailState(order: order, shop: shop);
        },
        onError: (Object error) {
          if (error is AppException) {
            state = state.copyWith(
              isLoading: false,
              error: error.userMessage,
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              error: '주문 정보를 불러올 수 없습니다',
            );
          }
        },
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '주문 정보를 불러올 수 없습니다',
      );
    }
  }
}
