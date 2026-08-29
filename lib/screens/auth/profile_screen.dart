import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../contacts/trusted_contacts_list_screen.dart';

/// Screen displaying the user's personal profile, safety settings,
/// and access to trusted contacts management.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
    this.authService,
    this.onSignOut,
  });

  final String userId;
  final AuthService? authService;
  final VoidCallback? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SafeWalk?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (widget.onSignOut != null) {
        widget.onSignOut!();
      }
    }
  }

  Future<void> _openEditProfileDialog(UserProfile profile) async {
    final nameController = TextEditingController(text: profile.displayName);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final noteController = TextEditingController(text: profile.emergencyNote);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Medical / Safety Notes',
                      hintText: 'e.g. Blood type O+, Asthma, emergency address',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => saving = true);

                            final updated = profile.copyWith(
                              displayName: nameController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                              emergencyNote: noteController.text.trim(),
                            );

                            await _authService.updateUserProfile(updated);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Safety'),
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _authService.userProfileStream(widget.userId),
        builder: (context, snapshot) {
          final profile = snapshot.data ??
              UserProfile(
                uid: widget.userId,
                email: _authService.currentUser?.email ?? '',
                displayName: _authService.currentUser?.displayName ?? 'User',
                phoneNumber: _authService.currentUser?.phoneNumber ?? '',
              );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // User Card Header
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          profile.initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName
                                  : 'SafeWalk User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (profile.phoneNumber.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                profile.phoneNumber,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Profile',
                        onPressed: () => _openEditProfileDialog(profile),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Emergency Medical Notes Card
              if (profile.emergencyNote.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: Colors.amber.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.medical_information_outlined,
                        color: Colors.amber),
                    title: const Text(
                      'Emergency Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(profile.emergencyNote),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quick Actions Section
              Text(
                'Safety Configuration',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Trusted Contacts Navigation Tile
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.people_outline, color: colorScheme.primary),
                  ),
                  title: const Text(
                    'Manage Trusted Contacts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Add, edit, and set primary emergency contacts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrustedContactsListScreen(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // App Safety Info Tile
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.security, color: Colors.teal),
                  ),
                  title: Text(
                    'Safety & Privacy Protocol',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Location is encrypted and shared only during active walks/SOS'),
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Section
              OutlinedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
