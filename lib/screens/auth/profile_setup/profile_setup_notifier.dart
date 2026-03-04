import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileSetupNotifierProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  bool get isValid =>
      Validators.name(state.name) == null &&
      Validators.phone(state.phone) == null;

  Future<String?> submit() async {
    if (!isValid) return null;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final userId =
          ref.read(supabaseProvider).auth.currentUser!.id;
      final user = User(
        id: userId,
        role: UserRole.customer,
        name: state.name,
        phone: state.phone,
        createdAt: DateTime.now(),
      );

      await ref.read(userRepositoryProvider).create(user);
      await ref
          .read(userRepositoryProvider)
          .matchMembersByPhone(state.phone, userId);

      return '/customer/home';
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '알 수 없는 오류가 발생했습니다',
      );
      return null;
    }
  }
}
