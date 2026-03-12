import 'dart:typed_data';

import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_notifier.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() =>
      _InventoryScreenState();
}

class _InventoryScreenState
    extends ConsumerState<InventoryScreen> {
  String? _shopId;
  final _picker = ImagePicker();

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
    var selectedCategory = InventoryCategory.other;
    final quantityController =
        TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    Uint8List? pickedImageBytes;
    String? pickedImageExt;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                DropdownButtonFormField<InventoryCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: InventoryCategory.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(
                        () => selectedCategory = value,
                      );
                    }
                  },
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
                const SizedBox(height: 12),
                _ImagePickerTile(
                  imageBytes: pickedImageBytes,
                  onPick: () async {
                    final xFile =
                        await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 80,
                    );
                    if (xFile == null) return;
                    final bytes =
                        await xFile.readAsBytes();
                    final ext = xFile.path
                        .split('.')
                        .last
                        .toLowerCase();
                    setSheetState(() {
                      pickedImageBytes = bytes;
                      pickedImageExt =
                          ['jpg', 'jpeg', 'png', 'webp']
                                  .contains(ext)
                              ? ext
                              : 'jpg';
                    });
                  },
                  onRemove: () {
                    setSheetState(() {
                      pickedImageBytes = null;
                      pickedImageExt = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!
                          .validate()) {
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
                            category: selectedCategory,
                            quantity: int.parse(
                              quantityController.text,
                            ),
                            imageBytes: pickedImageBytes,
                            imageExtension:
                                pickedImageExt,
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
                          AppTheme.accent,
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
      ),
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    final nameController =
        TextEditingController(text: item.name);
    var selectedCategory = item.category;
    final quantityController =
        TextEditingController(
            text: item.quantity.toString());
    final formKey = GlobalKey<FormState>();
    Uint8List? pickedImageBytes;
    String? pickedImageExt;
    String? existingImageUrl = item.imageUrl;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                DropdownButtonFormField<InventoryCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: InventoryCategory.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(
                        () => selectedCategory = value,
                      );
                    }
                  },
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
                const SizedBox(height: 12),
                _ImagePickerTile(
                  imageBytes: pickedImageBytes,
                  existingUrl: existingImageUrl,
                  onPick: () async {
                    final xFile =
                        await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 80,
                    );
                    if (xFile == null) return;
                    final bytes =
                        await xFile.readAsBytes();
                    final ext = xFile.path
                        .split('.')
                        .last
                        .toLowerCase();
                    setSheetState(() {
                      pickedImageBytes = bytes;
                      pickedImageExt =
                          ['jpg', 'jpeg', 'png', 'webp']
                                  .contains(ext)
                              ? ext
                              : 'jpg';
                      existingImageUrl = null;
                    });
                  },
                  onRemove: () {
                    setSheetState(() {
                      pickedImageBytes = null;
                      pickedImageExt = null;
                      existingImageUrl = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!
                          .validate()) {
                        return;
                      }
                      final updates = <String, dynamic>{
                        'name': nameController.text,
                        'category':
                            selectedCategory.toJson(),
                        'quantity': int.parse(
                          quantityController.text,
                        ),
                      };
                      if (existingImageUrl == null &&
                          pickedImageBytes == null) {
                        updates['image_url'] = null;
                      }

                      await ref
                          .read(
                            inventoryNotifierProvider
                                .notifier,
                          )
                          .updateItem(
                            item.id,
                            updates,
                            imageBytes: pickedImageBytes,
                            imageExtension:
                                pickedImageExt,
                          );

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
                          AppTheme.accent,
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
      body: CourtBackground(child: _buildBody(state)),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          backgroundColor: const Color(0xFF16A34A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
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
        // Grid: 28px left padding
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 16,
        ),
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
          color: AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 2),
                  Text(
                    item.category.label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          top: Radius.circular(20),
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
          top: Radius.circular(20),
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

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    this.imageBytes,
    this.existingUrl,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? imageBytes;
  final String? existingUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _hasImage =>
      imageBytes != null || existingUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이미지 (선택)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_hasImage)
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: existingUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding:
                        const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.border,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
