import 'package:flutter/material.dart';
import '../main_profile_creation.dart'; // <--- 1. Added import for StudentDashboardScreen

/// The final responsive version of the Profile Creation Screen for RuralEdu.
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classCodeController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().length >= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get total screen dimensions dynamically
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. True Full-Screen Background Image Layer
          Positioned.fill(
            child: Image.asset(
              'assets/hilly_background_asset.png',
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. Responsive Content Layer
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06, // 6% dynamic side padding
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.02),

                            // App Branding
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'RuralEdu',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Title
                            const Text(
                              'Create Your Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0D1B3E),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // 3. Responsive Student Avatar Image
                            Container(
                              height: screenHeight * 0.22, // 22% of screen height
                              width: screenHeight * 0.22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/student_avatar_asset.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // 4. Input Fields Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Your Name',
                                      prefixIcon: Icon(Icons.person, color: Color(0xFF42A5F5)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    ),
                                  ),
                                  const Divider(height: 1, indent: 50),
                                  TextFormField(
                                    controller: _classCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Class Code (Optional)',
                                      prefixIcon: Icon(Icons.group, color: Color(0xFF66BB6A)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(), // Automatically pushes button towards bottom smoothly
                            SizedBox(height: screenHeight * 0.03),

                            // 5. Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isButtonEnabled
                                    ? () {
                                  // 2. Navigate to Dashboard with Connectivity & Progress Tracker
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => StudentDashboardScreen(
                                        studentName: _nameController.text.trim(),
                                      ),
                                    ),
                                  );
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43A047),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFF81C784).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.person_add_alt_1),
                                    SizedBox(width: 12),
                                    Text(
                                      'Create Profile',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}