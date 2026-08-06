import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` that exposes a simple online/offline
/// signal for the rest of the sync engine and the UI banner.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  final _controller = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Emits `true` when the device gains a usable network, `false` otherwise.
  Stream<bool> get onStatusChange => _controller.stream;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  /// Reads the current state and starts listening for changes.
  Future<void> start() async {
    final results = await _connectivity.checkConnectivity();
    _update(results);
    _sub ??= _connectivity.onConnectivityChanged.listen(_update);
  }

  /// One-off check without needing to keep a subscription.
  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  void _update(List<ConnectivityResult> results) {
    final online = _hasConnection(results);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(online);
    } else {
      _isOnline = online;
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
