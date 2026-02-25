import 'dart:convert';

import 'package:badminton_app/core/config/env.dart';
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
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://naveropenapi.apigw.ntruss.com'
        '/map-geocode/v2/geocode',
      ).replace(queryParameters: {'query': address});

      final response = await _client.get(
        uri,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': _clientId,
          'X-NCP-APIGW-API-KEY': _clientSecret,
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final body =
          json.decode(response.body) as Map<String, dynamic>;
      final addresses = body['addresses'] as List<dynamic>?;

      if (addresses == null || addresses.isEmpty) {
        return null;
      }

      final first = addresses[0] as Map<String, dynamic>;
      final x = double.tryParse(first['x'] as String? ?? '');
      final y = double.tryParse(first['y'] as String? ?? '');

      if (x == null || y == null) {
        return null;
      }

      return (latitude: y, longitude: x);
    } catch (_) {
      return null;
    }
  }
}

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});
