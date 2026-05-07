// ============================================================
// splash_screen.dart — Animated futuristic splash screen
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Navigate to home after 3.5 s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // ── Background grid lines ──────────────────────
            _GridBackground(),

            // ── Main content ───────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glow ring + Logo
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonCyan.withValues(alpha: 0.35 * _glowAnim.value),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: AppTheme.neonBlue.withValues(alpha: 0.2 * _glowAnim.value),
                            blurRadius: 100,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF0A2040), Color(0xFF030B1A)],
                        ),
                        border: Border.all(
                          color: AppTheme.neonCyan.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        size: 72,
                        color: AppTheme.neonCyan,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 600.ms),

                  const SizedBox(height: 36),

                  // App name
                  Text(
                    'SMART CAR AI',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    AppConstants.appTagline.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms),

                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: AppTheme.darkBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.neonCyan,
                            ),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'INITIALIZING SYSTEMS...',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 500.ms),

                  const SizedBox(height: 60),

                  // Tech stack badges
                  Wrap(
                    spacing: 8,
                    children: ['AI', 'MQTT', 'NLP', 'ESP8266']
                        .map((tag) => _TechBadge(label: tag))
                        .toList(),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 500.ms),
                ],
              ),
            ),

            // ── Version tag ────────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                AppConstants.appVersion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Grid Background
// ─────────────────────────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Tech badge chip
// ─────────────────────────────────────────────────────────────
class _TechBadge extends StatelessWidget {
  final String label;
  const _TechBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.neonCyan.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.neonCyan,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
