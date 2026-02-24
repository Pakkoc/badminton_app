import 'package:badminton_app/core/error/app_exception.dart';

/// 에러를 [AppException]으로 변환하는 핸들러.
class ErrorHandler {
  ErrorHandler._();

  /// [error]를 [AppException]으로 변환한다.
  ///
  /// - [AppException]은 그대로 반환한다.
  /// - 기타 에러는 server 에러로 래핑한다.
  static AppException handle(Object error) {
    if (error is AppException) {
      return error;
    }

    return AppException.server(originalError: error);
  }
}
