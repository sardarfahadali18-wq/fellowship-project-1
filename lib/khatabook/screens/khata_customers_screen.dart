import 'package:flutter/material.dart';

import '../models/khata_customer_data.dart';
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
  late Future<List<KhataCustomerData>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _customersFuture = widget.repository.listCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KhataBook Lite')),
      body: FutureBuilder<List<KhataCustomerData>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final customers = snapshot.data!;
          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return FutureBuilder<double>(
                future: widget.repository.balanceForCustomer(customer.id),
                builder: (context, balanceSnapshot) {
                  final balance = balanceSnapshot.data;
                  return ListTile(
                    leading: KhataCustomerAvatar(
                      name: customer.name,
                      photoPath: customer.photoPath,
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.phone ?? ''),
                    trailing: balance == null
                        ? null
                        : Text(
                            balance == 0
                                ? 'Settled'
                                : 'Rs ${balance.abs().toStringAsFixed(balance % 1 == 0 ? 0 : 2)}',
                            style: TextStyle(
                              color: balance > 0
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
                          builder: (_) => KhataCustomerLedgerScreen(
                            customer: customer,
                            repository: widget.repository,
                          ),
                        ),
                      );
                      setState(_load);
                    },
                  );
                },
              );
            },
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
