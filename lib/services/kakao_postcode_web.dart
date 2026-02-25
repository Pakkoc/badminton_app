import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 웹 환경에서 카카오(다음) 우편번호 서비스를 호출한다.
///
/// index.html에 postcode.v2.js와 _openDaumPostcode 헬퍼가
/// 로드되어 있어야 한다.
Future<String?> openKakaoPostcode() async {
  final completer = Completer<String?>();

  // JS에서 주소 문자열을 직접 전달받는다.
  void onComplete(JSString address) {
    final result = address.toDart;
    if (!completer.isCompleted) {
      completer.complete(result.isNotEmpty ? result : null);
    }
    _removeOverlay();
  }

  void onClose(JSString state) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
    _removeOverlay();
  }

  // 오버레이 생성
  final overlay = _createOverlay(() {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
    _removeOverlay();
  });
  web.document.body?.append(overlay);

  final container =
      web.document.getElementById('kakao-postcode-layer')!;

  // index.html의 _openDaumPostcode 헬퍼 호출
  _openDaumPostcode(
    onComplete.toJS,
    onClose.toJS,
    container,
  );

  return completer.future;
}

@JS('_openDaumPostcode')
external void _openDaumPostcode(
  JSFunction onComplete,
  JSFunction onClose,
  web.Element container,
);

/// 오버레이 DOM을 생성한다.
web.HTMLDivElement _createOverlay(void Function() onDismiss) {
  final overlay = web.document.createElement('div')
      as web.HTMLDivElement;
  overlay.id = 'kakao-postcode-overlay';
  overlay.style
    ..position = 'fixed'
    ..top = '0'
    ..left = '0'
    ..width = '100%'
    ..height = '100%'
    ..backgroundColor = 'rgba(0,0,0,0.5)'
    ..display = 'flex'
    ..alignItems = 'flex-end'
    ..justifyContent = 'center'
    ..zIndex = '99999';

  final container = web.document.createElement('div')
      as web.HTMLDivElement;
  container.id = 'kakao-postcode-layer';
  container.style
    ..width = '100%'
    ..maxWidth = '500px'
    ..height = '80vh'
    ..backgroundColor = 'white'
    ..borderRadius = '16px 16px 0 0'
    ..overflow = 'hidden';

  overlay.addEventListener(
    'click',
    (web.Event event) {
      if (event.target == overlay) {
        onDismiss();
      }
    }.toJS,
  );

  overlay.append(container);
  return overlay;
}

/// 오버레이를 제거한다.
void _removeOverlay() {
  web.document
      .getElementById('kakao-postcode-overlay')
      ?.remove();
}
