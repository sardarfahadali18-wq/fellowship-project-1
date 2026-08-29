import '../models/walk_session.dart';

abstract class ShareLinkBuilder {
  String? buildFor(WalkSession session);
}

class StaticMapsLinkBuilder implements ShareLinkBuilder {
  const StaticMapsLinkBuilder();

  static const base = 'https://maps.google.com/';

  @override
  String? buildFor(WalkSession session) {
    final lat = session.lastLat;
    final lng = session.lastLng;
    if (lat == null || lng == null) return null;
    return '$base?q=${Uri.encodeComponent('$lat,$lng')}';
  }
}
