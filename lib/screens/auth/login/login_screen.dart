import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/screens/auth/login/login_notifier.dart';
import 'package:badminton_app/screens/auth/login/login_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);

    ref.listen<LoginState>(
      loginNotifierProvider,
      (_, next) {
        next.whenOrNull(
          error: (message) {
            AppToast.error(context, message);
          },
        );
      },
    );

    final isLoading = loginState.maybeWhen(
      authenticating: (_) => true,
      orElse: () => false,
    );

    final loadingProvider = loginState.maybeWhen(
      authenticating: (provider) => provider,
      orElse: () => null,
    );

    // TODO: 확인 후 아래 줄 제거하고 Platform.isIOS 로 복원
    const bool isIOS = true; // ignore: dead_code

    return Scaffold(
      body: CourtBackground(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(28, 24, 28, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 48,
                              height: 48,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '거트알림',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '반갑습니다!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '간편하게 시작하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // iOS: Apple 로그인 (최상단) + 구분선
                if (isIOS) ...[
                  _AppleLoginButton(
                    isLoading: isLoading &&
                        loadingProvider == 'apple',
                    isDisabled: isLoading,
                    onPressed: () => ref
                        .read(loginNotifierProvider.notifier)
                        .signInWithApple(),
                  ),
                  const SizedBox(height: 12),
                  const _Divider(),
                  const SizedBox(height: 12),
                ],

                // 카카오 로그인 (공식 디자인 가이드)
                _KakaoLoginButton(
                  isLoading:
                      isLoading && loadingProvider == 'kakao',
                  isDisabled: isLoading,
                  onPressed: () => ref
                      .read(loginNotifierProvider.notifier)
                      .signInWithKakao(),
                ),
                const SizedBox(height: 12),
                _SocialLoginButton(
                  iconWidget: const _NaverIcon(),
                  label: '네이버 로그인',
                  backgroundColor: AppTheme.naverGreen,
                  textColor: Colors.white,
                  isLoading:
                      isLoading && loadingProvider == 'naver',
                  isDisabled: isLoading,
                  onPressed: () => ref
                      .read(loginNotifierProvider.notifier)
                      .signInWithNaver(),
                ),
                const SizedBox(height: 12),
                _SocialLoginButton(
                  iconWidget: const _GoogleIcon(),
                  label: 'Gmail로 시작',
                  backgroundColor: AppTheme.surfaceHigh,
                  textColor: AppTheme.textPrimary,
                  borderColor: const Color(0x30FFFFFF),
                  isLoading: isLoading &&
                      loadingProvider == 'google',
                  isDisabled: isLoading,
                  onPressed: () => ref
                      .read(loginNotifierProvider.notifier)
                      .signInWithGoogle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple 로그인 버튼 (iOS 전용, Apple HIG 준수).
///
/// - 배경: #000000, 텍스트: #FFFFFF
/// - Apple 로고 + "Apple로 로그인"
/// - cornerRadius: 12, height: 52
class _AppleLoginButton extends StatelessWidget {
  const _AppleLoginButton({
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Colors.black.withValues(alpha: 0.6),
          disabledForegroundColor:
              Colors.white.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    size: 22,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Apple로 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 카카오 로그인 버튼 (공식 디자인 가이드 준수).
class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: Colors.black,
          disabledBackgroundColor:
              const Color(0xFFFEE500).withValues(alpha: 0.6),
          disabledForegroundColor:
              Colors.black.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black87,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(
                      painter: _KakaoSymbolPainter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '카카오 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xD9000000),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 카카오 말풍선 심볼 (공식).
class _KakaoSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromLTWH(0, 0, w, h * 0.72),
      paint,
    );

    final tailPath = Path()
      ..moveTo(w * 0.25, h * 0.62)
      ..lineTo(w * 0.15, h * 0.92)
      ..lineTo(w * 0.45, h * 0.65)
      ..close();
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}

/// 네이버 'N' 아이콘.
class _NaverIcon extends StatelessWidget {
  const _NaverIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Google 'G' 아이콘.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// "또는" 구분선 (iOS 화면에서 Apple ↔ 기타 버튼 사이).
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0x40FFFFFF),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 12,
              color: Color(0x80FFFFFF),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0x40FFFFFF),
          ),
        ),
      ],
    );
  }
}

/// 범용 소셜 로그인 버튼.
class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
    this.iconWidget,
    this.borderColor,
  });

  final String label;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor:
              backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor:
              textColor.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(
                    color: borderColor!,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconWidget != null) ...[
                    iconWidget!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
