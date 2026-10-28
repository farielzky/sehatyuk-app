import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Tombol bulat 40 px (putih, border tipis).
/// Jika onTap kosong (null), tombol tampil tapi belum berfungsi.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.color = textPrimaryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      shape: const CircleBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}