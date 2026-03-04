import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});

/// 알림 리포지토리.
///
/// Supabase `notifications` 테이블에 대한 조회/읽음처리 작업을 수행한다.
class NotificationRepository {
  final SupabaseClient client;

  NotificationRepository(this.client);

  /// 사용자 ID로 알림 목록을 조회한다.
  Future<List<NotificationItem>> getByUser(String userId) async {
    try {
      final data = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map(NotificationItem.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 알림을 읽음 처리한다.
  Future<void> markAsRead(String id) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 사용자의 모든 알림을 읽음 처리한다.
  Future<void> markAllAsRead(String userId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 알림 레코드를 생성한다.
  Future<void> create({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    try {
      await client.from('notifications').insert({
        'user_id': userId,
        'type': type.toJson(),
        'title': title,
        'body': body,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 사용자의 읽지 않은 알림 수를 조회한다.
  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact);
      return data.count;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
