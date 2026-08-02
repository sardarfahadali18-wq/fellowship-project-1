import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../data/isar_service.dart';
import 'connectivity_service.dart';
import 'sync_api_client.dart';
import 'sync_engine.dart';

/// Unique task name for the periodic background drain.
const String kSyncTaskName = 'sync-outbox-drain';
const String kSyncUniqueName = 'periodic-sync-outbox';

/// Base URL for Hammas's backend. Override at build time with:
///   flutter run --dart-define=SYNC_BASE_URL=https://PROJECT.supabase.co/functions/v1
const String kSyncBaseUrl = String.fromEnvironment(
  'SYNC_BASE_URL',
  defaultValue: 'http://10.0.2.2:54321/functions/v1',
);

/// Entry point invoked by WorkManager in a background isolate. Must be a
/// top-level or static function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final isar = await IsarService.getInstance();
      final connectivity = ConnectivityService();
      final api = HttpSyncApiClient(baseUrl: kSyncBaseUrl);
      final engine = SyncEngine(
        isar: isar,
        api: api,
        connectivity: connectivity,
      );
      final result = await engine.syncNow();
      // Ask WorkManager to retry if events remain.
      return result.state != SyncState.error;
    } catch (e) {
      debugPrint('Background sync failed: $e');
      return false; // triggers WorkManager's backoff retry
    }
  });
}

/// Wires up background sync. Call once from `main()` after Flutter is
/// initialized. No-op on platforms WorkManager doesn't support.
class BackgroundSync {
  static Future<void> initialize() async {
    if (!(defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS)) {
      return;
    }
    await Workmanager().initialize(
      syncCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      kSyncUniqueName,
      kSyncTaskName,
      frequency: const Duration(minutes: 15), // platform minimum
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  static Future<void> cancel() => Workmanager().cancelByUniqueName(
        kSyncUniqueName,
      );
}
