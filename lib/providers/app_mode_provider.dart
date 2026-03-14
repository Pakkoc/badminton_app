import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { customer, owner }

/// 현재 활성 모드. 앱 시작 시 항상 customer.
final activeModeProvider =
    StateProvider<AppMode>((ref) => AppMode.customer);

/// 현재 사용자의 샵 정보 (상태 무관).
final myShopProvider =
    FutureProvider.autoDispose<Shop?>((ref) async {
  final userId =
      ref.read(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return null;
  return ref
      .read(shopRepositoryProvider)
      .getByOwner(userId);
});

/// 현재 유저가 승인된 샵을 보유하는지 여부.
final hasShopProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final shop = await ref.watch(myShopProvider.future);
  return shop != null &&
      shop.status == ShopStatus.approved;
});

/// 현재 사용자의 샵 등록 상태.
/// null = 미신청, pending/approved/rejected
final shopStatusProvider =
    FutureProvider.autoDispose<ShopStatus?>((ref) async {
  final shop = await ref.watch(myShopProvider.future);
  return shop?.status;
});
