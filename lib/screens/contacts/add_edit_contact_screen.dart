import 'package:flutter/material.dart';
import '../../models/trusted_contact.dart';
import '../../services/trusted_contacts_service.dart';

/// Screen for adding or editing a [TrustedContact].
class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({
    super.key,
    required this.userId,
    this.contact,
    this.service,
  });

  final String userId;
  final TrustedContact? contact;
  final TrustedContactsService? service;

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TrustedContactsService _service;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  late String _relationship;
  late bool _isEmergency;
  bool _isLoading = false;
  String? _errorMessage;

  static const _relationshipOptions = [
    'Mother',
    'Father',
    'Sister',
    'Brother',
    'Spouse / Partner',
    'Friend',
    'Roommate',
    'Hostel Warden',
    'Colleague',
    'Neighbor',
    'Other',
  ];

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TrustedContactsService();

    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _relationship = c?.relationship ?? 'Mother';
    if (!_relationshipOptions.contains(_relationship)) {
      _relationship = 'Other';
    }
    _isEmergency = c?.isEmergency ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newContact = TrustedContact(
        id: widget.contact?.id ?? '',
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        relationship: _relationship,
        email: _emailController.text.trim(),
        isEmergency: _isEmergency,
        notes: _notesController.text.trim(),
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await _service.updateContact(widget.userId, newContact);
      } else {
        await _service.addContact(widget.userId, newContact);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? '${newContact.name} updated successfully'
              : '${newContact.name} added to trusted contacts'),
          backgroundColor: Colors.green[700],
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
          'Are you sure you want to remove ${widget.contact!.name} from your trusted contacts?',
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

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _service.deleteContact(widget.userId, widget.contact!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete contact: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Trusted Contact' : 'Add Trusted Contact'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: 'Delete Contact',
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Guidance Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Trusted contacts receive your live Walk-With-Me tracking links and emergency SOS alerts.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),

            // Name Field
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'e.g. Sarah Khan',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter contact name';
                }
                if (val.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: '+92 300 1234567',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                helperText: 'Include country code for reliable SMS & calls',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                final clean = val.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                if (clean.length < 7) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Relationship Selector
            Text(
              'Relationship',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _relationshipOptions.map((rel) {
                final isSelected = _relationship == rel;
                return ChoiceChip(
                  label: Text(rel),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _relationship = rel);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Email (Optional)
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                hintText: 'sarah@example.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val != null && val.trim().isNotEmpty) {
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes (Optional)
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Emergency Notes (Optional)',
                hintText: 'e.g. Has vehicle, lives nearby, workplace desk #',
                prefixIcon: Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Primary Emergency Switch
            Card(
              elevation: 0,
              color: _isEmergency
                  ? colorScheme.errorContainer.withOpacity(0.2)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isEmergency
                      ? colorScheme.error.withOpacity(0.5)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: const Text(
                  'Set as Primary Emergency Contact',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Priority contact for instant SOS alerts and offline SMS fallback notifications.',
                ),
                value: _isEmergency,
                activeColor: colorScheme.error,
                onChanged: (val) => setState(() => _isEmergency = val),
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isLoading
                    ? 'Saving...'
                    : (_isEditing ? 'Update Contact' : 'Save Contact'),
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
