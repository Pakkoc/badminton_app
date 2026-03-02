import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    group('색상 상수', () {
      test('courtGreen이 #22C55E이다', () {
        // Arrange & Act & Assert
        expect(
          AppTheme.courtGreen,
          const Color(0xFF22C55E),
        );
      });

      test('textPrimary가 #1E293B이다', () {
        expect(
          AppTheme.textPrimary,
          const Color(0xFF1E293B),
        );
      });

      test('error가 #EF4444이다', () {
        expect(
          AppTheme.error,
          const Color(0xFFEF4444),
        );
      });

      test('border가 #E2E8F0이다', () {
        expect(
          AppTheme.border,
          const Color(0xFFE2E8F0),
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

      test('inProgress 상태 배경색이 #DBEAFE이다', () {
        expect(
          AppTheme.inProgressBackground,
          const Color(0xFFDBEAFE),
        );
      });

      test('completed 상태 배경색이 #DCFCE7이다', () {
        expect(
          AppTheme.completedBackground,
          const Color(0xFFDCFCE7),
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

      test('primary 색상이 courtGreen이다', () {
        // Assert
        expect(
          theme.colorScheme.primary,
          AppTheme.courtGreen,
        );
      });

      test('error 색상이 올바르다', () {
        // Assert
        expect(
          theme.colorScheme.error,
          AppTheme.error,
        );
      });

      test('scaffoldBackgroundColor가 white이다', () {
        // Assert
        expect(
          theme.scaffoldBackgroundColor,
          Colors.white,
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
