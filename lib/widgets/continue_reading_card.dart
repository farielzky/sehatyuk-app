import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';

/// Kartu hijau "Lanjutkan membaca" untuk artikel yang terakhir dibuka.
class ContinueReadingCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ContinueReadingCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Garis denyut di kanan atas, sejajar dengan label
            Positioned(
              top: 12,
              right: 16,
              child: CustomPaint(
                size: const Size(90, 24),
                painter: _PulsePainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lanjutkan membaca',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: textOnPrimaryColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 22 / 16,
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
    );
  }
}

/// Garis tipis dengan satu lonjakan denyut (bentuknya seperti di splash, diperkecil).
class _PulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dx = size.width * 0.38; // posisi lonjakan dari kiri
    final path = Path()
      ..moveTo(0, 12)
      ..lineTo(dx, 12)
      ..lineTo(dx + 5, 4)
      ..lineTo(dx + 12, 24)
      ..lineTo(dx + 18, 9)
      ..lineTo(dx + 22, 12)
      ..lineTo(size.width, 12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}