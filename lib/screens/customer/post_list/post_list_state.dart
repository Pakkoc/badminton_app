import 'package:badminton_app/models/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_list_state.freezed.dart';

@freezed
class PostListState with _$PostListState {
  const factory PostListState({
    @Default([]) List<Post> posts,
    @Default(false) bool isLoading,
    String? error,
  }) = _PostListState;
}
