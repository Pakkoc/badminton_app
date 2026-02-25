import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 카카오(다음) 우편번호 서비스를 웹뷰로 표시하여
/// 주소를 검색하는 서비스.
class AddressSearchService {
  const AddressSearchService();

  /// 주소 검색 바텀시트를 표시하고 선택된 주소를 반환한다.
  ///
  /// 사용자가 주소를 선택하지 않고 닫으면 `null`을 반환한다.
  Future<String?> searchAddress(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) => const _AddressSearchBottomSheet(),
    );
  }
}

class _AddressSearchBottomSheet extends StatefulWidget {
  const _AddressSearchBottomSheet();

  @override
  State<_AddressSearchBottomSheet> createState() =>
      _AddressSearchBottomSheetState();
}

class _AddressSearchBottomSheetState
    extends State<_AddressSearchBottomSheet> {
  late final WebViewController _controller;

  static const _html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
    content="width=device-width, initial-scale=1.0,
    maximum-scale=1.0, user-scalable=no">
  <style>
    body { margin: 0; padding: 0; }
  </style>
</head>
<body>
  <div id="wrap" style="width:100%;height:100vh;"></div>
  <script
    src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js">
  </script>
  <script>
    new daum.Postcode({
      oncomplete: function(data) {
        var address = data.roadAddress || data.jibunAddress;
        AddressCallback.postMessage(address);
      },
      onclose: function() {
        CloseCallback.postMessage('close');
      },
      width: '100%',
      height: '100%'
    }).embed(document.getElementById('wrap'));
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AddressCallback',
        onMessageReceived: (message) {
          if (mounted) {
            Navigator.of(context).pop(message.message);
          }
        },
      )
      ..addJavaScriptChannel(
        'CloseCallback',
        onMessageReceived: (_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      )
      ..loadHtmlString(_html);
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
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
