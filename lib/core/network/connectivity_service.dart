import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity status enum for clean consumption by BLoCs.
enum ConnectivityStatus { online, offline }

/// Stream-based connectivity monitoring service.
///
/// Used by [TodoBloc] and [SyncBloc] to trigger automatic sync
/// when network becomes available.
class ConnectivityService {
  final Connectivity _connectivity;
  StreamController<ConnectivityStatus>? _statusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get statusStream {
    _statusController ??= StreamController<ConnectivityStatus>.broadcast();

    _subscription ??= _connectivity.onConnectivityChanged.listen(
      (results) {
        final status = _mapResultToStatus(results);
        _statusController?.add(status);
      },
    );

    return _statusController!.stream;
  }

  /// Get current connectivity status.
  Future<ConnectivityStatus> get currentStatus async {
    final results = await _connectivity.checkConnectivity();
    return _mapResultToStatus(results);
  }

  /// Check if currently online.
  Future<bool> get isOnline async {
    final status = await currentStatus;
    return status == ConnectivityStatus.online;
  }

  ConnectivityStatus _mapResultToStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  /// Clean up resources.
  void dispose() {
    _subscription?.cancel();
    _statusController?.close();
    _subscription = null;
    _statusController = null;
  }
}
