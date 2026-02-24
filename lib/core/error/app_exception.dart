export 'error_handler.dart';

/// 앱 공통 에러 클래스.
///
/// 모든 에러를 통일된 형태로 래핑하여 사용자 메시지와 에러 코드를 제공한다.
class AppException implements Exception {
  /// 에러 코드 (network, server, unauthorized, not_found, validation, duplicate).
  final String code;

  /// 디버그용 메시지.
  final String message;

  /// 사용자에게 표시할 한국어 메시지.
  final String userMessage;

  /// 원본 에러 객체.
  final Object? originalError;

  const AppException({
    required this.code,
    required this.message,
    required this.userMessage,
    this.originalError,
  });

  /// 네트워크 에러.
  factory AppException.network({Object? originalError}) =>
      AppException(
        code: 'network',
        message: 'Network error',
        userMessage: '네트워크 연결을 확인해주세요',
        originalError: originalError,
      );

  /// 서버 에러.
  factory AppException.server({Object? originalError}) =>
      AppException(
        code: 'server',
        message: 'Server error',
        userMessage: '서버 오류가 발생했습니다. 다시 시도해주세요',
        originalError: originalError,
      );

  /// 인증 에러.
  factory AppException.unauthorized({Object? originalError}) =>
      AppException(
        code: 'unauthorized',
        message: 'Unauthorized',
        userMessage: '로그인이 필요합니다',
        originalError: originalError,
      );

  /// 데이터 없음 에러.
  factory AppException.notFound({Object? originalError}) =>
      AppException(
        code: 'not_found',
        message: 'Not found',
        userMessage: '데이터를 찾을 수 없습니다',
        originalError: originalError,
      );

  /// 유효성 검증 에러.
  factory AppException.validation(
    String userMessage, {
    Object? originalError,
  }) => AppException(
    code: 'validation',
    message: 'Validation error: $userMessage',
    userMessage: userMessage,
    originalError: originalError,
  );

  /// 중복 데이터 에러.
  factory AppException.duplicate({Object? originalError}) =>
      AppException(
        code: 'duplicate',
        message: 'Duplicate entry',
        userMessage: '이미 등록된 데이터입니다',
        originalError: originalError,
      );

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
