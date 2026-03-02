import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_notifier.dart';
import 'package:badminton_app/screens/customer/post_detail/post_detail_state.dart';
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
        body: const LoadingIndicator(),
      );
    }

    if (state.error != null && state.post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글')),
        body: ErrorView(
          message: state.error!,
          onRetry: () {
            ref
                .read(postDetailNotifierProvider.notifier)
                .loadPost(widget.postId);
          },
        ),
      );
    }

    final post = state.post;
    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글')),
        body: const EmptyState(
          icon: Icons.article_outlined,
          message: '게시글을 찾을 수 없습니다',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: _PostContent(state: state),
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
      padding: const EdgeInsets.all(16),
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
                  color: Color(0xFF94A3B8),
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
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${Formatters.date(post.eventStartDate!)}'
                  ' ~ '
                  '${Formatters.date(post.eventEndDate!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF334155),
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
        const Color(0xFFDBEAFE),
        const Color(0xFF3B82F6),
      ),
      PostCategory.event => (
        const Color(0xFFFEF3C7),
        const Color(0xFFF59E0B),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: const Color(0xFFF0FDF4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: const Color(0xFFF0FDF4),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
