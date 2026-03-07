import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/screens/admin/shop_requests/shop_requests_notifier.dart';
import 'package:badminton_app/screens/admin/shop_requests/shop_requests_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopRequestsScreen extends ConsumerStatefulWidget {
  const ShopRequestsScreen({super.key});

  @override
  ConsumerState<ShopRequestsScreen> createState() =>
      _ShopRequestsScreenState();
}

class _ShopRequestsScreenState
    extends ConsumerState<ShopRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(shopRequestsNotifierProvider.notifier)
          .loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopRequestsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('샵 등록 요청'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ShopRequestsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(shopRequestsNotifierProvider.notifier)
            .loadRequests(),
      );
    }

    if (state.requests.isEmpty) {
      return const EmptyState(
        icon: Icons.store_outlined,
        message: '대기 중인 요청이 없습니다',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(shopRequestsNotifierProvider.notifier)
          .loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final shop = state.requests[index];
          return _ShopRequestCard(
            name: shop.name,
            businessNumber: shop.businessNumber,
            createdAt: shop.createdAt,
            onTap: () => context.push(
              '/admin/shop-requests/${shop.id}',
            ),
          );
        },
      ),
    );
  }
}

class _ShopRequestCard extends StatelessWidget {
  const _ShopRequestCard({
    required this.name,
    required this.businessNumber,
    required this.createdAt,
    required this.onTap,
  });

  final String name;
  final String? businessNumber;
  final DateTime createdAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    if (businessNumber != null)
                      Text(
                        Formatters.businessNumber(
                          businessNumber!,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    Text(
                      '신청일: ${Formatters.date(createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
