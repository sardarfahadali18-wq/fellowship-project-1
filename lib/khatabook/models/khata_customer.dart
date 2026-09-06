import 'package:isar_community/isar.dart';

import 'khata_customer_data.dart';

part 'khata_customer.g.dart';

/// A customer in the vendor's digital ledger.
///
/// Lives in its own [khatabook] Isar instance so this module never touches
/// the app's shared collections/schema list. Isar-only: UI code should use
/// [KhataCustomerData] instead (see [toData]) so it doesn't depend on
/// Isar's generated schema code, which cannot compile for web.
@collection
class KhataCustomer {
  Id id = Isar.autoIncrement;

  /// Client-generated idempotency key.
  @Index(unique: true, replace: false)
  late String uuid;

  @Index()
  late String name;

  String? phone;

  /// Local file path to the customer's photo, if one was attached.
  String? photoPath;

  late DateTime createdAt;

  KhataCustomerData toData() => KhataCustomerData(
        id: id,
        name: name,
        phone: phone,
        photoPath: photoPath,
        createdAt: createdAt,
      );
}
