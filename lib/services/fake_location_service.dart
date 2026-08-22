import 'dart:async';

import 'location_service.dart';

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.tick = const Duration(milliseconds: 5),
    this.permission = LocationPermissionState.granted,
  });

  static final route = List.generate(20, (i) => LocationSample(
      lat: 31.5204 + i * 0.0009,
      lng: 74.3587 + i * 0.0007,
      at: DateTime.fromMillisecondsSinceEpoch(i * 15000)));

  final Duration tick;
  final LocationPermissionState permission;
  final _controller = StreamController<LocationSample>.broadcast();
  Timer? _timer;
  int _index = 0;

  @override
  Stream<LocationSample> get positionStream {
    _timer ??= Timer.periodic(tick, (_) {
      if (_index >= route.length) return;
      _controller.add(route[_index]);
      _index++;
    });
    return _controller.stream;
  }

  @override
  Future<LocationSample?> currentPosition() async =>
      permission != LocationPermissionState.granted ? null : route[_index.clamp(0, route.length - 1)];

  @override
  Future<LocationPermissionState> ensurePermission() async => permission;

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _index = 0;
  }
}
