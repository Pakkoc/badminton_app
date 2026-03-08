import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = _MockAuthRepository();
  });

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
        authRepositoryProvider
            .overrideWithValue(mockAuthRepo),
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

    testWidgets('AppBar에 로그아웃 아이콘 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets(
      '로그아웃 버튼 탭 시 확인 다이얼로그를 표시한다',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        expect(
          find.text('다른 계정으로 로그인하시겠습니까?'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '로그아웃 확인 시 signOut이 호출되고 /login으로 이동한다',
      (tester) async {
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        // 다이얼로그의 "로그아웃" TextButton만 찾음
        // (AppBar 툴팁과 구분하기 위해 TextButton 내 Text를 탐색)
        final logoutButtons = find.descendant(
          of: find.byType(TextButton),
          matching: find.text('로그아웃'),
        );
        await tester.tap(logoutButtons.last);
        await tester.pumpAndSettle();

        verify(() => mockAuthRepo.signOut()).called(1);
        expect(find.text('Login'), findsOneWidget);
      },
    );

    testWidgets(
      '로그아웃 다이얼로그 취소 시 화면을 유지한다',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();

        expect(find.text('프로필 설정'), findsOneWidget);
      },
    );

    testWidgets(
      '뒤로가기(leading) 탭 시 확인 다이얼로그를 표시한다',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(
          find.text('다른 계정으로 로그인하시겠습니까?'),
          findsOneWidget,
        );
      },
    );
  });
}

class _FakeProfileSetupNotifier extends ProfileSetupNotifier {
  final ProfileSetupState _initialState;

  _FakeProfileSetupNotifier(this._initialState);

  @override
  ProfileSetupState build() => _initialState;
}
