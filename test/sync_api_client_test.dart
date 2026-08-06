import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:fellowship_project_1/sync/sync_api_client.dart';

void main() {
  group('HttpSyncApiClient.pushEvents', () {
    test('marks all events accepted on 200 with echoed ids', () async {
      final events = [
        {'uuid': 'a', 'type': 'lessonOpened'},
        {'uuid': 'b', 'type': 'quizSubmitted'},
      ];

      final mock = MockClient((req) async {
        expect(req.url.path, '/sync/events');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect((body['events'] as List).length, 2);
        return http.Response(jsonEncode({'accepted': ['a', 'b']}), 200);
      });

      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final res = await api.pushEvents(events);

      expect(res.isSuccess, isTrue);
      expect(res.acceptedUuids, {'a', 'b'});
    });

    test('assumes all accepted when server omits the accepted list', () async {
      final mock = MockClient(
        (req) async => http.Response(jsonEncode({'ok': true}), 200),
      );
      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final res = await api.pushEvents([
        {'uuid': 'only'},
      ]);
      expect(res.acceptedUuids, {'only'});
    });

    test('reports server error on 5xx and accepts nothing', () async {
      final mock = MockClient(
        (req) async => http.Response('boom', 500),
      );
      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final res = await api.pushEvents([
        {'uuid': 'a'},
      ]);
      expect(res.isSuccess, isFalse);
      expect(res.acceptedUuids, isEmpty);
      expect(res.serverError, contains('500'));
    });

    test('captures network exceptions as a server error (offline mid-sync)',
        () async {
      final mock = MockClient((req) async => throw Exception('no network'));
      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final res = await api.pushEvents([
        {'uuid': 'a'},
      ]);
      expect(res.isSuccess, isFalse);
      expect(res.serverError, contains('no network'));
    });

    test('empty batch short-circuits without an HTTP call', () async {
      var called = false;
      final mock = MockClient((req) async {
        called = true;
        return http.Response('', 200);
      });
      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final res = await api.pushEvents([]);
      expect(called, isFalse);
      expect(res.isSuccess, isTrue);
    });
  });

  group('ContentManifest parsing', () {
    test('parses version and packs', () async {
      final mock = MockClient(
        (req) async => http.Response(
          jsonEncode({
            'version': 3,
            'packs': [
              {'id': 'algebra', 'title': 'Basic Algebra', 'version': 2},
            ],
          }),
          200,
        ),
      );
      final api = HttpSyncApiClient(baseUrl: 'http://x', client: mock);
      final manifest = await api.fetchManifest();
      expect(manifest.version, 3);
      expect(manifest.packs.single.id, 'algebra');
      expect(manifest.packs.single.version, 2);
    });
  });
}
