import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';
import 'ledger_repository.dart';

class KhataLedgerPdfService {
  static Future<void> generateAndShare({
    required KhataCustomerData customer,
    required List<KhataTransactionData> transactions,
  }) async {
    final balance = computeKhataBalance(transactions);
    final document = pw.Document();
    final balanceLabel =
        balance > 0
            ? 'Customer owes you'
            : balance < 0
            ? 'You owe customer'
            : 'Settled';

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(),
        ),
        build:
            (context) => [
              pw.Text(
                'KhataBook Ledger',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(customer.name, style: pw.TextStyle(fontSize: 16)),
              if (customer.phone != null && customer.phone!.isNotEmpty)
                pw.Text('Phone: ${customer.phone}'),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      balanceLabel,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Balance: Rs ${_formatAmount(balance.abs())}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              if (transactions.isEmpty)
                pw.Text('No transactions recorded.')
              else
                pw.TableHelper.fromTextArray(
                  headers: const ['Type', 'Amount', 'Date', 'Note'],
                  data:
                      transactions
                          .map(
                            (transaction) => [
                              transaction.type == KhataTxnType.gave
                                  ? 'Gave (Credit)'
                                  : 'Got (Payment)',
                              'Rs ${_formatAmount(transaction.amount)}',
                              _formatDate(transaction.createdAt),
                              transaction.note?.isNotEmpty == true
                                  ? transaction.note!
                                  : '-',
                            ],
                          )
                          .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellPadding: const pw.EdgeInsets.all(6),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignments: {1: pw.Alignment.centerRight},
                ),
            ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_fileName(customer.name)}');
    await file.writeAsBytes(await document.save());
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'KhataBook ledger for ${customer.name}');
  }

  static String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _fileName(String customerName) {
    final safeName = customerName
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${safeName.isEmpty ? 'customer' : safeName}_ledger.pdf';
  }
}
