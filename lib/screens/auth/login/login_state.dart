import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.idle() = _Idle;
  const factory LoginState.authenticating(String provider) =
      _Authenticating;
  const factory LoginState.error(String message) = _Error;
}
