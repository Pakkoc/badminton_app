import 'package:flutter/material.dart';

/// 거트알림 앱 테마.
///
/// docs/design-system.md 기반 Material 3 테마 구현.
/// 라이트 모드만 지원한다.
class AppTheme {
  AppTheme._();

  // ── Primary (Sporty Blue) ─────────────────────
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryContainer = Color(0xFFEFF6FF);

  // ── Secondary (Warm Amber — 접수됨 상태 전용) ──
  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFCD34D);

  // ── Text ─────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF4A4A5A);
  static const textTertiary = Color(0xFF9CA3AF);

  // ── Background & Surface ─────────────────────
  static const background = Color(0xFFFBF8F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F0EB);

  // ── Border ───────────────────────────────────
  static const border = Color(0xFFE8E0D8);

  // ── Semantic ─────────────────────────────────
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2563EB);
  static const success = Color(0xFF10B981);

  // ── Social Login ─────────────────────────────
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // ── Status Badge ─────────────────────────────
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedText = Color(0xFF92400E);

  static const inProgressBackground = Color(0xFFEFF6FF);
  static const inProgressForeground = Color(0xFF2563EB);
  static const inProgressText = Color(0xFF1E40AF);

  static const completedBackground = Color(0xFFD1FAE5);
  static const completedForeground = Color(0xFF10B981);
  static const completedText = Color(0xFF065F46);

  // ── Font ────────────────────────────────────
  static const fontFamily = 'SUIT';

  /// @deprecated `courtGreen` → `primary`로 마이그레이션하세요.
  static const courtGreen = primary;

  /// 라이트 테마.
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: secondary,
          surface: surface,
          error: error,
        ),

        // Scaffold — 웜크림 배경
        scaffoldBackgroundColor: background,

        // AppBar — 흰색
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),

        // ElevatedButton (14px radius)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(
              color: primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // InputDecoration (14px radius)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: error,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // TextTheme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: textTertiary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),

        // Divider
        dividerColor: border,

        // Card (20px radius, subtle shadow)
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border, width: 0.5),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.05),
          color: surface,
        ),

        // BottomNavigationBar — 흰색
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: textTertiary,
        ),

        // FloatingActionButton — primary with glow
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),

        // Dialog (20px radius)
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // BottomSheet (20px top radius)
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
        ),

        // SnackBar — 다크 네이비
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textPrimary,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
