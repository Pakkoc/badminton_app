import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  Future<String?> _showWebFallbackDialog(
    BuildContext context,
  ) async {
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
  Future<String?> _showWebViewBottomSheet(
    BuildContext context,
  ) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) => const _KakaoAddressSearchSheet(),
    );
  }
}

/// 카카오(다음) 우편번호 서비스 WebView 바텀시트.
class _KakaoAddressSearchSheet extends StatefulWidget {
  const _KakaoAddressSearchSheet();

  @override
  State<_KakaoAddressSearchSheet> createState() =>
      _KakaoAddressSearchSheetState();
}

class _KakaoAddressSearchSheetState
    extends State<_KakaoAddressSearchSheet> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  /// 카카오 우편번호 서비스 HTML.
  ///
  /// 사용자가 주소를 선택하면 JavaScript → Flutter 채널로
  /// 도로명 주소(roadAddress) 또는 지번 주소(jibunAddress)를 전달한다.
  static const _html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
    content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; }
  </style>
</head>
<body>
  <div id="layer" style="width:100%;height:100%;"></div>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script>
    new daum.Postcode({
      oncomplete: function(data) {
        var address = data.roadAddress || data.jibunAddress;
        AddressChannel.postMessage(JSON.stringify({
          address: address,
          zonecode: data.zonecode,
          roadAddress: data.roadAddress,
          jibunAddress: data.jibunAddress,
          buildingName: data.buildingName
        }));
      },
      onclose: function(state) {
        if (state === 'FORCE_CLOSE') {
          AddressChannel.postMessage(JSON.stringify({ closed: true }));
        }
      },
      width: '100%',
      height: '100%'
    }).embed(document.getElementById('layer'));
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: _onAddressSelected,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadHtmlString(_html);
  }

  void _onAddressSelected(JavaScriptMessage message) {
    final data =
        json.decode(message.message) as Map<String, dynamic>;

    if (data.containsKey('closed')) {
      Navigator.of(context).pop();
      return;
    }

    final address = data['address'] as String?;
    if (address != null && address.isNotEmpty) {
      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style:
                      Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(
                  controller: _webViewController,
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
