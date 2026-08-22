enum LocationPermissionState { granted, denied, deniedForever, serviceDisabled }

class LocationSample {
  final double lat;
  final double lng;
  final DateTime at;

  const LocationSample({
    required this.lat,
    required this.lng,
    required this.at,
  });
}

abstract class LocationService {
  Stream<LocationSample> get positionStream;
  Future<LocationSample?> currentPosition();
  Future<LocationPermissionState> ensurePermission();
  Future<void> stop();
}

String? permissionProblem(LocationPermissionState state) => switch (state) {
      LocationPermissionState.granted => null,
      LocationPermissionState.denied => 'Location permission denied. Allow it to share your walk.',
      LocationPermissionState.deniedForever => 'Location permission is blocked. Turn it on in Settings.',
      LocationPermissionState.serviceDisabled => 'Location services are off. Turn them on to start a walk.',
    };
