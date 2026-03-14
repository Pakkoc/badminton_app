import 'dart:async';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownerDashboardNotifierProvider = StateNotifierProvider.autoDispose<
    OwnerDashboardNotifier, OwnerDashboardState>(
  (ref) => OwnerDashboardNotifier(
    shopRepository: ref.read(shopRepositoryProvider),
    orderRepository: ref.read(orderRepositoryProvider),
    memberRepository: ref.read(memberRepositoryProvider),
  ),
);

class OwnerDashboardNotifier
    extends StateNotifier<OwnerDashboardState> {
  final ShopRepository _shopRepository;
  final OrderRepository _orderRepository;
  final MemberRepository _memberRepository;
  StreamSubscription<List<Map<String, dynamic>>>?
      _orderSubscription;

  OwnerDashboardNotifier({
    required ShopRepository shopRepository,
    required OrderRepository orderRepository,
    required MemberRepository memberRepository,
  })  : _shopRepository = shopRepository,
        _orderRepository = orderRepository,
        _memberRepository = memberRepository,
        super(const OwnerDashboardState());

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadDashboard(String ownerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop =
          await _shopRepository.getByOwner(ownerId);
      if (shop == null) {
        state = state.copyWith(
          isLoading: false,
          error: '등록된 매장이 없습니다',
        );
        return;
      }

      final (orders, members) = await (
        _orderRepository.getByShop(shop.id),
        _memberRepository.getByShop(shop.id),
      ).wait;

      final memberNames = <String, String>{
        for (final m in members) m.id: m.name,
      };

      final receivedCount = orders
          .where((o) => o.status == OrderStatus.received)
          .length;
      final inProgressCount = orders
          .where((o) => o.status == OrderStatus.inProgress)
          .length;
      final completedCount = orders
          .where((o) => o.status == OrderStatus.completed)
          .length;

      state = state.copyWith(
        isLoading: false,
        shopName: shop.name,
        shopId: shop.id,
        receivedCount: receivedCount,
        inProgressCount: inProgressCount,
        completedCount: completedCount,
        recentOrders: orders.take(5).toList(),
        memberNames: memberNames,
      );

      // 실시간 구독 시작
      _subscribeOrders(shop.id);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    }
  }

  void _subscribeOrders(String shopId) {
    _orderSubscription?.cancel();
    _orderSubscription =
        _orderRepository.streamByShop(shopId).listen(
      (rows) async {
        if (!mounted) return;
        final orders =
            rows.map(GutOrder.fromJson).toList();

        // 새 회원이 추가됐을 수 있으므로 갱신
        final knownIds = state.memberNames.keys.toSet();
        final newIds = orders
            .map((o) => o.memberId)
            .toSet()
            .difference(knownIds);
        var memberNames = Map<String, String>.from(
          state.memberNames,
        );
        if (newIds.isNotEmpty) {
          final members =
              await _memberRepository.getByShop(shopId);
          memberNames = {
            for (final m in members) m.id: m.name,
          };
        }

        final receivedCount = orders
            .where(
                (o) => o.status == OrderStatus.received)
            .length;
        final inProgressCount = orders
            .where(
                (o) => o.status == OrderStatus.inProgress)
            .length;
        final completedCount = orders
            .where(
                (o) => o.status == OrderStatus.completed)
            .length;

        if (!mounted) return;
        state = state.copyWith(
          receivedCount: receivedCount,
          inProgressCount: inProgressCount,
          completedCount: completedCount,
          recentOrders: orders.take(5).toList(),
          memberNames: memberNames,
        );
      },
    );
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
        final orders = await _orderRepository
            .getByShop(state.shopId!);

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
          memberNames: state.memberNames,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }
}
