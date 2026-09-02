import 'package:isar_community/isar.dart';

import 'khata_transaction_data.dart';
import 'khata_txn_type.dart';

export 'khata_txn_type.dart';

part 'khata_transaction.g.dart';

/// A single ledger entry against one [KhataCustomer].
///
/// Isar-only: UI code should use [KhataTransactionData] instead (see
/// [toData]) so it doesn't depend on Isar's generated schema code, which
/// cannot compile for web.
@collection
class KhataTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: false)
  late String uuid;

  /// [KhataCustomer.id] this transaction belongs to.
  @Index()
  late int customerId;

  @enumerated
  @Index()
  late KhataTxnType type;

  /// Amount in rupees.
  late double amount;

  String? note;

  /// Local file path to an attached photo (receipt, goods, etc.), if any.
  String? photoPath;

  @Index()
  late DateTime createdAt;

  KhataTransactionData toData() => KhataTransactionData(
        id: id,
        customerId: customerId,
        type: type,
        amount: amount,
        note: note,
        photoPath: photoPath,
        createdAt: createdAt,
      );
}
