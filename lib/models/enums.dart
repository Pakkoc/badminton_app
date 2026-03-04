enum UserRole {
  customer,
  shopOwner,
  admin;

  String toJson() => switch (this) {
        customer => 'customer',
        shopOwner => 'shop_owner',
        admin => 'admin',
      };

  static UserRole fromJson(String value) => switch (value) {
        'customer' => customer,
        'shop_owner' => shopOwner,
        'admin' => admin,
        _ => throw ArgumentError(
              'Unknown UserRole: $value',
            ),
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

enum InventoryCategory {
  racket,
  top,
  bottom,
  bag,
  shoes,
  accessories,
  other;

  String toJson() => switch (this) {
        racket => 'racket',
        top => 'top',
        bottom => 'bottom',
        bag => 'bag',
        shoes => 'shoes',
        accessories => 'accessories',
        other => 'other',
      };

  static InventoryCategory fromJson(String value) =>
      switch (value) {
        'racket' => racket,
        'top' => top,
        'bottom' => bottom,
        'bag' => bag,
        'shoes' => shoes,
        'accessories' => accessories,
        'other' => other,
        _ => other,
      };

  String get label => switch (this) {
        racket => '라켓',
        top => '상의',
        bottom => '하의',
        bag => '가방',
        shoes => '신발',
        accessories => '악세서리',
        other => '기타',
      };
}

enum ShopStatus {
  pending,
  approved,
  rejected;

  String toJson() => switch (this) {
        pending => 'pending',
        approved => 'approved',
        rejected => 'rejected',
      };

  static ShopStatus fromJson(String value) =>
      switch (value) {
        'pending' => pending,
        'approved' => approved,
        'rejected' => rejected,
        _ => pending,
      };

  String get label => switch (this) {
        pending => '승인 대기',
        approved => '승인됨',
        rejected => '거절됨',
      };
}

enum NotificationType {
  statusChange,
  completion,
  notice,
  receipt,
  shopApproval,
  shopRejection;

  String toJson() => switch (this) {
        statusChange => 'status_change',
        completion => 'completion',
        notice => 'notice',
        receipt => 'receipt',
        shopApproval => 'shop_approval',
        shopRejection => 'shop_rejection',
      };

  static NotificationType fromJson(String value) => switch (value) {
        'status_change' => statusChange,
        'completion' => completion,
        'notice' => notice,
        'receipt' => receipt,
        'shop_approval' => shopApproval,
        'shop_rejection' => shopRejection,
        _ => throw ArgumentError(
              'Unknown NotificationType: $value',
            ),
      };
}
