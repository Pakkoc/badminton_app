import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { customer, owner }

/// 현재 활성 모드. 앱 시작 시 항상 customer.
final activeModeProvider =
    StateProvider<AppMode>((ref) => AppMode.customer);

/// 현재 유저가 샵을 보유하는지 여부.
final hasShopProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final userId =
      ref.read(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return false;

  final shop =
      await ref.read(shopRepositoryProvider).getByOwner(userId);
  return shop != null;
});
