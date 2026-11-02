import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/article_feed.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Layar peluncuran Android menampilkan logo tepat di tengah layar,
  // sedangkan di splash ini logo berada 45 px lebih tinggi (kolom logo + teks
  // berada di tengah). Jadi logo dimulai dari tengah, lalu naik 45 px.
  static const double _logoDrop = 45;

  // Waktu splash minimal supaya animasi sempat terlihat
  static const Duration _minSplash = Duration(milliseconds: 2400);

  final AuthService _authService = AuthService();

  // Animasi pembuka: dari tampilan awal Android (hanya logo) ke splash penuh
  late final AnimationController _intro;
  late final CurvedAnimation _logoMove;
  late final CurvedAnimation _decoIn;
  late final CurvedAnimation _textIn;
  late final CurvedAnimation _loaderIn;

  // Kemajuan loading bar (0.0 sampai 1.0)
  late final AnimationController _progress;

  String _status = 'Menyiapkan aplikasi...';

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoMove = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.55, curve: Curves.easeInOutCubic),
    );
    _decoIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.10, 0.75, curve: Curves.easeOut),
    );
    _textIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    );
    _loaderIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );

    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _intro.forward();
    _loadAndNavigate();
  }

  @override
  void dispose() {
    _logoMove.dispose();
    _decoIn.dispose();
    _textIn.dispose();
    _loaderIn.dispose();
    _intro.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _setStatus(String text) {
    if (mounted) setState(() => _status = text);
  }

  // Menyiapkan data lalu berpindah layar. Bar mengikuti pekerjaan yang nyata.
  Future<void> _loadAndNavigate() async {
    final started = DateTime.now();
    bool loggedIn = false;

    // 1. Tunggu status login dari Firebase
    try {
      _progress.animateTo(
        0.3,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
      );
      final user = await _authService.authStateChanges.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => _authService.currentUser,
      );
      loggedIn = user != null;
    } catch (e) {
      debugPrint('Gagal memeriksa status autentikasi: $e');
    }
    if (!mounted) return;

    // 2. Jika sudah login, muat artikel dulu supaya Home langsung siap
    if (loggedIn) {
      _setStatus('Memuat artikel...');
      // Bar merayap pelan selagi menunggu, lalu penuh saat data selesai
      _progress.animateTo(
        0.9,
        duration: const Duration(seconds: 7),
        curve: Curves.easeOutCubic,
      );
      try {
        await ArticleFeed.mixed().timeout(const Duration(seconds: 7));
      } catch (e) {
        // Gagal atau lambat: tetap lanjut. Home menampilkan pesan dan "Coba lagi"
        debugPrint('Artikel belum siap saat splash: $e');
      }
      if (!mounted) return;
    }

    // 3. Penuhi bar, dengan memastikan durasi splash minimal tercapai
    final remaining = _minSplash - DateTime.now().difference(started);
    const shortest = Duration(milliseconds: 400);
    final fillTime = remaining > shortest ? remaining : shortest;
    await _progress.animateTo(
      1.0,
      duration: fillTime,
      curve: Curves.easeInOut,
    );
    if (!mounted) return;

    _setStatus('Siap!');
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    _goTo(loggedIn ? const MainScreen() : const LoginScreen());
  }

  // Berpindah layar dengan efek memudar (fade)
  void _goTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loaderTop = size.height * 0.678;

    return Scaffold(
      backgroundColor: primaryColor,
      body: AnimatedBuilder(
        animation: _intro,
        builder: (context, _) {
          return Stack(
            children: [
              // Lingkaran dekorasi kanan atas (sebagian keluar layar)
              Positioned(
                top: -110,
                right: -120,
                child: _Circle(
                  size: 320,
                  alpha: 0.55 * _decoIn.value,
                  scale: 0.8 + 0.2 * _decoIn.value,
                ),
              ),

              // Lingkaran dekorasi kiri bawah
              Positioned(
                bottom: -56,
                left: -110,
                child: _Circle(
                  size: 260,
                  alpha: 0.4 * _decoIn.value,
                  scale: 0.8 + 0.2 * _decoIn.value,
                ),
              ),

              // Loading bar berbentuk garis denyut, beserta keterangannya
              Positioned(
                left: 0,
                right: 0,
                top: loaderTop,
                child: Opacity(
                  opacity: _loaderIn.value,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(size.width, 43),
                            painter: _PulseLoaderPainter(
                              progress: _progress.value,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _status,
                          key: ValueKey(_status),
                          style: TextStyle(
                            fontSize: 12,
                            height: 18 / 12,
                            color: textOnPrimaryColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Logo, nama aplikasi, dan tagline
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo dimulai dari tengah layar (sama seperti layar peluncuran)
                    Transform.translate(
                      offset: Offset(0, _logoDrop * (1 - _logoMove.value)),
                      child: SvgPicture.asset(
                        'assets/logo_light.svg',
                        width: 104,
                        height: 104,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: _textIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 14 * (1 - _textIn.value)),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SEHATYUK',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 36 / 28,
                                color: textOnPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
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
                  ],
                ),
              ),

              // Versi aplikasi di bagian bawah
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _loaderIn.value,
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
          );
        },
      ),
    );
  }
}

/// Lingkaran dekorasi yang membesar dan memudar masuk.
class _Circle extends StatelessWidget {
  final double size;
  final double alpha;
  final double scale;

  const _Circle({
    required this.size,
    required this.alpha,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryDarkColor.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

/// Loading bar berbentuk garis denyut (bentuk sama seperti sebelumnya).
/// Jalur redup = total, jalur putih = bagian yang sudah termuat.
class _PulseLoaderPainter extends CustomPainter {
  final double progress; // 0.0 sampai 1.0

  _PulseLoaderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 17.5)
      ..lineTo(120, 17.5)
      ..lineTo(130, 17.5)
      ..lineTo(140, 1.5)
      ..lineTo(154, 41.5)
      ..lineTo(166, 11.5)
      ..lineTo(174, 17.5)
      ..lineTo(size.width, 17.5);

    // Jalur latar (redup)
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, track);

    final metric = path.computeMetrics().first;
    final length = metric.length * progress.clamp(0.0, 1.0);
    if (length <= 0) return;

    // Bagian yang sudah termuat (putih terang)
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(metric.extractPath(0, length), fill);

    // Titik bercahaya di ujung garis
    final tip = metric.getTangentForOffset(length);
    if (tip != null) {
      canvas.drawCircle(
        tip.position,
        6,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
      canvas.drawCircle(tip.position, 3.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}