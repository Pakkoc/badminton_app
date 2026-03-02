import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_notifier.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() =>
      _InventoryScreenState();
}

class _InventoryScreenState
    extends ConsumerState<InventoryScreen> {
  String? _shopId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  Future<void> _loadInventory() async {
    final userId =
        ref.read(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return;

    final shop = await ref
        .read(shopRepositoryProvider)
        .getByOwner(userId);
    if (shop == null) return;

    _shopId = shop.id;
    ref
        .read(inventoryNotifierProvider.notifier)
        .loadItems(shop.id);
  }

  void _showAddItemDialog() {
    if (_shopId == null) return;

    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController =
        TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext)
                  .viewInsets
                  .bottom +
              24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상품 추가',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.productName,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '카테고리 (선택)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: '수량',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.quantity,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final success = await ref
                        .read(
                          inventoryNotifierProvider
                              .notifier,
                        )
                        .addItem(
                          shopId: _shopId!,
                          name: nameController.text,
                          category: categoryController
                                  .text.isEmpty
                              ? null
                              : categoryController.text,
                          quantity: int.parse(
                            quantityController.text,
                          ),
                        );
                    if (success &&
                        sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    if (success && mounted) {
                      AppToast.success(
                        context,
                        '상품이 추가되었습니다',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.secondary,
                    foregroundColor:
                        const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('추가'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    final nameController =
        TextEditingController(text: item.name);
    final categoryController =
        TextEditingController(text: item.category ?? '');
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext)
                  .viewInsets
                  .bottom +
              24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상품 수정',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.productName,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '카테고리 (선택)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: '수량',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.quantity,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final updates = <String, dynamic>{
                      'name': nameController.text,
                      'quantity': int.parse(
                        quantityController.text,
                      ),
                    };
                    final cat =
                        categoryController.text.trim();
                    updates['category'] =
                        cat.isEmpty ? null : cat;

                    await ref
                        .read(
                          inventoryNotifierProvider
                              .notifier,
                        )
                        .updateItem(item.id, updates);

                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    if (mounted) {
                      AppToast.success(
                        context,
                        '상품이 수정되었습니다',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.secondary,
                    foregroundColor:
                        const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('수정'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryNotifierProvider);

    ref.listen(
      inventoryNotifierProvider.select((s) => s.error),
      (_, error) {
        if (error != null) {
          AppToast.error(context, error);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('재고 관리')),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBody(InventoryState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: _loadInventory,
      );
    }

    if (state.items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        message: '등록된 상품이 없습니다',
        actionLabel: '상품 추가',
        onAction: _showAddItemDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInventory,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _InventoryGridCard(
            item: item,
            onTap: () => _showEditItemDialog(item),
            onLongPress: () {
              showConfirmDialog(
                context: context,
                title: '상품 삭제',
                content:
                    '${item.name}을(를) 삭제하시겠습니까?',
                onConfirm: () {
                  ref
                      .read(
                        inventoryNotifierProvider.notifier,
                      )
                      .deleteItem(item.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _InventoryGridCard extends StatelessWidget {
  const _InventoryGridCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.border,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(imageUrl: item.imageUrl),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.category!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity}개',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (ctx, url) => _placeholder(),
          errorWidget: (ctx, url, err) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: const Icon(
        Icons.inventory_2,
        size: 40,
        color: AppTheme.textTertiary,
      ),
    );
  }
}
