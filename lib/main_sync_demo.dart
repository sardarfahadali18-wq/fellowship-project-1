import 'package:flutter/material.dart';

import 'data/isar_service.dart';
import 'sync/background_sync.dart';
import 'sync/connectivity_service.dart';
import 'sync/outbox_service.dart';
import 'sync/sync_api_client.dart';
import 'sync/sync_engine.dart';

/// Standalone harness for the Sync Engine (Hamza).
///
/// Run with:
///   flutter run -t lib/main_sync_demo.dart \
///     --dart-define=SYNC_BASE_URL=https://PROJECT.supabase.co/functions/v1
///
/// Lets you queue events into the outbox, watch the pending count, toggle
/// airplane mode, and hit "Sync now" to drain the queue to the backend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.getInstance();
  final connectivity = ConnectivityService();
  await connectivity.start();

  final outbox = OutboxService(isar);
  final api = HttpSyncApiClient(baseUrl: kSyncBaseUrl);
  final engine = SyncEngine(isar: isar, api: api, connectivity: connectivity);
  engine.startAutoSync();

  runApp(SyncDemoApp(engine: engine, outbox: outbox));
}

class SyncDemoApp extends StatelessWidget {
  const SyncDemoApp({super.key, required this.engine, required this.outbox});

  final SyncEngine engine;
  final OutboxService outbox;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync Engine Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: SyncDemoPage(engine: engine, outbox: outbox),
    );
  }
}

class SyncDemoPage extends StatefulWidget {
  const SyncDemoPage({super.key, required this.engine, required this.outbox});

  final SyncEngine engine;
  final OutboxService outbox;

  @override
  State<SyncDemoPage> createState() => _SyncDemoPageState();
}

class _SyncDemoPageState extends State<SyncDemoPage> {
  static const int _demoStudentId = 1;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _refreshPending();
  }

  Future<void> _refreshPending() async {
    final count = await widget.outbox.pendingCount();
    if (mounted) setState(() => _pending = count);
  }

  Future<void> _queue(Future<void> Function() action) async {
    await action();
    await _refreshPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Engine (Hamza)'),
        actions: [const _SyncIndicator(), const SizedBox(width: 12)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pending events in outbox'),
                    Text(
                      '$_pending',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Simulate user actions:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _queue(() => widget.outbox.logLessonOpened(
                        studentId: _demoStudentId,
                        lessonId: 101,
                      )),
                  child: const Text('Lesson opened'),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      _queue(() => widget.outbox.logLessonCompleted(
                            studentId: _demoStudentId,
                            lessonId: 101,
                          )),
                  child: const Text('Lesson completed'),
                ),
                FilledButton.tonal(
                  onPressed: () => _queue(() => widget.outbox.logQuizSubmitted(
                        studentId: _demoStudentId,
                        lessonId: 101,
                        score: 4,
                        total: 5,
                      )),
                  child: const Text('Quiz submitted'),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Sync now'),
              onPressed: () async {
                await widget.engine.syncNow();
                await _refreshPending();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact status pill driven by [SyncEngine.status]. Drop this into any
/// AppBar (Adil's UI) to show live sync state.
class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator();

  @override
  Widget build(BuildContext context) {
    // Walks up to find the engine via the demo page. In the real app, pass the
    // engine's ValueNotifier down through your state management of choice.
    final page = context.findAncestorStateOfType<_SyncDemoPageState>();
    if (page == null) return const SizedBox.shrink();

    return ValueListenableBuilder<SyncStatusSnapshot>(
      valueListenable: page.widget.engine.status,
      builder: (context, snap, _) {
        final (icon, color, label) = switch (snap.state) {
          SyncState.idle => (Icons.cloud_queue, Colors.grey, 'Idle'),
          SyncState.syncing => (Icons.sync, Colors.blue, 'Syncing'),
          SyncState.success => (Icons.cloud_done, Colors.green, 'Synced'),
          SyncState.offline => (Icons.cloud_off, Colors.orange, 'Offline'),
          SyncState.error => (Icons.error_outline, Colors.red, 'Retry'),
        };
        return Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        );
      },
    );
  }
}
