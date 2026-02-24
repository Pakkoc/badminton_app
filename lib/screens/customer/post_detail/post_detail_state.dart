import 'package:badminton_app/models/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.freezed.dart';

@freezed
class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    Post? post,
    @Default(false) bool isLoading,
    String? error,
  }) = _PostDetailState;
}
