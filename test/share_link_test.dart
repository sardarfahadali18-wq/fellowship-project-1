import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/share_link_builder.dart';
import 'package:fellowship_project_1/services/walk_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WalkSession session({double? lat, double? lng}) => WalkSession(
        id: 'walk1',
        ownerUid: 'uid1',
        startedAt: DateTime.utc(2026, 8, 21, 10, 0),
        plannedDuration: const Duration(minutes: 30),
        lastLat: lat,
        lastLng: lng,
      );

  group('StaticMapsLinkBuilder', () {
    const builder = StaticMapsLinkBuilder();

    test('builds a maps query from the last location', () {
      final link = builder.buildFor(session(lat: 31.52, lng: 74.35));

      expect(link, 'https://maps.google.com/?q=31.52%2C74.35');
    });

    test('percent encodes the comma rather than leaving it raw', () {
      final link = builder.buildFor(session(lat: 1.5, lng: 2.5))!;

      expect(link.contains(','), isFalse);
      expect(link.contains('%2C'), isTrue);
    });

    test('returns null with no location', () {
      expect(builder.buildFor(session()), isNull);
      expect(builder.buildFor(session(lat: 31.52)), isNull);
      expect(builder.buildFor(session(lng: 74.35)), isNull);
    });

    test('never includes the share token', () {
      final withToken = session(lat: 1, lng: 2).copyWith(shareToken: 'secret1');

      expect(builder.buildFor(withToken), isNot(contains('secret1')));
    });
  });

  group('share token', () {
    test('is at least 24 URL safe characters', () {
      final token = WalkSessionService.newShareToken();

      expect(token.length, greaterThanOrEqualTo(24));
      expect(Uri.encodeComponent(token), token);
      for (final c in token.split('')) {
        expect(WalkSessionService.tokenAlphabet.contains(c), isTrue);
      }
    });

    test('does not repeat across many draws', () {
      final seen = {for (var i = 0; i < 200; i++) WalkSessionService.newShareToken()};

      expect(seen.length, 200);
    });
  });

  group('model', () {
    test('clearShareToken wipes the token, a plain copyWith keeps it', () {
      final live = session(lat: 1, lng: 2).copyWith(shareToken: 'secret1');

      expect(live.shareToken, 'secret1');
      expect(live.copyWith(status: WalkSessionStatus.overdue).shareToken,
          'secret1');
      expect(live.copyWith(clearShareToken: true).shareToken, isNull);
    });

    test('the token round trips through toMap and fromMap', () {
      final live = session(lat: 1, lng: 2).copyWith(shareToken: 'secret1');
      final restored = WalkSession.fromMap(live.id, live.toMap());

      expect(restored.shareToken, 'secret1');
    });
  });
}
