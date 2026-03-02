import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/screens/auth/login/login_notifier.dart';
import 'package:badminton_app/screens/auth/login/login_state.dart';
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
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(
                Icons.sports_tennis,
                size: 56,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                '거트알림',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '반갑습니다!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '간편하게 시작하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              _SocialLoginButton(
                label: '카카오로 시작하기',
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
                label: '네이버로 시작하기',
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
                label: 'Gmail로 시작하기',
                backgroundColor: AppTheme.surface,
                textColor: AppTheme.textPrimary,
                borderColor: AppTheme.border,
                isLoading:
                    isLoading && loadingProvider == 'google',
                isDisabled: isLoading,
                onPressed: () {
                  ref
                      .read(loginNotifierProvider.notifier)
                      .signInWithGoogle();
                },
              ),
              const Spacer(),
            ],
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
    this.borderColor,
  });

  final String label;
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
            borderRadius: BorderRadius.circular(20),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
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
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
