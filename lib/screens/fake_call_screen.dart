import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const FakeCallScreen({
    super.key,
    this.callerName = "Mom",
    this.callerNumber = "+92 300 1234567",
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  Timer? _vibrateTimer;

  @override
  void initState() {
    super.initState();
    _vibrateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    super.dispose();
  }

  void _endCall() {
    _vibrateTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Incoming call",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.callerNumber,
                style: const TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _callButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      label: "Decline",
                      onTap: _endCall,
                    ),
                    _callButton(
                      icon: Icons.call,
                      color: Colors.green,
                      label: "Accept",
                      onTap: _endCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
