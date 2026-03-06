import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required String title,
    required String content,
    @Default([]) List<String> images,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // JOIN으로 가져오는 작성자 정보 (DB 컬럼 아님)
    @JsonKey(name: 'author_name', includeToJson: false)
    String? authorName,
    @JsonKey(
      name: 'author_profile_image_url',
      includeToJson: false,
    )
    String? authorProfileImageUrl,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(_flattenAuthor(json));
}

/// Supabase JOIN 결과에서 author 정보를 flat하게 변환한다.
///
/// `{ "author": { "name": "홍길동", "profile_image_url": "..." } }`
/// → `{ "author_name": "홍길동", "author_profile_image_url": "..." }`
Map<String, dynamic> _flattenAuthor(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.from(json);
  if (copy['author'] is Map<String, dynamic>) {
    final author = copy['author'] as Map<String, dynamic>;
    copy['author_name'] = author['name'];
    copy['author_profile_image_url'] = author['profile_image_url'];
    copy.remove('author');
  }
  return copy;
}
