import 'dart:async';

import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 읽지 않은 알림 수를 실시간으로 제공하는 프로바이더.
final unreadNotificationCountProvider =
    StateNotifierProvider<UnreadNotificationCountNotifier, int>(
  (ref) => UnreadNotificationCountNotifier(ref),
);

class UnreadNotificationCountNotifier
    extends StateNotifier<int> {
  final Ref _ref;
  StreamSubscription<List<Map<String, dynamic>>>?
      _subscription;

  UnreadNotificationCountNotifier(this._ref) : super(0) {
    _init();
  }

  Future<void> _init() async {
    final userId = _ref.read(currentAuthUserIdProvider);
    if (userId == null) return;

    // 초기 카운트 조회
    await refresh();

    // 실시간 구독
    final client = _ref.read(supabaseProvider);
    _subscription = client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((_) => refresh());
  }

  Future<void> refresh() async {
    final userId = _ref.read(currentAuthUserIdProvider);
    if (userId == null) return;

    try {
      final repo =
          _ref.read(notificationRepositoryProvider);
      final count = await repo.getUnreadCount(userId);
      if (mounted) state = count;
    } catch (_) {
      // 무시 — 뱃지 업데이트 실패는 치명적이지 않음
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
