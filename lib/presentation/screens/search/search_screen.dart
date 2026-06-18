import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/space_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/space_providers.dart';

import 'ai_search_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _debouncedQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _debouncedQuery = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search workspaces...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
          ),
        ],
      ),
      body: _debouncedQuery.isEmpty ? _buildSuggestions() : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _buildSectionHeader('Curated for you'),
        const SizedBox(height: 12),
        AiSearchWidget(
          onSearchExtracted: (filters) {
            final neighborhood = filters['neighborhood'] as String?;
            final maxPrice = filters['maxPrice'];
            final amenitiesList = filters['amenities'] as List<dynamic>? ?? [];

            ref
                .read(spaceFilterProvider.notifier)
                .setMaxPrice(
                  maxPrice != null ? (maxPrice as num).toDouble() : null,
                );
            ref
                .read(spaceFilterProvider.notifier)
                .setSelectedNeighborhoods(
                  neighborhood != null ? [neighborhood] : [],
                );

            final amenities = amenitiesList
                .map((e) => e.toString().toLowerCase())
                .toList();
            ref
                .read(spaceFilterProvider.notifier)
                .setHasWifi(amenities.contains('wifi'));
            ref
                .read(spaceFilterProvider.notifier)
                .setHasParking(amenities.contains('parking'));
            ref
                .read(spaceFilterProvider.notifier)
                .setHasQuietZone(amenities.contains('quiet'));

            // Trigger a text search using the neighborhood or query terms
            final searchTerm = neighborhood ?? amenitiesList.join(' ');
            _searchController.text = searchTerm;
            _onSearchChanged(searchTerm);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'AI applied filters${neighborhood != null ? ' for $neighborhood' : ''}.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = [
                (
                  'Quiet corners',
                  'Low noise, fast Wi-Fi',
                  Icons.spa,
                  AppColors.neighborhoodKaren,
                ),
                (
                  'Open late',
                  'Night owls welcome',
                  Icons.nightlight,
                  AppColors.neighborhoodCbd,
                ),
                (
                  'Team friendly',
                  'Meeting-ready spaces',
                  Icons.groups,
                  AppColors.neighborhoodWestlands,
                ),
              ][index];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final searchTerm = data.$1 == 'Quiet corners'
                      ? 'quiet'
                      : data.$1 == 'Open late'
                      ? 'late'
                      : 'team';
                  _searchController.text = searchTerm;
                  _onSearchChanged(searchTerm);
                },
                child: _buildCollectionCard(
                  title: data.$1,
                  subtitle: data.$2,
                  icon: data.$3,
                  accent: data.$4,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Popular searches'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Wi-Fi',
                'Quiet',
                'Parking',
                'Power backup',
                '24 hours',
                'Food allowed',
              ].map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: false,
                  onSelected: (_) {
                    _searchController.text = tag;
                    _onSearchChanged(tag);
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Browse by neighborhood'),
        const SizedBox(height: 12),
        ...['Kilimani', 'Westlands', 'CBD', 'Ngong Road', 'Karen'].map((area) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on, color: AppColors.secondary),
            title: Text(area),
            subtitle: const Text('Tap to explore spaces'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _searchController.text = area;
              _onSearchChanged(area);
            },
          );
        }),
      ],
    );
  }

  Widget _buildResults() {
    final resultsAsync = ref.watch(searchSpacesProvider(_debouncedQuery));

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results for "$_debouncedQuery"',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final space = results[index];
            return _buildSpaceCard(space);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Error: $err',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(SpaceModel space) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/space/${space.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: space.photoUrls.isNotEmpty
                  ? Image.network(space.photoUrls.first, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(space.rating.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    space.neighborhood,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.formatKes(space.pricing.hourlyRate),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/hr',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.wifi,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chair,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.power,
                        size: 16,
                        color: AppColors.secondary,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: AppColors.onBackground),
    );
  }

  Widget _buildCollectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
