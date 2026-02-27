import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopDetailNotifierProvider =
    NotifierProvider<ShopDetailNotifier, ShopDetailState>(
  ShopDetailNotifier.new,
);

class ShopDetailNotifier extends Notifier<ShopDetailState> {
  @override
  ShopDetailState build() => const ShopDetailState();

  Future<void> loadShop(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shopRepo = ref.read(shopRepositoryProvider);
      final shop = await shopRepo.getById(shopId);
      if (shop == null) {
        state = state.copyWith(
          isLoading: false,
          error: '샵을 찾을 수 없습니다',
        );
        return;
      }

      final user =
          await ref.read(currentUserProvider.future);
      var isMember = false;
      if (user != null) {
        final memberRepo =
            ref.read(memberRepositoryProvider);
        final member =
            await memberRepo.getByShopAndUser(
          shopId,
          user.id,
        );
        isMember = member != null;
      }

      final postRepo = ref.read(postRepositoryProvider);
      final noticePosts =
          await postRepo.getByShopAndCategory(
        shopId,
        PostCategory.notice.toJson(),
      );
      final eventPosts =
          await postRepo.getByShopAndCategory(
        shopId,
        PostCategory.event.toJson(),
      );

      final inventoryRepo =
          ref.read(inventoryRepositoryProvider);
      final inventoryItems =
          await inventoryRepo.getByShop(shopId);

      final orderRepo =
          ref.read(orderRepositoryProvider);
      final orders = await orderRepo.getByShop(shopId);
      final receivedCount = orders
          .where((o) => o.status == OrderStatus.received)
          .length;
      final inProgressCount = orders
          .where(
              (o) => o.status == OrderStatus.inProgress)
          .length;

      state = state.copyWith(
        shop: shop,
        isMember: isMember,
        noticePosts: noticePosts,
        eventPosts: eventPosts,
        inventoryItems: inventoryItems,
        receivedCount: receivedCount,
        inProgressCount: inProgressCount,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '샵 정보를 불러올 수 없습니다',
      );
    }
  }

  Future<void> registerMember(String shopId) async {
    state =
        state.copyWith(isRegistering: true, error: null);
    try {
      final user =
          await ref.read(currentUserProvider.future);
      if (user == null) {
        state = state.copyWith(
          isRegistering: false,
          error: '로그인이 필요합니다',
        );
        return;
      }

      final memberRepo =
          ref.read(memberRepositoryProvider);
      await memberRepo.create(
        Member(
          id: '',
          shopId: shopId,
          userId: user.id,
          name: user.name,
          phone: user.phone,
          createdAt: DateTime.now(),
        ),
      );

      state = state.copyWith(
        isMember: true,
        isRegistering: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isRegistering: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        error: '회원 등록에 실패했습니다',
      );
    }
  }
}
