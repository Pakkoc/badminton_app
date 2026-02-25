import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:badminton_app/widgets/phone_input_field.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSignupNotifierProvider);
    final notifier =
        ref.read(shopSignupNotifierProvider.notifier);

    // 주소가 변경되면 컨트롤러를 동기화
    if (_addressController.text != state.address) {
      _addressController.text = state.address;
    }

    ref.listen(
      shopSignupNotifierProvider.select((s) => s.errorMessage),
      (_, errorMessage) {
        if (errorMessage != null) {
          AppToast.error(context, errorMessage);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('샵 등록'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '샵 정보를 등록해주세요',
              style: Theme.of(context).textTheme.bodyLarge,
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
              onSearch: () => notifier.searchAddress(context),
            ),
            if (state.latitude != 0.0 && state.longitude != 0.0)
              _MapPreview(
                latitude: state.latitude,
                longitude: state.longitude,
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
                onPressed:
                    notifier.isValid && !state.isSubmitting
                        ? () async {
                            final route =
                                await notifier.submit();
                            if (route != null && mounted) {
                              context.go(route);
                            }
                          }
                        : null,
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
                    : const Text('등록 완료'),
              ),
            ),
          ],
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

/// 네이버 지도 미리보기 위젯.
///
/// 웹 환경에서는 placeholder를 표시한다.
class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: 180,
          child: kIsWeb
              ? _buildWebPlaceholder(context)
              : _buildNaverMap(),
        ),
      ),
    );
  }

  Widget _buildNaverMap() {
    final position = NLatLng(latitude, longitude);
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: position,
          zoom: 16,
        ),
        scrollGesturesEnable: false,
        zoomGesturesEnable: false,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        stopGesturesEnable: false,
      ),
      onMapReady: (controller) {
        controller.addOverlay(
          NMarker(
            id: 'shop-location',
            position: position,
          ),
        );
      },
    );
  }

  Widget _buildWebPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              '지도 미리보기',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
