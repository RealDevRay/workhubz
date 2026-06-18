import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple provider for fetching hubs from Supabase.
/// For v1 we keep it lightweight.

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final hubsProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, neighborhood) async {
  final client = ref.watch(supabaseClientProvider);

  var query = client.from('hubs').select('''
    *,
    hub_contacts(*),
    hub_amenities(amenity_id)
  ''');

  if (neighborhood != null && neighborhood.isNotEmpty && neighborhood != 'All Nairobi' && neighborhood != 'current') {
    query = query.eq('neighborhood', neighborhood);
  }

  final response = await query
      .order('rating', ascending: false)
      .limit(20);

  return List<Map<String, dynamic>>.from(response);
});

final featuredHubsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('hubs')
      .select()
      .order('rating', ascending: false)
      .limit(6);
  return List<Map<String, dynamic>>.from(response);
});