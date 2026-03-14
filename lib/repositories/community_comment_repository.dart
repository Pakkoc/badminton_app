import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityCommentRepositoryProvider =
    Provider<CommunityCommentRepository>((ref) {
  return CommunityCommentRepository(ref.read(supabaseProvider));
});

/// 커뮤니티 댓글 리포지토리.
///
/// Supabase `community_comments` 테이블에 대한 조회/생성/삭제 작업을 수행한다.
/// JOIN으로 작성자 이름과 프로필 이미지를 함께 조회한다.
class CommunityCommentRepository {
  final SupabaseClient client;

  CommunityCommentRepository(this.client);

  static const _selectWithAuthor =
      '*, author:users!community_comments_author_id_fkey'
      '(name, profile_image_url)';

  /// 게시글에 속한 댓글 목록을 시간순으로 조회한다.
  Future<List<CommunityComment>> getByPostId(String postId) async {
    try {
      final data = await client
          .from('community_comments')
          .select(_selectWithAuthor)
          .eq('post_id', postId)
          .order('created_at');
      return data.map(CommunityComment.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 댓글 또는 대댓글을 생성한다.
  ///
  /// [parentId]가 null이면 1단 댓글, 값이 있으면 대댓글이다.
  Future<CommunityComment> create({
    required String postId,
    required String authorId,
    required String content,
    String? parentId,
  }) async {
    try {
      final data = await client.from('community_comments').insert({
        'post_id': postId,
        'author_id': authorId,
        'content': content,
        'parent_id': parentId,
      }).select(_selectWithAuthor).single();
      return CommunityComment.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 대댓글 2단 제한을 강제한다.
  ///
  /// [targetCommentParentId]가 null이면 1단 댓글 → [targetCommentId] 반환.
  /// [targetCommentParentId]가 있으면 이미 대댓글 → 루트([targetCommentParentId]) 반환.
  String resolveParentId({
    required String targetCommentId,
    required String? targetCommentParentId,
  }) =>
      targetCommentParentId ?? targetCommentId;

  /// 댓글을 삭제한다.
  Future<void> delete(String commentId) async {
    try {
      await client.from('community_comments').delete().eq('id', commentId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
