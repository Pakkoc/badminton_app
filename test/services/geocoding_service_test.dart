import 'dart:convert';

import 'package:badminton_app/services/geocoding_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _utf8Response(String body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('GeocodingService', () {
    test('정상 응답 시 위도와 경도를 반환한다', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(
          request.url.host,
          'naveropenapi.apigw.ntruss.com',
        );
        expect(
          request.headers['X-NCP-APIGW-API-KEY-ID'],
          'test-id',
        );
        expect(
          request.headers['X-NCP-APIGW-API-KEY'],
          'test-secret',
        );

        return _utf8Response(
          json.encode({
            'status': 'OK',
            'meta': {'totalCount': 1},
            'addresses': [
              {
                'roadAddress': '서울특별시 강남구 역삼동 123',
                'x': '127.0276',
                'y': '37.4979',
              },
            ],
          }),
          200,
        );
      });

      final service = GeocodingService(
        client: mockClient,
        clientId: 'test-id',
        clientSecret: 'test-secret',
      );

      // Act
      final result = await service.geocode('서울시 강남구 역삼동');

      // Assert
      expect(result, isNotNull);
      expect(result!.latitude, 37.4979);
      expect(result.longitude, 127.0276);
    });

    test('빈 addresses 응답 시 null을 반환한다', () async {
      // Arrange
      final mockClient = MockClient((_) async {
        return _utf8Response(
          json.encode({
            'status': 'OK',
            'meta': {'totalCount': 0},
            'addresses': <dynamic>[],
          }),
          200,
        );
      });

      final service = GeocodingService(
        client: mockClient,
        clientId: 'test-id',
        clientSecret: 'test-secret',
      );

      // Act
      final result = await service.geocode('존재하지않는주소');

      // Assert
      expect(result, isNull);
    });

    test('HTTP 에러 시 null을 반환한다', () async {
      // Arrange
      final mockClient = MockClient((_) async {
        return _utf8Response('Server Error', 500);
      });

      final service = GeocodingService(
        client: mockClient,
        clientId: 'test-id',
        clientSecret: 'test-secret',
      );

      // Act
      final result = await service.geocode('서울시 강남구');

      // Assert
      expect(result, isNull);
    });

    test('네트워크 예외 시 null을 반환한다', () async {
      // Arrange
      final mockClient = MockClient((_) async {
        throw Exception('Network error');
      });

      final service = GeocodingService(
        client: mockClient,
        clientId: 'test-id',
        clientSecret: 'test-secret',
      );

      // Act
      final result = await service.geocode('서울시 강남구');

      // Assert
      expect(result, isNull);
    });

    test('clientId가 빈 문자열이면 null을 반환한다', () async {
      // Arrange
      final service = GeocodingService(
        clientId: '',
        clientSecret: 'test-secret',
      );

      // Act
      final result = await service.geocode('서울시 강남구');

      // Assert
      expect(result, isNull);
    });

    test('clientSecret이 빈 문자열이면 null을 반환한다', () async {
      // Arrange
      final service = GeocodingService(
        clientId: 'test-id',
        clientSecret: '',
      );

      // Act
      final result = await service.geocode('서울시 강남구');

      // Assert
      expect(result, isNull);
    });
  });
}
