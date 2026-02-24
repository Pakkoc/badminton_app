import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/phone_input_field.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() =>
      _ShopSettingsScreenState();
}

class _ShopSettingsScreenState
    extends ConsumerState<ShopSettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSettingsNotifierProvider);
    final notifier =
        ref.read(shopSettingsNotifierProvider.notifier);

    if (!_initialized && state.shop != null) {
      _nameController.text = state.shop!.name;
      _addressController.text = state.shop!.address;
      _phoneController.text = state.shop!.phone;
      _descriptionController.text =
          state.shop!.description ?? '';
      _initialized = true;
    }

    ref.listen(
      shopSettingsNotifierProvider
          .select((s) => s.errorMessage),
      (_, errorMessage) {
        if (errorMessage != null) {
          AppToast.error(context, errorMessage);
        }
      },
    );

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('샵 설정')),
        body: const LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('샵 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '샵 이름',
                border: OutlineInputBorder(),
              ),
              validator: Validators.shopName,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction,
              onChanged: notifier.updateShopName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.updateAddress,
            ),
            const SizedBox(height: 16),
            PhoneInputField(
              controller: _phoneController,
              onChanged: notifier.updatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '소개글',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: Validators.description,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction,
              onChanged: notifier.updateDescription,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final success =
                            await notifier.submit();
                        if (success && context.mounted) {
                          AppToast.success(
                            context,
                            '샵 설정이 저장되었습니다',
                          );
                          context.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: const Color(0xFFFFFFFF),
                  disabledBackgroundColor:
                      const Color(0xFF16A34A).withValues(
                    alpha: 0.5,
                  ),
                  disabledForegroundColor:
                      const Color(0xFFFFFFFF).withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    : const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
