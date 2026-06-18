import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<ConnectivityResult> checkConnection() async {
    return await _connectivity.checkConnectivity();
  }

  Stream<ConnectivityResult> get connectionStream {
    return _connectivity.onConnectivityChanged;
  }

  void subscribe(void Function(ConnectivityResult) listener) {
    _subscription = _connectivity.onConnectivityChanged.listen(listener);
  }

  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  String getConnectionType(ConnectivityResult results) {
    if (results == ConnectivityResult.wifi) {
      return 'Wi-Fi';
    } else if (results == ConnectivityResult.mobile) {
      return 'Mobile Data';
    } else if (results == ConnectivityResult.ethernet) {
      return 'Ethernet';
    } else if (results == ConnectivityResult.vpn) {
      return 'VPN';
    } else if (results == ConnectivityResult.none) {
      return 'No Connection';
    }
    return 'Unknown';
  }
}

class ConnectivityNotifier {
  final Connectivity _connectivity;
  final void Function(bool isConnected)? onConnectivityChanged;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityNotifier({this.onConnectivityChanged, Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = results != ConnectivityResult.none;
      onConnectivityChanged?.call(connected);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
