import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/space_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/space_providers.dart';

import '../../widgets/error_state_widget.dart';

class SpaceDetailScreen extends ConsumerWidget {
  final String spaceId;

  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(spaceByIdProvider(spaceId));
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final textTheme = Theme.of(context).textTheme;

    return spaceAsync.when(
      data: (space) {
        if (space == null) {
          return Scaffold(
            body: ErrorStateWidget(
              title: 'Space not found',
              message: 'The space with ID $spaceId could not be found.',
            ),
          );
        }
        return _buildDetail(context, ref, space, isAuthenticated, textTheme);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: ErrorStateWidget(
          title: 'Failed to load space',
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    SpaceModel space,
    bool isAuthenticated,
    TextTheme textTheme,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.surfaceVariant,
                    child: space.photoUrls.isNotEmpty
                        ? Image.network(
                            space.photoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.image,
                              size: 64,
                              color: AppColors.onSurfaceVariant,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            size: 64,
                            color: AppColors.onSurfaceVariant,
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${space.rating} (${space.reviewCount})',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (space.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
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
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.address,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.access_time,
                        space.hours.isOpenNow()
                            ? AppColors.success
                            : AppColors.error,
                        space.hours.isOpenNow() ? 'Open now' : 'Closed',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.wifi,
                        space.hasWifi
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                        space.hasWifi ? 'Wi-Fi ready' : 'No Wi-Fi',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.power,
                        space.hasPowerBackup
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                        space.hasPowerBackup ? 'Power backup' : 'No backup',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('About', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(space.description, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Text('Amenities', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: space.amenities.map((amenity) {
                      return _buildAmenityChip(context, amenity.name);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text('Pricing', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPriceCard(
                          context,
                          'Hourly',
                          CurrencyFormatter.formatKes(space.pricing.hourlyRate),
                        ),
                        if (space.pricing.halfDayRate != null)
                          _buildPriceCard(
                            context,
                            'Half Day',
                            CurrencyFormatter.formatKes(
                              space.pricing.halfDayRate!,
                            ),
                          ),
                        if (space.pricing.fullDayRate != null)
                          _buildPriceCard(
                            context,
                            'Full Day',
                            CurrencyFormatter.formatKes(
                              space.pricing.fullDayRate!,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (space.securityNotes != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              space.securityNotes!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.formatPricePerHour(
                        space.pricing.hourlyRate,
                      ),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (space.pricing.notes != null)
                      Text(
                        space.pricing.notes!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isAuthenticated) {
                    context.push('/booking-payment/${space.id}');
                    return;
                  }

                  final redirectTo = Uri.encodeComponent(
                    '/booking-payment/${space.id}',
                  );
                  context.push('/phone-login?redirect=$redirectTo');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Reserve & Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, String label, String price) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
