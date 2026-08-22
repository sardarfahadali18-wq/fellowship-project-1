import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/walk_session.dart';
import '../services/share_link_builder.dart';
import '../services/walk_session_service.dart';
import '../widgets/map_placeholder.dart';

class ActiveWalkScreen extends StatefulWidget {
  const ActiveWalkScreen(
      {super.key, this.service, this.linkBuilder = const StaticMapsLinkBuilder()});

  final WalkSessionService? service;
  final ShareLinkBuilder linkBuilder;

  @override
  State<ActiveWalkScreen> createState() => _ActiveWalkScreenState();
}

class _ActiveWalkScreenState extends State<ActiveWalkScreen> {
  late final WalkSessionService _service =
      widget.service ?? WalkSessionService.instance;

  Timer? _ticker;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }

  static String _clock(Duration d) {
    final hours = d.inHours > 0 ? '${d.inHours}:' : '';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours$minutes:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  static String _stamp(DateTime? at) => at == null
      ? 'no update yet'
      : '${at.hour.toString().padLeft(2, '0')}:'
          '${at.minute.toString().padLeft(2, '0')}';

  Future<void> _finish(Future<void> Function() action, String confirmation) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await action();
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(confirmation)));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Walk stopped, but saving history failed.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(WalkSession session) async {
    final link = widget.linkBuilder.buildFor(session);
    final messenger = ScaffoldMessenger.of(context);
    if (link == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('No location yet. Wait for the first update.')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    messenger.showSnackBar(
        const SnackBar(content: Text('Link copied. Paste it to your contact.')));
  }

  Future<void> _confirmCancel() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this walk?'),
        content: const Text('Your contacts will stop seeing your location.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep walking')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel walk')),
        ],
      ),
    );
    if (yes == true) await _finish(_service.cancel, 'Walk cancelled.');
  }

  List<String> _lines(WalkSession session) => [
        'Status: ${session.status.name}',
        'Last update ${_stamp(session.lastUpdatedAt)}',
        if (session.lastDeviationMetres != null)
          'Off route by ${session.lastDeviationMetres!.round()} m',
        if (session.missedCheckInAt != null)
          'Missed check-in at ${_stamp(session.missedCheckInAt)}',
        if (_service.hasUnsyncedWrites)
          'Not synced yet. Your contacts may be seeing an older position.',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walk in progress')),
      body: StreamBuilder<WalkSession>(
        stream: _service.sessionStream,
        builder: (context, _) {
          final session = _service.activeSession;
          if (session == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No walk is running. Start one to see it here.'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const MapPlaceholder(),
              const SizedBox(height: 24),
              Center(
                child: Text(_clock(_service.remaining),
                    style: Theme.of(context).textTheme.displayMedium),
              ),
              ..._lines(session).map((t) => Center(child: Text(t))),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _finish(_service.end, 'Walk ended and saved.'),
                icon: const Icon(Icons.check),
                label: const Text('End Walk'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _share(session),
                icon: const Icon(Icons.link),
                label: const Text('Copy share link'),
              ),
              TextButton(
                onPressed: _busy ? null : _confirmCancel,
                child: const Text('Cancel walk'),
              ),
            ],
          );
        },
      ),
    );
  }
}
