import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            children: [
              _ProfileSection(
                name: user.name,
                phone: Formatters.phone(user.phone),
                imageUrl: user.profileImageUrl,
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.person_outline,
                label: '프로필 편집',
                onTap: () =>
                    context.push('/customer/profile-edit'),
              ),
              _MenuItem(
                icon: Icons.history,
                label: '작업 내역',
                onTap: () =>
                    context.push('/customer/order-history'),
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: '알림 설정',
                onTap: () {},
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.logout,
                label: '로그아웃',
                textColor:
                    Theme.of(context).colorScheme.error,
                onTap: () {
                  showConfirmDialog(
                    context: context,
                    title: '로그아웃',
                    content: '로그아웃 하시겠습니까?',
                    onConfirm: () async {
                      await ref
                          .read(authRepositoryProvider)
                          .signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '앱 버전 1.0.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.name,
    required this.phone,
    this.imageUrl,
  });

  final String name;
  final String phone;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            backgroundImage: imageUrl != null
                ? CachedNetworkImageProvider(imageUrl!)
                : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: textColor != null
            ? TextStyle(color: textColor)
            : null,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
