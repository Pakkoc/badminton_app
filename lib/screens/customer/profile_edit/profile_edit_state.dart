import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_state.freezed.dart';

@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    @Default('') String name,
    @Default('') String phone,
    String? profileImageUrl,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ProfileEditState;
}
