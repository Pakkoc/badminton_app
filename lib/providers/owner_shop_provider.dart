import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 로그인한 사장님의 매장 정보를 제공하는 프로바이더.
///
/// 사장님 화면 전체에서 공유하며, 매장 정보가 변경되면
/// [invalidate]로 갱신한다.
final currentOwnerShopProvider =
    FutureProvider.autoDispose<Shop?>((ref) async {
  final userId =
      ref.read(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return null;

  final shopRepo = ref.read(shopRepositoryProvider);
  return shopRepo.getByOwner(userId);
});
