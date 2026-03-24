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
            : const Text(
                '커뮤니티',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (_, index) =>
                  _PostCard(post: posts[index]),
            ),
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/create'),
        tooltip: '글쓰기',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/community/${post.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.cardBorder,
            width: 0.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.onCardPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        post.authorName ?? '알 수 없음',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onCardSecondary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.relativeTime(post.createdAt),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.onCardTertiary,
                                ),
                      ),
                      const Spacer(),
                      if (post.commentCount > 0) ...[
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: AppTheme.onCardTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.commentCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onCardSecondary,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (post.likeCount > 0) ...[
                        const Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: AppTheme.onCardTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.likeCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onCardSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.images.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, stack) => const SizedBox(
                    width: 60,
                    height: 60,
                    child: Icon(Icons.image, color: AppTheme.onCardTertiary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
