import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../sync/connectivity_service.dart';
import '../data/khatabook_isar_service.dart';
import 'khata_sync_api.dart';
import 'khata_sync_engine.dart';
import 'khata_sync_op.dart';
import 'khata_sync_types.dart';

const String kKhataSyncTask = 'khata-sync-drain';
const String kKhataSyncUnique = 'khata-periodic-sync';

@pragma('vm:entry-point')
void khataSyncDispatcher() {
  Workmanager().executeTask((_, __) async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final engine = KhataSyncEngine(
        store: IsarKhataSyncStore(await KhataBookIsarService.getInstance()),
        api: FirestoreKhataSyncApi(),
        connectivity: ConnectivityService(),
      );
      final result = await engine.sync();
      await engine.dispose();
      return result.state != KhataSyncState.error;
    } catch (error) {
      debugPrint('khata background sync: $error');
      return false;
    }
  });
}

class KhataBackgroundSync {
  static Future<void> initialize() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    await Workmanager().initialize(
      khataSyncDispatcher,
      isInDebugMode: kDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      kKhataSyncUnique,
      kKhataSyncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  }

  static Future<void> cancel() =>
      Workmanager().cancelByUniqueName(kKhataSyncUnique);
}
