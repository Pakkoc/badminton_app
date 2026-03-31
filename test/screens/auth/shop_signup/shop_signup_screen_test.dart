import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_screen.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:badminton_app/services/geocoding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockGeocodingService extends Mock
    implements GeocodingService {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late _MockGeocodingService mockGeocoding;
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockShopRepository mockShopRepo;

  setUp(() {
    mockGeocoding = _MockGeocodingService();
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockShopRepo = _MockShopRepository();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockShopRepo.getByOwner(any()))
        .thenAnswer((_) async => null);
  });

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
        supabaseProvider.overrideWithValue(mockSupabase),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
        if (initialState != null)
          shopSignupNotifierProvider.overrideWith(
            () => _FakeShopSignupNotifier(initialState),
          ),
        geocodingServiceProvider
            .overrideWithValue(mockGeocoding),
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

      // AppBar 제목 + StepProgressRow '샵 등록' 텍스트
      expect(find.text('샵 등록'), findsNWidgets(2));
    });

    testWidgets('섹션 제목을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('샵 정보'),
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

    testWidgets('주소 검색 아이콘 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
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

    testWidgets('뒤로가기 버튼이 있다', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets(
      '좌표가 없으면 지도 미리보기를 표시하지 않는다',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // 지도 관련 위젯이 없어야 함
        expect(find.byIcon(Icons.map_outlined), findsNothing);
      },
    );
  });
}

class _FakeShopSignupNotifier extends ShopSignupNotifier {
  final ShopSignupState _initialState;

  _FakeShopSignupNotifier(this._initialState);

  @override
  ShopSignupState build() => _initialState;
}
