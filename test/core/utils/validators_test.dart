import 'package:badminton_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.name', () {
    test('정상 이름은 null을 반환한다', () {
      expect(Validators.name('홍길동'), isNull);
      expect(Validators.name('AB'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name(null), isNotNull);
    });
    test('1자 이름은 에러 메시지를 반환한다', () {
      expect(Validators.name('홍'), isNotNull);
    });
    test('21자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.name('가' * 21), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('정상 전화번호는 null을 반환한다', () {
      expect(Validators.phone('01012345678'), isNull);
      expect(Validators.phone('010-1234-5678'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
    });
    test('잘못된 형식은 에러 메시지를 반환한다', () {
      expect(Validators.phone('0101234'), isNotNull);
      expect(Validators.phone('12345678901'), isNotNull);
    });
  });

  group('Validators.shopName', () {
    test('정상 샵 이름은 null을 반환한다', () {
      expect(Validators.shopName('거트 프로샵'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.shopName(''), isNotNull);
    });
    test('51자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.shopName('가' * 51), isNotNull);
    });
  });

  group('Validators.description', () {
    test('빈 문자열은 null을 반환한다 (허용)', () {
      expect(Validators.description(''), isNull);
      expect(Validators.description(null), isNull);
    });
    test('201자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.description('가' * 201), isNotNull);
    });
  });

  group('Validators.postTitle', () {
    test('정상 제목은 null을 반환한다', () {
      expect(Validators.postTitle('공지사항'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.postTitle(''), isNotNull);
    });
    test('101자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.postTitle('가' * 101), isNotNull);
    });
  });

  group('Validators.postContent', () {
    test('정상 내용은 null을 반환한다', () {
      expect(Validators.postContent('내용입니다'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.postContent(''), isNotNull);
    });
    test('2001자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.postContent('가' * 2001), isNotNull);
    });
  });

  group('Validators.memo', () {
    test('빈 문자열은 null을 반환한다 (허용)', () {
      expect(Validators.memo(''), isNull);
      expect(Validators.memo(null), isNull);
    });
    test('501자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.memo('가' * 501), isNotNull);
    });
  });

  group('Validators.productName', () {
    test('정상 상품명은 null을 반환한다', () {
      expect(Validators.productName('BG65'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.productName(''), isNotNull);
    });
    test('51자 이상은 에러 메시지를 반환한다', () {
      expect(Validators.productName('가' * 51), isNotNull);
    });
  });

  group('Validators.quantity', () {
    test('정상 수량은 null을 반환한다', () {
      expect(Validators.quantity('0'), isNull);
      expect(Validators.quantity('100'), isNull);
      expect(Validators.quantity('9999'), isNull);
    });
    test('빈 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.quantity(''), isNotNull);
    });
    test('음수는 에러 메시지를 반환한다', () {
      expect(Validators.quantity('-1'), isNotNull);
    });
    test('10000 이상은 에러 메시지를 반환한다', () {
      expect(Validators.quantity('10000'), isNotNull);
    });
    test('숫자가 아닌 문자열은 에러 메시지를 반환한다', () {
      expect(Validators.quantity('abc'), isNotNull);
    });
  });
}
