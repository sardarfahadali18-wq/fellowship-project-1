import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/khata_customer_data.dart';
import '../services/ledger_repository.dart';
import '../widgets/khata_customer_avatar.dart';

/// Add Customer flow: name, optional photo, optional import from the
/// device's contact book.
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key, required this.repository});

  final LedgerRepository repository;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _photoPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _importFromContacts() async {
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) return;
      setState(() {
        if (contact.displayName.isNotEmpty) {
          _nameController.text = contact.displayName;
        }
        if (contact.phones.isNotEmpty) {
          _phoneController.text = contact.phones.first.number;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open contacts: $e')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      setState(() => _photoPath = picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open gallery: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final customer = await widget.repository.addCustomer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photoPath: _photoPath,
      );
      if (!mounted) return;
      Navigator.of(context).pop<KhataCustomerData>(customer);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    KhataCustomerAvatar(
                      name: _nameController.text,
                      photoPath: _photoPath,
                      radius: 44,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _importFromContacts,
              icon: const Icon(Icons.contacts_outlined),
              label: const Text('Import from Contacts'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
