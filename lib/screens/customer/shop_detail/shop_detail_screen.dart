import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_notifier.dart';
import 'package:badminton_app/screens/customer/shop_detail/shop_detail_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/map_preview.dart';
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
    _tabController =
        TabController(length: 3, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '샵 정보',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: CourtBackground(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ShopDetailState state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.shop == null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(shopDetailNotifierProvider.notifier)
            .loadShop(widget.shopId),
      );
    }

    final shop = state.shop;
    if (shop == null) {
      return const LoadingIndicator();
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // 지도 미리보기 — 스펙 3.2
                _MapPreview(shop: shop),
                // 샵 이름/소개 — 스펙 3.3
                _ShopNameSection(shop: shop),
                // 작업 현황 — 스펙 3.4
                _OrderStatusCard(
                  receivedCount: state.receivedCount,
                  inProgressCount:
                      state.inProgressCount,
                ),
                // 위치 및 연락처 — 스펙 3.5
                _ContactSection(shop: shop),
                // 길찾기 버튼 — 스펙 3.6
                _DirectionsButton(shop: shop),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _NoticeTab(
            posts: state.noticePosts,
            shopId: widget.shopId,
          ),
          _EventTab(
            posts: state.eventPosts,
            shopId: widget.shopId,
          ),
          _InventoryTab(
            items: state.inventoryItems,
          ),
        ],
      ),
    );
  }
}

/// 지도 미리보기 — 스펙 3.2.
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMap(),
      child: MapPreview(
        latitude: shop.latitude,
        longitude: shop.longitude,
        height: 180,
        emptyText: '위치 정보가 없습니다',
      ),
    );
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(
      'nmap://place?lat=${shop.latitude}'
      '&lng=${shop.longitude}'
      '&name=${Uri.encodeComponent(shop.name)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// 샵 이름/소개 — 스펙 3.3.
class _ShopNameSection extends StatelessWidget {
  const _ShopNameSection({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront,
                size: 24,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shop.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (shop.description != null &&
              shop.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              shop.description!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 작업 현황 카드 — 스펙 3.4.
class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({
    required this.receivedCount,
    required this.inProgressCount,
  });

  final int receivedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '작업 현황',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$receivedCount',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warning,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '접수',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.border,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$inProgressCount',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.info,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '작업중',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 위치 및 연락처 — 스펙 3.5.
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치 및 연락처',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: AppTheme.border,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme
                                    .textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        _launchPhone(shop.phone),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.call,
                          size: 20,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.phone(shop.phone),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.info,
                                decoration: TextDecoration
                                    .underline,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final raw = Formatters.phoneRaw(phone);
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// 길찾기 버튼 — 스펙 3.6.
class _DirectionsButton extends StatelessWidget {
  const _DirectionsButton({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _openNaverNavigation(),
          icon: const Icon(Icons.directions, size: 20),
          label: const Text('길찾기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNaverNavigation() async {
    final encodedName =
        Uri.encodeComponent(shop.name);
    final appUrl = Uri.parse(
      'nmap://route/public'
      '?dlat=${shop.latitude}'
      '&dlng=${shop.longitude}'
      '&dname=$encodedName',
    );

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      final webUrl = Uri.parse(
        'https://map.naver.com/v5/directions/-/-/-/transit'
        '?c=${shop.longitude},${shop.latitude},15,0,0,0,dh',
      );
      await launchUrl(
        webUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

/// 탭 바 delegate — 스펙 3.7.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.tabController,
  });

  final TabController tabController;

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.surfaceHigh,
      child: TabBar(
        controller: tabController,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textTertiary,
        indicatorColor: AppTheme.accent,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '공지사항'),
          Tab(text: '이벤트'),
          Tab(text: '가게 재고'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      false;
}

/// 공지사항 탭 — 스펙 3.8.
class _NoticeTab extends StatelessWidget {
  const _NoticeTab({
    required this.posts,
    required this.shopId,
  });

  final List<Post> posts;
  final String shopId;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          '등록된 공지사항이 없습니다',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 12,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < posts.length - 1 ? 12 : 0,
          ),
          child: Card(
            elevation: 0,
            color: AppTheme.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: AppTheme.border,
              ),
            ),
            child: InkWell(
              onTap: () => context.push(
                '/customer/shop/$shopId/post/${post.id}',
              ),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.date(post.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppTheme.textTertiary,
                          ),
                    ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 이벤트 탭 — 스펙 3.9.
class _EventTab extends StatelessWidget {
  const _EventTab({
    required this.posts,
    required this.shopId,
  });

  final List<Post> posts;
  final String shopId;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          '등록된 이벤트가 없습니다',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 12,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isOngoing = post.eventEndDate != null &&
            post.eventEndDate!.isAfter(DateTime.now());
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < posts.length - 1 ? 12 : 0,
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: AppTheme.border,
              ),
            ),
            child: InkWell(
              onTap: () => context.push(
                '/customer/shop/$shopId/post/${post.id}',
              ),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 썸네일
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8),
                      child: post.images.isNotEmpty
                          ? Image.network(
                              post.images.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _defaultThumbnail(),
                            )
                          : _defaultThumbnail(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                  color: AppTheme
                                      .textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          if (post.eventStartDate !=
                                  null &&
                              post.eventEndDate != null)
                            Text(
                              '${Formatters.date(post.eventStartDate!)} ~ '
                              '${Formatters.date(post.eventEndDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .textTertiary,
                                  ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isOngoing
                                  ? AppTheme
                                      .completedBackground
                                  : AppTheme
                                      .surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(
                                      8),
                            ),
                            child: Text(
                              isOngoing
                                  ? '진행중'
                                  : '종료',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w500,
                                color: isOngoing
                                    ? AppTheme
                                        .completedText
                                    : AppTheme
                                        .textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _defaultThumbnail() {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.surfaceVariant,
      child: const Icon(
        Icons.event,
        size: 40,
        color: AppTheme.textTertiary,
      ),
    );
  }
}

/// 가게 재고 탭 — 스펙 3.10.
class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.items});

  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          '등록된 재고 정보가 없습니다',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textTertiary),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '재고 정보는 열람만 가능합니다',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textTertiary),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _InventoryCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppTheme.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _defaultImage(),
                  )
                : _defaultImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                ),
                Text(
                  '${item.quantity}개',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.inventory_2,
          size: 40,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
