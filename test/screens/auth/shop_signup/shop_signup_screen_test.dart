import 'package:badminton_app/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_screen.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget buildSubject({
    ShopSignupState? initialState,
  }) {
    final router = GoRouter(
      initialLocation: '/shop-register',
      routes: [
        GoRoute(
          path: '/shop-register',
          builder: (_, __) => const ShopSignupScreen(),
        ),
        GoRoute(
          path: '/owner/dashboard',
          builder: (_, __) => const Scaffold(
            body: Text('Owner Dashboard'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (initialState != null)
          shopSignupNotifierProvider.overrideWith(
            () => _FakeShopSignupNotifier(initialState),
          ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('ShopSignupScreen', () {
    testWidgets('AppBar에 "샵 등록" 제목을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('샵 등록'), findsOneWidget);
    });

    testWidgets('안내 문구를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('샵 정보를 등록해주세요'),
        findsOneWidget,
      );
    });

    testWidgets('샵 이름 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('샵 이름'), findsOneWidget);
    });

    testWidgets('주소 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('주소'), findsOneWidget);
    });

    testWidgets('전화번호 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('전화번호'), findsOneWidget);
    });

    testWidgets('소개글 입력 필드를 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('소개글'), findsOneWidget);
    });

    testWidgets('"등록 완료" 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('등록 완료'), findsOneWidget);
    });

    testWidgets('뒤로가기 버튼이 없다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}

class _FakeShopSignupNotifier extends ShopSignupNotifier {
  final ShopSignupState _initialState;

  _FakeShopSignupNotifier(this._initialState);

  @override
  ShopSignupState build() => _initialState;
}
