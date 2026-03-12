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
                // 카카오 로그인 (공식 디자인 가이드 준수)
                _KakaoLoginButton(
                  isLoading:
                      isLoading && loadingProvider == 'kakao',
                  isDisabled: isLoading,
                  onPressed: () {
                    ref
                        .read(loginNotifierProvider.notifier)
                        .signInWithKakao();
                  },
                ),
                const SizedBox(height: 12),
                _SocialLoginButton(
                  iconWidget: const Text(
                    'N',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  label: '네이버 로그인',
                  backgroundColor: AppTheme.naverGreen,
                  textColor: Colors.white,
                  isLoading:
                      isLoading && loadingProvider == 'naver',
                  isDisabled: isLoading,
                  onPressed: () {
                    ref
                        .read(loginNotifierProvider.notifier)
                        .signInWithNaver();
                  },
                ),
                const SizedBox(height: 12),
                _SocialLoginButton(
                  iconWidget: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  label: 'Gmail로 시작',
                  backgroundColor: AppTheme.surfaceHigh,
                  textColor: AppTheme.textPrimary,
                  borderColor: const Color(0x30FFFFFF),
                  isLoading:
                      isLoading &&
                      loadingProvider == 'google',
                  isDisabled: isLoading,
                  onPressed: () {
                    ref
                        .read(loginNotifierProvider.notifier)
                        .signInWithGoogle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 카카오 공식 디자인 가이드 준수 버튼.
///
/// - 배경: #FEE500
/// - 심볼: 검정 말풍선 (CustomPaint)
/// - 텍스트: "카카오 로그인", #000000 85%
/// - cornerRadius: 12
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
                  // 카카오 공식 말풍선 심볼
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
                      color: Color(0xD9000000), // #000000 85%
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 카카오 말풍선 심볼 페인터.
class _KakaoSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 말풍선 본체 (타원)
    final bodyRect = Rect.fromLTWH(0, 0, w, h * 0.72);
    canvas.drawOval(bodyRect, paint);

    // 말풍선 꼬리 (삼각형, 왼쪽 하단)
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
