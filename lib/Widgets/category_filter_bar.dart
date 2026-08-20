import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory.toLowerCase() == category.toLowerCase();
          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceLow,
            showCheckmark: false,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onSelected: (selected) {
              if (selected) {
                onCategorySelected(category);
              }
            },
          );
        },
      ),
    );
  }
}
