import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AmenityIcon extends StatelessWidget {
  final String name;
  final IconData? icon;
  final Color? color;
  final double size;
  final bool showLabel;

  const AmenityIcon({
    super.key,
    required this.name,
    this.icon,
    this.color,
    this.size = 24,
    this.showLabel = false,
  });

  IconData _getDefaultIcon() {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('wifi') || lowerName.contains('wi-fi')) {
      return Icons.wifi;
    } else if (lowerName.contains('power') || lowerName.contains('outlet')) {
      return Icons.power;
    } else if (lowerName.contains('quiet')) {
      return Icons.volume_off;
    } else if (lowerName.contains('24')) {
      return Icons.schedule;
    } else if (lowerName.contains('food')) {
      return Icons.restaurant;
    } else if (lowerName.contains('park')) {
      return Icons.local_parking;
    } else if (lowerName.contains('backup')) {
      return Icons.battery_charging_full;
    } else if (lowerName.contains('ac') || lowerName.contains('cool')) {
      return Icons.ac_unit;
    } else if (lowerName.contains('desk')) {
      return Icons.table_chart;
    } else if (lowerName.contains('security') || lowerName.contains('safe')) {
      return Icons.security;
    } else if (lowerName.contains('coffee')) {
      return Icons.local_cafe;
    } else if (lowerName.contains('printer')) {
      return Icons.print;
    } else if (lowerName.contains('projector')) {
      return Icons.smart_display;
    } else if (lowerName.contains('meeting')) {
      return Icons.meeting_room;
    } else if (lowerName.contains('phone')) {
      return Icons.phone;
    } else {
      return Icons.check_circle;
    }
  }

  Color _getDefaultColor() {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('wifi') || lowerName.contains('internet')) {
      return AppColors.primary;
    } else if (lowerName.contains('power')) {
      return AppColors.warning;
    } else if (lowerName.contains('quiet')) {
      return Colors.purple;
    } else if (lowerName.contains('24')) {
      return Colors.orange;
    } else if (lowerName.contains('food')) {
      return Colors.red[400]!;
    } else if (lowerName.contains('park')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon ?? _getDefaultIcon();
    final displayColor = color ?? _getDefaultColor();

    if (showLabel) {
      return Tooltip(
        message: name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(displayIcon, color: displayColor, size: size),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(fontSize: size * 0.3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Tooltip(
      message: name,
      child: Icon(displayIcon, color: displayColor, size: size),
    );
  }
}

class AmenityBadge extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final bool isSelected;

  const AmenityBadge({
    super.key,
    required this.name,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final lowerName = name.toLowerCase();

    Color? color;
    if (lowerName.contains('wifi')) {
      color = AppColors.primary;
    } else if (lowerName.contains('power')) {
      color = AppColors.warning;
    } else if (lowerName.contains('quiet')) {
      color = Colors.purple;
    } else if (lowerName.contains('24')) {
      color = Colors.orange;
    } else if (lowerName.contains('food')) {
      color = Colors.red[400];
    } else if (lowerName.contains('park')) {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color?.withValues(alpha: 0.3)
              : color?.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color?.withValues(alpha: 0.5) ?? Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('wifi')) {
      return Icons.wifi;
    } else if (lowerName.contains('power')) {
      return Icons.power;
    } else if (lowerName.contains('quiet')) {
      return Icons.volume_off;
    } else if (lowerName.contains('24')) {
      return Icons.schedule;
    } else if (lowerName.contains('food')) {
      return Icons.restaurant;
    } else if (lowerName.contains('park')) {
      return Icons.local_parking;
    } else {
      return Icons.check_circle;
    }
  }
}
