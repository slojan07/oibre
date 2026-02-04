import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';
import 'webview_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _overallFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo scale animation
    _logoController = AnimationController(
      duration: AppConstants.splashAnimationDuration,
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text fade animation
    _textController = AnimationController(
      duration: AppConstants.textFadeDuration,
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Overall fade out animation
    _fadeController = AnimationController(
      duration: AppConstants.fadeOutDuration,
      vsync: this,
    );

    _overallFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _startAnimation();
  }

  void _startAnimation() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // Navigate to main page after animations complete
    await Future.delayed(AppConstants.splashDelay);
    _fadeController.forward();

    await Future.delayed(AppConstants.fadeOutDuration);
    if (mounted) {
      AppUtils.navigateToScreenWithReplacementFade(context, const WebViewPage());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _overallFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _overallFadeAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.secondaryColor,
                    AppConstants.accentColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo/Icon
                    AnimatedBuilder(
                      animation: _logoScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.largeSpacing),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              boxShadow: const [AppConstants.strongShadow],
                            ),
                            child: const Icon(
                              Icons.business_center,
                              size: AppConstants.logoSize,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppConstants.extraLargeSpacing),

                    // Animated App Name
                    AnimatedBuilder(
                      animation: _textFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Column(
                            children: [
                              const Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppConstants.mediumSpacing),
                              Text(
                                AppConstants.appSubtitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppConstants.hugeSpacing),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}