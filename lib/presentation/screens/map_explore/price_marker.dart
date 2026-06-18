import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PriceMarker extends StatelessWidget {
  final double price;
  final double? rating;
  final bool isSelected;

  const PriceMarker({
    super.key,
    required this.price,
    this.rating,
    this.isSelected = false,
  });

  Color _getPriceColor() {
    if (price < 100) return AppColors.success;
    if (price <= 250) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriceColor();
    final bgColor = color.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: Colors.white, width: 3)
            : Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'KSh ${price.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (rating != null)
            Text(
              '⭐ ${rating!.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class PriceMarkerWidget extends StatelessWidget {
  final double price;
  final VoidCallback onTap;

  const PriceMarkerWidget({
    super.key,
    required this.price,
    required this.onTap,
  });

  Color _getPriceColor() {
    if (price < 100) return AppColors.success;
    if (price <= 250) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriceColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'KSh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${price.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
