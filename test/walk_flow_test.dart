import 'package:fellowship_project_1/models/walk_contact.dart';
import 'package:fellowship_project_1/screens/walk_history_screen.dart';
import 'package:fellowship_project_1/screens/walk_start_screen.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/location_service.dart';
import 'package:fellowship_project_1/services/trusted_contact_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'walk_support.dart';

class _StubReader extends TrustedContactReader {
  _StubReader(this._contacts);

  final List<WalkContact>? _contacts;

  @override
  Future<List<WalkContact>> forCurrentUser() async =>
      _contacts ?? (throw StateError('offline'));
}

void main() {
  Future<void> advance(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('start a walk, watch it, end it, find it in history',
      (tester) async {
    final store = MemoryStore();
    final location = FakeLocationService(tick: fast);
    final service = buildService(location, store);

    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(
            service: service, location: location, store: store)));

    expect(find.text('Start a walk'), findsOneWidget);
    expect(find.text('How long will you be walking? (minutes)'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Mom'), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);

    await tester.tap(find.text('Mom'));
    await tester.pump();

    await tester.tap(find.text('Start Walk'));
    await advance(tester);

    expect(find.text('Walk in progress'), findsOneWidget);
    expect(find.text('Map loads when the API key is added'), findsOneWidget);
    expect(find.text('Status: active'), findsOneWidget);
    expect(find.text('End Walk'), findsOneWidget);
    expect(find.text('Cancel walk'), findsOneWidget);
    expect(service.activeSession?.lastLat, isNotNull);

    await tester.tap(find.text('End Walk'));
    await advance(tester);

    expect(service.activeSession, isNull);
    expect(find.text('Start a walk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history));
    await advance(tester);

    expect(find.text('Walk history'), findsOneWidget);
    expect(find.text('30 min planned, completed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await advance(tester);

    expect(find.text('Walk details'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('completed'), findsOneWidget);
    expect(find.text('Positions recorded'), findsOneWidget);
    expect(find.text('1 contacts'), findsOneWidget);
  });

  testWidgets('the share button copies a maps link', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });

    final location = FakeLocationService(tick: fast);
    final service = buildService(location, MemoryStore());
    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(service: service, location: location)));

    await tester.tap(find.text('Start Walk'));
    await advance(tester);
    await tester.tap(find.text('Copy share link'));
    await advance(tester);

    expect(copied.single, startsWith('https://maps.google.com/?q='));
    expect(copied.single, contains('%2C'));
    expect(find.text('Link copied. Paste it to your contact.'), findsOneWidget);

    await tester.runAsync(service.end);
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('history shows an empty state with no walks', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: WalkHistoryScreen(store: MemoryStore())));
    await advance(tester);

    expect(find.text('No walks recorded yet.'), findsOneWidget);
  });

  testWidgets('cancel asks for confirmation before stopping', (tester) async {
    final store = MemoryStore();
    final location = FakeLocationService(tick: fast);
    final service = buildService(location, store);

    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(
            service: service, location: location, store: store)));

    await tester.tap(find.text('Start Walk'));
    await advance(tester);

    await tester.tap(find.text('Cancel walk'));
    await advance(tester);

    expect(find.text('Cancel this walk?'), findsOneWidget);
    expect(find.text('Keep walking'), findsOneWidget);

    await tester.tap(find.text('Keep walking'));
    await advance(tester);

    expect(service.activeSession, isNotNull);

    await tester.tap(find.text('Cancel walk'));
    await advance(tester);
    await tester.tap(find.text('Cancel walk').last);
    await advance(tester);

    expect(service.activeSession, isNull);
    expect(store.saved.single.status.name, 'cancelled');
  });

  testWidgets('real trusted contacts replace the fallback list',
      (tester) async {
    final location = FakeLocationService(tick: fast);
    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(
            service: buildService(location, MemoryStore()),
            location: location,
            reader: _StubReader(const [
              WalkContact(id: 'x1', name: 'Zara', phoneNumber: '+92300')
            ]))));
    await advance(tester);

    expect(find.text('Zara'), findsOneWidget);
    expect(find.text('Mom'), findsNothing);
    await location.stop();
  });

  testWidgets('an empty read keeps the fallback and says so', (tester) async {
    final location = FakeLocationService(tick: fast);
    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(
            service: buildService(location, MemoryStore()),
            location: location,
            reader: _StubReader(const []))));
    await advance(tester);

    expect(find.text('Mom'), findsOneWidget);
    expect(find.text('No trusted contacts saved yet. Showing examples.'),
        findsOneWidget);
    await location.stop();
  });

  testWidgets('a failed read keeps the fallback and says so', (tester) async {
    final location = FakeLocationService(tick: fast);
    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(
            service: buildService(location, MemoryStore()),
            location: location,
            reader: _StubReader(null))));
    await advance(tester);

    expect(find.text('Mom'), findsOneWidget);
    expect(find.text('Could not load your trusted contacts. Showing examples.'),
        findsOneWidget);
    await location.stop();
  });

  testWidgets('start is refused when permission is denied', (tester) async {
    final location = FakeLocationService(
        tick: fast, permission: LocationPermissionState.denied);
    final service = buildService(location, MemoryStore());

    await tester.pumpWidget(MaterialApp(
        home: WalkStartScreen(service: service, location: location)));

    await tester.tap(find.text('Start Walk'));
    await advance(tester);

    expect(
        find.text('Location permission denied. Allow it to share your walk.'),
        findsOneWidget);
    expect(find.text('Walk in progress'), findsNothing);
    expect(service.activeSession, isNull);
  });
}
