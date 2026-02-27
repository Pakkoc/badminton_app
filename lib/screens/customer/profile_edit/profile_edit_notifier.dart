import 'dart:typed_data';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileEditNotifierProvider =
    NotifierProvider<ProfileEditNotifier, ProfileEditState>(
  ProfileEditNotifier.new,
);

class ProfileEditNotifier extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() {
    Future.microtask(loadProfile);
    return const ProfileEditState();
  }

  Future<void> loadProfile() async {
    try {
      final user = await getCurrentUser(ref);
      if (user == null) return;

      state = state.copyWith(
        name: user.name,
        phone: user.phone,
        profileImageUrl: user.profileImageUrl,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: '프로필을 불러올 수 없습니다',
      );
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  Future<void> pickImage(Uint8List imageBytes) async {
    try {
      final user = await getCurrentUser(ref);
      if (user == null) return;

      final storageRepository =
          ref.read(storageRepositoryProvider);
      final path =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storageRepository.uploadImage(
        'profile-images',
        imageBytes,
        path,
      );
      state = state.copyWith(profileImageUrl: url);
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.userMessage);
    } catch (e) {
      state = state.copyWith(
        errorMessage: '이미지 업로드에 실패했습니다',
      );
    }
  }

  Future<bool> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );
    try {
      final user = await getCurrentUser(ref);
      if (user == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: '로그인이 필요합니다',
        );
        return false;
      }

      final userRepository = ref.read(userRepositoryProvider);
      final data = <String, dynamic>{
        'name': state.name,
        'phone': state.phone,
      };
      if (state.profileImageUrl != null) {
        data['profile_image_url'] = state.profileImageUrl;
      }

      await userRepository.update(user.id, data);
      ref.invalidate(currentUserProvider);
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
        errorMessage: '프로필 저장에 실패했습니다',
      );
      return false;
    }
  }
}
