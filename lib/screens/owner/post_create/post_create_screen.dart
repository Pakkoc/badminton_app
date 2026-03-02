import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCreateNotifierProvider);
    final notifier = ref.read(postCreateNotifierProvider.notifier);

    if (state.isLoadingPost) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글 수정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '게시글 수정' : '게시글 작성'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0FDF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0FDF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                    onAdd: notifier.addImage,
                    onRemove: notifier.removeImage,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                    color: Color(0xFFE2E8F0)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFB923C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
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
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF22C55E)
                : const Color(0xFF475569),
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
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> images;
  final ValueChanged<String> onAdd;
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
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '최대 5장',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
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
            if (images.length < 5)
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
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF0FDF4),
          ),
          child: const Icon(
            Icons.image,
            color: Color(0xFF94A3B8),
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
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: image_picker 연동
        onAdd('https://placeholder.com/image.jpg');
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
