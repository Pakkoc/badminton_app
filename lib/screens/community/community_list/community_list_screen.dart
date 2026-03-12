import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/providers/community_provider.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommunityListScreen extends ConsumerStatefulWidget {
  const CommunityListScreen({super.key});

  @override
  ConsumerState<CommunityListScreen> createState() =>
      _CommunityListScreenState();
}

class _CommunityListScreenState extends ConsumerState<CommunityListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = _isSearching && _searchController.text.isNotEmpty
        ? ref.watch(communitySearchProvider(_searchController.text))
        : ref.watch(communityPostListProvider);

    return Scaffold(
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => setState(() {}),
              )
            : const Text('커뮤니티'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: CourtBackground(
        child: postsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(communityPostListProvider),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(
              icon: Icons.article_outlined,
              message: '게시글이 없습니다',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityPostListProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1),
              itemBuilder: (_, index) =>
                  _PostListTile(post: posts[index]),
            ),
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/create'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _PostListTile extends StatelessWidget {
  const _PostListTile({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Text(
              post.authorName ?? '알 수 없음',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Text(
              Formatters.relativeTime(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
            const Spacer(),
            if (post.commentCount > 0) ...[
              const Icon(Icons.chat_bubble_outline, size: 14),
              const SizedBox(width: 2),
              Text(
                '${post.commentCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
            ],
            if (post.likeCount > 0) ...[
              const Icon(Icons.favorite_border, size: 14),
              const SizedBox(width: 2),
              Text(
                '${post.likeCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      trailing: post.images.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(Icons.image, color: AppTheme.textTertiary),
                ),
              ),
            )
          : null,
      onTap: () => context.push('/community/${post.id}'),
    );
  }
}
