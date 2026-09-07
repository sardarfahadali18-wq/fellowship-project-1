import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../services/ledger_repository.dart';
import '../widgets/khata_customer_avatar.dart';
import 'add_customer_screen.dart';
import 'khata_customer_ledger_screen.dart';

/// Minimal customer list so the Core Ledger Loop module can be run and
/// demoed standalone. The real app-wide home dashboard is Sardar's module.
class KhataCustomersScreen extends StatefulWidget {
  const KhataCustomersScreen({super.key, required this.repository});

  final LedgerRepository repository;

  @override
  State<KhataCustomersScreen> createState() => _KhataCustomersScreenState();
}

class _KhataCustomersScreenState extends State<KhataCustomersScreen> {
  static const _overdueThresholdKey = 'khatabook.overdue_threshold_days';
  static const _thresholdOptions = [7, 15, 30, 45, 60, 90];

  late Future<List<_CustomerSummary>> _customersFuture;
  _CustomerFilter _filter = _CustomerFilter.all;
  _CustomerSort _sort = _CustomerSort.name;
  int _overdueThreshold = overdueDays;

  @override
  void initState() {
    super.initState();
    _loadOverdueThreshold();
    _load();
  }

  Future<void> _loadOverdueThreshold() async {
    final preferences = await SharedPreferences.getInstance();
    final savedThreshold = preferences.getInt(_overdueThresholdKey);
    if (!mounted ||
        savedThreshold == null ||
        !_thresholdOptions.contains(savedThreshold)) {
      return;
    }
    setState(() => _overdueThreshold = savedThreshold);
  }

  Future<void> _setOverdueThreshold(int threshold) async {
    setState(() => _overdueThreshold = threshold);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_overdueThresholdKey, threshold);
  }

  void _load() {
    _customersFuture = _loadSummaries();
  }

  Future<List<_CustomerSummary>> _loadSummaries() async {
    final customers = await widget.repository.listCustomers();
    return Future.wait(
      customers.map((customer) async {
        final transactions = await widget.repository.transactionsForCustomer(
          customer.id,
        );
        return _CustomerSummary.from(customer, transactions);
      }),
    );
  }

  List<_CustomerSummary> _visibleCustomers(List<_CustomerSummary> summaries) {
    final visible =
        summaries.where((summary) {
          return _filter == _CustomerFilter.all ||
              summary.isOverdue(_overdueThreshold);
        }).toList();
    visible.sort((a, b) {
      final result = switch (_sort) {
        _CustomerSort.name => a.customer.name.compareTo(b.customer.name),
        _CustomerSort.balance => b.balance.compareTo(a.balance),
        _CustomerSort.oldestCredit => _compareDates(
          a.oldestCreditDate,
          b.oldestCreditDate,
        ),
      };
      return result == 0 ? a.customer.name.compareTo(b.customer.name) : result;
    });
    return visible;
  }

  int _compareDates(DateTime? first, DateTime? second) {
    if (first == null) return second == null ? 0 : 1;
    if (second == null) return -1;
    return first.compareTo(second);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KhataBook Lite'),
        actions: [
          PopupMenuButton<_CustomerSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort customers',
            initialValue: _sort,
            onSelected: (sort) => setState(() => _sort = sort),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: _CustomerSort.name,
                    child: Text('Name A-Z'),
                  ),
                  PopupMenuItem(
                    value: _CustomerSort.balance,
                    child: Text('Highest outstanding balance'),
                  ),
                  PopupMenuItem(
                    value: _CustomerSort.oldestCredit,
                    child: Text('Oldest credit first'),
                  ),
                ],
          ),
        ],
      ),
      body: FutureBuilder<List<_CustomerSummary>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final customers = _visibleCustomers(snapshot.data!);
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No customers yet. Tap + to add one.'),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: SegmentedButton<_CustomerFilter>(
                  segments: const [
                    ButtonSegment(
                      value: _CustomerFilter.all,
                      label: Text('All Customers'),
                    ),
                    ButtonSegment(
                      value: _CustomerFilter.overdue,
                      label: Text('Overdue'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged:
                      (selection) => setState(() => _filter = selection.first),
                ),
              ),
              if (_filter == _CustomerFilter.overdue)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Text('Overdue after:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _overdueThreshold,
                        items:
                            _thresholdOptions
                                .map(
                                  (days) => DropdownMenuItem(
                                    value: days,
                                    child: Text('$days days'),
                                  ),
                                )
                                .toList(),
                        onChanged: (days) {
                          if (days != null) _setOverdueThreshold(days);
                        },
                      ),
                    ],
                  ),
                ),
              if (customers.isEmpty)
                const Expanded(
                  child: Center(child: Text('No overdue customers.')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final summary = customers[index];
                      final customer = summary.customer;
                      final balance = summary.balance;
                      return ListTile(
                        leading: KhataCustomerAvatar(
                          name: customer.name,
                          photoPath: customer.photoPath,
                        ),
                        title: Text(customer.name),
                        subtitle: Text(
                          summary.isOverdue(_overdueThreshold)
                              ? '${customer.phone ?? ''}${customer.phone == null ? '' : ' · '}Overdue'
                              : customer.phone ?? '',
                        ),
                        trailing: Text(
                          balance == 0
                              ? 'Settled'
                              : 'Rs ${balance.abs().toStringAsFixed(balance % 1 == 0 ? 0 : 2)}',
                          style: TextStyle(
                            color:
                                balance > 0
                                    ? Theme.of(context).colorScheme.error
                                    : balance < 0
                                    ? Colors.green.shade700
                                    : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => KhataCustomerLedgerScreen(
                                    customer: customer,
                                    repository: widget.repository,
                                  ),
                            ),
                          );
                          setState(_load);
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(repository: widget.repository),
            ),
          );
          setState(_load);
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

enum _CustomerFilter { all, overdue }

enum _CustomerSort { name, balance, oldestCredit }

class _CustomerSummary {
  const _CustomerSummary({required this.customer, required this.transactions});

  factory _CustomerSummary.from(
    KhataCustomerData customer,
    List<KhataTransactionData> transactions,
  ) {
    return _CustomerSummary(customer: customer, transactions: transactions);
  }

  final KhataCustomerData customer;
  final List<KhataTransactionData> transactions;

  double get balance => computeKhataBalance(transactions);

  DateTime? get oldestCreditDate => oldestGaveTransactionDate(transactions);

  bool isOverdue(int thresholdDays) =>
      isKhataCustomerOverdue(transactions, thresholdDays: thresholdDays);
}
