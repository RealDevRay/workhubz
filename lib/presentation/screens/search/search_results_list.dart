import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/space_model.dart';
import '../../../core/theme/app_colors.dart';

class SearchResultsList extends StatelessWidget {
  final List<SpaceModel> spaces;
  final Function(SpaceModel) onSpaceSelected;
  final bool isLoading;
  final bool hasMoreResults;
  final VoidCallback? onLoadMore;

  const SearchResultsList({
    super.key,
    required this.spaces,
    required this.onSpaceSelected,
    this.isLoading = false,
    this.hasMoreResults = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && spaces.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (spaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No spaces found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: spaces.length + (hasMoreResults ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == spaces.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ElevatedButton(
                onPressed: onLoadMore,
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final space = spaces[index];
        return _buildSpaceCard(context, space);
      },
    );
  }

  Widget _buildSpaceCard(BuildContext context, SpaceModel space) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSpaceSelected(space),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: space.photoUrls.isNotEmpty
                        ? space.photoUrls[0]
                        : 'https://via.placeholder.com/400x200',
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                // Verified Badge
                if (space.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Rating Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          space.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    space.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.neighborhood,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and Amenities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KSh ${space.pricing.hourlyRate.toInt()}/hr',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${space.amenities.length} Amenities',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
