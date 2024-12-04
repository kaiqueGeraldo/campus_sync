import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService with ChangeNotifier {
  bool _isConnected = false;
  bool _isCheckingConnection = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool get isConnected => _isConnected;
  bool get isCheckingConnection => _isCheckingConnection;

  ConnectivityService() {
    initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    _isCheckingConnection = true;
    notifyListeners();

    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus(
          ConnectivityResult.none as List<ConnectivityResult>);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
  _isConnected = results.any((result) =>
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi);
  _isCheckingConnection = false;
  notifyListeners();
}


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
