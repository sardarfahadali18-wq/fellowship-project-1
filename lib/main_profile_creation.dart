import 'package:flutter/material.dart';
import 'screens/profile_creation_screen.dart';
import 'widgets/connectivity_banner.dart';
import 'widgets/progress_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuralEdu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
      ),
      home: const ProfileCreationScreen(),
    );
  }
}

/// A student dashboard screen displaying local progress and connectivity status.
class StudentDashboardScreen extends StatelessWidget {
  final String studentName;

  const StudentDashboardScreen({
    super.key,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $studentName!'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Disables back button after profile creation
      ),
      body: Column(
        children: [
          // 1. Non-blocking connectivity status banner at the top
          const ConnectivityBanner(),

          // 2. Main content area displaying local lesson progress tracker
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Your Lessons',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ProgressTracker(
                  title: 'Lesson 1: Intro to Numbers',
                  subtitle: 'Mathematics • 10 mins',
                  status: LessonStatus.done,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Lesson 1...')),
                    );
                  },
                ),
                ProgressTracker(
                  title: 'Lesson 2: Basic Addition',
                  subtitle: 'Mathematics • 15 mins',
                  status: LessonStatus.inProgress,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resuming Lesson 2...')),
                    );
                  },
                ),
                ProgressTracker(
                  title: 'Lesson 3: Basic Subtraction',
                  subtitle: 'Mathematics • 15 mins',
                  status: LessonStatus.locked,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}