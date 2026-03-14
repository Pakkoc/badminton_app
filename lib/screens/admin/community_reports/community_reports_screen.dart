import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _pendingReportsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(communityReportRepositoryProvider);
  return repo.getPendingReports();
});

class CommunityReportsScreen extends ConsumerWidget {
  const CommunityReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(_pendingReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티 신고 관리')),
      body: CourtBackground(
        child: reportsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(_pendingReportsProvider),
          ),
          data: (reports) {
            if (reports.isEmpty) {
              return const EmptyState(
                icon: Icons.report_off_outlined,
                message: '대기 중인 신고가 없습니다',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = reports[index];
                final isPostReport = report.postId != null;
                return _ReportCard(
                  type: isPostReport ? '게시글 신고' : '댓글 신고',
                  reason: report.reason,
                  date: Formatters.relativeTime(report.createdAt),
                  onTap: () => _showReportActionSheet(
                    context,
                    ref,
                    report: report,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showReportActionSheet(
    BuildContext context,
    WidgetRef ref, {
    required CommunityReport report,
  }) {
    final isPostReport = report.postId != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '신고 처리',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              _InfoSection(report: report, isPostReport: isPostReport),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _dismissReport(context, ref, report);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('기각'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _resolveReport(
                          context,
                          ref,
                          report,
                          isPostReport,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('삭제 및 제재'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resolveReport(
    BuildContext context,
    WidgetRef ref,
    CommunityReport report,
    bool isPostReport,
  ) async {
    if (isPostReport) {
      final postRepo = ref.read(communityPostRepositoryProvider);
      final post = await postRepo.getById(report.postId!);
      if (post != null) {
        await postRepo.delete(report.postId!);
        final notiRepo = ref.read(notificationRepositoryProvider);
        await notiRepo.create(
          userId: post.authorId,
          type: NotificationType.communityReport,
          title: '커뮤니티 게시글 삭제',
          body: '커뮤니티 규정 위반으로 게시글이 삭제되었습니다.',
        );
      }
    } else {
      final commentRepo =
          ref.read(communityCommentRepositoryProvider);
      await commentRepo.delete(report.commentId!);
    }

    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.updateStatus(
      report.id,
      ReportStatus.resolved,
    );
    ref.invalidate(_pendingReportsProvider);
    if (context.mounted) {
      AppToast.success(context, '삭제 및 제재 처리되었습니다');
    }
  }

  Future<void> _dismissReport(
    BuildContext context,
    WidgetRef ref,
    CommunityReport report,
  ) async {
    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.updateStatus(
      report.id,
      ReportStatus.dismissed,
    );
    ref.invalidate(_pendingReportsProvider);
    if (context.mounted) {
      AppToast.success(context, '기각되었습니다');
    }
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.type,
    required this.reason,
    required this.date,
    required this.onTap,
  });

  final String type;
  final String reason;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.receivedBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '대기중',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.receivedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              type,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '사유: $reason',
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.report,
    required this.isPostReport,
  });

  final CommunityReport report;
  final bool isPostReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(theme, '유형', isPostReport ? '게시글 신고' : '댓글 신고'),
          const SizedBox(height: 8),
          _infoRow(theme, '사유', report.reason),
          const SizedBox(height: 8),
          _infoRow(
            theme,
            '신고일',
            Formatters.relativeTime(report.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}
