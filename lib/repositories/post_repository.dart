import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(supabaseProvider));
});

/// 게시글 리포지토리.
///
/// Supabase `posts` 테이블에 대한 CRUD 작업을 수행한다.
class PostRepository {
  final SupabaseClient client;

  PostRepository(this.client);

  /// 게시글을 생성한다.
  Future<Post> create(Post post) async {
    try {
      final data =
          await client.from('posts').insert(post.toJson()).select().single();
      return Post.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 ID와 카테고리로 게시글 목록을 조회한다.
  Future<List<Post>> getByShopAndCategory(
    String shopId,
    String category,
  ) async {
    try {
      final data = await client
          .from('posts')
          .select()
          .eq('shop_id', shopId)
          .eq('category', category)
          .order('created_at', ascending: false);
      return data.map(Post.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// ID로 게시글을 조회한다.
  Future<Post?> getById(String id) async {
    try {
      final data =
          await client.from('posts').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Post.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
