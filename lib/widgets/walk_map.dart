import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/walk_session.dart';

class WalkMap extends StatefulWidget {
  const WalkMap({super.key, this.height = 220, this.session});

  static const maxTrackPoints = 500;

  final double height;
  final WalkSession? session;

  @override
  State<WalkMap> createState() => _WalkMapState();
}

class _WalkMapState extends State<WalkMap> {
  final _track = <LatLng>[];

  GoogleMapController? _controller;
  bool _following = true;
  bool _selfMove = false;
  int _followToken = 0;

  LatLng? _point(double? lat, double? lng) =>
      lat == null || lng == null ? null : LatLng(lat, lng);

  LatLng? get _here =>
      _point(widget.session?.lastLat, widget.session?.lastLng);

  LatLng? get _destination =>
      _point(widget.session?.destinationLat, widget.session?.destinationLng);

  @override
  void initState() {
    super.initState();
    _record();
  }

  @override
  void didUpdateWidget(WalkMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _record();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _record() {
    final here = _here;
    if (here == null) return;
    if (_track.isNotEmpty && _track.last == here) return;
    if (_track.length >= WalkMap.maxTrackPoints) _track.removeAt(0);
    _track.add(here);
    if (_following) _follow(here);
  }

  Future<void> _follow(LatLng target) async {
    final controller = _controller;
    if (controller == null) return;
    final token = ++_followToken;
    _selfMove = true;
    try {
      await controller.animateCamera(CameraUpdate.newLatLng(target));
    } finally {
      if (token == _followToken) _selfMove = false;
    }
  }

  void _resumeFollow() {
    setState(() => _following = true);
    final here = _here;
    if (here != null) _follow(here);
  }

  @override
  Widget build(BuildContext context) {
    final here = _here;
    final destination = _destination;
    return SizedBox(
      height: widget.height,
      child: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
              target: here ?? const LatLng(0, 0), zoom: here == null ? 2 : 16),
          onMapCreated: (controller) => _controller = controller,
          onCameraMoveStarted: () {
            if (_selfMove || !_following) return;
            setState(() => _following = false);
          },
          myLocationButtonEnabled: false,
          markers: {
            if (here != null)
              Marker(markerId: const MarkerId('me'), position: here),
            if (destination != null)
              Marker(
                  markerId: const MarkerId('destination'),
                  position: destination),
          },
          polylines: {
            if (_track.length > 1)
              Polyline(
                  polylineId: const PolylineId('track'),
                  points: List.of(_track),
                  width: 4),
          },
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: _following ? 'Following you' : 'Follow my location',
            onPressed: _following ? null : _resumeFollow,
            child: Icon(
                _following ? Icons.my_location : Icons.location_searching),
          ),
        ),
      ]),
    );
  }
}
