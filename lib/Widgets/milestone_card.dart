import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class MilestoneCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final Widget? customContent;
  final double rotateAngle;
  final Color dotColor;

  const MilestoneCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.fallbackIcon,
    this.customContent,
    this.rotateAngle = 0.0,
    this.dotColor = AppColors.primaryDeep,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bullet Dot
        Positioned(
          left: 0,
          top: 16,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
          ),
        ),

        // Content Card Padding
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Transform.rotate(
            angle: rotateAngle,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customContent != null)
                    customContent!
                  else if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: AppColors.surfaceVariant,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                fallbackIcon ?? Icons.photo_rounded,
                                size: 40,
                                color: AppColors.primaryDeep,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
