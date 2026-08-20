import 'package:flutter/material.dart';

import '../services/sos_service.dart';
import '../widgets/sos_button.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key, SosService? sosService})
    : _sosService = sosService;

  final SosService? _sosService;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  late final SosService _sosService = widget._sosService ?? SosService();

  bool _isBusy = false;
  bool get _isActive => _sosService.activeAlert != null;

  Future<void> _handleTap() {
    return _isActive ? _confirmAndResolve() : _confirmAndTrigger();
  }

  Future<void> _confirmAndTrigger() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Send SOS alert?'),
            content: const Text(
              'This will alert all your trusted contacts with your live '
              'location and turn on the siren and flashlight.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Send SOS'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      await _sosService.triggerSos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS sent to your trusted contacts.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not send SOS: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmAndResolve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("I'm safe now"),
            content: const Text(
              'This will stop the siren and let your contacts know the '
              'alert is over.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Keep alert active'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("I'm safe"),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      await _sosService.resolveSos();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SosButton(
                isActive: _isActive,
                isBusy: _isBusy,
                onPressed: _handleTap,
              ),
              const SizedBox(height: 32),
              Text(
                _isActive
                    ? 'Alert is active. Tap the button when you are safe.'
                    : 'Tap the button to alert your trusted contacts '
                        'immediately.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
