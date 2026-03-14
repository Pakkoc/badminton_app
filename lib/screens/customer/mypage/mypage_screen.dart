import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/court_background.dart';
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
  bool? _notifyShop;
  bool? _notifyCommunity;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 4,
      ),
      body: CourtBackground(
        child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('로그인이 필요합니다'),
            );
          }
          // 최초 로딩 시 User 모델의 값을 초기값으로 설정한다
          _notifyShop ??= user.notifyShop;
          _notifyCommunity ??= user.notifyCommunity;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 16,
            ),
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
                notifyShop: _notifyShop!,
                notifyCommunity: _notifyCommunity!,
                onNotifyShopChanged: (v) =>
                    _onNotifyShopChanged(user.id, v),
                onNotifyCommunityChanged: (v) =>
                    _onNotifyCommunityChanged(user.id, v),
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
      ),
    );
  }

  String? _resolveEmail(String? email) {
    if (email == null) return null;
    if (email.contains('placeholder')) return null;
    return email;
  }

  Future<void> _onNotifyShopChanged(
    String userId,
    bool value,
  ) async {
    setState(() => _notifyShop = value);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateNotifyShop(userId, value: value);
    } catch (_) {
      // 저장 실패 시 롤백
      if (mounted) setState(() => _notifyShop = !value);
    }
  }

  Future<void> _onNotifyCommunityChanged(
    String userId,
    bool value,
  ) async {
    setState(() => _notifyCommunity = value);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateNotifyCommunity(userId, value: value);
    } catch (_) {
      // 저장 실패 시 롤백
      if (mounted) setState(() => _notifyCommunity = !value);
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
        color: AppTheme.surfaceHigh,
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
              color: AppTheme.accent,
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
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Text(
                '프로필 수정',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.info,
                ),
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
    required this.notifyShop,
    required this.notifyCommunity,
    required this.onNotifyShopChanged,
    required this.onNotifyCommunityChanged,
    required this.phone,
  });

  final bool notifyShop;
  final bool notifyCommunity;
  final ValueChanged<bool> onNotifyShopChanged;
  final ValueChanged<bool> onNotifyCommunityChanged;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
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
            '알림 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          _NotifyToggleRow(
            label: '샵 알림',
            description: '주문 상태, 작업 완료, 접수 등',
            value: notifyShop,
            onChanged: onNotifyShopChanged,
          ),
          const Divider(height: 1, color: AppTheme.border),
          _NotifyToggleRow(
            label: '커뮤니티 알림',
            description: '댓글, 답글, 신고 등',
            value: notifyCommunity,
            onChanged: onNotifyCommunityChanged,
          ),
          const Divider(height: 1, color: AppTheme.border),
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

class _NotifyToggleRow extends StatelessWidget {
  const _NotifyToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.accent,
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
          color: AppTheme.surfaceHigh,
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
                color: const Color(0xFF5B2020),
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
              color: AppTheme.textTertiary,
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
        color: AppTheme.surfaceHigh,
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
                            : AppTheme.accent,
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
        color: AppTheme.surfaceHigh,
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
          color: AppTheme.surfaceHigh,
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
