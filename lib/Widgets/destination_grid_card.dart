import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class DestinationGridCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const DestinationGridCard({
    super.key,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.landscape_rounded,
                      size: 36,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              // Dark Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite Icon Top-Right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppColors.primaryDeep,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Card Bottom Info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
