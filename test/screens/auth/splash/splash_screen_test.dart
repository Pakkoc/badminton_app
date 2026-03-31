import 'package:badminton_app/screens/auth/splash/splash_providers.dart';
import 'package:badminton_app/screens/auth/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen', () {
    Widget createSplashApp({
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      );
    }

    testWidgets(
      '앱 이름 "거트알림"이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createSplashApp(
            overrides: [
              splashRouteProvider.overrideWith(
                (ref) async => SplashRoute.login,
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('거트알림'), findsOneWidget);
      },
    );

    testWidgets(
      '슬로건 "배드민턴 거트 작업 실시간 추적"이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createSplashApp(
            overrides: [
              splashRouteProvider.overrideWith(
                (ref) async => SplashRoute.login,
              ),
            ],
          ),
        );

        // Assert
        expect(find.text('배드민턴 거트 작업 실시간 추적'), findsOneWidget);
      },
    );

    testWidgets(
      '저작권 문구가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createSplashApp(
            overrides: [
              splashRouteProvider.overrideWith(
                (ref) async => SplashRoute.login,
              ),
            ],
          ),
        );

        // Assert
        expect(
          find.text('© 2026 거트알림'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '로고 이미지가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createSplashApp(
            overrides: [
              splashRouteProvider.overrideWith(
                (ref) async => SplashRoute.login,
              ),
            ],
          ),
        );

        // Assert
        expect(find.byType(Image), findsOneWidget);
      },
    );
  });
}
