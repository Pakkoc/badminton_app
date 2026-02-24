import 'package:badminton_app/screens/auth/login/login_notifier.dart';
import 'package:badminton_app/screens/auth/login/login_screen.dart';
import 'package:badminton_app/screens/auth/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen', () {
    Widget createLoginApp({
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: Scaffold(
            body: LoginScreen(),
          ),
        ),
      );
    }

    testWidgets(
      '카카오 로그인 버튼이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLoginApp(
            overrides: [
              loginNotifierProvider.overrideWith(
                () => LoginNotifier(),
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('카카오로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '네이버 로그인 버튼이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLoginApp(
            overrides: [
              loginNotifierProvider.overrideWith(
                () => LoginNotifier(),
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('네이버로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      'Gmail 로그인 버튼이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLoginApp(
            overrides: [
              loginNotifierProvider.overrideWith(
                () => LoginNotifier(),
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('Gmail로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '환영 문구가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLoginApp(
            overrides: [
              loginNotifierProvider.overrideWith(
                () => LoginNotifier(),
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('반갑습니다!'), findsOneWidget);
        expect(find.text('간편하게 시작하세요'), findsOneWidget);
      },
    );
  });
}
