import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('OwnerDashboardScreen', () {
    testWidgets('로딩 중일 때 LoadingIndicator를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Assert
      expect(find.text('거트 프로샵'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('접수됨'), findsAtLeastNWidgets(1));
      expect(find.text('작업중'), findsAtLeastNWidgets(1));
      expect(find.text('완료'), findsAtLeastNWidgets(1));
      expect(find.text('최근 작업'), findsOneWidget);
    });

    testWidgets('FAB에 작업 접수 텍스트를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Assert
      expect(find.text('작업 접수'), findsOneWidget);
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      );
    });

    testWidgets('하단 네비게이션 바를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Assert
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('대시보드'), findsOneWidget);
      expect(find.text('작업관리'), findsOneWidget);
      expect(find.text('QR'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
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
