import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderManageNotifierProvider = StateNotifierProvider<
    OrderManageNotifier, OrderManageState>(
  (ref) => OrderManageNotifier(
    orderRepository: ref.watch(orderRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  ),
);

class OrderManageNotifier
    extends StateNotifier<OrderManageState> {
  final OrderRepository _orderRepository;
  final MemberRepository _memberRepository;
  String? _shopId;

  OrderManageNotifier({
    required OrderRepository orderRepository,
    required MemberRepository memberRepository,
  })  : _orderRepository = orderRepository,
        _memberRepository = memberRepository,
        super(const OrderManageState());

  Future<void> loadOrders(String shopId) async {
    _shopId = shopId;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<GutOrder> orders =
          await _orderRepository.getByShop(shopId);
      final List<Member> members =
          await _memberRepository.getByShop(shopId);

      final memberNames = <String, String>{
        for (final m in members) m.id: m.name,
      };

      state = state.copyWith(
        isLoading: false,
        orders: orders,
        memberNames: memberNames,
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
