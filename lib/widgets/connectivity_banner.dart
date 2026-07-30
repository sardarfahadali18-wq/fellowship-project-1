import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Dynamic, non-blocking network status indicator for RuralEdu.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;
  bool _showOnlineRestored = false;

  @override
  void initState() {
    super.initState();

    // 1. Initial connectivity check upon widget load
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() {
          _isOffline = results.contains(ConnectivityResult.none);
        });
      }
    });

    // 2. Real-time dynamic network status listener
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);

      if (_isOffline && !offline) {
        // Connection restored: show green banner temporarily
        setState(() {
          _isOffline = false;
          _showOnlineRestored = true;
        });

        // Auto-hide the green restored banner after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showOnlineRestored = false;
            });
          }
        });
      } else {
        setState(() {
          _isOffline = offline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline && !_showOnlineRestored) {
      return const SizedBox.shrink(); // Hidden when online & idle
    }

    final bool isOfflineState = _isOffline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: isOfflineState ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOfflineState ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isOfflineState
                ? 'Offline — Changes saved locally'
                : 'Online — Ready to sync progress',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}