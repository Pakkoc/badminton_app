import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/community_comment_repository.dart';
import 'package:badminton_app/repositories/community_like_repository.dart';
import 'package:badminton_app/repositories/community_post_repository.dart';
import 'package:badminton_app/repositories/community_report_repository.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState
    extends ConsumerState<CommunityDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyToId;
  String? _replyToName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _currentUserId =>
      ref.read(supabaseProvider).auth.currentUser?.id ?? '';

  Future<void> _togglePostLike() async {
    final likeRepo = ref.read(communityLikeRepositoryProvider);
    await likeRepo.togglePostLike(_currentUserId, widget.postId);
    ref.invalidate(communityPostDetailProvider(widget.postId));
    ref.invalidate(communityPostLikeStatusProvider(
      (userId: _currentUserId, postId: widget.postId),
    ));
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final commentRepo = ref.read(communityCommentRepositoryProvider);
    await commentRepo.create(
      postId: widget.postId,
      authorId: _currentUserId,
      content: content,
      parentId: _replyToId,
    );
    _commentController.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
    ref.invalidate(communityCommentsProvider(widget.postId));
    ref.invalidate(communityPostDetailProvider(widget.postId));
  }

  Future<void> _deletePost() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: '게시글 삭제',
      content: '정말 삭제하시겠습니까?',
      onConfirm: () {},
    );
    if (confirmed != true) return;

    final repo = ref.read(communityPostRepositoryProvider);
    await repo.delete(widget.postId);
    if (mounted) context.pop();
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: '댓글 삭제',
      content: '정말 삭제하시겠습니까?',
      onConfirm: () {},
    );
    if (confirmed != true) return;

    final commentRepo = ref.read(communityCommentRepositoryProvider);
    await commentRepo.delete(commentId);
    ref.invalidate(communityCommentsProvider(widget.postId));
    ref.invalidate(communityPostDetailProvider(widget.postId));
  }

  Future<void> _reportPost() async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.reportPost(
      reporterId: _currentUserId,
      postId: widget.postId,
      reason: reason,
    );
    if (mounted) AppToast.success(context, '신고가 접수되었습니다');
  }

  Future<void> _reportComment(String commentId) async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    final reportRepo = ref.read(communityReportRepositoryProvider);
    await reportRepo.reportComment(
      reporterId: _currentUserId,
      commentId: commentId,
      reason: reason,
    );
    if (mounted) AppToast.success(context, '신고가 접수되었습니다');
  }

  Future<String?> _showReportDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신고'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '신고 사유를 입력해주세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAsync =
        ref.watch(communityPostDetailProvider(widget.postId));
    final commentsAsync =
        ref.watch(communityCommentsProvider(widget.postId));
    final likeStatusAsync = ref.watch(communityPostLikeStatusProvider(
      (userId: _currentUserId, postId: widget.postId),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('게시글')),
      body: postAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(
            communityPostDetailProvider(widget.postId),
          ),
        ),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('게시글을 찾을 수 없습니다'));
          }
          final isAuthor = post.authorId == _currentUserId;
          final isLiked = likeStatusAsync.valueOrNull ?? false;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 작성자 + 시간
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                post.authorProfileImageUrl != null
                                    ? NetworkImage(
                                        post.authorProfileImageUrl!)
                                    : null,
                            child: post.authorProfileImageUrl == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.authorName ?? '알 수 없음',
                            style:
                                Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.relativeTime(post.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push(
                                    '/community/${post.id}/edit');
                              } else if (value == 'delete') {
                                _deletePost();
                              } else if (value == 'report') {
                                _reportPost();
                              }
                            },
                            itemBuilder: (_) => [
                              if (isAuthor) ...[
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('수정'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('삭제'),
                                ),
                              ],
                              if (!isAuthor)
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Text('신고'),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 제목
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      // 내용
                      Text(
                        post.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      // 이미지
                      if (post.images.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...post.images.map(
                          (url) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // 좋아요 버튼
                      Row(
                        children: [
                          IconButton(
                            onPressed: _togglePostLike,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                          ),
                          Text('${post.likeCount}'),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}'),
                        ],
                      ),
                      const Divider(),
                      // 댓글 섹션
                      commentsAsync.when(
                        loading: () => const LoadingIndicator(),
                        error: (e, _) => Text('댓글 로딩 실패: $e'),
                        data: (comments) => _CommentSection(
                          comments: comments,
                          currentUserId: _currentUserId,
                          onReply: (id, name) {
                            setState(() {
                              _replyToId = id;
                              _replyToName = name;
                            });
                          },
                          onDelete: _deleteComment,
                          onReport: _reportComment,
                          onToggleLike: (commentId) async {
                            final likeRepo = ref.read(
                                communityLikeRepositoryProvider);
                            await likeRepo.toggleCommentLike(
                                _currentUserId, commentId);
                            ref.invalidate(
                                communityCommentsProvider(widget.postId));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 댓글 입력창
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyToName != null)
                        Row(
                          children: [
                            Text(
                              '@$_replyToName 에게 답글',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _replyToId = null;
                                _replyToName = null;
                              }),
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: '댓글을 입력하세요',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _submitComment,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection({
    required this.comments,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final List<CommunityComment> comments;
  final String currentUserId;
  final void Function(String id, String name) onReply;
  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final void Function(String id) onToggleLike;

  @override
  Widget build(BuildContext context) {
    final topLevel =
        comments.where((c) => c.parentId == null).toList();

    return Column(
      children: topLevel.map((comment) {
        final replies =
            comments.where((c) => c.parentId == comment.id).toList();
        return Column(
          children: [
            _CommentTile(
              comment: comment,
              isAuthor: comment.authorId == currentUserId,
              onReply: () =>
                  onReply(comment.id, comment.authorName ?? '알 수 없음'),
              onDelete: () => onDelete(comment.id),
              onReport: () => onReport(comment.id),
              onToggleLike: () => onToggleLike(comment.id),
            ),
            ...replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(left: 40),
                child: _CommentTile(
                  comment: reply,
                  isAuthor: reply.authorId == currentUserId,
                  onReply: () => onReply(
                      comment.id, reply.authorName ?? '알 수 없음'),
                  onDelete: () => onDelete(reply.id),
                  onReport: () => onReport(reply.id),
                  onToggleLike: () => onToggleLike(reply.id),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isAuthor,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final CommunityComment comment;
  final bool isAuthor;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.authorName ?? '알 수 없음',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.relativeTime(comment.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'report') onReport();
                },
                itemBuilder: (_) => [
                  if (isAuthor)
                    const PopupMenuItem(
                        value: 'delete', child: Text('삭제')),
                  if (!isAuthor)
                    const PopupMenuItem(
                        value: 'report', child: Text('신고')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: onToggleLike,
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${comment.likeCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onReply,
                child: Text(
                  '답글',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
