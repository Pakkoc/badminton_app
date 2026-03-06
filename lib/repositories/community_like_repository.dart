import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityLikeRepositoryProvider =
    Provider<CommunityLikeRepository>((ref) {
  return CommunityLikeRepository(ref.watch(supabaseProvider));
});

/// 커뮤니티 좋아요 리포지토리.
///
/// Supabase `community_likes` 테이블에 대한 토글/조회 작업을 수행한다.
class CommunityLikeRepository {
  final SupabaseClient client;

  CommunityLikeRepository(this.client);

  /// 게시글 좋아요를 토글한다.
  ///
  /// 이미 좋아요 상태이면 취소하고 `false`를 반환한다.
  /// 좋아요 상태가 아니면 추가하고 `true`를 반환한다.
  Future<bool> togglePostLike(String userId, String postId) async {
    try {
      final existing = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('community_likes')
            .delete()
            .eq('id', existing['id'] as String);
        return false;
      } else {
        await client.from('community_likes').insert({
          'user_id': userId,
          'post_id': postId,
        });
        return true;
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 댓글 좋아요를 토글한다.
  ///
  /// 이미 좋아요 상태이면 취소하고 `false`를 반환한다.
  /// 좋아요 상태가 아니면 추가하고 `true`를 반환한다.
  Future<bool> toggleCommentLike(String userId, String commentId) async {
    try {
      final existing = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('community_likes')
            .delete()
            .eq('id', existing['id'] as String);
        return false;
      } else {
        await client.from('community_likes').insert({
          'user_id': userId,
          'comment_id': commentId,
        });
        return true;
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 사용자가 해당 게시글에 좋아요했는지 확인한다.
  Future<bool> getPostLikeStatus(String userId, String postId) async {
    try {
      final data = await client
          .from('community_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return data != null;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 사용자가 좋아요한 댓글 ID의 집합을 반환한다.
  ///
  /// [commentIds]가 비어있으면 빈 집합을 즉시 반환한다.
  Future<Set<String>> getCommentLikedIds(
    String userId,
    List<String> commentIds,
  ) async {
    try {
      if (commentIds.isEmpty) return {};
      final data = await client
          .from('community_likes')
          .select('comment_id')
          .eq('user_id', userId)
          .inFilter('comment_id', commentIds);
      return data.map((e) => e['comment_id'] as String).toSet();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
