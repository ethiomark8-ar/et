import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _ribbonController;
  late AnimationController _loaderController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;
  late Animation<double> _ribbonOffset;
  late Animation<double> _loaderProgress;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ribbonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _ribbonOffset = Tween<double>(begin: -300.0, end: 0.0).animate(
      CurvedAnimation(parent: _ribbonController, curve: Curves.easeOutCubic),
    );
    _loaderProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _glowController.repeat(reverse: true);
    _ribbonController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _loaderController.forward();

    await Future.delayed(AppConstants.splashDuration);
    _navigate();
  }

  void _navigate() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _fadeController.forward();
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(RouteConstants.home);
    } else {
      context.go(RouteConstants.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _ribbonController.dispose();
    _loaderController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOut,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // AMOLED Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [Color(0xFF0A0A1A), Colors.black],
                ),
              ),
            ),

            // Glow overlay
            AnimatedBuilder(
              animation: _glowOpacity,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        AppColors.primaryGradientStart.withOpacity(
                          0.08 * _glowOpacity.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Ribbon sweep
            AnimatedBuilder(
              animation: _ribbonOffset,
              builder: (context, _) {
                return Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.35,
                  left: _ribbonOffset.value,
                  right: -_ribbonOffset.value,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.secondaryAccent,
                          AppColors.notificationYellow,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo area
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoScale, _logoOpacity]),
                    builder: (context, _) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Column(
                            children: [
                              // App Icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryAccent.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_rounded,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Gradient Logo Text
                              _buildGradientText(),

                              const SizedBox(height: 8),

                              // Tagline
                              Text(
                                'Ethiopia\'s Premier Marketplace',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom loading bar
            Positioned(
              bottom: 60,
              left: 48,
              right: 48,
              child: AnimatedBuilder(
                animation: _loaderProgress,
                builder: (context, _) {
                  return Column(
                    children: [
                      // Loader container
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _loaderProgress.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondaryAccent,
                                    AppColors.notificationYellow,
                                    AppColors.secondaryAccent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Version
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'v${AppConstants.appVersion}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00CFFF), Color(0xFF4C6FFF)],
          ).createShader(bounds),
          child: const Text(
            'Ethio',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFF6B6B), Color(0xFFFF2D87)],
          ).createShader(bounds),
          child: const Text(
            'Shop',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
      ],
    );
  }
}
