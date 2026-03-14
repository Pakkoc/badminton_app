import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'community_create_notifier.dart';

class CommunityCreateScreen extends ConsumerStatefulWidget {
  const CommunityCreateScreen({super.key, this.postId});

  final String? postId;

  @override
  ConsumerState<CommunityCreateScreen> createState() =>
      _CommunityCreateScreenState();
}

class _CommunityCreateScreenState
    extends ConsumerState<CommunityCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      Future.microtask(() async {
        final notifier =
            ref.read(communityCreateNotifierProvider.notifier);
        await notifier.loadPost(widget.postId!);
        final s = ref.read(communityCreateNotifierProvider);
        _titleController.text = s.title;
        _contentController.text = s.content;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final ext = image.path.split('.').last;
    if (mounted) {
      ref
          .read(communityCreateNotifierProvider.notifier)
          .addImage(bytes, ext);
    }
  }

  Future<void> _submit() async {
    final success =
        await ref.read(communityCreateNotifierProvider.notifier).submit();
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityCreateNotifierProvider);
    final notifier = ref.read(communityCreateNotifierProvider.notifier);
    final isEditing = widget.postId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? '게시글 수정' : '게시글 작성',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CourtBackground(
        child: state.isLoadingPost
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목 라벨
                          const Text(
                            '제목 *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 제목 입력 필드
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: '제목을 입력하세요',
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              constraints: const BoxConstraints(
                                minHeight: 48,
                              ),
                            ),
                            onChanged: notifier.updateTitle,
                          ),
                          const SizedBox(height: 20),
                          // 내용 라벨
                          const Text(
                            '내용 *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 내용 입력 필드
                          TextField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              hintText: '내용을 입력하세요',
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
                              contentPadding: const EdgeInsets.all(14),
                              constraints: const BoxConstraints(
                                minHeight: 160,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: null,
                            minLines: 8,
                            onChanged: notifier.updateContent,
                          ),
                          const SizedBox(height: 20),
                          _ImageSection(
                            images: state.images,
                            isUploading: state.isUploadingImage,
                            onAdd: _pickImage,
                            onRemove: notifier.removeImage,
                          ),
                          if (state.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom bar: 제출 버튼
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                    decoration: const BoxDecoration(
                      color: Color(0x15FFFFFF),
                      border: Border(
                        top: BorderSide(
                          color: Color(0x20FFFFFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryCta,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppTheme.primaryCta.withValues(alpha: 0.5),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? '수정 완료' : '작성 완료'),
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
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('이미지 (${images.length}/5)'),
            const Spacer(),
            if (images.length < 5)
              IconButton(
                onPressed: isUploading ? null : onAdd,
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
              ),
          ],
        ),
        if (images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 8),
              itemBuilder: (_, index) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
