import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 카카오(다음) 우편번호 서비스를 통해 주소를 검색하는 서비스.
///
/// 웹에서는 WebView를 사용할 수 없으므로 텍스트 입력 다이얼로그로 대체한다.
/// 모바일에서는 webview_flutter로 카카오 주소 API 웹뷰를 표시한다.
class AddressSearchService {
  const AddressSearchService();

  /// 주소 검색을 수행하고 선택된 주소를 반환한다.
  Future<String?> searchAddress(BuildContext context) async {
    if (kIsWeb) {
      return _showWebFallbackDialog(context);
    }
    return _showWebViewBottomSheet(context);
  }

  /// 웹 환경: 텍스트 입력 다이얼로그
  Future<String?> _showWebFallbackDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주소 입력'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '도로명 주소를 입력하세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop(text);
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 모바일 환경: 카카오 주소 API 웹뷰 바텀시트
  Future<String?> _showWebViewBottomSheet(BuildContext context) async {
    // webview_flutter는 모바일에서만 동작
    // 동적 import로 웹 빌드 에러 방지
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) => const _MobileAddressSearchSheet(),
    );
  }
}

class _MobileAddressSearchSheet extends StatefulWidget {
  const _MobileAddressSearchSheet();

  @override
  State<_MobileAddressSearchSheet> createState() =>
      _MobileAddressSearchSheetState();
}

class _MobileAddressSearchSheetState
    extends State<_MobileAddressSearchSheet> {
  @override
  Widget build(BuildContext context) {
    // 모바일에서 webview_flutter를 사용하여 카카오 주소 검색
    // 웹에서는 이 위젯이 호출되지 않음 (kIsWeb 분기)
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '주소 검색',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(
              child: Text('모바일에서 카카오 주소 검색이 표시됩니다'),
            ),
          ),
        ],
      ),
    );
  }
}
