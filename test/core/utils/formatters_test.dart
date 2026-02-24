import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_app/core/utils/formatters.dart';

void main() {
  group('Formatters.relativeTime', () {
    test('1분 미만은 "방금 전"을 반환한다', () {
      final now = DateTime.now();
      expect(Formatters.relativeTime(now), '방금 전');
    });
    test('5분 전은 "5분 전"을 반환한다', () {
      final fiveMinAgo = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      expect(Formatters.relativeTime(fiveMinAgo), '5분 전');
    });
    test('2시간 전은 "2시간 전"을 반환한다', () {
      final twoHoursAgo = DateTime.now().subtract(
        const Duration(hours: 2),
      );
      expect(Formatters.relativeTime(twoHoursAgo), '2시간 전');
    });
    test('3일 전은 "3일 전"을 반환한다', () {
      final threeDaysAgo = DateTime.now().subtract(
        const Duration(days: 3),
      );
      expect(Formatters.relativeTime(threeDaysAgo), '3일 전');
    });
  });

  group('Formatters.dateTime', () {
    test('MM/DD HH:mm 형식을 반환한다', () {
      final dt = DateTime(2026, 3, 15, 14, 30);
      expect(Formatters.dateTime(dt), '03/15 14:30');
    });
  });

  group('Formatters.date', () {
    test('YYYY.MM.DD 형식을 반환한다', () {
      final dt = DateTime(2026, 3, 15);
      expect(Formatters.date(dt), '2026.03.15');
    });
  });

  group('Formatters.phone', () {
    test('11자리 전화번호에 하이픈을 삽입한다', () {
      expect(Formatters.phone('01012345678'), '010-1234-5678');
    });
    test('이미 하이픈이 있는 번호는 그대로 반환한다', () {
      expect(Formatters.phone('010-1234-5678'), '010-1234-5678');
    });
  });

  group('Formatters.phoneRaw', () {
    test('하이픈이 있는 번호에서 하이픈을 제거한다', () {
      expect(Formatters.phoneRaw('010-1234-5678'), '01012345678');
    });
    test('하이픈이 없는 번호는 그대로 반환한다', () {
      expect(Formatters.phoneRaw('01012345678'), '01012345678');
    });
  });
}
