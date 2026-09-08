import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'khatabook/data/khatabook_isar_service.dart';
import 'khatabook/screens/khata_customers_screen.dart';
import 'khatabook/services/khata_ledger_repository.dart';
import 'khatabook/services/ledger_repository.dart';
import 'khatabook/sync/khata_background_sync.dart';
import 'khatabook/sync/khata_sync_api.dart';
import 'khatabook/sync/khata_sync_banner.dart';
import 'khatabook/sync/khata_sync_engine.dart';
import 'khatabook/sync/khata_sync_op.dart';
import 'khatabook/sync/syncing_ledger_repository.dart';
import 'sync/connectivity_service.dart';

/// Offline storage + sync engine (Hamza):
/// `flutter run -t lib/main_khatabook_sync_demo.dart`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = IsarKhataSyncStore(await KhataBookIsarService.getInstance());
  final connectivity = ConnectivityService();
  await connectivity.start();

  var cloudReady = true;
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    await KhataBackgroundSync.initialize();
  } catch (_) {
    cloudReady = false;
  }

  final engine = KhataSyncEngine(
    store: store,
    api: FirestoreKhataSyncApi(),
    connectivity: connectivity,
  );
  if (cloudReady) {
    engine.start();
    await engine.sync();
  } else {
    await engine.refresh();
  }

  runApp(
    KhataSyncDemoApp(
      engine: engine,
      repository: SyncingLedgerRepository(
        KhataLedgerRepository(),
        store,
        onQueued: engine.refresh,
      ),
    ),
  );
}

class KhataSyncDemoApp extends StatelessWidget {
  const KhataSyncDemoApp({
    super.key,
    required this.engine,
    required this.repository,
  });

  final KhataSyncEngine engine;
  final LedgerRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhataBook Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: Column(
        children: [
          SafeArea(
            bottom: false,
            child: KhataSyncBanner(engine: engine, onRestore: engine.restore),
          ),
          Expanded(child: KhataCustomersScreen(repository: repository)),
        ],
      ),
    );
  }
}
