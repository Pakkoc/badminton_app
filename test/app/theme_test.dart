import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    group('색상 상수', () {
      test('primary가 #2563EB이다', () {
        // Arrange & Act & Assert
        expect(
          AppTheme.primary,
          const Color(0xFF2563EB),
        );
      });

      test('textPrimary가 #1A1A2E이다', () {
        expect(
          AppTheme.textPrimary,
          const Color(0xFF1A1A2E),
        );
      });

      test('error가 #EF4444이다', () {
        expect(
          AppTheme.error,
          const Color(0xFFEF4444),
        );
      });

      test('border가 #E8E0D8이다', () {
        expect(
          AppTheme.border,
          const Color(0xFFE8E0D8),
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

    group('Status Badge 색상', () {
      test('received 상태 배경색이 #FEF3C7이다', () {
        expect(
          AppTheme.receivedBackground,
          const Color(0xFFFEF3C7),
        );
      });

      test('inProgress 상태 배경색이 #EFF6FF이다', () {
        expect(
          AppTheme.inProgressBackground,
          const Color(0xFFEFF6FF),
        );
      });

      test('completed 상태 배경색이 #D1FAE5이다', () {
        expect(
          AppTheme.completedBackground,
          const Color(0xFFD1FAE5),
        );
      });
    });

    group('lightTheme', () {
      late ThemeData theme;

      setUp(() {
        // Arrange
        theme = AppTheme.lightTheme;
      });

      test('Material 3을 사용한다', () {
        // Assert
        expect(theme.useMaterial3, isTrue);
      });

      test('primary 색상이 올바르다', () {
        // Assert
        expect(
          theme.colorScheme.primary,
          AppTheme.primary,
        );
      });

      test('error 색상이 올바르다', () {
        // Assert
        expect(
          theme.colorScheme.error,
          AppTheme.error,
        );
      });

      test('scaffoldBackgroundColor가 웜크림이다', () {
        // Assert
        expect(
          theme.scaffoldBackgroundColor,
          AppTheme.background,
        );
      });

      test('AppBar 배경이 white이다', () {
        // Assert
        expect(
          theme.appBarTheme.backgroundColor,
          Colors.white,
        );
      });

      test('AppBar가 centerTitle이다', () {
        // Assert
        expect(
          theme.appBarTheme.centerTitle,
          isTrue,
        );
      });

      test('AppBar elevation이 0이다', () {
        // Assert
        expect(
          theme.appBarTheme.elevation,
          0,
        );
      });

      test('dividerColor가 border이다', () {
        // Assert
        expect(
          theme.dividerColor,
          AppTheme.border,
        );
      });

      test('displayLarge fontSize가 32이다', () {
        // Assert
        expect(
          theme.textTheme.displayLarge?.fontSize,
          32,
        );
      });

      test('bodyMedium 색상이 textSecondary이다', () {
        // Assert
        expect(
          theme.textTheme.bodyMedium?.color,
          AppTheme.textSecondary,
        );
      });
    });
  });
}
