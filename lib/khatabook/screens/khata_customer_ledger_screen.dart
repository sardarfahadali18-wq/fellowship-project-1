import 'package:flutter/material.dart';

import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';
import '../services/ledger_repository.dart';
import '../services/khata_ledger_pdf_service.dart';
import '../services/sms_reminder_service.dart';
import '../services/whatsapp_reminder_service.dart';
import '../widgets/khata_customer_avatar.dart';
import 'record_transaction_screen.dart';

/// Per-customer balance view: a big running balance, plus the full
/// transaction history for that customer.
class KhataCustomerLedgerScreen extends StatefulWidget {
  const KhataCustomerLedgerScreen({
    super.key,
    required this.customer,
    required this.repository,
  });

  final KhataCustomerData customer;
  final LedgerRepository repository;

  @override
  State<KhataCustomerLedgerScreen> createState() =>
      _KhataCustomerLedgerScreenState();
}

class _KhataCustomerLedgerScreenState extends State<KhataCustomerLedgerScreen> {
  late Future<List<KhataTransactionData>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _transactionsFuture = widget.repository.transactionsForCustomer(
      widget.customer.id,
    );
  }

  String _formatAmount(double amount) {
    final rounded = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return 'Rs $rounded';
  }

  Future<void> _remindOnWhatsApp(double balance) async {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending amount to remind about.')),
      );
      return;
    }
    if (WhatsAppReminderService.normalizePhone(widget.customer.phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a valid phone number for this customer first.'),
        ),
      );
      return;
    }

    try {
      final opened = await WhatsAppReminderService.launch(
        customerName: widget.customer.name,
        phone: widget.customer.phone,
        balance: balance,
      );
      if (!mounted || opened) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp on this device.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp on this device.'),
        ),
      );
    }
  }

  Future<void> _shareLedger(List<KhataTransactionData> transactions) async {
    try {
      await KhataLedgerPdfService.generateAndShare(
        customer: widget.customer,
        transactions: transactions,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not generate or share the ledger.'),
        ),
      );
    }
  }

  Future<void> _remindBySms(double balance) async {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending amount to remind about.')),
      );
      return;
    }
    if (WhatsAppReminderService.normalizePhone(widget.customer.phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a valid phone number for this customer first.'),
        ),
      );
      return;
    }

    try {
      final opened = await SmsReminderService.launch(
        customerName: widget.customer.name,
        phone: widget.customer.phone,
        balance: balance,
      );
      if (!mounted || opened) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the SMS app on this device.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the SMS app on this device.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.name)),
      body: FutureBuilder<List<KhataTransactionData>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data!;
          final balance = computeKhataBalance(transactions);
          final Color balanceColor;
          final String balanceLabel;
          if (balance > 0) {
            balanceColor = colorScheme.error;
            balanceLabel = 'Owes you';
          } else if (balance < 0) {
            balanceColor = Colors.green.shade700;
            balanceLabel = 'You owe';
          } else {
            balanceColor = colorScheme.onSurfaceVariant;
            balanceLabel = 'Settled up';
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: balanceColor.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    KhataCustomerAvatar(
                      name: widget.customer.name,
                      photoPath: widget.customer.photoPath,
                      radius: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      balanceLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _formatAmount(balance.abs()),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.customer.phone != null)
                      Text(
                        widget.customer.phone!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _remindOnWhatsApp(balance),
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Remind on WhatsApp'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _remindBySms(balance),
                      icon: const Icon(Icons.sms_outlined),
                      label: const Text('Remind by SMS'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _shareLedger(transactions),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export as PDF'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    transactions.isEmpty
                        ? const Center(child: Text('No transactions yet'))
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            final isGave = txn.type == KhataTxnType.gave;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    isGave
                                        ? colorScheme.errorContainer
                                        : Colors.green.shade100,
                                child: Icon(
                                  isGave
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                      isGave
                                          ? colorScheme.onErrorContainer
                                          : Colors.green.shade800,
                                ),
                              ),
                              title: Text(
                                isGave ? 'Gave (Credit)' : 'Got (Payment)',
                              ),
                              subtitle: Text(
                                [
                                  if (txn.note != null && txn.note!.isNotEmpty)
                                    txn.note!,
                                  '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
                                ].join(' · '),
                              ),
                              trailing: Text(
                                _formatAmount(txn.amount),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color:
                                      isGave
                                          ? colorScheme.error
                                          : Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder:
                  (_) => RecordTransactionScreen(
                    customer: widget.customer,
                    repository: widget.repository,
                  ),
            ),
          );
          if (saved == true) {
            setState(_load);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Record Transaction'),
      ),
    );
  }
}
