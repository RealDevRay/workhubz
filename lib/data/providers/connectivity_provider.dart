import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStream.map((r) => r != ConnectivityResult.none);
});

