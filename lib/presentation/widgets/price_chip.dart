import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class PriceChip extends StatelessWidget {
  final double price;
  final bool showIcon;

  const PriceChip({
    super.key,
    required this.price,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriceColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        CurrencyFormatter.formatKes(price),
        style: TextStyle(
          color: _getPriceColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriceColor() {
    if (price < 100) return AppColors.priceGreen;
    if (price < 250) return AppColors.priceAmber;
    return AppColors.priceRed;
  }
}
