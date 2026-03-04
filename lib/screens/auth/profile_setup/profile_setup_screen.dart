import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:badminton_app/widgets/phone_input_field.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupNotifierProvider);
    final notifier =
        ref.read(profileSetupNotifierProvider.notifier);

    ref.listen(
      profileSetupNotifierProvider.select((s) => s.errorMessage),
      (_, errorMessage) {
        if (errorMessage != null) {
          AppToast.error(context, errorMessage);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서비스 이용을 위해 정보를 입력해주세요',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
              validator: Validators.name,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction,
              onChanged: notifier.updateName,
            ),
            const SizedBox(height: 16),
            PhoneInputField(
              controller: _phoneController,
              onChanged: notifier.updatePhone,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: notifier.isValid && !state.isSubmitting
                    ? () async {
                        final route = await notifier.submit();
                        if (route != null && mounted) {
                          context.go(route);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.primary.withValues(
                    alpha: 0.5,
                  ),
                  disabledForegroundColor:
                      Colors.white.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                    : const Text('시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
