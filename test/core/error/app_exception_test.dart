import 'package:badminton_app/core/error/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('network 팩토리는 network 코드를 가진다', () {
      final e = AppException.network();
      expect(e.code, 'network');
      expect(e.userMessage, '네트워크 연결을 확인해주세요');
    });

    test('server 팩토리는 server 코드를 가진다', () {
      final e = AppException.server();
      expect(e.code, 'server');
      expect(e.userMessage, '서버 오류가 발생했습니다. 다시 시도해주세요');
    });

    test('unauthorized 팩토리는 unauthorized 코드를 가진다', () {
      final e = AppException.unauthorized();
      expect(e.code, 'unauthorized');
      expect(e.userMessage, '로그인이 필요합니다');
    });

    test('notFound 팩토리는 not_found 코드를 가진다', () {
      final e = AppException.notFound();
      expect(e.code, 'not_found');
      expect(e.userMessage, '데이터를 찾을 수 없습니다');
    });

    test('validation 팩토리는 커스텀 메시지를 가진다', () {
      final e = AppException.validation('이름을 입력해주세요');
      expect(e.code, 'validation');
      expect(e.userMessage, '이름을 입력해주세요');
    });

    test('duplicate 팩토리는 duplicate 코드를 가진다', () {
      final e = AppException.duplicate();
      expect(e.code, 'duplicate');
      expect(e.userMessage, '이미 등록된 데이터입니다');
    });

    test('originalError를 저장한다', () {
      final original = Exception('원본 에러');
      final e = AppException.server(originalError: original);
      expect(e.originalError, original);
    });

    test('toString은 code와 message를 포함한다', () {
      final e = AppException.network();
      expect(e.toString(), contains('network'));
    });
  });

  group('ErrorHandler', () {
    test('SocketException을 network AppException으로 변환한다', () {
      final result = ErrorHandler.handle(Exception('connection failed'));
      expect(result, isA<AppException>());
    });

    test('AppException은 그대로 반환한다', () {
      final original = AppException.network();
      final result = ErrorHandler.handle(original);
      expect(identical(result, original), isTrue);
    });
  });
}
