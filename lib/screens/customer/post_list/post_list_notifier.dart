import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postListNotifierProvider =
    NotifierProvider<PostListNotifier, PostListState>(
  PostListNotifier.new,
);

class PostListNotifier extends Notifier<PostListState> {
  @override
  PostListState build() => const PostListState();

  Future<void> loadPosts(
    String shopId,
    String category,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final postRepository = ref.read(postRepositoryProvider);
      final posts = await postRepository.getByShopAndCategory(
        shopId,
        category,
      );
      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '게시글 목록을 불러올 수 없습니다',
      );
    }
  }
}
