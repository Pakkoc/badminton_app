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
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 64),
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
                      const SizedBox(height: 16),
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
                _SocialLoginButton(
                  label: '카카오로 시작하기',
                  icon: '💬',
                  backgroundColor: AppTheme.kakaoYellow,
                  textColor: const Color(0xFF191919),
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
                  label: 'N  네이버로 시작하기',
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
                  label: 'G  Gmail로 시작하기',
                  backgroundColor: AppTheme.surfaceHigh,
                  textColor: AppTheme.textPrimary,
                  borderColor: const Color(0x30FFFFFF),
                  isLoading:
                      isLoading && loadingProvider == 'google',
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

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
    this.icon,
    this.borderColor,
  });

  final String label;
  final String? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
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
                  if (icon != null) ...[
                    Text(icon!, style: const TextStyle(
                      fontSize: 18,
                    )),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    icon != null
                        ? label.replaceFirst(
                            RegExp(r'^[^\s]+\s+'), '')
                        : label,
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
