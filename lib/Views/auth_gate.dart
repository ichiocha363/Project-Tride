import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Constants/app_typography.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_utama.dart';
import 'package:project_tride/Views/halaman_login.dart';
import 'package:project_tride/utils/session_manager.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _nameFadeAnimation;
  late Animation<double> _nameScaleAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashAndSessionCheck();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 1 & 2. Logo Fade in (0.0 -> 0.45) & Scale (0.85 -> 1.0)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Name Fade in & subtle scale (0.35 -> 0.75)
    _nameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _nameScaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Tagline Fade in & Slide up (0.60 -> 0.95)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.95, curve: Curves.easeOut),
      ),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.95, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> _startSplashAndSessionCheck() async {
    // Jalankan animasi splash
    _controller.forward();

    final DateTime startTime = DateTime.now();

    // Periksa status persistent login session
    bool isLoggedIn = false;
    UserModel? currentUser;

    try {
      isLoggedIn = await SessionManager.isLoggedIn();
      if (isLoggedIn) {
        currentUser = await SessionManager.getCurrentUser();
        // Jika data user tidak ditemukan di SQLite, anggap session invalid
        if (currentUser == null) {
          await SessionManager.clearSession();
          isLoggedIn = false;
        }
      }
    } catch (_) {
      isLoggedIn = false;
    }

    // Pastikan animasi berjalan minimal selama 1800ms untuk pengalaman visual terbaik
    final int elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    final int remainingMs = 1800 - elapsedMs;

    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }

    if (!mounted) return;

    // Navigasi ke Halaman Utama jika loggedIn & data user valid, jika tidak ke Login
    if (isLoggedIn && currentUser != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanUtama(user: currentUser!),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HalamanLogin()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==========================================
              // 1 & 2. TRIDE LOGO (Fade & Scale)
              // ==========================================
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/image/playstore.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.explore_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. TRIDE NAME (Fade In after Logo)
              // ==========================================
              FadeTransition(
                opacity: _nameFadeAnimation,
                child: ScaleTransition(
                  scale: _nameScaleAnimation,
                  child: Text(
                    'TRIDE',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==========================================
              // 4. TAGLINE (Fade In & Slide Up after Name)
              // ==========================================
              FadeTransition(
                opacity: _taglineFadeAnimation,
                child: SlideTransition(
                  position: _taglineSlideAnimation,
                  child: Text(
                    'Discover. Plan. Go.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
