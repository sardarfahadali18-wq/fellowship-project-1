import 'package:flutter/material.dart';

import '../models/walk_contact.dart';
import '../services/trusted_contact_reader.dart';

class ContactSelector extends StatefulWidget {
  const ContactSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.reader,
  });

  static const fallbackContacts = [
    WalkContact(id: 'Mom', name: 'Mom', phoneNumber: ''),
    WalkContact(id: 'Ayesha', name: 'Ayesha', phoneNumber: ''),
    WalkContact(id: 'Bilal', name: 'Bilal', phoneNumber: ''),
    WalkContact(id: 'Warden', name: 'Hostel warden', phoneNumber: ''),
  ];

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final TrustedContactReader? reader;

  @override
  State<ContactSelector> createState() => _ContactSelectorState();
}

class _ContactSelectorState extends State<ContactSelector> {
  List<WalkContact> _contacts = ContactSelector.fallbackContacts;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reader = widget.reader;
    if (reader == null) return;
    try {
      final found = await reader.forCurrentUser();
      if (!mounted) return;
      setState(() {
        if (found.isEmpty) {
          _notice = 'No trusted contacts saved yet. Showing examples.';
          return;
        }
        _contacts = found;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() =>
          _notice = 'Could not load your trusted contacts. Showing examples.');
    }
  }

  void _toggle(String id, bool on) {
    final next = {...widget.selected};
    if (on) {
      next.add(id);
    } else {
      next.remove(id);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_notice != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_notice!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
        ..._contacts.map((c) => CheckboxListTile(
              title: Text(c.name),
              value: widget.selected.contains(c.id),
              onChanged: (on) => _toggle(c.id, on == true),
            )),
      ],
    );
  }
}
