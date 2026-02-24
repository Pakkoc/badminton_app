import 'package:badminton_app/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget buildSubject({
    ProfileSetupState? initialState,
  }) {
    final router = GoRouter(
      initialLocation: '/profile-setup',
      routes: [
        GoRoute(
          path: '/profile-setup',
          builder: (_, __) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(
            body: Text('Login'),
          ),
        ),
        GoRoute(
          path: '/customer/home',
          builder: (_, __) => const Scaffold(
            body: Text('Customer Home'),
          ),
        ),
        GoRoute(
          path: '/shop-register',
          builder: (_, __) => const Scaffold(
            body: Text('Shop Register'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (initialState != null)
          profileSetupNotifierProvider.overrideWith(
            () => _FakeProfileSetupNotifier(initialState),
          ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('ProfileSetupScreen', () {
    testWidgets('AppBar에 "프로필 설정" 제목을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('프로필 설정'), findsOneWidget);
    });

    testWidgets('안내 문구를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('서비스 이용을 위해 정보를 입력해주세요'),
        findsOneWidget,
      );
    });

    testWidgets('역할 선택 카드 2개를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('고객'), findsOneWidget);
      expect(find.text('사장님'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('이름 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('이름'), findsOneWidget);
    });

    testWidgets('전화번호 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('전화번호'), findsOneWidget);
    });

    testWidgets('기본 상태에서 "시작하기" 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('뒤로가기 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}

class _FakeProfileSetupNotifier extends ProfileSetupNotifier {
  final ProfileSetupState _initialState;

  _FakeProfileSetupNotifier(this._initialState);

  @override
  ProfileSetupState build() => _initialState;
}
