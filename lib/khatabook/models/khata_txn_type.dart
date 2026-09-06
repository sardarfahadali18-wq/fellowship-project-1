/// Whether the vendor gave credit to the customer, or received a payment.
///
/// Plain (non-Isar) enum shared by the UI-facing data classes and the Isar
/// persistence layer, so UI code never needs to import Isar-generated code.
enum KhataTxnType {
  /// Vendor gave goods/credit to the customer — increases what they owe.
  gave,

  /// Vendor received a payment from the customer — reduces what they owe.
  got,
}
