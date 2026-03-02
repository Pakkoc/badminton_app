import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/repositories/post_repository.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postCreateNotifierProvider =
    NotifierProvider<PostCreateNotifier, PostCreateState>(
  PostCreateNotifier.new,
);

class PostCreateNotifier extends Notifier<PostCreateState> {
  @override
  PostCreateState build() => const PostCreateState();

  void updateTitle(String title) {
    state = state.copyWith(title: title, errorMessage: null);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content, errorMessage: null);
  }

  void selectCategory(PostCategory category) {
    state = state.copyWith(
      category: category,
      errorMessage: null,
    );
    if (category == PostCategory.notice) {
      state = state.copyWith(
        eventStartDate: null,
        eventEndDate: null,
      );
    }
  }

  void addImage(String imageUrl) {
    if (state.images.length >= 5) {
      state = state.copyWith(
        errorMessage: '이미지는 최대 5장까지 등록할 수 있습니다',
      );
      return;
    }
    state = state.copyWith(
      images: [...state.images, imageUrl],
      errorMessage: null,
    );
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.images.length) return;
    final images = [...state.images]..removeAt(index);
    state = state.copyWith(images: images, errorMessage: null);
  }

  void setEventDates({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      eventStartDate: startDate ?? state.eventStartDate,
      eventEndDate: endDate ?? state.eventEndDate,
      errorMessage: null,
    );
  }

  /// 기존 게시글을 수정 모드로 로드한다.
  Future<void> loadPost(String postId) async {
    state = state.copyWith(isLoadingPost: true, errorMessage: null);
    try {
      final repo = ref.read(postRepositoryProvider);
      final post = await repo.getById(postId);
      if (post == null) {
        state = state.copyWith(
          isLoadingPost: false,
          errorMessage: '게시글을 찾을 수 없습니다',
        );
        return;
      }
      state = state.copyWith(
        editingPostId: post.id,
        category: post.category,
        title: post.title,
        content: post.content,
        images: post.images,
        eventStartDate: post.eventStartDate,
        eventEndDate: post.eventEndDate,
        isLoadingPost: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingPost: false,
        errorMessage: e.userMessage,
      );
    }
  }

  Future<bool> submit(String shopId) async {
    final titleError = Validators.postTitle(state.title);
    if (titleError != null) {
      state = state.copyWith(errorMessage: titleError);
      return false;
    }

    final contentError = Validators.postContent(state.content);
    if (contentError != null) {
      state = state.copyWith(errorMessage: contentError);
      return false;
    }

    if (state.category == PostCategory.event) {
      if (state.eventStartDate == null ||
          state.eventEndDate == null) {
        state = state.copyWith(
          errorMessage: '이벤트 기간을 설정해주세요',
        );
        return false;
      }
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );

    try {
      final postRepository = ref.read(postRepositoryProvider);
      final post = Post(
        id: '',
        shopId: shopId,
        category: state.category,
        title: state.title,
        content: state.content,
        images: state.images,
        eventStartDate: state.eventStartDate,
        eventEndDate: state.eventEndDate,
        createdAt: DateTime.now(),
      );
      if (state.editingPostId != null) {
        await postRepository.update(state.editingPostId!, post);
      } else {
        await postRepository.create(post);
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: state.editingPostId != null
            ? '게시글 수정에 실패했습니다'
            : '게시글 등록에 실패했습니다',
      );
      return false;
    }
  }
}
