import 'package:flutter/material.dart';

import 'khatabook/data/khatabook_isar_service.dart';
import 'khatabook/screens/khata_customers_screen.dart';
import 'khatabook/services/khata_ledger_repository.dart';

/// Standalone entry point to run/demo just the KhataBook Lite Core Ledger
/// Loop module (Hammas): `flutter run -t lib/main_khatabook_demo.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KhataBookIsarService.getInstance();
  runApp(const KhataBookDemoApp());
}

class KhataBookDemoApp extends StatelessWidget {
  const KhataBookDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhataBook Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: KhataCustomersScreen(repository: KhataLedgerRepository()),
    );
  }
}
