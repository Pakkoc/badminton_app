import 'package:badminton_app/models/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_create_state.freezed.dart';

@freezed
class OrderCreateState with _$OrderCreateState {
  const factory OrderCreateState({
    Member? selectedMember,
    @Default('') String memo,
    @Default(false) bool isSubmitting,
    @Default('') String searchQuery,
    @Default([]) List<Member> searchResults,
    String? error,
    @Default(false) bool isSuccess,
  }) = _OrderCreateState;
}
