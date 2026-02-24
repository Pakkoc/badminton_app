import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postDetailNotifierProvider =
    NotifierProvider<PostDetailNotifier, PostDetailState>(
  PostDetailNotifier.new,
);

class PostDetailNotifier extends Notifier<PostDetailState> {
  @override
  PostDetailState build() => const PostDetailState();

  Future<void> loadPost(String postId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final postRepository = ref.read(postRepositoryProvider);
      final post = await postRepository.getById(postId);
      if (post == null) {
        state = state.copyWith(
          isLoading: false,
          error: '게시글을 찾을 수 없습니다',
        );
        return;
      }
      state = state.copyWith(
        post: post,
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
        error: '게시글을 불러올 수 없습니다',
      );
    }
  }
}
