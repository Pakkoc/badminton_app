import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/screens/admin/shop_request_detail/shop_request_detail_notifier.dart';
import 'package:badminton_app/screens/admin/shop_request_detail/shop_request_detail_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopRequestDetailScreen
    extends ConsumerStatefulWidget {
  const ShopRequestDetailScreen({
    super.key,
    required this.shopId,
  });

  final String shopId;

  @override
  ConsumerState<ShopRequestDetailScreen> createState() =>
      _ShopRequestDetailScreenState();
}

class _ShopRequestDetailScreenState
    extends ConsumerState<ShopRequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(shopRequestDetailNotifierProvider.notifier)
          .loadDetail(widget.shopId);
    });
  }

  Future<void> _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('승인 확인'),
        content: const Text('이 샵 등록 요청을 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true),
            child: const Text('승인'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(shopRequestDetailNotifierProvider.notifier)
        .approve();

    if (success && mounted) {
      AppToast.success(context, '승인이 완료되었습니다');
      context.pop(true);
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거절 사유'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '거절 사유를 입력하세요',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '거절 사유를 입력해주세요';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(
                  reasonController.text.trim(),
                );
              }
            },
            child: const Text('거절'),
          ),
        ],
      ),
    );

    reasonController.dispose();

    if (reason == null || !mounted) return;

    final success = await ref
        .read(shopRequestDetailNotifierProvider.notifier)
        .reject(reason);

    if (success && mounted) {
      AppToast.success(context, '거절이 완료되었습니다');
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(shopRequestDetailNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('등록 요청 상세'),
      ),
      body: CourtBackground(child: _buildBody(state)),
      bottomNavigationBar: state.shop != null
          ? _BottomActions(
              isProcessing: state.isProcessing,
              onApprove: _handleApprove,
              onReject: _handleReject,
            )
          : null,
    );
  }

  Widget _buildBody(ShopRequestDetailState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.shop == null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(
              shopRequestDetailNotifierProvider.notifier,
            )
            .loadDetail(widget.shopId),
      );
    }

    final shop = state.shop;
    if (shop == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: '샵 정보',
            children: [
              _InfoRow(label: '이름', value: shop.name),
              _InfoRow(label: '주소', value: shop.address),
              _InfoRow(
                label: '연락처',
                value: Formatters.phone(shop.phone),
              ),
              if (shop.description != null &&
                  shop.description!.isNotEmpty)
                _InfoRow(
                  label: '소개글',
                  value: shop.description!,
                ),
              if (shop.businessNumber != null)
                _InfoRow(
                  label: '사업자번호',
                  value: Formatters.businessNumber(
                    shop.businessNumber!,
                  ),
                ),
              _InfoRow(
                label: '신청일',
                value: Formatters.date(shop.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.owner != null)
            _SectionCard(
              title: '사장님 정보',
              children: [
                _InfoRow(
                  label: '이름',
                  value: state.owner!.name,
                ),
                _InfoRow(
                  label: '연락처',
                  value: Formatters.phone(
                    state.owner!.phone,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isProcessing ? null : onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(
                  color: AppTheme.error,
                  width: 1.5,
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('거절'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isProcessing ? null : onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('승인'),
            ),
          ),
        ],
      ),
    );
  }
}
