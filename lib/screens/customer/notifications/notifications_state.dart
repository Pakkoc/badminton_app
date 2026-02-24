import 'package:badminton_app/models/notification_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default([]) List<NotificationItem> notifications,
    @Default(false) bool isLoading,
    String? error,
  }) = _NotificationsState;
}
