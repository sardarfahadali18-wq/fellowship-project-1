import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/fake_call_screen.dart';

class FakeCallService {
  static Timer? _delayTimer;

  /// Schedules a fake call to trigger after [delay].
  /// Call this when user taps "Fake Call" button on SafeWalk home.
  static void scheduleFakeCall({
    required BuildContext context,
    Duration delay = const Duration(seconds: 5),
    String callerName = "Mom",
    String callerNumber = "+92 300 1234567",
  }) {
    _delayTimer?.cancel();
    _delayTimer = Timer(delay, () {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FakeCallScreen(
              callerName: callerName,
              callerNumber: callerNumber,
            ),
          ),
        );
      }
    });
  }

  static void cancel() {
    _delayTimer?.cancel();
  }
}
