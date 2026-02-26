import 'dart:convert';

import 'package:badminton_app/core/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// 네이버 Geocoding API를 사용하여 주소를 좌표로 변환하는 서비스.
class GeocodingService {
  final http.Client _client;
  final String _clientId;
  final String _clientSecret;

  GeocodingService({
    http.Client? client,
    String? clientId,
    String? clientSecret,
  })  : _client = client ?? http.Client(),
        _clientId = clientId ?? Env.naverMapClientId,
        _clientSecret = clientSecret ?? Env.naverMapClientSecret;

  /// 주소를 위도/경도 좌표로 변환한다.
  ///
  /// 변환 성공 시 `(latitude, longitude)` 레코드를 반환하고,
  /// 실패 시 `null`을 반환한다.
  Future<({double latitude, double longitude})?> geocode(
    String address,
  ) async {
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      debugPrint('[Geocoding] 키가 비어있음: '
          'clientId=${_clientId.isEmpty}, '
          'clientSecret=${_clientSecret.isEmpty}');
      return null;
    }

    // 웹에서는 CORS로 인해 Geocoding API 호출 불가
    if (kIsWeb) {
      debugPrint('[Geocoding] 웹 환경이라 스킵');
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://maps.apigw.ntruss.com'
        '/map-geocode/v2/geocode',
      ).replace(queryParameters: {'query': address});

      debugPrint('[Geocoding] 요청: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': _clientId,
          'X-NCP-APIGW-API-KEY': _clientSecret,
        },
      );

      debugPrint('[Geocoding] 응답 코드: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Geocoding] 응답 본문: ${response.body}');
        return null;
      }

      final body =
          json.decode(response.body) as Map<String, dynamic>;
      final addresses = body['addresses'] as List<dynamic>?;

      if (addresses == null || addresses.isEmpty) {
        debugPrint('[Geocoding] 결과 없음: ${response.body}');
        return null;
      }

      final first = addresses[0] as Map<String, dynamic>;
      final x = double.tryParse(first['x'] as String? ?? '');
      final y = double.tryParse(first['y'] as String? ?? '');

      if (x == null || y == null) {
        debugPrint('[Geocoding] 좌표 파싱 실패: x=$x, y=$y');
        return null;
      }

      debugPrint('[Geocoding] 성공: lat=$y, lng=$x');
      return (latitude: y, longitude: x);
    } catch (e) {
      debugPrint('[Geocoding] 예외 발생: $e');
      return null;
    }
  }
}

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});
