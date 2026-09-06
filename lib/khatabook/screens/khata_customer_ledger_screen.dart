import 'package:flutter/material.dart';

import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';
import '../services/ledger_repository.dart';
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
  State<KhataCustomerLedgerScreen> createState() => _KhataCustomerLedgerScreenState();
}

class _KhataCustomerLedgerScreenState extends State<KhataCustomerLedgerScreen> {
  late Future<List<KhataTransactionData>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _transactionsFuture = widget.repository.transactionsForCustomer(widget.customer.id);
  }

  String _formatAmount(double amount) {
    final rounded = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return 'Rs $rounded';
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
                    Text(balanceLabel, style: Theme.of(context).textTheme.titleMedium),
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
                  ],
                ),
              ),
              Expanded(
                child: transactions.isEmpty
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
                              backgroundColor: isGave
                                  ? colorScheme.errorContainer
                                  : Colors.green.shade100,
                              child: Icon(
                                isGave ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isGave ? colorScheme.onErrorContainer : Colors.green.shade800,
                              ),
                            ),
                            title: Text(isGave ? 'Gave (Credit)' : 'Got (Payment)'),
                            subtitle: Text(
                              [
                                if (txn.note != null && txn.note!.isNotEmpty) txn.note!,
                                '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
                              ].join(' · '),
                            ),
                            trailing: Text(
                              _formatAmount(txn.amount),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isGave ? colorScheme.error : Colors.green.shade700,
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
              builder: (_) => RecordTransactionScreen(
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
