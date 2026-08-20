import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class DestinationHeroCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const DestinationHeroCard({
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
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite Toggle Button (Top Right)
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppColors.primaryDeep,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Hero Card Content (Bottom)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textWhite.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
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
