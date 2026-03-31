import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    group('색상 상수', () {
      test('primary가 Court Green #2D5A27이다', () {
        expect(
          AppTheme.primary,
          const Color(0xFF2D5A27),
        );
      });

      test('accent가 Amber #F59E0B이다', () {
        expect(
          AppTheme.accent,
          const Color(0xFFF59E0B),
        );
      });

      test('textPrimary가 White 93% #FFFFFFEE이다', () {
        expect(
          AppTheme.textPrimary,
          const Color(0xEEFFFFFF),
        );
      });

      test('error가 #EF4444이다', () {
        expect(
          AppTheme.error,
          const Color(0xFFEF4444),
        );
      });

      test('border가 White 12% #20FFFFFF이다', () {
        expect(
          AppTheme.border,
          const Color(0x20FFFFFF),
        );
      });

      test('kakaoYellow가 #FEE500이다', () {
        expect(
          AppTheme.kakaoYellow,
          const Color(0xFFFEE500),
        );
      });

      test('naverGreen이 #03C75A이다', () {
        expect(
          AppTheme.naverGreen,
          const Color(0xFF03C75A),
        );
      });
    });

    group('Status Badge 색상 (Dark Court)', () {
      test('received 상태 배경색이 #422006이다', () {
        expect(
          AppTheme.receivedBackground,
          const Color(0xFF422006),
        );
      });

      test('inProgress 상태 배경색이 #1E3A5F이다', () {
        expect(
          AppTheme.inProgressBackground,
          const Color(0xFF1E3A5F),
        );
      });

      test('completed 상태 배경색이 #064E3B이다', () {
        expect(
          AppTheme.completedBackground,
          const Color(0xFF064E3B),
        );
      });
    });

    group('darkTheme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.darkTheme;
      });

      test('Material 3을 사용한다', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('brightness가 dark이다', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('primary 색상이 accent(Amber)이다', () {
        expect(
          theme.colorScheme.primary,
          AppTheme.accent,
        );
      });

      test('error 색상이 올바르다', () {
        expect(
          theme.colorScheme.error,
          AppTheme.error,
        );
      });

      test('scaffoldBackgroundColor가 다크 그린이다', () {
        expect(
          theme.scaffoldBackgroundColor,
          AppTheme.background,
        );
      });

      test('AppBar 배경이 background이다', () {
        expect(
          theme.appBarTheme.backgroundColor,
          AppTheme.background,
        );
      });

      test('AppBar가 좌측 정렬이다', () {
        expect(
          theme.appBarTheme.centerTitle,
          isFalse,
        );
      });

      test('AppBar elevation이 0이다', () {
        expect(
          theme.appBarTheme.elevation,
          0,
        );
      });

      test('dividerColor가 border이다', () {
        expect(
          theme.dividerColor,
          AppTheme.border,
        );
      });

      test('displayLarge fontSize가 32이다', () {
        expect(
          theme.textTheme.displayLarge?.fontSize,
          32,
        );
      });

      test('bodyMedium 색상이 textSecondary이다', () {
        expect(
          theme.textTheme.bodyMedium?.color,
          AppTheme.textSecondary,
        );
      });
    });

    group('lightTheme (deprecated)', () {
      test('darkTheme의 brightness와 동일하다', () {
        expect(
          AppTheme.lightTheme.brightness,
          AppTheme.darkTheme.brightness,
        );
      });
    });
  });
}
