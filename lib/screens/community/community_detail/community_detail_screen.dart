import 'package:badminton_app/app/theme.dart';
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
  String? _replyToParentId;
  String? _replyToName;
  String? _mentionName;

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
    var content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (_mentionName != null) {
      content = '@$_mentionName $content';
    }

    final commentRepo = ref.read(communityCommentRepositoryProvider);
    final parentId = _replyToId != null
        ? commentRepo.resolveParentId(
            targetCommentId: _replyToId!,
            targetCommentParentId: _replyToParentId,
          )
        : null;

    try {
      await commentRepo.create(
        postId: widget.postId,
        authorId: _currentUserId,
        content: content,
        parentId: parentId,
      );
      _commentController.clear();
      setState(() {
        _replyToId = null;
        _replyToParentId = null;
        _replyToName = null;
        _mentionName = null;
      });
      ref.invalidate(communityCommentsProvider(widget.postId));
      ref.invalidate(communityPostDetailProvider(widget.postId));
    } catch (e) {
      if (mounted) AppToast.error(context, '댓글 등록에 실패했습니다');
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: '게시글 삭제',
      content: '정말 삭제하시겠습니까?',
      onConfirm: () {},
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(communityPostRepositoryProvider);
      await repo.delete(widget.postId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) AppToast.error(context, '게시글 삭제에 실패했습니다');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: '댓글 삭제',
      content: '정말 삭제하시겠습니까?',
      onConfirm: () {},
    );
    if (confirmed != true) return;

    try {
      final commentRepo = ref.read(communityCommentRepositoryProvider);
      await commentRepo.delete(commentId);
      ref.invalidate(communityCommentsProvider(widget.postId));
      ref.invalidate(communityPostDetailProvider(widget.postId));
    } catch (e) {
      if (mounted) AppToast.error(context, '댓글 삭제에 실패했습니다');
    }
  }

  Future<void> _reportPost() async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    try {
      final reportRepo = ref.read(communityReportRepositoryProvider);
      await reportRepo.reportPost(
        reporterId: _currentUserId,
        postId: widget.postId,
        reason: reason,
      );
      if (mounted) AppToast.success(context, '신고가 접수되었습니다');
    } catch (e) {
      if (mounted) AppToast.error(context, '신고 접수에 실패했습니다');
    }
  }

  Future<void> _reportComment(String commentId) async {
    final reason = await _showReportDialog();
    if (reason == null) return;

    try {
      final reportRepo = ref.read(communityReportRepositoryProvider);
      await reportRepo.reportComment(
        reporterId: _currentUserId,
        commentId: commentId,
        reason: reason,
      );
      if (mounted) AppToast.success(context, '신고가 접수되었습니다');
    } catch (e) {
      if (mounted) AppToast.error(context, '신고 접수에 실패했습니다');
    }
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
                                ?.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
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
                          postAuthorId: post.authorId,
                          onReply: (
                            commentId,
                            parentCommentId,
                            replyToName,
                            mentionName,
                          ) {
                            setState(() {
                              _replyToId = commentId;
                              _replyToParentId = parentCommentId;
                              _replyToName = replyToName;
                              _mentionName = mentionName;
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
                              '@$_replyToName 에게 답글 중',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _replyToId = null;
                                _replyToParentId = null;
                                _replyToName = null;
                                _mentionName = null;
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
                              decoration: InputDecoration(
                                hintText: _replyToName != null
                                    ? '답글을 입력하세요'
                                    : '댓글을 입력하세요',
                                border: const OutlineInputBorder(),
                                contentPadding:
                                    const EdgeInsets.symmetric(
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

// ── _CommentSection ────────────────────────────────────────────────

class _CommentSection extends StatefulWidget {
  const _CommentSection({
    required this.comments,
    required this.currentUserId,
    required this.postAuthorId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final List<CommunityComment> comments;
  final String currentUserId;
  final String postAuthorId;

  /// (commentId, parentCommentId, replyToName, mentionName)
  ///
  /// - commentId: 답글 대상 댓글 ID
  /// - parentCommentId: 댓글의 parent_id (대댓글이면 루트 ID, 1단이면 null)
  /// - replyToName: 답글 입력 바에 표시할 닉네임
  /// - mentionName: 전송 시 내용 앞에 @멘션으로 삽입할 닉네임
  ///   (대댓글에 답글을 달 때만 non-null)
  final void Function(
    String commentId,
    String? parentCommentId,
    String replyToName,
    String? mentionName,
  ) onReply;

  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final void Function(String id) onToggleLike;

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  /// 댓글 ID별 대댓글 펼침 상태. 기본 접힘(false).
  final Map<String, bool> _expanded = {};

  bool _isExpanded(String commentId) => _expanded[commentId] ?? false;

  void _toggle(String commentId) {
    setState(() {
      _expanded[commentId] = !_isExpanded(commentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topLevel = widget.comments
        .where((c) => c.parentId == null)
        .toList();

    return Column(
      children: List.generate(topLevel.length, (index) {
        final comment = topLevel[index];
        final replies = widget.comments
            .where((c) => c.parentId == comment.id)
            .toList();
        final hasReplies = replies.isNotEmpty;
        final expanded = _isExpanded(comment.id);
        final isLast = index == topLevel.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CommentRow(
              comment: comment,
              isAuthor: comment.authorId == widget.currentUserId,
              isPostAuthor:
                  comment.authorId == widget.postAuthorId,
              hasRepliesBelow: hasReplies,
              onReply: () => widget.onReply(
                comment.id,
                null,
                comment.authorName ?? '알 수 없음',
                null,
              ),
              onDelete: () => widget.onDelete(comment.id),
              onReport: () => widget.onReport(comment.id),
              onToggleLike: () => widget.onToggleLike(comment.id),
            ),
            if (hasReplies)
              _ThreadSection(
                replies: replies,
                expanded: expanded,
                onToggle: () => _toggle(comment.id),
                isLastTopLevel: isLast,
                currentUserId: widget.currentUserId,
                postAuthorId: widget.postAuthorId,
                onReply: widget.onReply,
                onDelete: widget.onDelete,
                onReport: widget.onReport,
                onToggleLike: widget.onToggleLike,
              ),
          ],
        );
      }),
    );
  }
}

// ── _CommentRow ────────────────────────────────────────────────────

/// 1단 댓글 행. 댓글들은 서로 독립적이며 연결선 없이 표시된다.
///
/// 대댓글이 있을 때는 [_ThreadSection]이 아래에 이어지며,
/// 대댓글 내부 연결선(종류 2)은 [_ThreadSection] / [_ReplyRow]에서 처리한다.
class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.isAuthor,
    required this.isPostAuthor,
    required this.hasRepliesBelow,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final CommunityComment comment;
  final bool isAuthor;
  final bool isPostAuthor;

  /// 이 댓글 아래 대댓글 섹션이 이어지는지
  final bool hasRepliesBelow;

  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onToggleLike;

  static const _avatarRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = comment.authorName ?? '알 수 없음';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타
          CircleAvatar(
            radius: _avatarRadius,
            backgroundImage:
                comment.authorProfileImageUrl != null
                    ? NetworkImage(
                        comment.authorProfileImageUrl!)
                    : null,
            child: comment.authorProfileImageUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontSize: _avatarRadius * 0.8,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // 내용 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 + 배지 + 시간 + 더보기
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (isPostAuthor) ...[
                      const SizedBox(width: 4),
                      Text(
                        '· 작성자',
                        style:
                            theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Text(
                      '· ${Formatters.relativeTime(comment.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                        if (value == 'report') onReport();
                      },
                      itemBuilder: (_) => [
                        if (isAuthor)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        if (!isAuthor)
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('신고'),
                          ),
                      ],
                      icon: const Icon(Icons.more_vert, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 내용 (@멘션 파란색 처리)
                _CommentContent(content: comment.content),
                const SizedBox(height: 4),
                // 좋아요 + 답글
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleLike,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        '답글',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _ThreadSection ─────────────────────────────────────────────────

/// 1단 댓글에 달린 대댓글 영역 (종류 2 연결선).
///
/// 부모 아바타 열에 세로선을 이어 내리고, 각 대댓글 아바타까지
/// 둥근 꺾임(└ 모양)으로 연결한다.
/// - 세로선: 부모 아바타 아래에서 마지막 대댓글까지
/// - 꺾임: 각 대댓글 아바타 높이에서 세로→가로로 연결
/// - 마지막 대댓글에서 세로선이 끊김
class _ThreadSection extends StatelessWidget {
  const _ThreadSection({
    required this.replies,
    required this.expanded,
    required this.onToggle,
    required this.isLastTopLevel,
    required this.currentUserId,
    required this.postAuthorId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final List<CommunityComment> replies;
  final bool expanded;
  final VoidCallback onToggle;

  /// 이 스레드가 마지막 1단 댓글 아래에 있는지
  final bool isLastTopLevel;

  final String currentUserId;
  final String postAuthorId;
  final void Function(
    String commentId,
    String? parentCommentId,
    String replyToName,
    String? mentionName,
  ) onReply;
  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final void Function(String id) onToggleLike;

  /// 부모 아바타 직경 (=1단 댓글 아바타 diameter)
  static const _parentAvatarDiameter = 40.0;
  static const _lineColor = AppTheme.border;
  static const _lineWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 부모 아바타 열: 세로 연결선 계속
          SizedBox(
            width: _parentAvatarDiameter,
            child: Center(
              child: Container(
                width: _lineWidth,
                height: double.infinity,
                color: _lineColor,
              ),
            ),
          ),
          // 버튼 + 대댓글 목록
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 답글 접기/펼치기 버튼
                TextButton.icon(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppTheme.primary,
                  ),
                  icon: Icon(
                    expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                  ),
                  label: Text(
                    expanded
                        ? '답글 숨기기'
                        : '답글 ${replies.length}개 더보기',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppTheme.primary),
                  ),
                ),
                // 펼쳤을 때 대댓글 목록
                if (expanded)
                  ...List.generate(replies.length, (index) {
                    final reply = replies[index];
                    final isLastReply = index == replies.length - 1;
                    return _ReplyRow(
                      comment: reply,
                      isAuthor: reply.authorId == currentUserId,
                      isPostAuthor: reply.authorId == postAuthorId,
                      isLastReply: isLastReply,
                      onReply: () => onReply(
                        reply.id,
                        reply.parentId,
                        reply.authorName ?? '알 수 없음',
                        reply.authorName,
                      ),
                      onDelete: () => onDelete(reply.id),
                      onReport: () => onReport(reply.id),
                      onToggleLike: () => onToggleLike(reply.id),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _ReplyRow ──────────────────────────────────────────────────────

/// 대댓글 행. 좌측에 종류 2 연결선(둥근 꺾임)을 표시한다.
///
/// 마지막 대댓글 왼쪽에는 └ 모양 연결선을 그리고,
/// 중간 대댓글은 ├ 모양(세로선 + 가로선)으로 연결한다.
///
/// 꺾임은 [BoxDecoration.border] + [BorderRadius]로 구현한다:
/// - 중간: 왼쪽 + 아래쪽 border → 꺾임
/// - 마지막: 왼쪽 + 아래쪽 border + bottomLeft radius → └ 모양
class _ReplyRow extends StatelessWidget {
  const _ReplyRow({
    required this.comment,
    required this.isAuthor,
    required this.isPostAuthor,
    required this.isLastReply,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleLike,
  });

  final CommunityComment comment;
  final bool isAuthor;
  final bool isPostAuthor;

  /// 마지막 대댓글이면 └ 모양, 아니면 ├ 모양
  final bool isLastReply;

  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onToggleLike;

  static const _avatarRadius = 16.0;
  static const _lineColor = AppTheme.border;
  static const _lineWidth = 1.5;

  /// 세로선 + 꺾임 영역 너비 (아바타 중심까지)
  static const _threadWidth = 20.0;

  /// 꺾임 후 가로선 길이
  static const _horizontalLineWidth = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = comment.authorName ?? '알 수 없음';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 종류 2 연결선: 세로 + 둥근 꺾임
            SizedBox(
              width: _threadWidth,
              child: _ReplyThreadLine(isLastReply: isLastReply),
            ),
            // 가로선 (아바타까지 연결)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: _avatarRadius + 8, // 아바타 중심 높이
                ),
                child: Container(
                  width: _horizontalLineWidth,
                  height: _lineWidth,
                  color: _lineColor,
                ),
              ),
            ),
            // 대댓글 아바타
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CircleAvatar(
                  radius: _avatarRadius,
                  backgroundImage:
                      comment.authorProfileImageUrl != null
                          ? NetworkImage(comment.authorProfileImageUrl!)
                          : null,
                  child: comment.authorProfileImageUrl == null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: _avatarRadius * 0.8,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 내용 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임 + 배지 + 시간 + 더보기
                  Row(
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (isPostAuthor) ...[
                        const SizedBox(width: 4),
                        Text(
                          '· 작성자',
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Text(
                        '· ${Formatters.relativeTime(comment.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'delete') onDelete();
                          if (value == 'report') onReport();
                        },
                        itemBuilder: (_) => [
                          if (isAuthor)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          if (!isAuthor)
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('신고'),
                            ),
                        ],
                        icon: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 내용
                  _CommentContent(content: comment.content),
                  const SizedBox(height: 4),
                  // 좋아요 + 답글
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onToggleLike,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.thumb_up_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likeCount}',
                              style:
                                  theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          '답글',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ReplyThreadLine ───────────────────────────────────────────────

/// 대댓글 좌측 연결선 위젯.
///
/// [CustomPaint]로 세로선 + 둥근 꺾임 호(arc)를 그린다.
/// - 중간 대댓글: 세로선 전체 + 꺾임 호 + 가로선 시작 (─┤ 형태)
/// - 마지막 대댓글: 세로선 절반까지 + 꺾임 호 (└ 형태)
class _ReplyThreadLine extends StatelessWidget {
  const _ReplyThreadLine({required this.isLastReply});

  final bool isLastReply;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ReplyThreadPainter(isLastReply: isLastReply),
      child: const SizedBox.expand(),
    );
  }
}

class _ReplyThreadPainter extends CustomPainter {
  const _ReplyThreadPainter({required this.isLastReply});

  final bool isLastReply;

  static const _lineColor = AppTheme.border;
  static const _lineWidth = 1.5;
  static const _cornerRadius = 10.0;

  /// 아바타 중심 Y 위치 (padding 8 + radius 16)
  static const _avatarCenterY = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lineX = size.width / 2;
    const cornerY = _avatarCenterY - _cornerRadius;

    if (isLastReply) {
      // 세로선: 위에서 꺾임 시작점까지
      canvas.drawLine(
        Offset(lineX, 0),
        Offset(lineX, cornerY),
        paint,
      );
      // 둥근 꺾임 호: 세로→가로 (좌하→우)
      // 호는 (lineX, cornerY)에서 시작해서 (lineX + radius, avatarCenterY)로 끝남
      final arcRect = Rect.fromLTWH(
        lineX,
        cornerY,
        _cornerRadius * 2,
        _cornerRadius * 2,
      );
      // 180도(pi)에서 시작해서 90도(pi/2) 만큼 — 좌→아래 호
      canvas.drawArc(arcRect, _pi, _halfPi, false, paint);
    } else {
      // 세로선: 위에서 아래 끝까지 (다음 대댓글로 이어짐)
      canvas.drawLine(
        Offset(lineX, 0),
        Offset(lineX, size.height),
        paint,
      );
      // 꺾임 호
      final arcRect = Rect.fromLTWH(
        lineX,
        cornerY,
        _cornerRadius * 2,
        _cornerRadius * 2,
      );
      canvas.drawArc(arcRect, _pi, _halfPi, false, paint);
    }
  }

  static const _pi = 3.141592653589793;
  static const _halfPi = 1.5707963267948966;

  @override
  bool shouldRepaint(_ReplyThreadPainter oldDelegate) =>
      oldDelegate.isLastReply != isLastReply;
}

// ── _CommentTile (레거시 — 내부 호환용) ───────────────────────────
// _CommentRow / _ReplyRow로 교체됨. 삭제.

// ── _CommentContent ────────────────────────────────────────────────

/// 댓글 내용을 렌더링한다.
///
/// 내용이 @로 시작하면 첫 공백까지를 Primary 색상 Bold로 표시하고,
/// 나머지는 일반 스타일로 표시한다.
class _CommentContent extends StatelessWidget {
  const _CommentContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium;

    if (!content.startsWith('@')) {
      return Text(content, style: base);
    }

    final spaceIdx = content.indexOf(' ');
    if (spaceIdx == -1) {
      // 전체가 멘션
      return Text.rich(
        TextSpan(
          text: content,
          style: base?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final mention = content.substring(0, spaceIdx);
    final rest = content.substring(spaceIdx);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: mention,
            style: base?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: rest, style: base),
        ],
      ),
    );
  }
}
