import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/auth_provider.dart';
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
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final shop = await ref
        .read(shopRepositoryProvider)
        .getByOwner(user.id);
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
                      if (context.mounted) {
                        AppToast.success(
                          context,
                          '상품이 추가되었습니다',
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF16A34A),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.add),
        label: const Text('상품 추가'),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _InventoryItemTile(
            item: item,
            onIncrement: () {
              ref
                  .read(inventoryNotifierProvider.notifier)
                  .updateItem(
                    item.id,
                    {'quantity': item.quantity + 1},
                  );
            },
            onDecrement: () {
              if (item.quantity > 0) {
                ref
                    .read(
                      inventoryNotifierProvider.notifier,
                    )
                    .updateItem(
                      item.id,
                      {'quantity': item.quantity - 1},
                    );
              }
            },
            onDelete: () {
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

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    if (item.category != null)
                      Text(
                        item.category!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              _QuantityControl(
                quantity: item.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: item.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (ctx, url) => Container(
            width: 48,
            height: 48,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(Icons.image, size: 24),
          ),
          errorWidget: (ctx, url, err) => Container(
            width: 48,
            height: 48,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(
              Icons.broken_image,
              size: 24,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2, size: 24),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      ],
    );
  }
}
