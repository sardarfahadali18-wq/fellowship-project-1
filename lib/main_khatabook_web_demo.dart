import 'package:flutter/material.dart';

import 'khatabook/screens/khata_customers_screen.dart';
import 'khatabook/services/in_memory_khata_ledger_repository.dart';

/// Chrome/web demo entry point for the KhataBook Lite Core Ledger Loop
/// module. Isar (this app's real local database) cannot compile for web, so
/// this uses an in-memory repository instead — data resets on reload. For a
/// persistent, production-shaped run use `lib/main_khatabook_demo.dart` on
/// Android or another native platform.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KhataBookWebDemoApp());
}

class KhataBookWebDemoApp extends StatelessWidget {
  const KhataBookWebDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhataBook Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: KhataCustomersScreen(repository: InMemoryKhataLedgerRepository()),
    );
  }
}
