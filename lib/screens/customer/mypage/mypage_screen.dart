import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/services/fcm_service.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  bool _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 3,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('로그인이 필요합니다'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileCard(
                name: user.name,
                email: _resolveEmail(
                  ref
                      .read(supabaseProvider)
                      .auth
                      .currentUser
                      ?.email,
                ),
                onEditTap: () =>
                    context.push('/customer/profile-edit'),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                pushEnabled: _pushEnabled,
                onPushChanged: _onPushChanged,
                phone: Formatters.phone(user.phone),
              ),
              const SizedBox(height: 16),
              _ShopModeCard(ref: ref),
              if (user.role == UserRole.admin) ...[
                const SizedBox(height: 16),
                _AdminMenuCard(
                  onTap: () =>
                      context.push('/admin/shop-requests'),
                ),
              ],
              const SizedBox(height: 16),
              const _AppInfoCard(),
              const SizedBox(height: 16),
              _LogoutButton(
                onTap: () => _onLogoutTap(context),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, st) => const Center(
          child: Text('오류가 발생했습니다'),
        ),
      ),
    );
  }

  String? _resolveEmail(String? email) {
    if (email == null) return null;
    if (email.contains('placeholder')) return null;
    return email;
  }

  void _onPushChanged(bool value) {
    setState(() => _pushEnabled = value);
    if (value) {
      FcmService().initialize();
    }
  }

  void _onLogoutTap(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: '로그아웃',
      content: '로그아웃 하시겠습니까?',
      onConfirm: () async {
        await ref.read(authRepositoryProvider).signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.onEditTap,
    this.email,
  });

  final String name;
  final String? email;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              size: 28,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onEditTap,
            child: const Text(
              '프로필 수정',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.pushEnabled,
    required this.onPushChanged,
    required this.phone,
  });

  final bool pushEnabled;
  final ValueChanged<bool> onPushChanged;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '푸시 알림',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Switch(
                  value: pushEnabled,
                  onChanged: onPushChanged,
                  activeTrackColor: AppTheme.primary,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: AppTheme.border,
          ),
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '연락처',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  const _AdminMenuCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '관리자 페이지',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopModeCard extends StatelessWidget {
  const _ShopModeCard({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(shopStatusProvider);
    final shopAsync = ref.watch(myShopProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: statusAsync.when(
        data: (status) {
          final shop = shopAsync.valueOrNull;
          final config = _shopMenuConfig(status);
          final isRejected =
              status == ShopStatus.rejected;
          final isPending =
              status == ShopStatus.pending;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(
              context,
              status,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Icon(
                        config.icon,
                        color: isRejected
                            ? AppTheme.error
                            : AppTheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          config.label,
                          style: TextStyle(
                            fontSize: 15,
                            color: isRejected
                                ? AppTheme.error
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!isPending)
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textTertiary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                if (isRejected &&
                    shop?.rejectReason != null) ...[
                  const Divider(
                    height: 1,
                    color: AppTheme.border,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 34,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '사유: ${shop!.rejectReason}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  void _onTap(BuildContext context, ShopStatus? status) {
    switch (status) {
      case null:
      case ShopStatus.rejected:
        context.push('/shop-register');
      case ShopStatus.approved:
        ref.read(activeModeProvider.notifier).state =
            AppMode.owner;
        context.go('/owner/dashboard');
      case ShopStatus.pending:
        AppToast.success(
          context,
          '샵 등록 승인 대기 중입니다',
        );
    }
  }

  ({IconData icon, String label}) _shopMenuConfig(
    ShopStatus? status,
  ) =>
      switch (status) {
        null => (
          icon: Icons.storefront,
          label: '샵 등록 신청',
        ),
        ShopStatus.pending => (
          icon: Icons.hourglass_top,
          label: '매장 등록 승인 대기 중',
        ),
        ShopStatus.approved => (
          icon: Icons.swap_horiz,
          label: '사장님 모드 전환',
        ),
        ShopStatus.rejected => (
          icon: Icons.error_outline,
          label: '샵 등록 거절됨 — 재신청',
        ),
      };
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '앱 버전',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.error,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
