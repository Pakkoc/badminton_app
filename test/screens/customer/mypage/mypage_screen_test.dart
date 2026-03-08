import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/auth_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/customer/mypage/mypage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

class _MockAuthRepository extends Mock
    implements AuthRepository {}

class _MockUserRepository extends Mock
    implements UserRepository {}

class _MockSupabaseClient extends Mock
    implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthUser extends Mock implements AuthUser {}

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockAuthUser mockAuthUser;
  late _MockUserRepository mockUserRepository;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockAuthUser = _MockAuthUser();
    mockUserRepository = _MockUserRepository();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
    when(() => mockAuthUser.email)
        .thenReturn('test@example.com');
    when(() => mockAuthUser.id).thenReturn('test-user-id');

    when(
      () => mockUserRepository.updateNotifyShop(
        any(),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => testUser);

    when(
      () => mockUserRepository.updateNotifyCommunity(
        any(),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => testUser);
  });

  List<Override> baseOverrides({
    bool hasShop = false,
    User? user,
  }) =>
      [
        currentUserProvider.overrideWith(
          (ref) async => user ?? testUser,
        ),
        authRepositoryProvider.overrideWithValue(
          _MockAuthRepository(),
        ),
        userRepositoryProvider.overrideWithValue(
          mockUserRepository,
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

      // 로그아웃 버튼이 스크롤 영역 밖에 있을 수 있으므로
      // ListView를 끝까지 스크롤한 뒤 탭한다.
      await tester.scrollUntilVisible(
        find.text('로그아웃'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
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

    testWidgets('"알림 설정" 섹션에 샵 알림과 커뮤니티 알림 토글이 표시된다',
        (tester) async {
      await pumpTestApp(
        tester,
        child: const MypageScreen(),
        overrides: baseOverrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('샵 알림'), findsOneWidget);
      expect(find.text('커뮤니티 알림'), findsOneWidget);
      // Switch가 2개 렌더링되어야 한다
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets(
      'User의 notifyShop=false이면 샵 알림 토글이 꺼진 상태로 초기화된다',
      (tester) async {
        final userWithShopOff = testUser.copyWith(
          notifyShop: false,
          notifyCommunity: true,
        );
        await pumpTestApp(
          tester,
          child: const MypageScreen(),
          overrides: baseOverrides(user: userWithShopOff),
        );
        await tester.pumpAndSettle();

        final switches = tester
            .widgetList<Switch>(find.byType(Switch))
            .toList();
        // 첫 번째 Switch = 샵 알림
        expect(switches[0].value, false);
        // 두 번째 Switch = 커뮤니티 알림
        expect(switches[1].value, true);
      },
    );

    testWidgets(
      '샵 알림 토글을 탭하면 updateNotifyShop이 호출된다',
      (tester) async {
        await pumpTestApp(
          tester,
          child: const MypageScreen(),
          overrides: baseOverrides(),
        );
        await tester.pumpAndSettle();

        // 첫 번째 Switch (샵 알림) 탭
        final shopSwitch = find.byType(Switch).first;
        await tester.tap(shopSwitch);
        await tester.pumpAndSettle();

        verify(
          () => mockUserRepository.updateNotifyShop(
            testUser.id,
            value: false,
          ),
        ).called(1);
      },
    );

    testWidgets(
      '커뮤니티 알림 토글을 탭하면 updateNotifyCommunity가 호출된다',
      (tester) async {
        await pumpTestApp(
          tester,
          child: const MypageScreen(),
          overrides: baseOverrides(),
        );
        await tester.pumpAndSettle();

        // 두 번째 Switch (커뮤니티 알림) 탭
        final communitySwitch = find.byType(Switch).at(1);
        await tester.tap(communitySwitch);
        await tester.pumpAndSettle();

        verify(
          () => mockUserRepository.updateNotifyCommunity(
            testUser.id,
            value: false,
          ),
        ).called(1);
      },
    );
  });
}
