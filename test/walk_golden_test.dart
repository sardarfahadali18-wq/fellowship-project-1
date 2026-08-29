@Tags(['golden'])
library;

import 'package:fellowship_project_1/main_walk_demo.dart';
import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/screens/active_walk_screen.dart';
import 'package:fellowship_project_1/screens/home_screen.dart';
import 'package:fellowship_project_1/screens/walk_history_screen.dart';
import 'package:fellowship_project_1/screens/walk_session_detail_screen.dart';
import 'package:fellowship_project_1/screens/walk_start_screen.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/streak_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'walk_support.dart';

void main() {
  const surface = Size(420, 900);

  Future<void> shoot(WidgetTester tester, Widget screen, String name) async {
    await tester.binding.setSurfaceSize(surface);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: walkDemoTheme(),
      home: screen,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(name));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  final startedAt = DateTime.utc(2026, 8, 21, 10, 0);

  WalkSession finished() => WalkSession(
        id: 'walk1',
        ownerUid: 'uid1',
        startedAt: startedAt,
        plannedDuration: const Duration(minutes: 30),
        endedAt: startedAt.add(const Duration(minutes: 28)),
        destinationLat: 31.53,
        destinationLng: 74.37,
        status: WalkSessionStatus.completed,
        lastLat: 31.52,
        lastLng: 74.35,
        lastUpdatedAt: startedAt.add(const Duration(minutes: 27)),
        sharedWithContactIds: const ['Mom', 'Ayesha'],
      );

  testWidgets('golden 1 walk start screen', (tester) async {
    final location = FakeLocationService(tick: fast);
    await shoot(
        tester,
        WalkStartScreen(
            service: buildService(location, MemoryStore()),
            location: location,
            store: MemoryStore()),
        'goldens/1_walk_start.png');
  });

  testWidgets('golden 2 active walk screen', (tester) async {
    final location = FakeLocationService(tick: fast);
    final service = buildService(location, MemoryStore());
    await tester.runAsync(
        () => service.start(plannedDuration: const Duration(minutes: 30)));
    await shoot(tester, ActiveWalkScreen(service: service),
        'goldens/2_active_walk.png');
    await tester.runAsync(service.end);
  });

  testWidgets('golden 3 walk history screen', (tester) async {
    final store = MemoryStore();
    await store.save(finished());
    await shoot(tester, WalkHistoryScreen(store: store),
        'goldens/3_walk_history.png');
  });

  testWidgets('golden 4 walk detail screen', (tester) async {
    await shoot(tester, WalkSessionDetailScreen(session: finished()),
        'goldens/4_walk_detail.png');
  });

  testWidgets('golden 5 existing app home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await StreakService.init(prepopulateDefaults: false);
    await shoot(tester, const HomeScreen(), 'goldens/5_app_home.png');
  });

  testWidgets('golden 6 walk history empty state', (tester) async {
    await shoot(tester, WalkHistoryScreen(store: MemoryStore()),
        'goldens/6_history_empty.png');
  });
}
