import 'package:flutter/material.dart';
import '../services/caregiver_link_service.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _linkService = CaregiverLinkService();
  String? _code;
  bool _loading = false;
  String? _error;

  Future<void> _generateCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final code = await _linkService.generateInviteCode();
      setState(() => _code = code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite a Caregiver')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Generate a code and share it with your caregiver so they can follow your progress.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_code != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _code!,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
              ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _generateCode,
                    child: Text(_code == null ? 'Generate Invite Code' : 'Generate New Code'),
                  ),
          ],
        ),
      ),
    );
  }
}
