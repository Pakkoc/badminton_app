import 'dart:convert';

import 'package:badminton_app/services/kakao_postcode_web.dart'
    if (dart.library.io) 'package:badminton_app/services/kakao_postcode_stub.dart'
    as kakao_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 카카오(다음) 우편번호 서비스를 통해 주소를 검색하는 서비스.
///
/// 웹에서는 카카오 JS API를 직접 호출하고,
/// 모바일에서는 webview_flutter로 카카오 주소 API 웹뷰를 표시한다.
class AddressSearchService {
  const AddressSearchService();

  /// 주소 검색을 수행하고 선택된 주소를 반환한다.
  Future<String?> searchAddress(BuildContext context) async {
    if (kIsWeb) {
      return _showWebAddressSearch(context);
    }
    return _showWebViewBottomSheet(context);
  }

  /// 웹 환경: 카카오 우편번호 JS API 직접 호출
  Future<String?> _showWebAddressSearch(
    BuildContext context,
  ) async {
    return kakao_web.openKakaoPostcode();
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

  /// oncomplete에서 커스텀 scheme URL로 네비게이션하여
  /// NavigationDelegate에서 인터셉트한다.
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
        var payload = JSON.stringify({
          address: address,
          zonecode: data.zonecode,
          roadAddress: data.roadAddress,
          jibunAddress: data.jibunAddress,
          buildingName: data.buildingName
        });
        location.href = 'postcode://result?' + encodeURIComponent(payload);
      },
      onclose: function(state) {
        if (state === 'FORCE_CLOSE') {
          location.href = 'postcode://close';
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.scheme == 'postcode') {
              _handlePostcodeCallback(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
        _html,
        baseUrl: 'https://postcode.map.daum.net',
      );
  }

  void _handlePostcodeCallback(Uri uri) {
    if (uri.host == 'close') {
      Navigator.of(context).pop();
      return;
    }

    if (uri.host == 'result') {
      try {
        final payload = Uri.decodeComponent(uri.query);
        final data =
            json.decode(payload) as Map<String, dynamic>;
        final address = data['address'] as String?;
        if (address != null && address.isNotEmpty) {
          Navigator.of(context).pop(address);
        }
      } catch (_) {
        Navigator.of(context).pop();
      }
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
                  gestureRecognizers: {
                    Factory<VerticalDragGestureRecognizer>(
                      VerticalDragGestureRecognizer.new,
                    ),
                    Factory<TapGestureRecognizer>(
                      TapGestureRecognizer.new,
                    ),
                  },
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
