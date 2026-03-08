import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/screens/customer/mypage/mypage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

class _MockAuthRepository extends Mock
    implements AuthRepository {}

class _MockSupabaseClient extends Mock
    implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthUser extends Mock implements AuthUser {}

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockAuthUser mockAuthUser;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockAuthUser = _MockAuthUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
    when(() => mockAuthUser.email)
        .thenReturn('test@example.com');
    when(() => mockAuthUser.id).thenReturn('test-user-id');
  });

  List<Override> baseOverrides({bool hasShop = false}) => [
        currentUserProvider.overrideWith(
          (ref) async => testUser,
        ),
        authRepositoryProvider.overrideWithValue(
          _MockAuthRepository(),
        ),
        supabaseProvider.overrideWithValue(mockSupabase),
        hasShopProvider.overrideWith(
          (ref) async => hasShop,
        ),
        shopStatusProvider.overrideWith(
          (ref) async =>
              hasShop ? ShopStatus.approved : null,
        ),
        myShopProvider.overrideWith(
          (ref) async => null,
        ),
      ];

  group('MypageScreen', () {
    testWidgets('AppBar 제목이 "마이페이지"이다', (tester) async {
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: baseOverrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('마이페이지'), findsOneWidget);
    });

    testWidgets('사용자 이름을 표시한다', (tester) async {
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: baseOverrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('홍길동'), findsOneWidget);
    });

    testWidgets('로그아웃 탭 시 확인 다이얼로그를 표시한다',
        (tester) async {
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: baseOverrides(),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('로그아웃'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      expect(find.text('로그아웃 하시겠습니까?'), findsOneWidget);
    });

    testWidgets('사용자가 null일 때 로그인 안내를 표시한다',
        (tester) async {
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => null,
          ),
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(),
          ),
          supabaseProvider.overrideWithValue(mockSupabase),
          hasShopProvider.overrideWith(
            (ref) async => false,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('로그인이 필요합니다'), findsOneWidget);
    });

    testWidgets(
      '샵 미등록이면 "샵 사장님 등록" 메뉴가 표시된다',
      (tester) async {
        await pumpTestApp(
          tester,
          child: const MypageScreen(),
          overrides: baseOverrides(hasShop: false),
        );
        await tester.pumpAndSettle();

        expect(find.text('샵 등록 신청'), findsOneWidget);
        expect(
          find.byIcon(Icons.storefront),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '샵 등록 완료이면 "사장님 모드 전환" 메뉴가 표시된다',
      (tester) async {
        await pumpTestApp(
          tester,
          child: const MypageScreen(),
          overrides: baseOverrides(hasShop: true),
        );
        await tester.pumpAndSettle();

        expect(find.text('사장님 모드 전환'), findsOneWidget);
        expect(
          find.byIcon(Icons.swap_horiz),
          findsOneWidget,
        );
      },
    );
  });
}
