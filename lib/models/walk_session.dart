enum WalkSessionStatus { active, completed, cancelled, overdue }

class WalkSession {
  static const maxSharedContacts = 20;
  static const keyOwnerUid = 'ownerUid';
  static const keyStartedAt = 'startedAt';
  static const keyEndedAt = 'endedAt';
  static const keyPlannedDurationMs = 'plannedDurationMs';
  static const keyDestinationLat = 'destinationLat';
  static const keyDestinationLng = 'destinationLng';
  static const keyStatus = 'status';
  static const keyLastLat = 'lastLat';
  static const keyLastLng = 'lastLng';
  static const keyLastUpdatedAt = 'lastUpdatedAt';
  static const keySharedWithContactIds = 'sharedWithContactIds';
  static const keyLastDeviationMetres = 'lastDeviationMetres';
  static const keyMissedCheckInAt = 'missedCheckInAt';
  static const keyShareToken = 'shareToken';

  final String id;
  final String ownerUid;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration plannedDuration;
  final double? destinationLat;
  final double? destinationLng;
  final WalkSessionStatus status;
  final double? lastLat;
  final double? lastLng;
  final DateTime? lastUpdatedAt;
  final List<String> sharedWithContactIds;
  final double? lastDeviationMetres;
  final DateTime? missedCheckInAt;
  final String? shareToken;

  const WalkSession({
    required this.id,
    required this.ownerUid,
    required this.startedAt,
    required this.plannedDuration,
    this.endedAt,
    this.destinationLat,
    this.destinationLng,
    this.status = WalkSessionStatus.active,
    this.lastLat,
    this.lastLng,
    this.lastUpdatedAt,
    this.sharedWithContactIds = const [],
    this.lastDeviationMetres,
    this.missedCheckInAt,
    this.shareToken,
  });

  bool get isFinished =>
      status != WalkSessionStatus.active && status != WalkSessionStatus.overdue;

  static final epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static double? _double(Object? v) => v is num ? v.toDouble() : null;
  static DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;
  static List<String> _ids(Object? v) => v is List
      ? v.map((e) => e.toString()).take(maxSharedContacts).toList()
      : const [];

  factory WalkSession.fromMap(String id, Map<String, dynamic> map) =>
      WalkSession(
        id: id,
        ownerUid: map[keyOwnerUid] is String ? map[keyOwnerUid] as String : '',
        startedAt: _date(map[keyStartedAt]) ?? epoch,
        endedAt: _date(map[keyEndedAt]),
        plannedDuration: Duration(milliseconds: _double(map[keyPlannedDurationMs])?.toInt() ?? 0),
        destinationLat: _double(map[keyDestinationLat]),
        destinationLng: _double(map[keyDestinationLng]),
        status: WalkSessionStatus.values.firstWhere(
            (s) => s.name == map[keyStatus], orElse: () => WalkSessionStatus.active),
        lastLat: _double(map[keyLastLat]),
        lastLng: _double(map[keyLastLng]),
        lastUpdatedAt: _date(map[keyLastUpdatedAt]),
        sharedWithContactIds: _ids(map[keySharedWithContactIds]),
        lastDeviationMetres: _double(map[keyLastDeviationMetres]),
        missedCheckInAt: _date(map[keyMissedCheckInAt]),
        shareToken:
            map[keyShareToken] is String ? map[keyShareToken] as String : null,
      );

  Map<String, dynamic> toMap() => {
        keyOwnerUid: ownerUid,
        keyStartedAt: startedAt.toIso8601String(),
        keyEndedAt: endedAt?.toIso8601String(),
        keyPlannedDurationMs: plannedDuration.inMilliseconds,
        keyDestinationLat: destinationLat,
        keyDestinationLng: destinationLng,
        keyStatus: status.name,
        keyLastLat: lastLat,
        keyLastLng: lastLng,
        keyLastUpdatedAt: lastUpdatedAt?.toIso8601String(),
        keySharedWithContactIds: sharedWithContactIds,
        keyLastDeviationMetres: lastDeviationMetres,
        keyMissedCheckInAt: missedCheckInAt?.toIso8601String(),
        keyShareToken: shareToken,
      };

  WalkSession copyWith({
    DateTime? endedAt,
    WalkSessionStatus? status,
    double? lastLat,
    double? lastLng,
    DateTime? lastUpdatedAt,
    List<String>? sharedWithContactIds,
    double? lastDeviationMetres,
    DateTime? missedCheckInAt,
    String? shareToken,
    bool clearShareToken = false,
  }) =>
      WalkSession(
        id: id,
        ownerUid: ownerUid,
        startedAt: startedAt,
        plannedDuration: plannedDuration,
        endedAt: endedAt ?? this.endedAt,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        status: status ?? this.status,
        lastLat: lastLat ?? this.lastLat,
        lastLng: lastLng ?? this.lastLng,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        sharedWithContactIds: sharedWithContactIds ?? this.sharedWithContactIds,
        lastDeviationMetres: lastDeviationMetres ?? this.lastDeviationMetres,
        missedCheckInAt: missedCheckInAt ?? this.missedCheckInAt,
        shareToken:
            clearShareToken ? null : (shareToken ?? this.shareToken),
      );
}
