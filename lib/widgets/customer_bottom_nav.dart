import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 고객 플로우 공통 하단 네비게이션 바.
///
/// 4개 탭: 홈, 샵검색, 이력, MY.
/// [currentIndex]로 현재 활성 탭을 지정한다.
class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _routes = [
    '/customer/home',
    '/customer/shop-search',
    '/customer/order-history',
    '/customer/mypage',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != currentIndex) {
          context.go(_routes[index]);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.search),
          label: '샵검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          activeIcon: Icon(Icons.history),
          label: '이력',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'MY',
        ),
      ],
    );
  }
}
