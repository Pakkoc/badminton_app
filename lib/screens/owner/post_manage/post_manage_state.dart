import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_manage_state.freezed.dart';

@freezed
class PostManageState with _$PostManageState {
  const factory PostManageState({
    @Default([]) List<Post> posts,
    PostCategory? selectedCategory,
    @Default(false) bool isLoading,
    @Default(false) bool isDeleting,
    String? errorMessage,
  }) = _PostManageState;
}
