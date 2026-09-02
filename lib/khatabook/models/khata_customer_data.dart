/// Plain, storage-agnostic customer record used throughout the UI layer.
///
/// Deliberately has no Isar dependency: the real Isar-backed repository
/// converts its `@collection` row into this on the way out, and the
/// in-memory (web demo) repository constructs it directly. This keeps
/// Isar's generated schema code (which cannot compile for web) out of
/// every file that only needs to display or pass around a customer.
class KhataCustomerData {
  const KhataCustomerData({
    required this.id,
    required this.name,
    this.phone,
    this.photoPath,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? phone;
  final String? photoPath;
  final DateTime createdAt;
}
