import 'dart:async';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/auth/login/login_screen.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_screen.dart';
import 'package:badminton_app/screens/auth/splash/splash_screen.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_screen.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_screen.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_screen.dart';
import 'package:badminton_app/screens/owner/shop_qr/shop_qr_screen.dart';
import 'package:badminton_app/screens/customer/home/customer_home_screen.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_screen.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_screen.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_screen.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_screen.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_screen.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_screen.dart';
import 'package:badminton_app/screens/customer/mypage/mypage_screen.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_screen.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_screen.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_screen.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_screen.dart';
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
    redirect: (context, state) {
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
        builder: (context, state) => const ShopSignupScreen(),
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

      // 사장님 라우트
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/owner/dashboard',
            builder: (context, state) =>
                const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/owner/order-create',
            builder: (context, state) => OrderCreateScreen(
              shopId: state.uri.queryParameters['shopId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/owner/order-manage',
            builder: (context, state) => OrderManageScreen(
              shopId: state.uri.queryParameters['shopId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/owner/shop-qr',
            builder: (context, state) =>
                const _PlaceholderScreen('Shop QR'),
          ),
          GoRoute(
            path: '/owner/post-create',
            builder: (context, state) {
              final shopId =
                  state.uri.queryParameters['shopId'] ?? '';
              return PostCreateScreen(shopId: shopId);
            },
          ),
          GoRoute(
            path: '/owner/inventory',
            builder: (context, state) =>
                const InventoryScreen(),
          ),
          GoRoute(
            path: '/owner/settings',
            builder: (context, state) =>
                const ShopSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('$name Screen')),
    );
  }
}
