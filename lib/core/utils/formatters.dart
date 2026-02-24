/// 표시 포맷 유틸리티.
///
/// 날짜, 시간, 전화번호 등을 사용자에게 보여주기 위한 포맷 변환.
class Formatters {
  Formatters._();

  /// 상대 시간 문자열을 반환한다.
  ///
  /// - 1분 미만: "방금 전"
  /// - 60분 미만: "N분 전"
  /// - 24시간 미만: "N시간 전"
  /// - 그 외: "N일 전"
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '방금 전';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    }
    return '${diff.inDays}일 전';
  }

  /// `MM/DD HH:mm` 형식으로 반환한다.
  static String dateTime(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  /// `YYYY.MM.DD` 형식으로 반환한다.
  static String date(DateTime dt) {
    final year = dt.year.toString();
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  /// 전화번호에 하이픈을 삽입하여 `010-1234-5678` 형식으로 반환한다.
  static String phone(String value) {
    if (value.contains('-')) {
      return value;
    }
    if (value.length == 11) {
      return '${value.substring(0, 3)}-'
          '${value.substring(3, 7)}-'
          '${value.substring(7)}';
    }
    return value;
  }

  /// 전화번호에서 하이픈을 제거한다.
  static String phoneRaw(String value) => value.replaceAll('-', '');
}
