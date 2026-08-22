import 'package:flutter/material.dart';

import '../models/walk_session.dart';
import '../services/walk_session_store.dart';
import 'walk_session_detail_screen.dart';

String formatStamp(DateTime at) =>
    '${at.year}-${at.month.toString().padLeft(2, '0')}-'
    '${at.day.toString().padLeft(2, '0')} '
    '${at.hour.toString().padLeft(2, '0')}:'
    '${at.minute.toString().padLeft(2, '0')}';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key, required this.store});

  final WalkSessionStore store;

  @override
  State<WalkHistoryScreen> createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  late Future<List<WalkSession>> _sessions = widget.store.loadAll();

  void _reload() => setState(() => _sessions = widget.store.loadAll());

  static Widget _message(String text) => Center(child: Text(text));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk history'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<WalkSession>>(
        future: _sessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _message('Could not read your walk history.');
          }
          final sessions = snapshot.data ?? const <WalkSession>[];
          if (sessions.isEmpty) {
            return _message('No walks recorded yet.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final session = sessions[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(formatStamp(session.startedAt),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${session.plannedDuration.inMinutes} min '
                      'planned, ${session.status.name}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          WalkSessionDetailScreen(session: session))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
