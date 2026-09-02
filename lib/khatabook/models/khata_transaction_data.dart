import 'khata_txn_type.dart';

/// Plain, storage-agnostic transaction record used throughout the UI layer.
/// See [KhataCustomerData] for why this is kept separate from the Isar
/// persistence model.
class KhataTransactionData {
  const KhataTransactionData({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note,
    this.photoPath,
    required this.createdAt,
  });

  final int id;
  final int customerId;
  final KhataTxnType type;
  final double amount;
  final String? note;
  final String? photoPath;
  final DateTime createdAt;
}
