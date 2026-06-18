import 'package:flutter/material.dart';
import '../../../data/models/amenity_model.dart';
import '../../../core/theme/app_colors.dart';

class AmenityGrid extends StatelessWidget {
  final List<AmenityModel> amenities;
  final Function(AmenityModel)? onAmenityTap;

  const AmenityGrid({super.key, required this.amenities, this.onAmenityTap});

  IconData _getAmenityIcon(String name) {
    final nameLC = name.toLowerCase();
    if (nameLC.contains('wifi') || nameLC.contains('wi-fi')) {
      return Icons.wifi;
    }
    if (nameLC.contains('power') || nameLC.contains('outlet')) {
      return Icons.power;
    }
    if (nameLC.contains('quiet')) return Icons.volume_off;
    if (nameLC.contains('24')) return Icons.schedule;
    if (nameLC.contains('food')) return Icons.restaurant;
    if (nameLC.contains('park')) return Icons.local_parking;
    if (nameLC.contains('backup')) return Icons.battery_charging_full;
    if (nameLC.contains('ac') || nameLC.contains('cool')) return Icons.ac_unit;
    if (nameLC.contains('desk')) return Icons.table_chart;
    if (nameLC.contains('security') || nameLC.contains('safe')) {
      return Icons.security;
    }
    return Icons.check_circle;
  }

  Color _getAmenityColor(String category) {
    switch (category) {
      case 'connectivity':
        return AppColors.primary;
      case 'power':
        return AppColors.warning;
      case 'comfort':
        return AppColors.success;
      case 'security':
        return AppColors.error;
      case 'food':
        return Colors.orange;
      case 'accessibility':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No amenities available'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return _buildAmenityCard(amenity);
      },
    );
  }

  Widget _buildAmenityCard(AmenityModel amenity) {
    final icon = _getAmenityIcon(amenity.name);
    final color = _getAmenityColor(amenity.category.toString().split('.').last);

    return GestureDetector(
      onTap: () => onAmenityTap?.call(amenity),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                amenity.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (amenity.isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.verified, size: 14, color: color),
              ),
          ],
        ),
      ),
    );
  }
}

class AmenityDetailSheet extends StatelessWidget {
  final AmenityModel amenity;

  const AmenityDetailSheet({super.key, required this.amenity});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  amenity.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (amenity.isVerified)
                  const Tooltip(
                    message: 'Verified by admin',
                    child: Icon(
                      Icons.verified,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (amenity.description != null)
              Text(
                amenity.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
