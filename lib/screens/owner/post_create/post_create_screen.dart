import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class PostCreateScreen extends ConsumerStatefulWidget {
  const PostCreateScreen({
    super.key,
    required this.shopId,
    this.postId,
  });

  final String shopId;
  final String? postId;

  @override
  ConsumerState<PostCreateScreen> createState() =>
      _PostCreateScreenState();
}

class _PostCreateScreenState
    extends ConsumerState<PostCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool get _isEditMode => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      Future.microtask(() async {
        final notifier =
            ref.read(postCreateNotifierProvider.notifier);
        await notifier.loadPost(widget.postId!);
        final state = ref.read(postCreateNotifierProvider);
        _titleController.text = state.title;
        _contentController.text = state.content;
      });
    }
  }

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(
    PostCreateNotifier notifier,
  ) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    final ext = xFile.path.split('.').last.toLowerCase();
    final extension =
        ['jpg', 'jpeg', 'png', 'webp'].contains(ext)
            ? ext
            : 'jpg';
    await notifier.addImage(bytes, extension);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCreateNotifierProvider);
    final notifier = ref.read(postCreateNotifierProvider.notifier);

    bool hasContent = state.title.isNotEmpty ||
        state.content.isNotEmpty ||
        state.images.isNotEmpty;

    if (state.isLoadingPost) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글 수정')),
        body: const CourtBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return PopScope(
      canPop: !hasContent,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showConfirmDialog(
          context: context,
          title: '작성 취소',
          content: '작성 중인 내용이 사라집니다.\n정말 나가시겠습니까?',
          onConfirm: () {},
          confirmLabel: '나가기',
        );
        if (confirmed == true && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isEditMode ? '게시글 수정' : '게시글 작성'),
        ),
        body: CourtBackground(
          child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // Content Area: padding [16,28], gap 20
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategorySelector(
                    selected: state.category,
                    onChanged: notifier.selectCategory,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제목 *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title Input: cornerRadius 14, fill #ffffff18, height 48, padding [0,14]
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                      onChanged: notifier.updateTitle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '내용 *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Content Input: cornerRadius 14, fill #ffffff18, height 160, padding 14
                  SizedBox(
                    height: 160,
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.all(14),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical:
                          TextAlignVertical.top,
                      onChanged: notifier.updateContent,
                    ),
                  ),
                  if (state.category ==
                      PostCategory.event) ...[
                    const SizedBox(height: 20),
                    _DateRangeSection(
                      startDate: state.eventStartDate,
                      endDate: state.eventEndDate,
                      onSelectStart: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              state.eventStartDate ??
                                  DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          notifier.setEventDates(
                              startDate: date);
                        }
                      },
                      onSelectEnd: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              state.eventEndDate ??
                                  DateTime.now(),
                          firstDate:
                              state.eventStartDate ??
                                  DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          notifier.setEventDates(
                              endDate: date);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  _ImageSection(
                    images: state.images,
                    isUploading: state.isUploadingImage,
                    onAdd: () => _pickAndUploadImage(
                      notifier,
                    ),
                    onRemove: notifier.removeImage,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Bottom Bar: padding [16,28], fill #ffffff15, top border #ffffff20 0.5px
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final success =
                            await notifier
                                .submit(widget.shopId);
                        if (success &&
                            context.mounted) {
                          AppToast.success(
                            context,
                            _isEditMode
                                ? '게시글이 수정되었습니다'
                                : '게시글이 등록되었습니다',
                          );
                          context.pop(true);
                        }
                      },
                // Submit Button: cornerRadius 20, fill primaryCta, height 48
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditMode
                            ? '수정하기'
                            : '등록하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.completedBackground
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppTheme.activeTab
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.onChanged,
  });

  final PostCategory selected;
  final ValueChanged<PostCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PostCategory.values.map((category) {
        final isSelected = category == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _CategoryChip(
            label: category.label,
            isSelected: isSelected,
            onTap: () => onChanged(category),
          ),
        );
      }).toList(),
    );
  }
}

class _DateRangeSection extends StatelessWidget {
  const _DateRangeSection({
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSelectStart,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              startDate != null
                  ? Formatters.date(startDate!)
                  : '시작일',
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('~'),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSelectEnd,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              endDate != null
                  ? Formatters.date(endDate!)
                  : '종료일',
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.images,
    required this.isUploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> images;
  final bool isUploading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

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
        const SizedBox(height: 4),
        const Text(
          '최대 5장',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...images.asMap().entries.map(
                  (entry) => _ImageThumbnail(
                    url: entry.value,
                    onRemove: () => onRemove(entry.key),
                  ),
                ),
            if (isUploading)
              const SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else if (images.length < 5)
              _AddImageButton(onAdd: onAdd),
          ],
        ),
      ],
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.url,
    required this.onRemove,
  });

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 80,
              height: 80,
              color: AppTheme.cardBackground,
              child: const Icon(
                Icons.image,
                color: AppTheme.onCardTertiary,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.error,
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
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.border,
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
