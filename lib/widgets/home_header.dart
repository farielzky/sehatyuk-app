import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';
import 'circle_icon_button.dart';

/// Header Home: logo, sapaan, dan tombol lonceng (sesuai Figma).
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo yang sama dengan halaman Login, diperkecil menjadi 40 px
        SvgPicture.asset('assets/logo.svg', width: 40, height: 40),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang',
                style: TextStyle(
                  fontSize: 12,
                  height: 18 / 12,
                  color: textSecondaryColor,
                ),
              ),
              Text(
                'Baca apa hari ini?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 30 / 22,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        // Lonceng notifikasi (belum berfungsi, tidak ada di fitur minimum)
        const CircleIconButton(icon: Icons.notifications_none_outlined),
      ],
    );
  }
}