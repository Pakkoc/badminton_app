import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커뮤니티 게시글 목록 Provider.
final communityPostListProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.getAll();
});

/// 커뮤니티 게시글 상세 Provider.
final communityPostDetailProvider =
    FutureProvider.autoDispose
        .family<CommunityPost?, String>((ref, postId) async {
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.getById(postId);
});

/// 커뮤니티 댓글 목록 Provider.
final communityCommentsProvider =
    FutureProvider.autoDispose
        .family<List<CommunityComment>, String>((ref, postId) async {
  final repo = ref.watch(communityCommentRepositoryProvider);
  return repo.getByPostId(postId);
});

/// 게시글 좋아요 상태 Provider.
final communityPostLikeStatusProvider = FutureProvider.autoDispose
    .family<bool, ({String userId, String postId})>((ref, params) async {
  final repo = ref.watch(communityLikeRepositoryProvider);
  return repo.getPostLikeStatus(params.userId, params.postId);
});

/// 커뮤니티 검색 Provider.
final communitySearchProvider =
    FutureProvider.autoDispose
        .family<List<CommunityPost>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(communityPostRepositoryProvider);
  return repo.search(query);
});
