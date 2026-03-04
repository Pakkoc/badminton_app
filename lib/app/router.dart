import 'dart:async';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/auth/login/login_screen.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_screen.dart';
import 'package:badminton_app/screens/auth/splash/splash_screen.dart';
import 'package:badminton_app/screens/customer/home/customer_home_screen.dart';
import 'package:badminton_app/screens/customer/mypage/mypage_screen.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_screen.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_screen.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_screen.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_screen.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_screen.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_screen.dart';
import 'package:badminton_app/screens/customer/qr_order/qr_order_screen.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_screen.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_screen.dart';
import 'package:badminton_app/screens/admin/shop_request_detail/shop_request_detail_screen.dart';
import 'package:badminton_app/screens/admin/shop_requests/shop_requests_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_screen.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_screen.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_screen.dart';
import 'package:badminton_app/screens/owner/owner_shell_screen.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_screen.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_screen.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증 상태 변경 시 GoRouter를 갱신하는 Listenable.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// 인증이 필요하지 않은 경로 목록.
const _publicPaths = {'/splash', '/login'};

final routerProvider = Provider<GoRouter>((ref) {
  final client = ref.read(supabaseProvider);
  final refreshNotifier =
      _AuthRefreshNotifier(client.auth.onAuthStateChange);

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final session = client.auth.currentSession;
      final isPublic = _publicPaths.contains(state.matchedLocation);

      // 세션이 없으면 공개 경로만 허용
      if (session == null) {
        return isPublic ? null : '/login';
      }

      // 세션이 있는데 /login에 있으면 → 스플래시로 (라우트 해석)
      if (state.matchedLocation == '/login') {
        return '/splash';
      }

      // /owner/* 라우트는 approved 샵이 있을 때만 접근 가능
      if (state.matchedLocation.startsWith('/owner')) {
        final hasShop =
            await ref.read(hasShopProvider.future);
        if (!hasShop) return '/customer/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/shop-register',
        redirect: (context, state) async {
          final shopStatus =
              await ref.read(shopStatusProvider.future);
          return switch (shopStatus) {
            ShopStatus.approved => '/owner/dashboard',
            ShopStatus.pending => '/customer/mypage',
            ShopStatus.rejected => null,
            null => null,
          };
        },
        builder: (context, state) => const ShopSignupScreen(),
      ),

      // QR 딥링크: /shop/:shopId → QR 접수 화면
      GoRoute(
        path: '/shop/:shopId',
        builder: (context, state) => QrOrderScreen(
          shopId: state.pathParameters['shopId']!,
        ),
      ),

      // 고객 라우트
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/customer/home',
            builder: (context, state) =>
                const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/order/:orderId',
            builder: (context, state) => OrderDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
          GoRoute(
            path: '/customer/order-history',
            builder: (context, state) =>
                const OrderHistoryScreen(),
          ),
          GoRoute(
            path: '/customer/shop-search',
            builder: (context, state) =>
                const ShopSearchScreen(),
          ),
          GoRoute(
            path: '/customer/shop/:shopId',
            builder: (context, state) => ShopDetailScreen(
              shopId: state.pathParameters['shopId']!,
            ),
          ),
          GoRoute(
            path: '/customer/shop/:shopId/posts/:category',
            builder: (context, state) {
              final category =
                  state.pathParameters['category']!;
              final label =
                  PostCategory.fromJson(category).label;
              return PostListScreen(
                shopId: state.pathParameters['shopId']!,
                category: category,
                categoryLabel: label,
              );
            },
          ),
          GoRoute(
            path: '/customer/shop/:shopId/post/:postId',
            builder: (context, state) => PostDetailScreen(
              shopId: state.pathParameters['shopId']!,
              postId: state.pathParameters['postId']!,
            ),
          ),
          GoRoute(
            path: '/customer/notifications',
            builder: (context, state) =>
                const NotificationsScreen(),
          ),
          GoRoute(
            path: '/customer/mypage',
            builder: (context, state) =>
                const MypageScreen(),
          ),
          GoRoute(
            path: '/customer/profile-edit',
            builder: (context, state) =>
                const ProfileEditScreen(),
          ),
        ],
      ),

      // 관리자 라우트
      GoRoute(
        path: '/admin/shop-requests',
        builder: (context, state) =>
            const ShopRequestsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                ShopRequestDetailScreen(
              shopId:
                  state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // 사장님 라우트 (하단 네비게이션 바 공유)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            OwnerShellScreen(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/owner/dashboard',
              builder: (context, state) =>
                  const OwnerDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'order-create',
                  builder: (context, state) =>
                      OrderCreateScreen(
                    shopId: state.uri
                            .queryParameters['shopId'] ??
                        '',
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/owner/order-manage',
              builder: (context, state) => OrderManageScreen(
                shopId: state.uri
                    .queryParameters['shopId'],
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/owner/settings',
              builder: (context, state) =>
                  const ShopSettingsScreen(),
              routes: [
                GoRoute(
                  path: 'inventory',
                  builder: (context, state) =>
                      const InventoryScreen(),
                ),
                GoRoute(
                  path: 'post-manage',
                  builder: (context, state) {
                    final shopId = state.uri
                            .queryParameters['shopId'] ??
                        '';
                    return PostManageScreen(
                        shopId: shopId);
                  },
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        final shopId = state.uri
                                .queryParameters[
                            'shopId'] ??
                            '';
                        return PostCreateScreen(
                            shopId: shopId);
                      },
                    ),
                    GoRoute(
                      path: 'edit/:postId',
                      builder: (context, state) {
                        final shopId = state.uri
                                .queryParameters[
                            'shopId'] ??
                            '';
                        return PostCreateScreen(
                          shopId: shopId,
                          postId: state
                              .pathParameters['postId'],
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'shop-qr',
                  builder: (context, state) =>
                      ShopQrScreen(
                    shop: state.extra! as Shop,
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
