import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  const factory Member({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'user_id') String? userId,
    required String name,
    required String phone,
    String? memo,
    @JsonKey(name: 'visit_count') @Default(0) int visitCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) =>
      _$MemberFromJson(json);
}
