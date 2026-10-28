import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Baris chip kategori yang bisa digeser: Semua, Gizi, Mental, dan seterusnya.
class CategoryChips extends StatelessWidget {
  final AppCategory selected;
  final ValueChanged<AppCategory> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // "Semua" lebih dulu, lalu enam kategori
    final items = [allCategory, ...categories];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final c = items[index];
          final isSelected = c == selected;
          final label = c == allCategory ? 'Semua' : c.shortName;

          return Material(
            color: isSelected ? primaryColor : surfaceColor,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? primaryColor : borderColor,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => onSelected(c),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? textOnPrimaryColor : textPrimaryColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}