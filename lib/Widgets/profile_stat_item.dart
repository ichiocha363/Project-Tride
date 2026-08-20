import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const ProfileStatItem({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
