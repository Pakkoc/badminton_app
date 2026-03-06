import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_create_state.freezed.dart';

@freezed
class CommunityCreateState with _$CommunityCreateState {
  const factory CommunityCreateState({
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<String> images,
    @Default(false) bool isSubmitting,
    @Default(false) bool isUploadingImage,
    String? errorMessage,
    String? editingPostId,
    @Default(false) bool isLoadingPost,
  }) = _CommunityCreateState;
}
