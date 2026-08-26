import 'package:flutter/material.dart';
import '../../models/trusted_contact.dart';
import '../../services/trusted_contacts_service.dart';
import '../../widgets/contact_card.dart';
import 'add_edit_contact_screen.dart';

/// Screen listing all Trusted Contacts for the signed-in user.
class TrustedContactsListScreen extends StatefulWidget {
  const TrustedContactsListScreen({
    super.key,
    required this.userId,
    this.service,
  });

  final String userId;
  final TrustedContactsService? service;

  @override
  State<TrustedContactsListScreen> createState() =>
      _TrustedContactsListScreenState();
}

class _TrustedContactsListScreenState extends State<TrustedContactsListScreen> {
  late final TrustedContactsService _service;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TrustedContactsService();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(
          userId: widget.userId,
          service: _service,
        ),
      ),
    );
  }

  void _navigateToEditContact(TrustedContact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(
          userId: widget.userId,
          contact: contact,
          service: _service,
        ),
      ),
    );
  }

  Future<void> _handleDelete(TrustedContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your trusted contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteContact(widget.userId, contact.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contact.name} removed')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _handleToggleEmergency(
    TrustedContact contact,
    bool isEmergency,
  ) async {
    try {
      if (isEmergency) {
        await _service.setPrimaryEmergencyContact(widget.userId, contact.id);
      } else {
        await _service.toggleEmergencyStatus(
          widget.userId,
          contact.id,
          false,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEmergency
                ? '${contact.name} marked as Primary Emergency Contact'
                : '${contact.name} removed from Primary Emergency Contact',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating contact: $e')),
      );
    }
  }

  void _handleCall(TrustedContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${contact.name} (${contact.phoneNumber})...'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _handleSms(TrustedContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Composing SMS to ${contact.name} (${contact.phoneNumber})...'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  /// Helper to populate sample contacts for testing & demonstrations
  Future<void> _seedDemoContacts() async {
    final sampleContacts = [
      const TrustedContact(
        id: '',
        name: 'Mom (Fatima)',
        phoneNumber: '+92 300 1122334',
        relationship: 'Mother',
        isEmergency: true,
        notes: 'Available 24/7',
      ),
      const TrustedContact(
        id: '',
        name: 'Ayesha (Sister)',
        phoneNumber: '+92 321 5566778',
        relationship: 'Sister',
        isEmergency: true,
        notes: 'Lives in same neighborhood',
      ),
      const TrustedContact(
        id: '',
        name: 'Bilal Khan',
        phoneNumber: '+92 333 9988776',
        relationship: 'Friend',
        isEmergency: false,
        notes: 'Coworker commuting same route',
      ),
    ];

    try {
      for (final c in sampleContacts) {
        await _service.addContact(widget.userId, c);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample demo contacts added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error seeding contacts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Seed Demo Contacts',
            onPressed: _seedDemoContacts,
          ),
        ],
      ),
      body: StreamBuilder<List<TrustedContact>>(
        stream: _service.streamContacts(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allContacts = snapshot.data ?? [];
          final filteredContacts = _searchQuery.isEmpty
              ? allContacts
              : allContacts.where((c) {
                  return c.name.toLowerCase().contains(_searchQuery) ||
                      c.phoneNumber.contains(_searchQuery) ||
                      c.relationship.toLowerCase().contains(_searchQuery);
                }).toList();

          final emergencyCount =
              allContacts.where((c) => c.isEmergency).length;

          return CustomScrollView(
            slivers: [
              // Safety Info Banner & Counter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: emergencyCount > 0
                              ? colorScheme.primaryContainer.withOpacity(0.4)
                              : colorScheme.errorContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: emergencyCount > 0
                                ? colorScheme.primary.withOpacity(0.2)
                                : colorScheme.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: emergencyCount > 0
                                  ? colorScheme.primary
                                  : colorScheme.error,
                              radius: 20,
                              child: Icon(
                                emergencyCount > 0
                                    ? Icons.security
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emergencyCount > 0
                                        ? '${allContacts.length} Contacts Saved • $emergencyCount Primary'
                                        : 'No Emergency Contacts Set',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: emergencyCount > 0
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onErrorContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    emergencyCount > 0
                                        ? 'These contacts will automatically receive your live walk link & SOS alerts.'
                                        : 'Please add at least 1-2 trusted contacts to enable safety features.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: emergencyCount > 0
                                          ? colorScheme.onPrimaryContainer
                                              .withOpacity(0.8)
                                          : colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search Box
                      if (allContacts.isNotEmpty)
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search contacts by name or phone...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            filled: true,
                            fillColor:
                                colorScheme.surfaceVariant.withOpacity(0.3),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Empty State
              if (allContacts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            size: 72,
                            color: colorScheme.outline.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Trusted Contacts Yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add family members or close friends who should receive your live tracking location and SOS alerts.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _navigateToAddContact,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Trusted Contact'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _seedDemoContacts,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Add Demo Contacts'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredContacts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No contacts matching "$_searchQuery"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = filteredContacts[index];
                      return ContactCard(
                        contact: contact,
                        onEdit: () => _navigateToEditContact(contact),
                        onDelete: () => _handleDelete(contact),
                        onToggleEmergency: (val) =>
                            _handleToggleEmergency(contact, val),
                        onCall: () => _handleCall(contact),
                        onSms: () => _handleSms(contact),
                      );
                    },
                    childCount: filteredContacts.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddContact,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
