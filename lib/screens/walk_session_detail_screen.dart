import 'package:flutter/material.dart';

import '../models/walk_session.dart';
import 'walk_history_screen.dart';

class WalkSessionDetailScreen extends StatelessWidget {
  const WalkSessionDetailScreen({super.key, required this.session});

  final WalkSession session;

  int get _pointCount => session.lastLat == null ? 0 : 1;

  Duration? get _actual =>
      session.endedAt?.difference(session.startedAt);

  @override
  Widget build(BuildContext context) {
    final rows = <String, String>{
      'Status': session.status.name,
      'Started': formatStamp(session.startedAt),
      'Ended': session.endedAt == null
          ? 'not recorded'
          : formatStamp(session.endedAt!),
      'Planned': '${session.plannedDuration.inMinutes} min',
      'Actual': _actual == null ? 'not recorded' : '${_actual!.inMinutes} min',
      'Positions recorded': '$_pointCount',
      'Shared with': '${session.sharedWithContactIds.length} contacts',
      'Last update': session.lastUpdatedAt == null
          ? 'none'
          : formatStamp(session.lastUpdatedAt!),
      'Off route': session.lastDeviationMetres == null
          ? 'no'
          : '${session.lastDeviationMetres!.round()} m',
      'Missed check-in': session.missedCheckInAt == null
          ? 'no'
          : formatStamp(session.missedCheckInAt!),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Walk details')),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: rows.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 190,
                                child: Text(e.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(child: Text(e.value)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
