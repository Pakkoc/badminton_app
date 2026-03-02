import 'package:flutter/material.dart';

/// 거트알림 앱 테마.
///
/// docs/design-system.md 기반 Material 3 테마 구현.
/// 라이트 모드만 지원한다.
class AppTheme {
  AppTheme._();

  // ── Primary (Green) ──────────────────────────
  static const courtGreen = Color(0xFF22C55E);
  static const primaryLight = Color(0xFF86EFAC);
  static const primaryDark = Color(0xFF16A34A);
  static const primaryContainer = Color(0xFFF0FDF4);

  // ── Secondary (Orange CTA) ───────────────────
  static const secondary = Color(0xFFFB923C);
  static const secondaryLight = Color(0xFFFDBA74);

  // ── Text ─────────────────────────────────────
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);

  // ── Background & Surface ─────────────────────
  static const background = Color(0xFFFAFDF7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0FDF4);

  // ── Border ───────────────────────────────────
  static const border = Color(0xFFE2E8F0);

  // ── Semantic ─────────────────────────────────
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const success = Color(0xFF22C55E);

  // ── Social Login ─────────────────────────────
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // ── Status Badge ─────────────────────────────
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedText = Color(0xFF92400E);

  static const inProgressBackground = Color(0xFFDBEAFE);
  static const inProgressForeground = Color(0xFF3B82F6);
  static const inProgressText = Color(0xFF1E40AF);

  static const completedBackground = Color(0xFFDCFCE7);
  static const completedForeground = Color(0xFF22C55E);
  static const completedText = Color(0xFF166534);

  // ── Font ────────────────────────────────────
  static const fontFamily = 'SUIT';

  /// 라이트 테마.
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: courtGreen,
          brightness: Brightness.light,
          primary: courtGreen,
          secondary: secondary,
          surface: surface,
          error: error,
        ),

        // Scaffold
        scaffoldBackgroundColor: Colors.white,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
        ),

        // ElevatedButton (14px radius)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: courtGreen,
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
            foregroundColor: courtGreen,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(
              color: courtGreen,
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
              color: courtGreen,
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

        // Card (20px radius, shadow instead of border)
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.06),
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: courtGreen,
          unselectedItemColor: textTertiary,
        ),
      );
}
