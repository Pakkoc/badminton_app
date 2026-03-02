import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/map_preview.dart';
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

    // 주소 검색으로 변경 시 컨트롤러 동기화
    ref.listen(
      shopSettingsNotifierProvider
          .select((s) => s.shop?.address),
      (prev, next) {
        if (next != null && _addressController.text != next) {
          _addressController.text = next;
        }
      },
    );

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
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
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
                          icon: Icons.article,
                          label: '게시글 관리',
                          showDivider: true,
                          onTap: () => context.push(
                            '/owner/settings/post-manage'
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

                  // 샵 정보 카드
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingsField(
                          label: '샵 이름',
                          controller: _nameController,
                          onChanged: notifier.updateShopName,
                          validator: Validators.shopName,
                        ),
                        const SizedBox(height: 12),
                        _AddressSettingsField(
                          controller: _addressController,
                          onSearch: () =>
                              notifier.searchAddress(context),
                        ),
                        const SizedBox(height: 12),
                        MapPreview(
                          latitude: state.shop?.latitude,
                          longitude: state.shop?.longitude,
                        ),
                        const SizedBox(height: 12),
                        _PhoneSettingsField(
                          label: '전화번호',
                          controller: _phoneController,
                          onChanged: notifier.updatePhone,
                        ),
                        const SizedBox(height: 12),
                        _SettingsField(
                          label: '소개글',
                          controller: _descriptionController,
                          onChanged: notifier.updateDescription,
                          maxLines: 4,
                          height: 80,
                          validator: Validators.description,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 사장님 정보 섹션 헤더
                  const _SectionHeader(
                    icon: Icons.person,
                    label: '사장님 정보',
                  ),
                  const SizedBox(height: 12),

                  // 사장님 정보 카드
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingsField(
                          label: '이름',
                          controller: _ownerNameController,
                          onChanged: notifier.updateOwnerName,
                        ),
                        const SizedBox(height: 12),
                        _PhoneSettingsField(
                          label: '전화번호',
                          controller: _ownerPhoneController,
                          onChanged: notifier.updateOwnerPhone,
                        ),
                      ],
                    ),
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

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.height = 44,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final double height;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: height,
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// PhoneInputField를 Pencil 스타일 라벨과 함께 감싸는 위젯.
/// PhoneInputField 내부의 포맷팅 로직을 유지하면서
/// 외부 라벨을 Pencil 디자인에 맞게 표현한다.
class _PhoneSettingsField extends StatelessWidget {
  const _PhoneSettingsField({
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              labelStyle: TextStyle(fontSize: 0),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: PhoneInputField(
              controller: controller,
              label: '',
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// 주소 입력 필드 (읽기 전용) + 검색 아이콘.
class _AddressSettingsField extends StatelessWidget {
  const _AddressSettingsField({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주소',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onSearch,
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                ),
                tooltip: '주소 검색',
                onPressed: onSearch,
              ),
            ),
          ),
        ),
      ],
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
              : const Text('저장하기'),
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
