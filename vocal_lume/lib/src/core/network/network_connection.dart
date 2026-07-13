import 'package:connectivity_plus/connectivity_plus.dart';

/// Active network connection kind for download / streaming decisions.
enum NetworkConnectionKind {
  wifi,
  ethernet,
  mobile,
  none,
  other,
}

class NetworkConnectionInfo {
  const NetworkConnectionInfo(this.kind, this.rawResults);

  final NetworkConnectionKind kind;
  final List<ConnectivityResult> rawResults;

  bool get isMobileData => kind == NetworkConnectionKind.mobile;

  bool get isUnmetered =>
      kind == NetworkConnectionKind.wifi ||
      kind == NetworkConnectionKind.ethernet;

  bool get hasConnection => kind != NetworkConnectionKind.none;

  String get label => switch (kind) {
        NetworkConnectionKind.wifi => 'Wi‑Fi',
        NetworkConnectionKind.ethernet => 'Ethernet',
        NetworkConnectionKind.mobile => 'Mobile data',
        NetworkConnectionKind.none => 'No connection',
        NetworkConnectionKind.other => 'Other network',
      };
}

/// Reads the current network type (Wi‑Fi vs mobile data).
Future<NetworkConnectionInfo> checkNetworkConnection() async {
  final results = await Connectivity().checkConnectivity();
  return NetworkConnectionInfo(_classify(results), results);
}

NetworkConnectionKind _classify(List<ConnectivityResult> results) {
  if (results.isEmpty || results.contains(ConnectivityResult.none)) {
    // Prefer a more specific result if present alongside none.
    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkConnectionKind.wifi;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkConnectionKind.ethernet;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkConnectionKind.mobile;
    }
    if (results.length == 1 && results.first == ConnectivityResult.none) {
      return NetworkConnectionKind.none;
    }
    if (results.isEmpty) return NetworkConnectionKind.none;
  }

  // Prefer unmetered networks when both Wi‑Fi and mobile are reported.
  if (results.contains(ConnectivityResult.wifi)) {
    return NetworkConnectionKind.wifi;
  }
  if (results.contains(ConnectivityResult.ethernet)) {
    return NetworkConnectionKind.ethernet;
  }
  if (results.contains(ConnectivityResult.mobile)) {
    return NetworkConnectionKind.mobile;
  }
  return NetworkConnectionKind.other;
}
