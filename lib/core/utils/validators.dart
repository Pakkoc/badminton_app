/// 폼 필드 유효성 검증 유틸리티.
///
/// 모든 메서드는 유효하면 `null`, 유효하지 않으면 한국어 에러 메시지를 반환한다.
class Validators {
  Validators._();

  static final RegExp _phoneRegExp = RegExp(
    r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$',
  );

  /// 이름 검증: 2~20자 필수.
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    if (value.length > 20) {
      return '이름은 20자 이하여야 합니다';
    }
    return null;
  }

  /// 전화번호 검증: 010-XXXX-XXXX 또는 01XXXXXXXXX 형식.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    if (!_phoneRegExp.hasMatch(value)) {
      return '올바른 전화번호 형식이 아닙니다';
    }
    return null;
  }

  /// 샵 이름 검증: 1~50자 필수.
  static String? shopName(String? value) {
    if (value == null || value.isEmpty) {
      return '샵 이름을 입력해주세요';
    }
    if (value.length > 50) {
      return '샵 이름은 50자 이하여야 합니다';
    }
    return null;
  }

  /// 설명 검증: 선택 입력, 최대 200자.
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > 200) {
      return '설명은 200자 이하여야 합니다';
    }
    return null;
  }

  /// 게시글 제목 검증: 1~100자 필수.
  static String? postTitle(String? value) {
    if (value == null || value.isEmpty) {
      return '제목을 입력해주세요';
    }
    if (value.length > 100) {
      return '제목은 100자 이하여야 합니다';
    }
    return null;
  }

  /// 게시글 내용 검증: 1~2000자 필수.
  static String? postContent(String? value) {
    if (value == null || value.isEmpty) {
      return '내용을 입력해주세요';
    }
    if (value.length > 2000) {
      return '내용은 2000자 이하여야 합니다';
    }
    return null;
  }

  /// 메모 검증: 선택 입력, 최대 500자.
  static String? memo(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > 500) {
      return '메모는 500자 이하여야 합니다';
    }
    return null;
  }

  /// 상품명 검증: 1~50자 필수.
  static String? productName(String? value) {
    if (value == null || value.isEmpty) {
      return '상품명을 입력해주세요';
    }
    if (value.length > 50) {
      return '상품명은 50자 이하여야 합니다';
    }
    return null;
  }

  /// 수량 검증: 0~9999 정수 필수.
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) {
      return '수량을 입력해주세요';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return '숫자를 입력해주세요';
    }
    if (parsed < 0) {
      return '수량은 0 이상이어야 합니다';
    }
    if (parsed > 9999) {
      return '수량은 9999 이하여야 합니다';
    }
    return null;
  }
}
