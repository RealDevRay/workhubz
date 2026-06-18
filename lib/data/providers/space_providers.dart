import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/space_model.dart';
import '../repositories/space_repository.dart';

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return SpaceRepository();
});

final spacesProvider = FutureProvider.family<List<SpaceModel>, void>((
  ref,
  _,
) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getAllSpaces();
});

final spaceByIdProvider = FutureProvider.family<SpaceModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getSpaceById(id);
});

final nearbySpacesProvider =
    FutureProvider.family<List<SpaceModel>, LocationQuery>((ref, query) async {
      final repository = ref.watch(spaceRepositoryProvider);
      return repository.getSpacesNearby(
        latitude: query.latitude,
        longitude: query.longitude,
        radiusKm: query.radiusKm,
      );
    });

final searchSpacesProvider = FutureProvider.family<List<SpaceModel>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.searchSpaces(query: query);
});

final filteredSpacesProvider =
    FutureProvider.family<List<SpaceModel>, FilterQuery>((ref, query) async {
      final repository = ref.watch(spaceRepositoryProvider);
      return repository.filterSpaces(
        maxPrice: query.maxPrice,
        hasWifi: query.hasWifi,
        hasParking: query.hasParking,
        hasQuietZone: query.hasQuietZone,
        hasPowerBackup: query.hasPowerBackup,
        neighborhoods: query.neighborhoods,
      );
    });

class LocationQuery {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LocationQuery({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5.0,
  });

  @override
  bool operator ==(Object other) =>
      other is LocationQuery &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.radiusKm == radiusKm;

  @override
  int get hashCode => Object.hash(latitude, longitude, radiusKm);
}

class FilterQuery {
  final double? maxPrice;
  final bool? hasWifi;
  final bool? hasParking;
  final bool? hasQuietZone;
  final bool? hasPowerBackup;
  final List<String>? neighborhoods;

  const FilterQuery({
    this.maxPrice,
    this.hasWifi,
    this.hasParking,
    this.hasQuietZone,
    this.hasPowerBackup,
    this.neighborhoods,
  });

  @override
  bool operator ==(Object other) =>
      other is FilterQuery &&
      other.maxPrice == maxPrice &&
      other.hasWifi == hasWifi &&
      other.hasParking == hasParking &&
      other.hasQuietZone == hasQuietZone &&
      other.hasPowerBackup == hasPowerBackup &&
      _listEquals(other.neighborhoods, neighborhoods);

  @override
  int get hashCode => Object.hash(
    maxPrice,
    hasWifi,
    hasParking,
    hasQuietZone,
    hasPowerBackup,
    neighborhoods,
  );

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final selectedSpaceProvider = StateProvider<SpaceModel?>((ref) => null);

final spaceFilterProvider =
    StateNotifierProvider<SpaceFilterNotifier, SpaceFilterState>((ref) {
      return SpaceFilterNotifier();
    });

class SpaceFilterState {
  final double? maxPrice;
  final bool hasWifi;
  final bool hasParking;
  final bool hasQuietZone;
  final bool hasPowerBackup;
  final List<String> selectedNeighborhoods;
  final String? sortBy;

  const SpaceFilterState({
    this.maxPrice,
    this.hasWifi = false,
    this.hasParking = false,
    this.hasQuietZone = false,
    this.hasPowerBackup = false,
    this.selectedNeighborhoods = const [],
    this.sortBy,
  });

  SpaceFilterState copyWith({
    double? maxPrice,
    bool? hasWifi,
    bool? hasParking,
    bool? hasQuietZone,
    bool? hasPowerBackup,
    List<String>? selectedNeighborhoods,
    String? sortBy,
  }) {
    return SpaceFilterState(
      maxPrice: maxPrice ?? this.maxPrice,
      hasWifi: hasWifi ?? this.hasWifi,
      hasParking: hasParking ?? this.hasParking,
      hasQuietZone: hasQuietZone ?? this.hasQuietZone,
      hasPowerBackup: hasPowerBackup ?? this.hasPowerBackup,
      selectedNeighborhoods:
          selectedNeighborhoods ?? this.selectedNeighborhoods,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class SpaceFilterNotifier extends StateNotifier<SpaceFilterState> {
  SpaceFilterNotifier() : super(const SpaceFilterState());

  void setMaxPrice(double? price) {
    state = state.copyWith(maxPrice: price);
  }

  void setHasWifi(bool value) {
    state = state.copyWith(hasWifi: value);
  }

  void setHasParking(bool value) {
    state = state.copyWith(hasParking: value);
  }

  void setHasQuietZone(bool value) {
    state = state.copyWith(hasQuietZone: value);
  }

  void setHasPowerBackup(bool value) {
    state = state.copyWith(hasPowerBackup: value);
  }

  void setSelectedNeighborhoods(List<String> neighborhoods) {
    state = state.copyWith(selectedNeighborhoods: neighborhoods);
  }

  void toggleNeighborhood(String neighborhood) {
    final neighborhoods = List<String>.from(state.selectedNeighborhoods);
    if (neighborhoods.contains(neighborhood)) {
      neighborhoods.remove(neighborhood);
    } else {
      neighborhoods.add(neighborhood);
    }
    state = state.copyWith(selectedNeighborhoods: neighborhoods);
  }

  void setSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const SpaceFilterState();
  }
}

final savedSpacesProvider = StateProvider<List<String>>((ref) => []);
