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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.isReapply ? '샵 재등록' : '샵 등록',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (!state.isReapply)
              const Text(
                '2/2',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x88FFFFFF),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CourtBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 단계 표시 (재등록 시 숨김)
              if (!state.isReapply) ...[
                const _StepProgressRow(),
                const SizedBox(height: 16),
              ],
              // 섹션 제목
              const Text(
                '샵 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: '샵 이름',
                  filled: true,
                  fillColor: AppTheme.cardBackgroundVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                    ),
                  ),
                ),
                validator: Validators.shopName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: notifier.updateShopName,
              ),
              const SizedBox(height: 16),
              _AddressField(
                controller: _addressController,
                onSearch: () => notifier.searchAddress(context),
              ),
              if (state.latitude != 0.0 && state.longitude != 0.0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MapPreview(
                      latitude: state.latitude,
                      longitude: state.longitude,
                      height: 150,
                    ),
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
                decoration: InputDecoration(
                  labelText: '소개글',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppTheme.cardBackgroundVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                    ),
                  ),
                ),
                maxLines: 4,
                validator: Validators.description,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: notifier.updateDescription,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: notifier.isValid && !state.isSubmitting
                      ? () async {
                          final result = await notifier.submit();
                          if (result != null && mounted) {
                            AppToast.success(
                              context,
                              '샵 등록 신청이 완료되었습니다',
                            );
                            context.go('/customer/mypage');
                          }
                        }
                      : null,
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
                          state.isReapply ? '재신청' : '등록 완료',
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

/// 샵 등록 단계 표시 (정보 입력 → 샵 등록).
///
/// Pencil 스펙 (PdstH): padding [0,60], gap 6
/// - 체크 원: 18x18, fill #4A8FE2, cornerRadius 9
/// - "정보 입력": fontSize 12, fontWeight 500
/// - 연결선: fill #4A8FE2, height 2, width 40
/// - 활성 점: 10x10, fill #4A8FE2
/// - "샵 등록": fontSize 12, fontWeight 500
class _StepProgressRow extends StatelessWidget {
  const _StepProgressRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 완료된 1단계: 체크 원
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF4A8FE2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '정보 입력',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          // 연결선
          Container(
            width: 40,
            height: 2,
            color: AppTheme.primaryCta,
          ),
          const SizedBox(width: 6),
          // 현재 2단계: 활성 점
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF4A8FE2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '샵 등록',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
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
        filled: true,
        fillColor: AppTheme.cardBackgroundVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
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
      decoration: InputDecoration(
        labelText: '사업자등록번호',
        hintText: '000-00-00000',
        filled: true,
        fillColor: AppTheme.cardBackgroundVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
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
