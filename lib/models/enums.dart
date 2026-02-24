enum UserRole {
  customer,
  shopOwner;

  String toJson() => switch (this) {
        customer => 'customer',
        shopOwner => 'shop_owner',
      };

  static UserRole fromJson(String value) => switch (value) {
        'customer' => customer,
        'shop_owner' => shopOwner,
        _ => throw ArgumentError('Unknown UserRole: $value'),
      };
}

enum OrderStatus {
  received,
  inProgress,
  completed;

  String toJson() => switch (this) {
        received => 'received',
        inProgress => 'in_progress',
        completed => 'completed',
      };

  static OrderStatus fromJson(String value) => switch (value) {
        'received' => received,
        'in_progress' => inProgress,
        'completed' => completed,
        _ => throw ArgumentError('Unknown OrderStatus: $value'),
      };

  String get label => switch (this) {
        received => '접수됨',
        inProgress => '작업중',
        completed => '완료',
      };
}

enum PostCategory {
  notice,
  event;

  String toJson() => switch (this) {
        notice => 'notice',
        event => 'event',
      };

  static PostCategory fromJson(String value) => switch (value) {
        'notice' => notice,
        'event' => event,
        _ => throw ArgumentError('Unknown PostCategory: $value'),
      };

  String get label => switch (this) {
        notice => '공지사항',
        event => '이벤트',
      };
}

enum NotificationType {
  statusChange,
  completion,
  notice,
  receipt;

  String toJson() => switch (this) {
        statusChange => 'status_change',
        completion => 'completion',
        notice => 'notice',
        receipt => 'receipt',
      };

  static NotificationType fromJson(String value) => switch (value) {
        'status_change' => statusChange,
        'completion' => completion,
        'notice' => notice,
        'receipt' => receipt,
        _ => throw ArgumentError('Unknown NotificationType: $value'),
      };
}
