import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
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

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockShopRepository mockShopRepo;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockShopRepo = _MockShopRepository();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('OwnerDashboardScreen', () {
    testWidgets('로딩 중일 때 LoadingIndicator를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProvider.overrideWithValue(mockSupabase),
            shopRepositoryProvider.overrideWithValue(mockShopRepo),
            ownerDashboardNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OwnerDashboardState(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerDashboardScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('작업이 없으면 EmptyState를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProvider.overrideWithValue(mockSupabase),
            shopRepositoryProvider.overrideWithValue(mockShopRepo),
            ownerDashboardNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OwnerDashboardState(
                  isLoading: false,
                  recentOrders: [],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerDashboardScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(
        find.text('오늘 접수된 작업이 없습니다'),
        findsOneWidget,
      );
    });

    testWidgets('카운트 카드와 최근 작업을 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProvider.overrideWithValue(mockSupabase),
            shopRepositoryProvider.overrideWithValue(mockShopRepo),
            ownerDashboardNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                OwnerDashboardState(
                  isLoading: false,
                  shopName: '거트 프로샵',
                  shopId: testShop.id,
                  receivedCount: 2,
                  inProgressCount: 1,
                  completedCount: 3,
                  recentOrders: [testOrderReceived],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerDashboardScreen(),
          ),
        ),
      );

      // Assert: shopName은 화면에 직접 표시하지 않음
      // 카운트 카드에 숫자가 표시된다
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('접수됨'), findsAtLeastNWidgets(1));
      expect(find.text('작업중'), findsAtLeastNWidgets(1));
      expect(find.text('완료'), findsAtLeastNWidgets(1));
      expect(find.text('최근 작업'), findsOneWidget);
    });

    testWidgets('FAB이 표시된다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProvider.overrideWithValue(mockSupabase),
            shopRepositoryProvider.overrideWithValue(mockShopRepo),
            ownerDashboardNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OwnerDashboardState(
                  isLoading: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerDashboardScreen(),
          ),
        ),
      );

      // Assert: FAB이 표시되고 + 아이콘을 포함한다
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AppBar 타이틀이 "대시보드"이다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProvider.overrideWithValue(mockSupabase),
            shopRepositoryProvider.overrideWithValue(mockShopRepo),
            ownerDashboardNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OwnerDashboardState(
                  isLoading: false,
                  shopName: '테스트샵',
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerDashboardScreen(),
          ),
        ),
      );

      // Assert: AppBar 타이틀이 "대시보드"이다
      // NavigationBar는 OwnerShellScreen에 있어 단독 테스트에서는 표시되지 않음
      expect(find.text('대시보드'), findsOneWidget);
    });
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
