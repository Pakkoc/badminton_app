import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:badminton_app/models/enums.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(
      fromJson: PostCategory.fromJson,
      toJson: _postCategoryToJson,
    )
    required PostCategory category,
    required String title,
    required String content,
    @Default([]) List<String> images,
    @JsonKey(name: 'event_start_date') DateTime? eventStartDate,
    @JsonKey(name: 'event_end_date') DateTime? eventEndDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

String _postCategoryToJson(PostCategory category) => category.toJson();
