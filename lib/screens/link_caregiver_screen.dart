import 'package:flutter/material.dart';
import '../services/caregiver_link_service.dart';

class LinkCaregiverScreen extends StatefulWidget {
  const LinkCaregiverScreen({super.key});

  @override
  State<LinkCaregiverScreen> createState() => _LinkCaregiverScreenState();
}

class _LinkCaregiverScreenState extends State<LinkCaregiverScreen> {
  final _linkService = CaregiverLinkService();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _redeemCode() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final error = await _linkService.redeemInviteCode(_codeController.text);
    setState(() {
      _loading = false;
      _message = error ?? 'Successfully linked to patient!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link to a Patient')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the invite code your patient shared with you.'),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Invite Code'),
            ),
            const SizedBox(height: 24),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message == 'Successfully linked to patient!' ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _redeemCode,
                    child: const Text('Link Account'),
                  ),
          ],
        ),
      ),
    );
  }
}
