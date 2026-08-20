import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
          ),
    );
  }
}
