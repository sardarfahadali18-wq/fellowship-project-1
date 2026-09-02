import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/khata_customer.dart';
import '../models/khata_transaction.dart';

/// Standalone Isar instance for the KhataBook Lite ledger module.
///
/// Kept separate from the app's shared [IsarService] (lib/data/isar_service.dart)
/// so this module can ship without editing that file's fixed schema list.
class KhataBookIsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) {
      return _isar!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [KhataCustomerSchema, KhataTransactionSchema],
      directory: dir.path,
      name: 'khatabook',
    );
    return _isar!;
  }
}
