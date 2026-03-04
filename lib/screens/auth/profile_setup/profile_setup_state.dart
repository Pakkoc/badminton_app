import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_setup_state.freezed.dart';

@freezed
class ProfileSetupState with _$ProfileSetupState {
  const factory ProfileSetupState({
    @Default('') String name,
    @Default('') String phone,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ProfileSetupState;
}
