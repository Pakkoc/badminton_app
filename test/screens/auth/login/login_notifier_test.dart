import 'package:badminton_app/screens/auth/login/login_notifier.dart';
import 'package:badminton_app/screens/auth/login/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginNotifier', () {
    test('초기 상태는 idle이다', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final state = container.read(loginNotifierProvider);

      // Assert
      expect(state, const LoginState.idle());
    });
  });
}
