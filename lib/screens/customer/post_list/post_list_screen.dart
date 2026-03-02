import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_notifier.dart';
import 'package:badminton_app/screens/customer/post_list/post_list_state.dart';
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
      body: _buildBody(state),
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
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              Formatters.date(post.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
            trailing: post.images.isNotEmpty
                ? const Icon(
                    Icons.image_outlined,
                    color: AppTheme.textTertiary,
                  )
                : null,
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
