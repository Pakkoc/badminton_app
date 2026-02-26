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
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
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
      _ownerNameController.text = state.ownerName;
      _ownerPhoneController.text = state.ownerPhone;
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 관리 메뉴 섹션
                  Row(
                    children: [
                      const Icon(
                        Icons.menu,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '관리 메뉴',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _MenuItemTile(
                          icon: Icons.qr_code_2,
                          label: '내 샵 QR코드',
                          showDivider: true,
                          onTap: () => context.push(
                            '/owner/settings/shop-qr',
                            extra: state.shop,
                          ),
                        ),
                        _MenuItemTile(
                          icon: Icons.edit_note,
                          label: '게시글 작성',
                          showDivider: true,
                          onTap: () => context.push(
                            '/owner/settings/post-create'
                            '?shopId=${state.shop!.id}',
                          ),
                        ),
                        _MenuItemTile(
                          icon: Icons.inventory_2,
                          label: '재고 관리',
                          showDivider: false,
                          onTap: () => context
                              .push('/owner/settings/inventory'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 샵 정보 섹션 헤더
                  const _SectionHeader(
                    icon: Icons.store,
                    label: '샵 정보',
                  ),
                  const SizedBox(height: 12),

                  // 샵 정보 필드
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
                  const SizedBox(height: 24),

                  // 사장님 정보 섹션 헤더
                  const _SectionHeader(
                    icon: Icons.person,
                    label: '사장님 정보',
                  ),
                  const SizedBox(height: 12),

                  // 사장님 정보 필드
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: notifier.updateOwnerName,
                  ),
                  const SizedBox(height: 16),
                  PhoneInputField(
                    controller: _ownerPhoneController,
                    onChanged: notifier.updateOwnerPhone,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 저장 버튼 — 하단 고정
          _SaveButton(
            isSubmitting: state.isSubmitting,
            onPressed: () async {
              final success = await notifier.submit();
              if (success && context.mounted) {
                AppToast.success(
                  context,
                  '샵 설정이 저장되었습니다',
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF16A34A),
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: const Color(0xFFFFFFFF),
            disabledBackgroundColor:
                const Color(0xFF16A34A).withValues(alpha: 0.5),
            disabledForegroundColor:
                const Color(0xFFFFFFFF).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isSubmitting
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
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? BorderRadius.zero
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
          child: SizedBox(
            height: 52,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF475569),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}
