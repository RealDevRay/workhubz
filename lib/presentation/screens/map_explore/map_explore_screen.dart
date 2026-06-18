import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/space_model.dart';
import '../../../data/providers/space_providers.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/location_preference_provider.dart';
import '../../widgets/price_chip.dart';
import '../../widgets/loading_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'filter_bottom_sheet.dart';

class MapExploreScreen extends ConsumerStatefulWidget {
  const MapExploreScreen({super.key});

  @override
  ConsumerState<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends ConsumerState<MapExploreScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  SpaceModel? _selectedSpace;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    _loadSpacesMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final position = locationState.position;
    final initialPosition = position != null
        ? LatLng(position.latitude, position.longitude)
        : const LatLng(
            AppConstants.defaultLatitude,
            AppConstants.defaultLongitude,
          );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: AppConstants.defaultZoom,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _loadSpacesMarkers();
            },
            onTap: (_) {
              setState(() => _selectedSpace = null);
            },
          ),
          if (_isLoading)
            const Center(child: LoadingShimmer())
          else ...[
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(textTheme),
                  const SizedBox(height: 12),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildQuickFilters(),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 170,
              right: 16,
              child: _buildMapControls(),
            ),
          ],
          if (_selectedSpace != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildSpacePreviewCard(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recenterMap,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search workspaces...',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nairobi, Kenya',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.wifi, size: 16, color: AppColors.secondary),
              SizedBox(width: 6),
              Text('Fast Wi-Fi'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final filters = ['Quiet', '24/7', 'Power Backup', 'Parking', 'Outdoor'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FilterChip(
            label: Text(filters[index]),
            selected: false,
            onSelected: (_) {},
          );
        },
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
                icon: const Icon(Icons.add),
              ),
              const Divider(height: 1),
              IconButton(
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                },
                icon: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _showFilterBottomSheet(),
            icon: const Icon(Icons.filter_list),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacePreviewCard() {
    return Card(
      child: InkWell(
        onTap: () => context.push('/space/${_selectedSpace!.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceVariant,
                  child: _selectedSpace!.photoUrls.isNotEmpty
                      ? Image.network(
                          _selectedSpace!.photoUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.image),
                        )
                      : const Icon(Icons.image),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSpace!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedSpace!.isVerified)
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSpace!.address,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedSpace!.website != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _selectedSpace!.website!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (_selectedSpace!.phoneNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _selectedSpace!.phoneNumber!,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriceChip(price: _selectedSpace!.pricing.hourlyRate),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          _selectedSpace!.ratingDisplay,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () =>
                              context.push('/space/${_selectedSpace!.id}'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Book'),
                        ),
                      ],
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

  void _loadSpacesMarkers() async {
    final locationPref = ref.read(locationPreferenceProvider);
    final spaces = await ref.read(spacesProvider(null).future);

    _markers.clear();
    for (final space in spaces) {
      // Skip hubs with invalid geo (common in current seed data)
      if (space.latitude == 0 && space.longitude == 0) continue;

      // Optional: filter by current location preference if set and not "current"/"All"
      if (locationPref != null &&
          locationPref != 'current' &&
          locationPref != 'All Nairobi' &&
          space.neighborhood.toLowerCase() != locationPref.toLowerCase()) {
        continue;
      }

      _markers.add(
        Marker(
          markerId: MarkerId(space.id),
          position: LatLng(space.latitude, space.longitude),
          infoWindow: InfoWindow(title: space.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            space.pricing.hourlyRate < 100
                ? BitmapDescriptor.hueGreen
                : space.pricing.hourlyRate < 250
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            setState(() => _selectedSpace = space);
          },
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _recenterMap() async {
    final position = ref.read(locationNotifierProvider).position;
    if (position != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } else {
      await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(
        onApply: (filters) {
          ref.read(spaceFilterProvider.notifier).setMaxPrice(filters.maxPrice);
          ref
              .read(spaceFilterProvider.notifier)
              .setHasWifi(filters.amenities.contains('wifi'));
          ref
              .read(spaceFilterProvider.notifier)
              .setHasParking(filters.amenities.contains('parking'));
          ref
              .read(spaceFilterProvider.notifier)
              .setHasQuietZone(filters.amenities.contains('quiet'));
          ref
              .read(spaceFilterProvider.notifier)
              .setHasPowerBackup(filters.amenities.contains('backup'));
          ref
              .read(spaceFilterProvider.notifier)
              .setSelectedNeighborhoods(filters.neighborhoods);
        },
      ),
    );
  }
}
