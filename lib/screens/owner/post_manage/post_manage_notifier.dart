import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postManageNotifierProvider =
    NotifierProvider<PostManageNotifier, PostManageState>(
  PostManageNotifier.new,
);

class PostManageNotifier extends Notifier<PostManageState> {
  @override
  PostManageState build() => const PostManageState();

  Future<void> loadPosts(String shopId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(postRepositoryProvider);
      final posts = await repo.getByShop(
        shopId,
        category: state.selectedCategory,
      );
      state = state.copyWith(posts: posts, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.userMessage,
      );
    }
  }

  Future<void> filterByCategory(
    String shopId,
    PostCategory? category,
  ) async {
    state = state.copyWith(selectedCategory: category);
    await loadPosts(shopId);
  }

  Future<bool> deletePost(String shopId, String postId) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.delete(postId);
      await loadPosts(shopId);
      state = state.copyWith(isDeleting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: e.userMessage,
      );
      return false;
    }
  }
}
