import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's chosen neighborhood for the Discover experience.
/// Uses Hive (already a project dependency).

final locationPreferenceProvider = StateNotifierProvider<LocationPreferenceNotifier, String?>((ref) {
  return LocationPreferenceNotifier();
});

class LocationPreferenceNotifier extends StateNotifier<String?> {
  static const _boxName = 'location_prefs';
  static const _key = 'selected_neighborhood';

  LocationPreferenceNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    // Hive.initFlutter() should be called once in main.dart
    final box = await Hive.openBox(_boxName);
    state = box.get(_key) as String?;
  }

  Future<void> setNeighborhood(String neighborhood) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, neighborhood);
    state = neighborhood;
  }

  Future<void> clear() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_key);
    state = null;
  }
}