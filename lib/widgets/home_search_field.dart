import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Kolom pencarian di Home (putih, border tipis, ikon kaca pembesar).
class HomeSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  const HomeSearchField({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14, color: textPrimaryColor),
      decoration: InputDecoration(
        hintText: 'Cari artikel kesehatan...',
        hintStyle: const TextStyle(fontSize: 14, color: textSecondaryColor),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 12),
          child: Icon(Icons.search, size: 20, color: textSecondaryColor),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: _border(borderColor, 1),
        enabledBorder: _border(borderColor, 1),
        focusedBorder: _border(primaryColor, 1.5),
      ),
    );
  }
}