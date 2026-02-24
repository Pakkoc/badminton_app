import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

void main() {
  group('authRepositoryProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        authRepositoryProvider,
        isA<Provider<AuthRepository>>(),
      );
    });
  });

  group('authStateProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        authStateProvider,
        isA<StreamProvider<AuthState>>(),
      );
    });
  });

  group('currentUserProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        currentUserProvider,
        isA<FutureProvider<User?>>(),
      );
    });
  });

  group('isNewUserProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        isNewUserProvider,
        isA<Provider<bool>>(),
      );
    });
  });

  group('userRoleProvider', () {
    test('Provider가 정의되어 있다', () {
      // Assert
      expect(
        userRoleProvider,
        isA<Provider<UserRole?>>(),
      );
    });
  });
}
