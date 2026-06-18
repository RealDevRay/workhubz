import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/hub_providers.dart';
import '../../../data/providers/location_preference_provider.dart';
import '../../../data/providers/tab_provider.dart';
import '../search/ai_search_widget.dart';

class DiscoverScreen extends ConsumerWidget {
  final String? initialNeighborhood;

  const DiscoverScreen({super.key, this.initialNeighborhood});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persisted = ref.watch(locationPreferenceProvider);
    final neighborhood = initialNeighborhood ?? persisted ?? 'All Nairobi';
    final hubsAsync = ref.watch(
      hubsProvider(neighborhood == 'All Nairobi' ? null : neighborhood),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Discover in $neighborhood'),
        actions: [
          TextButton(
            onPressed: () => context.push('/onboarding-location'),
            child: const Text('Change area'),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              ref.read(tabIndexProvider.notifier).state = 1;
            },
            tooltip: 'Open Locator Map',
          ),
        ],
      ),
      body: hubsAsync.when(
        data: (hubs) {
          if (hubs.isEmpty) {
            return _EmptyState(neighborhood: neighborhood);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here are the best workspaces in $neighborhood right now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AiSearchWidget(
                onSearchExtracted: (filters) {
                  final neighborhood = filters['neighborhood'] as String?;
                  if (neighborhood != null && neighborhood.isNotEmpty) {
                    context.push('/discover?neighborhood=$neighborhood');
                  }
                  // Extendable for maxPrice/amenities filters in future
                },
              ),

              const SizedBox(height: 16),
              Text(
                'Featured & Highly Rated',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...hubs.take(6).map((hub) => _HubListTile(hub: hub)),
              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading hubs: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(tabIndexProvider.notifier).state = 1;
        },
        icon: const Icon(Icons.map),
        label: const Text('Open Locator'),
      ),
    );
  }
}

class _HubListTile extends StatelessWidget {
  final Map<String, dynamic> hub;
  const _HubListTile({required this.hub});

  @override
  Widget build(BuildContext context) {
    final name = hub['name'] ?? 'Unnamed Hub';
    final neighborhood = hub['neighborhood'] ?? '';
    final hourly = hub['price_hourly'];
    final daily = hub['price_daily'];
    final monthly = hub['price_monthly'];
    String priceStr;
    if (hourly != null) {
      priceStr = 'KSh ${hourly.toStringAsFixed(0)}/hr';
    } else if (daily != null) {
      priceStr = 'KSh ${daily.toStringAsFixed(0)}/day';
    } else if (monthly != null) {
      priceStr = 'KSh ${monthly.toStringAsFixed(0)}/mo';
    } else {
      priceStr = 'Contact for pricing';
    }

    // Extract from joined data (Supabase returns object for to-one like contacts, list for to-many like amenities)
    dynamic contactsRaw = hub['hub_contacts'];
    final contacts = contactsRaw is List
        ? contactsRaw
        : (contactsRaw != null ? [contactsRaw] : []);
    final firstContact = contacts.isNotEmpty
        ? (contacts.first as Map<String, dynamic>)
        : null;
    final website = firstContact?['website'] as String?;
    final phone = firstContact?['phone'] as String?;

    final amenitiesList = (hub['hub_amenities'] as List<dynamic>?) ?? [];
    final amenityIds = amenitiesList
        .map((a) => (a as Map)['amenity_id'] as String)
        .toList();
    final amenitiesStr = amenityIds.isNotEmpty
        ? amenityIds.take(3).join(', ')
        : 'Various';

    final id = hub['id'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.workspaces_filled, color: AppColors.primary),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$neighborhood • $priceStr'),
            if (amenityIds.isNotEmpty)
              Text(
                'Amenities: $amenitiesStr',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (website != null)
              Text(
                website,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
              ),
            if (phone != null)
              Text(phone, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () async {
          if (website != null && website.isNotEmpty) {
            // Launch website using url_launcher (already a project dep)
            final uri = Uri.parse(website);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open $website')),
                );
              }
            }
          } else if (id != null) {
            context.push(
              '/space/$id',
            ); // fallback to space detail (may show mock or adapt later)
          }
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String neighborhood;
  const _EmptyState({required this.neighborhood});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No hubs found in $neighborhood yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Run the Python pipeline in tools/hub-ingest/ to seed data from SerpAPI + Firecrawl + Groq into Supabase.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
