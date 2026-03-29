import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:badminton_app/widgets/court_background.dart';
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
        body: const CourtBackground(child: LoadingIndicator()),
      );
    }

    final isEditing = state.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('샵 설정'),
        actions: [
          TextButton(
            onPressed: () {
              if (isEditing) {
                notifier.cancelEditing();
                // 컨트롤러 값 원복
                if (state.originalShop != null) {
                  _nameController.text =
                      state.originalShop!.name;
                  _addressController.text =
                      state.originalShop!.address;
                  _phoneController.text =
                      state.originalShop!.phone;
                  _descriptionController.text =
                      state.originalShop!.description ?? '';
                }
                _ownerNameController.text =
                    state.originalOwnerName;
                _ownerPhoneController.text =
                    state.originalOwnerPhone;
              } else {
                notifier.startEditing();
              }
            },
            child: Text(
              isEditing ? '취소' : '수정하기',
              style: TextStyle(
                color: isEditing
                    ? AppTheme.error
                    : AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: CourtBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // 관리 메뉴 섹션
                  const _SectionHeader(
                    icon: Icons.menu,
                    label: '관리 메뉴',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.cardBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _MenuItemTile(
                          icon: Icons.qr_code_2,
                          label: '내 샵 QR코드',
                          showDivider: true,
                          onTap: () => context.push(
                            '/owner/settings/shop-qr/'
                            '${state.shop!.id}',
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
                          showDivider: true,
                          onTap: () => context
                              .push('/owner/settings/inventory'),
                        ),
                        _MenuItemTile(
                          icon: Icons.swap_horiz,
                          label: '고객 모드 전환',
                          showDivider: false,
                          onTap: () {
                            ref
                                .read(
                                  activeModeProvider.notifier,
                                )
                                .state = AppMode.customer;
                            context.go('/customer/home');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 알림 설정 섹션
                  const _SectionHeader(
                    icon: Icons.notifications,
                    label: '알림 설정',
                  ),
                  const SizedBox(height: 12),
                  _NotifyShopToggle(
                    value: state.notifyShop,
                    onChanged: notifier.toggleNotifyShop,
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: isEditing
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _SettingsField(
                                label: '샵 이름',
                                controller: _nameController,
                                onChanged:
                                    notifier.updateShopName,
                                validator: Validators.shopName,
                              ),
                              const SizedBox(height: 16),
                              _AddressSettingsField(
                                controller: _addressController,
                                onSearch: () => notifier
                                    .searchAddress(context),
                              ),
                              const SizedBox(height: 16),
                              MapPreview(
                                latitude: state.shop?.latitude,
                                longitude:
                                    state.shop?.longitude,
                              ),
                              const SizedBox(height: 16),
                              _PhoneSettingsField(
                                label: '전화번호',
                                controller: _phoneController,
                                onChanged: notifier.updatePhone,
                              ),
                              const SizedBox(height: 16),
                              _SettingsField(
                                label: '소개글',
                                controller:
                                    _descriptionController,
                                onChanged:
                                    notifier.updateDescription,
                                maxLines: 4,
                                height: 80,
                                validator:
                                    Validators.description,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _ReadOnlyField(
                                label: '샵 이름',
                                value:
                                    state.shop?.name ?? '',
                              ),
                              const Divider(
                                height: 24,
                                color: AppTheme.cardBorder,
                              ),
                              _ReadOnlyField(
                                label: '주소',
                                value:
                                    state.shop?.address ?? '',
                              ),
                              const SizedBox(height: 16),
                              MapPreview(
                                latitude: state.shop?.latitude,
                                longitude:
                                    state.shop?.longitude,
                              ),
                              const Divider(
                                height: 24,
                                color: AppTheme.cardBorder,
                              ),
                              _ReadOnlyField(
                                label: '전화번호',
                                value: Formatters.phone(
                                  state.shop?.phone ?? '',
                                ),
                              ),
                              const Divider(
                                height: 24,
                                color: AppTheme.cardBorder,
                              ),
                              _ReadOnlyField(
                                label: '소개글',
                                value:
                                    state.shop?.description ??
                                        '',
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: isEditing
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _SettingsField(
                                label: '이름',
                                controller:
                                    _ownerNameController,
                                onChanged:
                                    notifier.updateOwnerName,
                              ),
                              const SizedBox(height: 16),
                              _PhoneSettingsField(
                                label: '전화번호',
                                controller:
                                    _ownerPhoneController,
                                onChanged:
                                    notifier.updateOwnerPhone,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _ReadOnlyField(
                                label: '이름',
                                value: state.ownerName,
                              ),
                              const Divider(
                                height: 24,
                                color: AppTheme.cardBorder,
                              ),
                              _ReadOnlyField(
                                label: '전화번호',
                                value: Formatters.phone(
                                  state.ownerPhone,
                                ),
                              ),
                            ],
                          ),
                  ),
                  // 저장 버튼 — 편집 모드일 때만 표시
                  if (isEditing) ...[
                    const SizedBox(height: 24),
                    _SaveButton(
                      isSubmitting: state.isSubmitting,
                      onPressed: () async {
                        final success = await notifier.submit();
                        if (success && context.mounted) {
                          AppToast.success(
                            context,
                            '샵 설정이 저장되었습니다',
                          );
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }
}

/// 읽기 모드 전용 — 라벨 + 텍스트 값.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.onCardSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.onCardPrimary,
          ),
        ),
      ],
    );
  }
}

/// 편집 모드 전용 입력 필드.
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
            color: AppTheme.onCardSecondary,
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
            style: const TextStyle(
              color: AppTheme.onCardPrimary,
            ),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.onCardHint,
              ),
              filled: true,
              fillColor: AppTheme.cardBackgroundVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
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
            color: AppTheme.onCardSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: AppTheme.cardBackgroundVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppTheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppTheme.error),
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
              textStyle: const TextStyle(
                color: AppTheme.onCardPrimary,
              ),
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
            color: AppTheme.onCardSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onSearch,
            style: const TextStyle(
              color: AppTheme.onCardPrimary,
            ),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.onCardHint,
              ),
              filled: true,
              fillColor: AppTheme.cardBackgroundVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: AppTheme.onCardTertiary,
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

class _NotifyShopToggle extends StatelessWidget {
  const _NotifyShopToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.store,
            color: AppTheme.onCardSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가게 알림',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onCardPrimary,
                  ),
                ),
                Text(
                  'QR 접수, 새 주문 등',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onCardSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.accent,
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
          color: AppTheme.accent,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryCta,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppTheme.primaryCta.withValues(alpha: 0.5),
          disabledForegroundColor:
              Colors.white.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
                    color: AppTheme.onCardSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onCardPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.onCardTertiary,
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
            color: AppTheme.cardBorder,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}
