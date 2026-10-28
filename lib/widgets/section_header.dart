import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Judul bagian dengan tautan kecil di kanan, misalnya "Kategori / Lihat semua".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 24 / 18,
            color: textPrimaryColor,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}