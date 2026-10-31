import 'package:flutter/cupertino.dart' show RefreshIndicatorMode;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Indikator tarik-untuk-memuat-ulang bergambar jantung dengan garis EKG.
/// Dipakai di dalam CupertinoSliverRefreshControl.
class PulseRefreshIndicator extends StatefulWidget {
  final RefreshIndicatorMode mode;
  final double pulledExtent; // seberapa jauh layar ditarik
  final double triggerDistance; // jarak tarik agar siap memuat ulang

  const PulseRefreshIndicator({
    super.key,
    required this.mode,
    required this.pulledExtent,
    required this.triggerDistance,
  });

  @override
  State<PulseRefreshIndicator> createState() => _PulseRefreshIndicatorState();
}

class _PulseRefreshIndicatorState extends State<PulseRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat;

  bool get _isRefreshing => widget.mode == RefreshIndicatorMode.refresh;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PulseRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  // Denyut hanya berjalan saat sedang memuat
  void _syncAnimation() {
    if (_isRefreshing) {
      if (!_beat.isAnimating) _beat.repeat();
    } else {
      _beat.stop();
      _beat.value = 0;
    }
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  // Dua denyut cepat lalu jeda, seperti detak jantung
  double _beatScale(double t) {
    if (t < 0.15) return 1 + 0.18 * (t / 0.15);
    if (t < 0.30) return 1.18 - 0.18 * ((t - 0.15) / 0.15);
    if (t < 0.45) return 1 + 0.12 * ((t - 0.30) / 0.15);
    if (t < 0.60) return 1.12 - 0.12 * ((t - 0.45) / 0.15);
    return 1.0;
  }

  String get _label {
    switch (widget.mode) {
      case RefreshIndicatorMode.drag:
        return 'Tarik untuk memuat ulang';
      case RefreshIndicatorMode.armed:
        return 'Lepas untuk memuat ulang';
      case RefreshIndicatorMode.refresh:
        return 'Memuat artikel...';
      case RefreshIndicatorMode.done:
        return 'Selesai';
      case RefreshIndicatorMode.inactive:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.pulledExtent / widget.triggerDistance).clamp(0.0, 1.0);
    final filled = widget.mode == RefreshIndicatorMode.armed ||
        widget.mode == RefreshIndicatorMode.refresh ||
        widget.mode == RefreshIndicatorMode.done;
    final opacity = (widget.mode == RefreshIndicatorMode.refresh ||
            widget.mode == RefreshIndicatorMode.done)
        ? 1.0
        : progress;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        minHeight: 0,
        maxHeight: 80,
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _beat,
                builder: (context, _) {
                  final t = _beat.value;
                  final scale = _isRefreshing
                      ? _beatScale(t)
                      : (filled ? 1.0 : 0.85 + 0.15 * progress);

                  // Saat memuat, garis EKG digambar ulang di tiap denyut
                  final ecg = _isRefreshing ? (t / 0.6).clamp(0.0, 1.0) : null;

                  return Transform.scale(
                    scale: scale,
                    child: CustomPaint(
                      size: const Size(44, 44),
                      painter: _HeartPainter(
                        progress: progress,
                        filled: filled,
                        ecgOverride: ecg,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                _label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menggambar jantung dan garis EKG (bentuk sama dengan logo SEHATYUK).
class _HeartPainter extends CustomPainter {
  final double progress; // 0.0 sampai 1.0 (jarak tarikan)
  final bool filled; // true: jantung terisi hijau
  final double? ecgOverride; // dipakai saat memuat (animasi)

  _HeartPainter({
    required this.progress,
    required this.filled,
    this.ecgOverride,
  });

  // Koordinat mengikuti vektor logo (kotak 88 x 88)
  static Path _heartPath() {
    return Path()
      ..moveTo(44.0001, 64.5)
      ..cubicTo(44.0001, 64.5, 26.6667, 53.6667, 26.6667, 40.6667)
      ..cubicTo(26.6667, 38.3929, 27.3822, 36.1768, 28.7116, 34.3323)
      ..cubicTo(30.0411, 32.4878, 31.9172, 31.1083, 34.0743, 30.3893)
      ..cubicTo(36.2313, 29.6702, 38.5599, 29.6482, 40.7302, 30.3261)
      ..cubicTo(42.9005, 31.0041, 44.8025, 32.3477, 46.1667, 34.1667)
      ..cubicTo(47.531, 32.3477, 49.433, 31.0041, 51.6033, 30.3261)
      ..cubicTo(53.7736, 29.6482, 56.1022, 29.6702, 58.2592, 30.3893)
      ..cubicTo(60.4163, 31.1083, 62.2924, 32.4878, 63.6219, 34.3323)
      ..cubicTo(64.9513, 36.1768, 65.6667, 38.3929, 65.6667, 40.6667)
      ..cubicTo(65.6667, 53.6667, 48.3334, 64.5, 48.3334, 64.5)
      ..lineTo(44.0001, 64.5)
      ..close();
  }

  static Path _ecgPath() {
    return Path()
      ..moveTo(33.1667, 45)
      ..lineTo(38.5834, 45)
      ..lineTo(41.8334, 38.5)
      ..lineTo(46.1667, 51.5)
      ..lineTo(49.4167, 45)
      ..lineTo(54.8334, 45);
  }

  // Menggambar sebagian jalur (fraction 0.0 sampai 1.0)
  void _drawPartial(Canvas canvas, Path path, Paint paint, double fraction) {
    if (fraction <= 0) return;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * fraction), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Pusatkan jantung (titik tengahnya sekitar 46.17, 47.07) di kanvas
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.width / 44);
    canvas.translate(-46.17, -47.07);

    final heart = _heartPath();
    final ecg = _ecgPath();

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (filled) {
      // Jantung hijau penuh dengan garis EKG putih
      canvas.drawPath(heart, Paint()..color = primaryColor);

      final ecgFraction = ecgOverride ?? 1.0;
      _drawPartial(canvas, ecg, stroke..color = Colors.white, ecgFraction);
    } else {
      // Bayangan jantung tipis sebagai pemandu
      canvas.drawPath(
        heart,
        stroke..color = primaryColor.withValues(alpha: 0.15),
      );

      // Garis jantung tergambar sesuai jarak tarikan, lalu garis EKG
      final heartFraction = (progress / 0.7).clamp(0.0, 1.0);
      final ecgFraction = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

      stroke.color = primaryColor;
      _drawPartial(canvas, heart, stroke, heartFraction);
      _drawPartial(canvas, ecg, stroke, ecgFraction);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartPainter old) =>
      old.progress != progress ||
      old.filled != filled ||
      old.ecgOverride != ecgOverride;
}