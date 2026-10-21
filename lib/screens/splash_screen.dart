import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _ecgController;

  @override
  void initState() {
    super.initState();

    // Logo + text fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // ECG line draw animation
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ecgController.forward();
    });

    // Navigate after 3 seconds: ke Home jika sudah login, atau ke Login jika belum
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _ecgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A9B8C), // lighter teal at top
              Color(0xFF0B8578), // primary teal
              Color(0xFF085E55), // darker teal at bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // --- Decorative circle at top-right ---
            Positioned(
              top: -screenSize.width * 0.25,
              right: -screenSize.width * 0.15,
              child: Container(
                width: screenSize.width * 0.7,
                height: screenSize.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // --- Second smaller decorative circle ---
            Positioned(
              top: -screenSize.width * 0.1,
              right: -screenSize.width * 0.05,
              child: Container(
                width: screenSize.width * 0.45,
                height: screenSize.width * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            // --- ECG heartbeat line across the middle ---
            Positioned(
              left: 0,
              right: 0,
              top: screenSize.height * 0.58,
              child: AnimatedBuilder(
                animation: _ecgController,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(screenSize.width, 60),
                    painter: _SplashECGLinePainter(
                      progress: _ecgController.value,
                    ),
                  );
                },
              ),
            ),

            // --- Center content: logo + text ---
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SehatYuk logo icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/icon.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App name
                    const Text(
                      'SEHATYUK',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Text(
                      'Hidup sehat, yuk mulai dari sini.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Version text at bottom ---
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Versi 1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated ECG line that draws across the splash screen horizontally.
class _SplashECGLinePainter extends CustomPainter {
  final double progress;
  _SplashECGLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;

    // Flat line from left edge
    path.moveTo(0, midY);
    path.lineTo(w * 0.25, midY);

    // Small bump
    path.lineTo(w * 0.30, midY - 5);
    path.lineTo(w * 0.33, midY + 3);
    path.lineTo(w * 0.35, midY);

    // Flat to center
    path.lineTo(w * 0.42, midY);

    // Big spike (main QRS complex)
    path.lineTo(w * 0.45, midY - 22);
    path.lineTo(w * 0.48, midY + 15);
    path.lineTo(w * 0.51, midY - 8);
    path.lineTo(w * 0.53, midY);

    // Flat
    path.lineTo(w * 0.60, midY);

    // Small T wave
    path.lineTo(w * 0.64, midY - 7);
    path.lineTo(w * 0.68, midY);

    // Flat to right edge
    path.lineTo(w, midY);

    // Animate the drawing using path metrics
    final metrics = path.computeMetrics().first;
    final drawLength = metrics.length * progress;
    final extractedPath = metrics.extractPath(0, drawLength);

    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashECGLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
