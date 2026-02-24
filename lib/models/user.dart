import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    @JsonKey(
      fromJson: UserRole.fromJson,
      toJson: _userRoleToJson,
    )
    required UserRole role,
    required String name,
    required String phone,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

String _userRoleToJson(UserRole role) => role.toJson();
