import 'package:badminton_app/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_create_state.freezed.dart';

@freezed
class PostCreateState with _$PostCreateState {
  const factory PostCreateState({
    @Default(PostCategory.notice) PostCategory category,
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<String> images,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    String? editingPostId,
    @Default(false) bool isLoadingPost,
  }) = _PostCreateState;
}
