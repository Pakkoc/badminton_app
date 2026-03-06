import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
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
      body: reportsAsync.when(
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
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final report = reports[index];
              final isPostReport = report.postId != null;
              return ListTile(
                title: Text(
                  isPostReport ? '게시글 신고' : '댓글 신고',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('사유: ${report.reason}'),
                    Text(
                      Formatters.relativeTime(report.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 삭제(제재) 버튼
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showConfirmDialog(
                          context: context,
                          title: '콘텐츠 삭제',
                          content: '해당 콘텐츠를 삭제하고 작성자에게 알림을 보냅니다.',
                          onConfirm: () {},
                        );
                        if (confirmed != true) return;

                        if (isPostReport) {
                          final postRepo =
                              ref.read(communityPostRepositoryProvider);
                          final post =
                              await postRepo.getById(report.postId!);
                          if (post != null) {
                            await postRepo.delete(report.postId!);
                            final notiRepo =
                                ref.read(notificationRepositoryProvider);
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

                        final reportRepo =
                            ref.read(communityReportRepositoryProvider);
                        await reportRepo.updateStatus(
                            report.id, ReportStatus.resolved);
                        ref.invalidate(_pendingReportsProvider);
                        if (context.mounted) {
                          AppToast.success(context, '처리되었습니다');
                        }
                      },
                    ),
                    // 기각 버튼
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        final reportRepo =
                            ref.read(communityReportRepositoryProvider);
                        await reportRepo.updateStatus(
                            report.id, ReportStatus.dismissed);
                        ref.invalidate(_pendingReportsProvider);
                        if (context.mounted) {
                          AppToast.success(context, '기각되었습니다');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
