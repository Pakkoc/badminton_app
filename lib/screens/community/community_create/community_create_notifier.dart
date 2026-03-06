import 'dart:typed_data';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'community_create_state.dart';

final communityCreateNotifierProvider =
    NotifierProvider<CommunityCreateNotifier, CommunityCreateState>(
  CommunityCreateNotifier.new,
);

class CommunityCreateNotifier extends Notifier<CommunityCreateState> {
  @override
  CommunityCreateState build() => const CommunityCreateState();

  void updateTitle(String title) {
    state = state.copyWith(title: title, errorMessage: null);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content, errorMessage: null);
  }

  Future<void> loadPost(String postId) async {
    state = state.copyWith(isLoadingPost: true, editingPostId: postId);
    try {
      final repo = ref.read(communityPostRepositoryProvider);
      final post = await repo.getById(postId);
      if (post != null) {
        state = state.copyWith(
          title: post.title,
          content: post.content,
          images: post.images,
          isLoadingPost: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingPost: false,
        errorMessage: '게시글을 불러오지 못했습니다',
      );
    }
  }

  Future<void> addImage(Uint8List bytes, String extension) async {
    if (state.images.length >= 5) {
      state = state.copyWith(errorMessage: '이미지는 최대 5장까지 첨부할 수 있습니다');
      return;
    }
    state = state.copyWith(isUploadingImage: true);
    try {
      final userId = ref.read(supabaseProvider).auth.currentUser!.id;
      final storageRepo = ref.read(storageRepositoryProvider);
      final path =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
      final url =
          await storageRepo.uploadImage('community-images', bytes, path);
      state = state.copyWith(
        images: [...state.images, url],
        isUploadingImage: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: '이미지 업로드에 실패했습니다',
      );
    }
  }

  void removeImage(int index) {
    final images = [...state.images]..removeAt(index);
    state = state.copyWith(images: images);
  }

  Future<bool> submit() async {
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

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(communityPostRepositoryProvider);
      final userId = ref.read(supabaseProvider).auth.currentUser!.id;

      if (state.editingPostId != null) {
        await repo.update(
          state.editingPostId!,
          title: state.title,
          content: state.content,
          images: state.images,
        );
      } else {
        await repo.create(
          authorId: userId,
          title: state.title,
          content: state.content,
          images: state.images,
        );
      }
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return false;
    }
  }
}
