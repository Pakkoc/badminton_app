import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/escape_like.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityPostRepositoryProvider =
    Provider<CommunityPostRepository>((ref) {
  return CommunityPostRepository(ref.read(supabaseProvider));
});

/// 커뮤니티 게시글 리포지토리.
///
/// Supabase `community_posts` 테이블에 대한 CRUD 및 검색 작업을 수행한다.
/// JOIN으로 작성자 이름과 프로필 이미지를 함께 조회한다.
class CommunityPostRepository {
  final SupabaseClient client;

  CommunityPostRepository(this.client);

  static const _selectWithAuthor =
      '*, author:users!community_posts_author_id_fkey'
      '(name, profile_image_url)';

  /// 최신순으로 게시글 목록을 조회한다.
  Future<List<CommunityPost>> getAll({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return data.map(CommunityPost.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// ID로 게시글을 조회한다.
  Future<CommunityPost?> getById(String id) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 게시글을 생성한다.
  Future<CommunityPost> create({
    required String authorId,
    required String title,
    required String content,
    List<String> images = const [],
  }) async {
    try {
      final data = await client.from('community_posts').insert({
        'author_id': authorId,
        'title': title,
        'content': content,
        'images': images,
      }).select(_selectWithAuthor).single();
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 게시글을 수정한다. null인 필드는 변경하지 않는다.
  Future<CommunityPost> update(
    String postId, {
    String? title,
    String? content,
    List<String>? images,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (images != null) updates['images'] = images;

      final data = await client
          .from('community_posts')
          .update(updates)
          .eq('id', postId)
          .select(_selectWithAuthor)
          .single();
      return CommunityPost.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 게시글을 삭제한다.
  Future<void> delete(String postId) async {
    try {
      await client.from('community_posts').delete().eq('id', postId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 제목 또는 내용에서 키워드로 게시글을 검색한다.
  Future<List<CommunityPost>> search(String query) async {
    try {
      final data = await client
          .from('community_posts')
          .select(_selectWithAuthor)
          .or('title.ilike.%${escapeLike(query)}%,content.ilike.%${escapeLike(query)}%')
          .order('created_at', ascending: false)
          .limit(50);
      return data.map(CommunityPost.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
