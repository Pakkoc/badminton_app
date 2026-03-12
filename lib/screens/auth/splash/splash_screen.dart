import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/screens/auth/splash/splash_providers.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(SplashRoute route) {
    if (!mounted) return;
    final path = switch (route) {
      SplashRoute.login => '/login',
      SplashRoute.customerHome => '/customer/home',
      SplashRoute.ownerDashboard => '/owner/dashboard',
      SplashRoute.profileSetup => '/profile-setup',
    };
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SplashRoute>>(
      splashRouteProvider,
      (_, next) {
        next.whenData(_navigate);
      },
    );

    return Scaffold(
      body: CourtBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 77),
                  const Spacer(),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 124,
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
                  const SizedBox(height: 12),
                  const Text(
                    '배드민턴 거트 작업 실시간 추적',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Text(
                      '© 2026 거트알림',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
