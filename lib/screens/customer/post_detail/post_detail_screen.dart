import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.shopId,
  });

  final String postId;
  final String shopId;

  @override
  ConsumerState<PostDetailScreen> createState() =>
      _PostDetailScreenState();
}

class _PostDetailScreenState
    extends ConsumerState<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postDetailNotifierProvider.notifier)
          .loadPost(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글')),
        body: const CourtBackground(child: LoadingIndicator()),
      );
    }

    if (state.error != null && state.post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글')),
        body: CourtBackground(
          child: ErrorView(
            message: state.error!,
            onRetry: () {
              ref
                  .read(postDetailNotifierProvider.notifier)
                  .loadPost(widget.postId);
            },
          ),
        ),
      );
    }

    final post = state.post;
    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글')),
        body: const CourtBackground(
          child: EmptyState(
            icon: Icons.article_outlined,
            message: '게시글을 찾을 수 없습니다',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      body: CourtBackground(child: _PostContent(state: state)),
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({required this.state});

  final PostDetailState state;

  @override
  Widget build(BuildContext context) {
    final post = state.post!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryBadge(category: post.category),
              const SizedBox(width: 8),
              Text(
                Formatters.date(post.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          if (post.category == PostCategory.event &&
              post.eventStartDate != null &&
              post.eventEndDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${Formatters.date(post.eventStartDate!)}'
                  ' ~ '
                  '${Formatters.date(post.eventEndDate!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Post Title — 스펙: fontSize 20, fontWeight Bold, color textPrimary
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Color(0x30FFFFFF),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textPrimary,
            ),
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 24),
            _ImageGallery(images: post.images),
          ],
        ],
      ),
    );
  }
}

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

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: images.map((url) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: const Color(0x20FFFFFF),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: const Color(0x20FFFFFF),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
