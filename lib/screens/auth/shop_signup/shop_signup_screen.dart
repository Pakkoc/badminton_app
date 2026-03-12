import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/map_preview.dart';
import 'package:badminton_app/widgets/phone_input_field.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopSignupScreen extends ConsumerStatefulWidget {
  const ShopSignupScreen({super.key});

  @override
  ConsumerState<ShopSignupScreen> createState() =>
      _ShopSignupScreenState();
}

class _ShopSignupScreenState
    extends ConsumerState<ShopSignupScreen> {
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _businessNumberController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _businessNumberController.dispose();
    super.dispose();
  }

  /// 재신청 시 기존 rejected 샵 정보를 폼에 채운다.
  Future<void> _loadExistingShop() async {
    if (_initialized) return;
    _initialized = true;

    final notifier =
        ref.read(shopSignupNotifierProvider.notifier);
    await notifier.loadExistingShop();

    final state = ref.read(shopSignupNotifierProvider);
    if (state.isReapply) {
      _shopNameController.text = state.shopName;
      _addressController.text = state.address;
      _phoneController.text = state.phone;
      _descriptionController.text = state.description;
      _businessNumberController.text =
          state.businessNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSignupNotifierProvider);
    final notifier =
        ref.read(shopSignupNotifierProvider.notifier);

    // 재신청 시 기존 정보 로드
    _loadExistingShop();

    // 주소가 변경되면 컨트롤러를 동기화
    if (_addressController.text != state.address) {
      _addressController.text = state.address;
    }

    ref.listen(
      shopSignupNotifierProvider.select(
        (s) => s.errorMessage,
      ),
      (_, errorMessage) {
        if (errorMessage != null) {
          AppToast.error(context, errorMessage);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isReapply ? '샵 재등록' : '샵 등록',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CourtBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isReapply
                  ? '샵 정보를 수정하여 다시 신청해주세요'
                  : '샵 정보를 등록해주세요',
              style:
                  Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _shopNameController,
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
            _AddressField(
              controller: _addressController,
              onSearch: () =>
                  notifier.searchAddress(context),
            ),
            if (state.latitude != 0.0 &&
                state.longitude != 0.0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MapPreview(
                  latitude: state.latitude,
                  longitude: state.longitude,
                  height: 180,
                ),
              ),
            const SizedBox(height: 16),
            PhoneInputField(
              controller: _phoneController,
              onChanged: notifier.updatePhone,
            ),
            const SizedBox(height: 16),
            _BusinessNumberField(
              controller: _businessNumberController,
              onChanged: notifier.updateBusinessNumber,
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
                onPressed:
                    notifier.isValid && !state.isSubmitting
                        ? () async {
                            final result =
                                await notifier.submit();
                            if (result != null &&
                                mounted) {
                              AppToast.success(
                                context,
                                '샵 등록 신청이 완료되었습니다',
                              );
                              context.go('/customer/mypage');
                            }
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.accent.withValues(
                    alpha: 0.5,
                  ),
                  disabledForegroundColor:
                      Colors.white.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
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
                    : Text(
                        state.isReapply
                            ? '재신청'
                            : '등록 신청',
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

/// 주소 입력 필드 (읽기 전용) + 검색 버튼.
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '주소',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          tooltip: '주소 검색',
          onPressed: onSearch,
        ),
      ),
      onTap: onSearch,
    );
  }
}

/// 사업자등록번호 입력 필드 (하이픈 자동 포맷).
class _BusinessNumberField extends StatelessWidget {
  const _BusinessNumberField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: '사업자등록번호',
        hintText: '000-00-00000',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _BusinessNumberFormatter(),
        LengthLimitingTextInputFormatter(12),
      ],
      validator: Validators.businessNumber,
      autovalidateMode:
          AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
    );
  }
}

/// 사업자등록번호 XXX-XX-XXXXX 자동 하이픈 포맷터.
class _BusinessNumberFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll('-', '');
    if (raw.isEmpty) return newValue;

    final formatted = Formatters.businessNumber(raw);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
