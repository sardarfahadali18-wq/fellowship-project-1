import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of pushing a batch of events to the backend.
class PushResult {
  const PushResult({required this.acceptedUuids, this.serverError});

  /// UUIDs the backend confirmed it stored (idempotent — duplicates count as
  /// accepted). These get marked `synced` locally.
  final Set<String> acceptedUuids;

  /// Non-null when the whole request failed (network/5xx); callers should keep
  /// the events pending and retry later.
  final String? serverError;

  bool get isSuccess => serverError == null;
}

/// Backend contract for the sync engine. Kept abstract so the engine can be
/// unit-tested with a fake, and so Hammas's real Supabase endpoints can slot in
/// behind [HttpSyncApiClient] without touching [SyncEngine].
abstract class SyncApi {
  /// POST /sync/events — idempotent by event UUID.
  Future<PushResult> pushEvents(List<Map<String, dynamic>> events);

  /// GET /content/manifest — returns the server's current content version so
  /// the app knows whether new lesson packs are available.
  Future<ContentManifest> fetchManifest();
}

class ContentManifest {
  const ContentManifest({required this.version, required this.packs});

  final int version;
  final List<ManifestPack> packs;

  factory ContentManifest.fromJson(Map<String, dynamic> json) {
    final rawPacks = (json['packs'] as List?) ?? const [];
    return ContentManifest(
      version: (json['version'] as num?)?.toInt() ?? 0,
      packs: rawPacks
          .map((e) => ManifestPack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManifestPack {
  const ManifestPack({
    required this.id,
    required this.title,
    required this.version,
  });

  final String id;
  final String title;
  final int version;

  factory ManifestPack.fromJson(Map<String, dynamic> json) => ManifestPack(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        version: (json['version'] as num?)?.toInt() ?? 0,
      );
}

/// HTTP implementation targeting Hammas's backend. Base URL is injected so it
/// can point at localhost during dev and the deployed Supabase URL later.
class HttpSyncApiClient implements SyncApi {
  HttpSyncApiClient({
    required this.baseUrl,
    http.Client? client,
    this.authToken,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String? authToken;
  final Duration timeout;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  @override
  Future<PushResult> pushEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) {
      return const PushResult(acceptedUuids: {});
    }
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/sync/events'),
            headers: _headers,
            body: jsonEncode({'events': events}),
          )
          .timeout(timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final accepted = (body['accepted'] as List?)?.cast<String>() ??
            // If the backend doesn't echo ids, assume all were accepted.
            events.map((e) => e['uuid'].toString()).toList();
        return PushResult(acceptedUuids: accepted.toSet());
      }
      return PushResult(
        acceptedUuids: const {},
        serverError: 'HTTP ${resp.statusCode}: ${resp.body}',
      );
    } catch (e) {
      return PushResult(acceptedUuids: const {}, serverError: e.toString());
    }
  }

  @override
  Future<ContentManifest> fetchManifest() async {
    final resp = await _client
        .get(Uri.parse('$baseUrl/content/manifest'), headers: _headers)
        .timeout(timeout);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ContentManifest.fromJson(
        jsonDecode(resp.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Manifest fetch failed: HTTP ${resp.statusCode}');
  }
}
