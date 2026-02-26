import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/owner/post_create/post_create_notifier.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostCreateScreen extends ConsumerWidget {
  const PostCreateScreen({
    super.key,
    required this.shopId,
  });

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postCreateNotifierProvider);
    final notifier = ref.read(postCreateNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategorySelector(
              selected: state.category,
              onChanged: notifier.selectCategory,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: notifier.updateTitle,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              onChanged: notifier.updateContent,
            ),
            if (state.category == PostCategory.event) ...[
              const SizedBox(height: 16),
              _DateRangeSection(
                startDate: state.eventStartDate,
                endDate: state.eventEndDate,
                onSelectStart: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        state.eventStartDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 365),
                    ),
                  );
                  if (date != null) {
                    notifier.setEventDates(startDate: date);
                  }
                },
                onSelectEnd: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        state.eventEndDate ?? DateTime.now(),
                    firstDate: state.eventStartDate ??
                        DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 365),
                    ),
                  );
                  if (date != null) {
                    notifier.setEventDates(endDate: date);
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final success =
                            await notifier.submit(shopId);
                        if (success && context.mounted) {
                          AppToast.success(
                            context,
                            '게시글이 등록되었습니다',
                          );
                          context.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
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
          child: ChoiceChip(
            label: Text(category.label),
            selected: isSelected,
            selectedColor: const Color(0xFF16A34A),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
            ),
            onSelected: (_) => onChanged(category),
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
        Row(
          children: [
            const Text(
              '이미지',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${images.length}/5',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
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
            color: const Color(0xFFF1F5F9),
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
