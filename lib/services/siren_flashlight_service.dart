import 'dart:async';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';

/// Drives the SOS siren sound, strobing flashlight and vibration pattern
/// used to draw attention while a panic alert is active.
class SirenFlashlightService {
  Timer? _strobeTimer;
  bool _torchOn = false;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    unawaited(
      FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true),
    );

    if (await Vibration.hasVibrator()) {
      unawaited(
        Vibration.vibrate(pattern: const [0, 500, 200, 500], repeat: 0),
      );
    }

    _strobeTimer = Timer.periodic(const Duration(milliseconds: 400), (
      _,
    ) async {
      try {
        if (_torchOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        _torchOn = !_torchOn;
      } catch (_) {
        // No torch on this device, or it's in use elsewhere; siren and
        // vibration keep running regardless.
      }
    });
  }

  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    _strobeTimer?.cancel();
    _strobeTimer = null;

    FlutterRingtonePlayer().stop();
    Vibration.cancel();

    if (_torchOn) {
      try {
        await TorchLight.disableTorch();
      } catch (_) {}
      _torchOn = false;
    }
  }
}
