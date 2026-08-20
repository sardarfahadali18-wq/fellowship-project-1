import 'package:flutter/material.dart';
import 'screens/safewalk_home_screen.dart';

void main() {
  runApp(const SafeWalkTestApp());
}

class SafeWalkTestApp extends StatelessWidget {
  const SafeWalkTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeWalk Test',
      debugShowCheckedModeBanner: false,
      home: const SafeWalkHomeScreen(),
    );
  }
}
