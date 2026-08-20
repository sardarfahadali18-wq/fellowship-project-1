import 'package:flutter/material.dart';
import '../services/fake_call_service.dart';

class SafeWalkHomeScreen extends StatelessWidget {
  const SafeWalkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SafeWalk")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                FakeCallService.scheduleFakeCall(
                  context: context,
                  delay: const Duration(seconds: 5),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fake call in 5 seconds...")),
                );
              },
              icon: const Icon(Icons.call),
              label: const Text("Fake Call"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
