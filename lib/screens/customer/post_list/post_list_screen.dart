import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_notifier.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({
    super.key,
    required this.shopId,
    required this.category,
    required this.categoryLabel,
  });

  final String shopId;
  final String category;
  final String categoryLabel;

  @override
  ConsumerState<PostListScreen> createState() =>
      _PostListScreenState();
}

class _PostListScreenState
    extends ConsumerState<PostListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postListNotifierProvider.notifier)
          .loadPosts(widget.shopId, widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryLabel),
      ),
      body: CourtBackground(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PostListState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () {
          ref
              .read(postListNotifierProvider.notifier)
              .loadPosts(widget.shopId, widget.category);
        },
      );
    }

    if (state.posts.isEmpty) {
      return const EmptyState(
        icon: Icons.article_outlined,
        message: '등록된 게시글이 없습니다',
      );
    }

    return ListView.builder(
      itemCount: state.posts.length,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 12,
      ),
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < state.posts.length - 1
                ? 12
                : 0,
          ),
          child: _PostCard(
            post: post,
            onTap: () {
              context.push(
                '/customer/shop/${widget.shopId}'
                '/post/${post.id}',
              );
            },
          ),
        );
      },
    );
  }
}

/// 게시글 카드 — cornerRadius 20.
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onTap,
  });

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0x20FFFFFF),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryBadge(
                    category: post.category,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.date(post.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                  const Spacer(),
                  if (post.images.isNotEmpty)
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppTheme.textTertiary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 카테고리 뱃지 — pill 형태.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final PostCategory category;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (category) {
      PostCategory.notice => (
        AppTheme.completedBackground,
        AppTheme.completedText,
      ),
      PostCategory.event => (
        AppTheme.receivedBackground,
        AppTheme.receivedText,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
