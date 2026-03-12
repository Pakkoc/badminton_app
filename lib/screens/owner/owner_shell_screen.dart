import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 사장님 화면의 공통 하단 네비게이션 바를 제공하는 셸.
///
/// Pencil 디자인 기준: 3탭 (대시보드/작업관리/설정),
/// BottomNavigationBar, height 80, top border 1px.
class OwnerShellScreen extends StatelessWidget {
  const OwnerShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.activeTab,
        unselectedItemColor: AppTheme.textTertiary,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation:
                index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: '작업관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
