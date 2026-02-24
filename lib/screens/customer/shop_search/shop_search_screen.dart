import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopSearchScreen extends ConsumerStatefulWidget {
  const ShopSearchScreen({super.key});

  @override
  ConsumerState<ShopSearchScreen> createState() =>
      _ShopSearchScreenState();
}

class _ShopSearchScreenState
    extends ConsumerState<ShopSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSearchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('샵 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '샵 이름을 검색하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (query) {
                ref
                    .read(shopSearchNotifierProvider.notifier)
                    .searchShops(query);
              },
            ),
          ),
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ShopSearchState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () {
          ref
              .read(shopSearchNotifierProvider.notifier)
              .searchShops(state.searchQuery);
        },
      );
    }

    if (state.shops.isEmpty) {
      return const EmptyState(
        icon: Icons.store_outlined,
        message: '검색 결과가 없습니다',
      );
    }

    return ListView.builder(
      itemCount: state.shops.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final shop = state.shops[index];
        return _ShopCard(
          name: shop.name,
          address: shop.address,
          onTap: () {
            context.push('/customer/shop/${shop.id}');
          },
        );
      },
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.name,
    required this.address,
    required this.onTap,
  });

  final String name;
  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFDCFCE7),
          child: Icon(
            Icons.store,
            color: Color(0xFF16A34A),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(address),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
