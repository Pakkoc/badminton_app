import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/screens/owner/post_manage/post_manage_notifier.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 사장님 게시글 관리 화면.
///
/// 샵의 공지사항/이벤트 게시글을 조회, 필터링, 삭제한다.
class PostManageScreen extends ConsumerStatefulWidget {
  const PostManageScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<PostManageScreen> createState() => _PostManageScreenState();
}

class _PostManageScreenState extends ConsumerState<PostManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postManageNotifierProvider.notifier)
          .loadPosts(widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postManageNotifierProvider);
    final notifier = ref.read(postManageNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('게시글 관리')),
      body: Column(
        children: [
          _CategoryTabs(
            selected: state.selectedCategory,
            onChanged: (cat) =>
                notifier.filterByCategory(widget.shopId, cat),
          ),
          Expanded(
            child: state.isLoading
                ? const LoadingIndicator()
                : state.posts.isEmpty
                    ? const EmptyState(
                        icon: Icons.article_outlined,
                        message: '등록된 게시글이 없습니다',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.posts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return _PostCard(
                            post: post,
                            onEdit: () => _onEditPost(post.id),
                            onDelete: () => _confirmDelete(post.id),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        backgroundColor: const Color(0xFFFB923C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _onCreatePost() async {
    final result = await context.push<bool>(
      '/owner/settings/post-manage/create'
      '?shopId=${widget.shopId}',
    );
    if (result == true && mounted) {
      ref
          .read(postManageNotifierProvider.notifier)
          .loadPosts(widget.shopId);
    }
  }

  Future<void> _onEditPost(String postId) async {
    final result = await context.push<bool>(
      '/owner/settings/post-manage/edit/$postId'
      '?shopId=${widget.shopId}',
    );
    if (result == true && mounted) {
      ref
          .read(postManageNotifierProvider.notifier)
          .loadPosts(widget.shopId);
    }
  }

  Future<void> _confirmDelete(String postId) async {
    bool deleted = false;
    await showConfirmDialog(
      context: context,
      title: '게시글 삭제',
      content: '정말 삭제하시겠습니까?',
      onConfirm: () {
        deleted = true;
      },
    );
    if (deleted && mounted) {
      final notifier = ref.read(postManageNotifierProvider.notifier);
      final success = await notifier.deletePost(widget.shopId, postId);
      if (success && mounted) {
        AppToast.success(context, '게시글이 삭제되었습니다');
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 카테고리 탭
// ---------------------------------------------------------------------------

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.selected,
    required this.onChanged,
  });

  final PostCategory? selected;
  final ValueChanged<PostCategory?> onChanged;

  static const _tabs = <(String, PostCategory?)>[
    ('전체', null),
    ('공지사항', PostCategory.notice),
    ('이벤트', PostCategory.event),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final (label, category) = tab;
          final isActive = selected == category;
          return Expanded(
            child: _TabItem(
              label: label,
              isActive: isActive,
              onTap: () => onChanged(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF22C55E);
    const activeTextColor = Color(0xFF1E293B);
    const inactiveTextColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 게시글 카드
// ---------------------------------------------------------------------------

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  final Post post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            category: post.category,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.date(post.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final PostCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CategoryBadge(category: category),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: const Icon(
            Icons.edit,
            size: 22,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(
            Icons.delete_outline,
            size: 22,
            color: Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final PostCategory category;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (category) {
      PostCategory.notice => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          '공지사항',
        ),
      PostCategory.event => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          '이벤트',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
