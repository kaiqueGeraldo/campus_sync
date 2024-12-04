import 'package:campus_sync/src/connectivity/connectivity_service.dart';
import 'package:campus_sync/src/connectivity/offline_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final context = navigator?.context;
    if (context != null) {
      final connectivityService =
          Provider.of<ConnectivityService>(context, listen: false);

      // Só exibe a OfflinePage se estiver desconectado
      if (!connectivityService.isConnected) {
        Future.microtask(() {
          if (!connectivityService.isConnected) {
            navigator?.pushReplacement(
              MaterialPageRoute(
                builder: (_) => OfflinePage(
                  onRetry: () {
                    // Forçar verificação manual
                    connectivityService.initConnectivity();
                  },
                  isLoading: connectivityService.isCheckingConnection,
                ),
              ),
            );
          }
        });
      }
    }
  }
}
