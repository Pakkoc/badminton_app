import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// AuthRepository 프로바이더.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

/// 인증 상태 변경 스트림 프로바이더.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.onAuthStateChange;
});

/// 현재 사용자 정보를 users 테이블에서 조회하는 프로바이더.
///
/// auth user가 없으면 null을 반환한다.
/// users 테이블에 레코드가 없으면 null을 반환한다 (신규 사용자).
final currentUserProvider =
    FutureProvider<User?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) async {
      final authUser =
          ref.read(authRepositoryProvider).currentUser;
      if (authUser == null) return null;

      final userRepository = ref.read(userRepositoryProvider);
      return userRepository.getById(authUser.id);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 신규 사용자 여부 프로바이더.
///
/// currentUserProvider의 데이터가 null이면 true를 반환한다.
final isNewUserProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user == null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// 현재 인증된 사용자 ID를 동기적으로 반환하는 프로바이더.
///
/// Notifier에서 현재 사용자를 조회할 때
/// [currentUserProvider.future] 대신 사용한다.
/// 테스트에서 쉽게 오버라이드할 수 있다.
final currentAuthUserIdProvider = Provider<String?>((ref) {
  return ref.read(authRepositoryProvider).currentUser?.id;
});

/// 현재 인증된 사용자의 User 객체를 직접 조회.
///
/// [currentUserProvider.future]는 StreamProvider를 watch하므로
/// auth 스트림이 여러 이벤트를 발행하면 Future가 orphan되어
/// 무한 대기할 수 있다. 이 함수는 [currentAuthUserIdProvider]를
/// 읽어 race condition을 방지한다.
Future<User?> getCurrentUser(Ref ref) async {
  final userId = ref.read(currentAuthUserIdProvider);
  if (userId == null) return null;
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.getById(userId);
}

/// 현재 사용자의 역할 프로바이더.
final userRoleProvider = Provider<UserRole?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});
