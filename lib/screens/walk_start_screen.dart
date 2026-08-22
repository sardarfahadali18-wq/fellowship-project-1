import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/trusted_contact_reader.dart';
import '../services/walk_session_service.dart';
import '../services/walk_session_store.dart';
import '../widgets/contact_selector.dart';
import 'active_walk_screen.dart';
import 'walk_history_screen.dart';

class WalkStartScreen extends StatefulWidget {
  const WalkStartScreen({super.key, this.service, this.location, this.store, this.reader});

  final WalkSessionService? service;
  final LocationService? location;
  final WalkSessionStore? store;
  final TrustedContactReader? reader;

  @override
  State<WalkStartScreen> createState() => _WalkStartScreenState();
}

class _WalkStartScreenState extends State<WalkStartScreen> {
  static const choices = [10, 20, 30, 45, 60];

  late final WalkSessionService _service =
      widget.service ?? WalkSessionService.instance;
  Set<String> _picked = const {};
  int _minutes = 30;
  bool _busy = false;
  String? _error;

  Future<void> _start() async {
    setState(() { _busy = true; _error = null; });
    try {
      final location = widget.location;
      final problem = location == null
          ? null
          : permissionProblem(await location.ensurePermission());
      if (problem != null) {
        setState(() => _error = problem);
        return;
      }
      await _service.start(
          plannedDuration: Duration(minutes: _minutes),
          contactIds: _picked.toList());
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ActiveWalkScreen(service: _service)));
    } on StateError catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a walk'), actions: [
        if (widget.store != null)
          IconButton(
              tooltip: 'Walk history',
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WalkHistoryScreen(store: widget.store!)))),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('How long will you be walking? (minutes)'),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              children: choices
                  .map((m) => ChoiceChip(
                      label: Text('$m'),
                      showCheckmark: false,
                      selected: _minutes == m,
                      onSelected: (_) => setState(() => _minutes = m)))
                  .toList()),
          const SizedBox(height: 16),
          const Text('Who should see this walk?'),
          ContactSelector(
              selected: _picked,
              reader: widget.reader,
              onChanged: (next) => setState(() => _picked = next)),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:
                    Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
              onPressed: _busy ? null : _start,
              icon: const Icon(Icons.directions_walk),
              label: Text(_busy ? 'Starting...' : 'Start Walk')),
        ],
      ),
    );
  }
}
