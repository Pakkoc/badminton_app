import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderCreateNotifierProvider = StateNotifierProvider.autoDispose<
    OrderCreateNotifier, OrderCreateState>(
  (ref) => OrderCreateNotifier(
    memberRepository: ref.read(memberRepositoryProvider),
    orderRepository: ref.read(orderRepositoryProvider),
  ),
);

class OrderCreateNotifier
    extends StateNotifier<OrderCreateState> {
  final MemberRepository _memberRepository;
  final OrderRepository _orderRepository;

  OrderCreateNotifier({
    required MemberRepository memberRepository,
    required OrderRepository orderRepository,
  })  : _memberRepository = memberRepository,
        _orderRepository = orderRepository,
        super(const OrderCreateState());

  Future<void> searchMembers(
    String shopId,
    String query,
  ) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    try {
      final results =
          await _memberRepository.search(shopId, query);
      state = state.copyWith(searchResults: results);
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }

  void selectMember(Member member) {
    state = state.copyWith(
      selectedMember: member,
      searchResults: [],
      searchQuery: '',
    );
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  Future<void> submit(String shopId) async {
    if (state.selectedMember == null) {
      state = state.copyWith(
        error: '회원을 선택해주세요',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      error: null,
    );

    try {
      final now = DateTime.now();
      final order = GutOrder(
        id: '',
        shopId: shopId,
        memberId: state.selectedMember!.id,
        status: OrderStatus.received,
        memo: state.memo.isEmpty ? null : state.memo,
        createdAt: now,
        updatedAt: now,
      );

      await _orderRepository.create(order);

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.userMessage,
      );
    }
  }

  void reset() {
    state = const OrderCreateState();
  }
}
