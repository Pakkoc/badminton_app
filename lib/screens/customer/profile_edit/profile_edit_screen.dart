import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_notifier.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/phone_input_field.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() =>
      _ProfileEditScreenState();
}

class _ProfileEditScreenState
    extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    ref
        .read(profileEditNotifierProvider.notifier)
        .pickImage(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileEditNotifierProvider);

    if (!_initialized && state.name.isNotEmpty) {
      _nameController.text = state.name;
      _phoneController.text = state.phone;
      _initialized = true;
    }

    ref.listen(
      profileEditNotifierProvider
          .select((s) => s.errorMessage),
      (_, errorMessage) {
        if (errorMessage != null) {
          AppToast.error(context, errorMessage);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: CourtBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _ProfileAvatar(
                      imageUrl: state.profileImageUrl,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                      ),
                      validator: Validators.name,
                      autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                      onChanged: ref
                          .read(
                            profileEditNotifierProvider.notifier,
                          )
                          .updateName,
                    ),
                    const SizedBox(height: 16),
                    PhoneInputField(
                      controller: _phoneController,
                      onChanged: ref
                          .read(
                            profileEditNotifierProvider.notifier,
                          )
                          .updatePhone,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Bar — 스펙: padding [16,28], fill #ffffff15, top border #ffffff20 0.5px
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.surfaceHigh,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.surfaceBorder,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final success = await ref
                              .read(
                                profileEditNotifierProvider
                                    .notifier,
                              )
                              .submit();
                          if (success && context.mounted) {
                            AppToast.success(
                              context,
                              '프로필이 저장되었습니다',
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF16A34A,
                    ).withValues(alpha: 0.5),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.5),
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
                      : const Text('저장'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    this.imageUrl,
    required this.onTap,
  });

  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            backgroundImage: imageUrl != null
                ? CachedNetworkImageProvider(imageUrl!)
                : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
