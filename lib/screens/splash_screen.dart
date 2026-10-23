import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Logo dan teks muncul perlahan (fade-in)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Garis denyut digambar dari kiri ke kanan
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _pulseController.forward();
    });

    // Setelah 3 detik: ke Home jika sudah login, ke Login jika belum
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Lingkaran dekorasi kanan atas (sebagian keluar layar)
          Positioned(
            top: -110,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryDarkColor.withValues(alpha: 0.55),
              ),
            ),
          ),

          // Lingkaran dekorasi kiri bawah
          Positioned(
            bottom: -56,
            left: -110,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryDarkColor.withValues(alpha: 0.4),
              ),
            ),
          ),

          // Garis denyut di tengah layar
          Positioned(
            left: 0,
            right: 0,
            top: screenSize.height * 0.678,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(screenSize.width, 43),
                  painter: _PulseLinePainter(progress: _pulseController.value),
                );
              },
            ),
          ),

          // Logo, nama aplikasi, dan tagline
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/logo_light.svg',
                    width: 104,
                    height: 104,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SEHATYUK',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 36 / 28,
                      color: textOnPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hidup sehat, yuk mulai dari sini.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 22 / 14,
                      color: textOnPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Versi aplikasi di bagian bawah
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Versi 1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textOnPrimaryColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Garis denyut yang digambar bertahap dari kiri ke kanan.
/// Bentuknya mengikuti vektor di Figma (tinggi 43).
class _PulseLinePainter extends CustomPainter {
  final double progress;
  _PulseLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, 17.5)
      ..lineTo(120, 17.5)
      ..lineTo(130, 17.5)
      ..lineTo(140, 1.5)
      ..lineTo(154, 41.5)
      ..lineTo(166, 11.5)
      ..lineTo(174, 17.5)
      ..lineTo(size.width, 17.5);

    // Gambar hanya sebagian garis sesuai progress animasi (0.0 sampai 1.0)
    final metrics = path.computeMetrics().first;
    canvas.drawPath(metrics.extractPath(0, metrics.length * progress), paint);
  }

  @override
  bool shouldRepaint(covariant _PulseLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
