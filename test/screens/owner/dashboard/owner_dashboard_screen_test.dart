import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/fixtures.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockMemberRepository extends Mock
    implements MemberRepository {}

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockShopRepository mockShopRepo;
  late _MockMemberRepository mockMemberRepo;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockShopRepo = _MockShopRepository();
    mockMemberRepo = _MockMemberRepository();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  Widget buildApp(OwnerDashboardState state) {
    return ProviderScope(
      overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        shopRepositoryProvider
            .overrideWithValue(mockShopRepo),
        memberRepositoryProvider
            .overrideWithValue(mockMemberRepo),
        ownerDashboardNotifierProvider.overrideWith(
          (_) => _FakeNotifier(state),
        ),
      ],
      child: const MaterialApp(
        home: OwnerDashboardScreen(),
      ),
    );
  }

  group('OwnerDashboardScreen', () {
    testWidgets('로딩 중일 때 LoadingIndicator를 표시한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          const OwnerDashboardState(isLoading: true),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('작업이 없으면 빈 상태를 표시한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          const OwnerDashboardState(
            isLoading: false,
            recentOrders: [],
          ),
        ),
      );

      expect(
        find.text('아직 접수된 작업이 없습니다'),
        findsOneWidget,
      );
      expect(
        find.text("'+' 버튼으로 새 작업을 접수하세요"),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.assignment),
        findsOneWidget,
      );
    });

    testWidgets('카운트 카드와 최근 작업을 표시한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          OwnerDashboardState(
            isLoading: false,
            shopName: '거트 프로샵',
            shopId: testShop.id,
            receivedCount: 2,
            inProgressCount: 1,
            completedCount: 3,
            recentOrders: [testOrderReceived],
            memberNames: {
              testOrderReceived.memberId: '홍길동',
            },
          ),
        ),
      );

      // 카운트 카드 숫자
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(
        find.text('접수됨'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('작업중'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('완료'),
        findsAtLeastNWidgets(1),
      );
      // 최근 작업 섹션
      expect(find.text('최근 작업'), findsOneWidget);
      // 회원 이름 표시
      expect(find.text('홍길동'), findsOneWidget);
      // 액션 버튼 (received → "작업 시작")
      expect(find.text('작업 시작'), findsOneWidget);
    });

    testWidgets('FAB이 표시된다', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const OwnerDashboardState(isLoading: false),
        ),
      );

      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AppBar 타이틀이 "대시보드"이다', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          const OwnerDashboardState(
            isLoading: false,
            shopName: '테스트샵',
          ),
        ),
      );

      expect(find.text('대시보드'), findsOneWidget);
    });

    testWidgets('알림 벨 아이콘이 표시된다', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const OwnerDashboardState(isLoading: false),
        ),
      );

      expect(
        find.byIcon(Icons.notifications_outlined),
        findsOneWidget,
      );
    });

    testWidgets('전체보기 링크가 표시된다', (tester) async {
      await tester.pumpWidget(
        buildApp(
          OwnerDashboardState(
            isLoading: false,
            recentOrders: [testOrderReceived],
            memberNames: {
              testOrderReceived.memberId: '홍길동',
            },
          ),
        ),
      );

      expect(find.text('전체보기'), findsOneWidget);
    });

    testWidgets(
      '작업중 상태일 때 "작업 완료" 버튼을 표시한다',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            OwnerDashboardState(
              isLoading: false,
              recentOrders: [testOrderInProgress],
              memberNames: {
                testOrderInProgress.memberId: '이지은',
              },
            ),
          ),
        );

        expect(find.text('작업 완료'), findsOneWidget);
      },
    );

    testWidgets(
      '완료 상태일 때 액션 버튼이 없다',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            OwnerDashboardState(
              isLoading: false,
              recentOrders: [testOrderCompleted],
              memberNames: {
                testOrderCompleted.memberId: '박현우',
              },
            ),
          ),
        );

        expect(find.text('작업 시작'), findsNothing);
        expect(find.text('작업 완료'), findsNothing);
      },
    );
  });
}

class _FakeNotifier
    extends StateNotifier<OwnerDashboardState>
    implements OwnerDashboardNotifier {
  _FakeNotifier(super.state);

  @override
  Future<void> loadDashboard(String ownerId) async {}

  @override
  Future<void> changeOrderStatus(
    String orderId,
    dynamic newStatus,
  ) async {}
}
