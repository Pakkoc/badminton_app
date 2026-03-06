import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment.freezed.dart';
part 'community_comment.g.dart';

@freezed
class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'parent_id') String? parentId,
    required String content,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // JOIN으로 가져오는 작성자 정보 (DB 컬럼 아님)
    @JsonKey(name: 'author_name', includeToJson: false)
    String? authorName,
    @JsonKey(
      name: 'author_profile_image_url',
      includeToJson: false,
    )
    String? authorProfileImageUrl,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentFromJson(_flattenCommentAuthor(json));
}

/// Supabase JOIN 결과에서 author 정보를 flat하게 변환한다.
///
/// `{ "author": { "name": "홍길동", "profile_image_url": null } }`
/// → `{ "author_name": "홍길동", "author_profile_image_url": null }`
Map<String, dynamic> _flattenCommentAuthor(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.from(json);
  if (copy['author'] is Map<String, dynamic>) {
    final author = copy['author'] as Map<String, dynamic>;
    copy['author_name'] = author['name'];
    copy['author_profile_image_url'] = author['profile_image_url'];
    copy.remove('author');
  }
  return copy;
}
