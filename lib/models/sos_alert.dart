enum SosStatus { active, resolved, cancelled }

class SosAlert {
  final String id;
  final String userId;
  final DateTime triggeredAt;
  final double? latitude;
  final double? longitude;
  final SosStatus status;
  final List<String> notifiedContactIds;

  const SosAlert({
    required this.id,
    required this.userId,
    required this.triggeredAt,
    this.latitude,
    this.longitude,
    this.status = SosStatus.active,
    this.notifiedContactIds = const [],
  });

  bool get hasLocation => latitude != null && longitude != null;

  String get googleMapsLink =>
      hasLocation ? 'https://maps.google.com/?q=$latitude,$longitude' : '';

  SosAlert copyWith({SosStatus? status, List<String>? notifiedContactIds}) {
    return SosAlert(
      id: id,
      userId: userId,
      triggeredAt: triggeredAt,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      notifiedContactIds: notifiedContactIds ?? this.notifiedContactIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'triggeredAt': triggeredAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'notifiedContactIds': notifiedContactIds,
    };
  }

  factory SosAlert.fromMap(String id, Map<String, dynamic> map) {
    return SosAlert(
      id: id,
      userId: map['userId'] as String? ?? '',
      triggeredAt:
          DateTime.tryParse(map['triggeredAt'] as String? ?? '') ??
          DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      status: SosStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SosStatus.active,
      ),
      notifiedContactIds: List<String>.from(
        map['notifiedContactIds'] as List? ?? const [],
      ),
    );
  }
}
