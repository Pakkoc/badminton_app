import 'package:flutter/material.dart';

/// 거트알림 앱 테마.
///
/// docs/design-system.md 기반 Material 3 다크 그린 배드민턴 코트 테마.
class AppTheme {
  AppTheme._();

  // ── Primary (Court Green) ─────────────────────
  static const primary = Color(0xFF2D5A27);
  static const primaryLight = Color(0xFF3D7A35);

  // ── Accent (Amber — CTA, 다이얼로그 아이콘) ───
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // ── Active Tab ────────────────────────────────
  static const activeTab = Color(0xFF22C55E);

  // ── CTA Button ──────────────────────────────
  static const primaryCta = Color(0xFF16A34A);

  // ── Background (Court Green gradient) ──────
  static const backgroundStart = Color(0xFF1B5E30);
  static const backgroundEnd = Color(0xFF1B5E30);
  static const background = Color(0xFF1B5E30);

  // ── Surface (Opaque Dark Green) ───────────────
  // 기존 white overlay를 #1B5E30 위에 합성한 불투명 등가색.
  // 코트 라인이 카드를 관통하지 않도록 불투명 처리.
  static const surface = Color(0xFF2E6B41);
  static const surfaceHigh = Color(0xFF306D44);
  static const surfaceBorder = Color(0x20FFFFFF);
  static const surfaceVariant = Color(0xFF29683D);

  // ── Dialog ────────────────────────────────────
  static const dialogSurface = Color(0xFF1A2E1A);

  // ── Text (White Variants) ─────────────────────
  static const textPrimary = Color(0xEEFFFFFF);
  static const textSecondary = Color(0xCCFFFFFF);
  static const textTertiary = Color(0xAAFFFFFF);
  static const textHint = Color(0x88FFFFFF);
  static const textDisabled = Color(0x66FFFFFF);
  static const textInactive = Color(0x80FFFFFF);

  // ── Court Line (장식) ─────────────────────────
  static const courtLine = Color(0xA3FFFFFF);

  // ── Border ────────────────────────────────────
  static const border = Color(0x20FFFFFF);

  // ── Shadow ──────────────────────────────────
  static const shadowSubtle = Color(0x0A000000);

  // ── Semantic ──────────────────────────────────
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const info = Color(0xFF3B82F6);

  // ── Social Login ──────────────────────────────
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // ── Status Badge (Dark Court 최적화) ──────────
  static const receivedBackground = Color(0xFF422006);
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedText = Color(0xFFFCD34D);

  static const inProgressBackground = Color(0xFF1E3A5F);
  static const inProgressForeground = Color(0xFF60A5FA);
  static const inProgressText = Color(0xFF93C5FD);

  static const completedBackground = Color(0xFF064E3B);
  static const completedForeground = Color(0xFF34D399);
  static const completedText = Color(0xFF6EE7B7);

  // ── Legacy Compat ──────────────────────────────
  /// @deprecated `primaryContainer` → `surfaceHigh`로 마이그레이션.
  static const primaryContainer = surfaceHigh;

  // ── Font ──────────────────────────────────────
  static const fontFamily = 'Pretendard';

  // ── Gradient ──────────────────────────────────
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );

  /// 다크 그린 배드민턴 코트 테마.
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: activeTab,
          surface: dialogSurface,
          error: error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
        ),

        // Scaffold — 다크 그린 단색 (그라디언트는 CourtBackground에서)
        scaffoldBackgroundColor: background,

        // AppBar — 글래스
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceHigh,
          foregroundColor: textSecondary,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          shape: const Border(
            bottom: BorderSide(
              color: surfaceBorder,
              width: 0.5,
            ),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textSecondary,
          ),
          iconTheme: const IconThemeData(
            color: textSecondary,
          ),
        ),

        // ElevatedButton — Amber CTA (14px radius)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // OutlinedButton — 글래스 테두리
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textSecondary,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(
              color: Color(0x40FFFFFF),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accent,
          ),
        ),

        // InputDecoration — 글래스 테두리 (14px radius)
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
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
              color: accent,
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
          focusedErrorBorder: OutlineInputBorder(
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
          hintStyle: const TextStyle(color: textHint),
          labelStyle: const TextStyle(color: textTertiary),
        ),

        // TextTheme — White variants
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
            color: textHint,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),

        // Divider
        dividerColor: border,

        // Card — 글래스 (16px radius)
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: surfaceHigh,
        ),

        // BottomNavigationBar — 글래스
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: activeTab,
          unselectedItemColor: textInactive,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),

        // FloatingActionButton — 밝은 그린
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: activeTab,
          foregroundColor: Colors.white,
        ),

        // Dialog — 다크 그린
        dialogTheme: DialogThemeData(
          backgroundColor: dialogSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          contentTextStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            color: textTertiary,
          ),
        ),

        // BottomSheet — 다크 그린
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: dialogSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
        ),

        // SnackBar — 다크 그린
        snackBarTheme: SnackBarThemeData(
          backgroundColor: dialogSurface,
          contentTextStyle: const TextStyle(
            fontFamily: fontFamily,
            color: textPrimary,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent;
            }
            return textDisabled;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent.withValues(alpha: 0.3);
            }
            return surfaceBorder;
          }),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: textInactive, width: 1.5),
        ),

        // TabBar
        tabBarTheme: const TabBarThemeData(
          labelColor: textPrimary,
          unselectedLabelColor: textInactive,
          indicatorColor: accent,
        ),

        // ProgressIndicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accent,
          linearTrackColor: surfaceBorder,
        ),
      );

  /// 현재 다크 테마 단일 지원 (docs/design-system.md 참조)
  /// 라이트 테마가 필요할 때 별도 구현 예정
  static ThemeData get lightTheme => darkTheme;
}
