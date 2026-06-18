import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/nairobi_neighborhoods.dart';
import '../../../data/providers/location_preference_provider.dart';

class LocationOnboardingScreen extends ConsumerStatefulWidget {
  const LocationOnboardingScreen({super.key});

  @override
  ConsumerState<LocationOnboardingScreen> createState() => _LocationOnboardingScreenState();
}

class _LocationOnboardingScreenState extends ConsumerState<LocationOnboardingScreen> {
  String? _selectedNeighborhood;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Where are you working\ntoday?',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.onBackground,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a neighborhood to see the best workspaces near you.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Neighborhood Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: NairobiNeighborhood.values.length,
                  itemBuilder: (context, index) {
                    final neighborhood = NairobiNeighborhood.values[index];
                    final isSelected = _selectedNeighborhood == neighborhood.name;

                    return _NeighborhoodCard(
                      neighborhood: neighborhood,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedNeighborhood = neighborhood.name;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // For now just go to discover (current location logic can be added later)
                        await ref.read(locationPreferenceProvider.notifier).setNeighborhood('current');
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        context.push('/home');
                      },
                      child: const Text('Current location', textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedNeighborhood != null
                          ? () async {
                              await ref
                                  .read(locationPreferenceProvider.notifier)
                                  .setNeighborhood(_selectedNeighborhood!);
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              context.push('/home?neighborhood=$_selectedNeighborhood');
                            }
                          : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(locationPreferenceProvider.notifier).clear();
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    context.push('/home');
                  },
                  child: const Text('Explore all of Nairobi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeighborhoodCard extends StatelessWidget {
  final NairobiNeighborhood neighborhood;
  final bool isSelected;
  final VoidCallback onTap;

  const _NeighborhoodCard({
    required this.neighborhood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getNeighborhoodColor(neighborhood.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              neighborhood.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_getHubCountHint(neighborhood.name)} hubs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNeighborhoodColor(String name) {
    switch (name) {
      case 'kilimani': return AppColors.neighborhoodKilimani;
      case 'westlands': return AppColors.neighborhoodWestlands;
      case 'cbd': return AppColors.neighborhoodCbd;
      case 'ngongRoad': return AppColors.neighborhoodNgongRoad;
      case 'karen': return AppColors.neighborhoodKaren;
      case 'lavington': return AppColors.primaryLight;
      case 'ridgeways': return AppColors.secondary;
      case 'muthaiga': return AppColors.info;
      case 'hurlingham': return AppColors.error;
      case 'upperHill': return AppColors.primary;
      case 'kitengela': return const Color(0xFF8E24AA);
      case 'mlolongo': return const Color(0xFF00897B);
      case 'thikaRoad': return const Color(0xFF6D4C41);
      default: return AppColors.primary;
    }
  }

  String _getHubCountHint(String name) {
    const counts = {
      'kilimani': 7, 'westlands': 7, 'cbd': 7, 'ngongRoad': 6,
      'karen': 8, 'lavington': 5, 'ridgeways': 5, 'muthaiga': 5,
      'hurlingham': 1, 'upperHill': 8, 'kitengela': 9, 'mlolongo': 6,
      'thikaRoad': 6,
    };
    return (counts[name] ?? 10).toString();
  }
}