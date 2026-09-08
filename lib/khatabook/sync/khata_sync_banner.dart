import 'package:flutter/material.dart';

import 'khata_sync_engine.dart';
import 'khata_sync_types.dart';

const Map<KhataSyncState, (IconData, Color, String)> _looks = {
  KhataSyncState.idle: (Icons.cloud_queue, Colors.blueGrey, 'Ready'),
  KhataSyncState.syncing: (Icons.sync, Colors.blue, 'Syncing'),
  KhataSyncState.offline: (Icons.cloud_off, Colors.orange, 'Offline'),
  KhataSyncState.error: (Icons.error_outline, Colors.red, 'Retrying'),
  KhataSyncState.done: (Icons.cloud_done, Colors.green, 'Backed up'),
};

class KhataSyncBanner extends StatelessWidget {
  const KhataSyncBanner({super.key, required this.engine, this.onRestore});

  final KhataSyncEngine engine;
  final Future<void> Function()? onRestore;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KhataSyncStatus>(
      valueListenable: engine.status,
      builder: (context, status, _) {
        final (icon, color, label) = _looks[status.state]!;
        return Material(
          color: color.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status.pending == 0
                        ? label
                        : '$label · ${status.pending} waiting',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sync now',
                  icon: const Icon(Icons.refresh),
                  onPressed: status.state == KhataSyncState.syncing
                      ? null
                      : () => engine.sync(force: true),
                ),
                if (onRestore != null)
                  IconButton(
                    tooltip: 'Restore from backup',
                    icon: const Icon(Icons.cloud_download_outlined),
                    onPressed: status.state == KhataSyncState.syncing
                        ? null
                        : onRestore,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
