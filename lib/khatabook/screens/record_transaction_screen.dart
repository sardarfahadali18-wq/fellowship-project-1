import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/khata_customer_data.dart';
import '../models/khata_txn_type.dart';
import '../services/ledger_repository.dart';
import '../widgets/numeric_keypad.dart';

/// Record Transaction screen: Gave (credit) / Got (payment) toggle, a large
/// numeric keypad for the amount, and an optional dictated/typed note with
/// a photo attachment.
class RecordTransactionScreen extends StatefulWidget {
  const RecordTransactionScreen({
    super.key,
    required this.customer,
    required this.repository,
  });

  final KhataCustomerData customer;
  final LedgerRepository repository;

  @override
  State<RecordTransactionScreen> createState() => _RecordTransactionScreenState();
}

class _RecordTransactionScreenState extends State<RecordTransactionScreen> {
  KhataTxnType _type = KhataTxnType.gave;
  String _amountText = '';
  final _noteController = TextEditingController();
  String? _photoPath;
  bool _isSaving = false;

  final _speech = SpeechToText();
  bool _isListening = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountText);

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition unavailable on this device')),
      );
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() => _noteController.text = result.recognizedWords);
      },
    );
  }

  Future<void> _attachPhoto() async {
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
    final amount = _amount;
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than zero')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.repository.addTransaction(
        customerId: widget.customer.id,
        type: _type,
        amount: amount,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        photoPath: _photoPath,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Record Transaction · ${widget.customer.name}')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          SegmentedButton<KhataTxnType>(
            segments: const [
              ButtonSegment(
                value: KhataTxnType.gave,
                label: Text('Gave (Credit)'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: KhataTxnType.got,
                label: Text('Got (Payment)'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() => _type = selection.first),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rs ${_amountText.isEmpty ? '0' : _amountText}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          NumericKeypad(onChanged: (value) => setState(() => _amountText = value)),
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                color: _isListening ? colorScheme.error : null,
                onPressed: _toggleListening,
                tooltip: 'Dictate note',
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _attachPhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(_photoPath == null ? 'Attach Photo' : 'Photo attached'),
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
            label: const Text('Save Transaction'),
          ),
        ],
      ),
    );
  }
}
