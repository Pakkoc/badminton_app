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
        builder: (context, state) =>
            const _PlaceholderScreen('Profile Setup'),
      ),
      GoRoute(
        path: '/shop-register',
        builder: (context, state) =>
            const _PlaceholderScreen('Shop Register'),
      ),

      // 고객 라우트
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/customer/home',
            builder: (context, state) =>
                const _PlaceholderScreen('Customer Home'),
          ),
          GoRoute(
            path: '/customer/order/:orderId',
            builder: (context, state) =>
                const _PlaceholderScreen('Order Detail'),
          ),
          GoRoute(
            path: '/customer/order-history',
            builder: (context, state) =>
                const _PlaceholderScreen('Order History'),
          ),
          GoRoute(
            path: '/customer/shop-search',
            builder: (context, state) =>
                const _PlaceholderScreen('Shop Search'),
          ),
          GoRoute(
            path: '/customer/shop/:shopId',
            builder: (context, state) =>
                const _PlaceholderScreen('Shop Detail'),
          ),
          GoRoute(
            path: '/customer/shop/:shopId/posts/:category',
            builder: (context, state) =>
                const _PlaceholderScreen('Post List'),
          ),
          GoRoute(
            path: '/customer/shop/:shopId/post/:postId',
            builder: (context, state) =>
                const _PlaceholderScreen('Post Detail'),
          ),
          GoRoute(
            path: '/customer/notifications',
            builder: (context, state) =>
                const _PlaceholderScreen('Notifications'),
          ),
          GoRoute(
            path: '/customer/mypage',
            builder: (context, state) =>
                const _PlaceholderScreen('My Page'),
          ),
          GoRoute(
            path: '/customer/profile-edit',
            builder: (context, state) =>
                const _PlaceholderScreen('Profile Edit'),
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
            builder: (context, state) =>
                const _PlaceholderScreen('Post Create'),
          ),
          GoRoute(
            path: '/owner/inventory',
            builder: (context, state) =>
                const _PlaceholderScreen('Inventory'),
          ),
          GoRoute(
            path: '/owner/settings',
            builder: (context, state) =>
                const _PlaceholderScreen('Shop Settings'),
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
