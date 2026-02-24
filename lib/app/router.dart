import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_screen.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _PlaceholderScreen('Splash'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const _PlaceholderScreen('Login'),
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
                const _PlaceholderScreen('Owner Dashboard'),
          ),
          GoRoute(
            path: '/owner/order-create',
            builder: (context, state) =>
                const _PlaceholderScreen('Order Create'),
          ),
          GoRoute(
            path: '/owner/order-manage',
            builder: (context, state) =>
                const _PlaceholderScreen('Order Manage'),
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
