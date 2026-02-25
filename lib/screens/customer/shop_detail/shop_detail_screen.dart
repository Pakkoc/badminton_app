import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopDetailScreen extends ConsumerStatefulWidget {
  const ShopDetailScreen({
    super.key,
    required this.shopId,
  });

  final String shopId;

  @override
  ConsumerState<ShopDetailScreen> createState() =>
      _ShopDetailScreenState();
}

class _ShopDetailScreenState
    extends ConsumerState<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopDetailNotifierProvider.notifier)
          .loadShop(widget.shopId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopDetailNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('샵 상세')),
        body: const LoadingIndicator(),
      );
    }

    if (state.error != null && state.shop == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('샵 상세')),
        body: ErrorView(
          message: state.error!,
          onRetry: () {
            ref
                .read(shopDetailNotifierProvider.notifier)
                .loadShop(widget.shopId);
          },
        ),
      );
    }

    final shop = state.shop;
    if (shop == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('샵 상세')),
        body: const EmptyState(
          icon: Icons.store_outlined,
          message: '샵을 찾을 수 없습니다',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
      ),
      body: Column(
        children: [
          _ShopInfoSection(
            name: shop.name,
            address: shop.address,
            phone: Formatters.phone(shop.phone),
            description: shop.description,
            latitude: shop.latitude,
            longitude: shop.longitude,
          ),
          _MemberSection(
            isMember: state.isMember,
            isRegistering: state.isRegistering,
            onRegister: () {
              ref
                  .read(shopDetailNotifierProvider.notifier)
                  .registerMember(widget.shopId);
            },
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '공지사항'),
              Tab(text: '이벤트'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PostTab(
                  posts: state.noticePosts,
                  shopId: widget.shopId,
                  emptyMessage: '등록된 공지사항이 없습니다',
                ),
                _PostTab(
                  posts: state.eventPosts,
                  shopId: widget.shopId,
                  emptyMessage: '등록된 이벤트가 없습니다',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopInfoSection extends StatelessWidget {
  const _ShopInfoSection({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String? description;

  Future<void> _openNaverNavigation() async {
    final encodedName = Uri.encodeComponent(name);
    final appUrl = Uri.parse(
      'nmap://route/car'
      '?dlat=$latitude&dlng=$longitude'
      '&dname=$encodedName'
      '&appname=com.gurtalim.app',
    );

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      final webUrl = Uri.parse(
        'https://map.naver.com/v5/directions/-/'
        '$longitude,$latitude,$encodedName/-/car',
      );
      await launchUrl(
        webUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openNaverNavigation,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1EC800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '길찾기',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberSection extends StatelessWidget {
  const _MemberSection({
    required this.isMember,
    required this.isRegistering,
    required this.onRegister,
  });

  final bool isMember;
  final bool isRegistering;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isMember
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '등록된 회원입니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRegistering ? null : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
                child: isRegistering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '회원 등록',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
    );
  }
}

class _PostTab extends StatelessWidget {
  const _PostTab({
    required this.posts,
    required this.shopId,
    required this.emptyMessage,
  });

  final List<Post> posts;
  final String shopId;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return EmptyState(
        icon: Icons.article_outlined,
        message: emptyMessage,
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final post = posts[index];
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
                color: Color(0xFF94A3B8),
              ),
            ),
            trailing: post.images.isNotEmpty
                ? const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF94A3B8),
                  )
                : null,
            onTap: () {
              context.push(
                '/customer/shop/$shopId/post/${post.id}',
              );
            },
          ),
        );
      },
    );
  }
}
