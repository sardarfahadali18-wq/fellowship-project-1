import 'package:flutter/material.dart';
import '../models/trusted_contact.dart';

/// Reusable Material 3 Card widget for displaying a single [TrustedContact].
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleEmergency,
    this.onCall,
    this.onSms,
  });

  final TrustedContact contact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleEmergency;
  final VoidCallback? onCall;
  final VoidCallback? onSms;

  Color _avatarColor(String text) {
    const colors = [
      Color(0xFF6750A4), // Deep Purple
      Color(0xFFB3261E), // Crimson Red
      Color(0xFF006A6A), // Teal
      Color(0xFF2E6B18), // Forest Green
      Color(0xFF984061), // Ruby
      Color(0xFF00639B), // Blue
      Color(0xFF7D5260), // Mauve
    ];
    if (text.isEmpty) return colors[0];
    final hash = text.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmergency = contact.isEmergency;

    return Card(
      elevation: isEmergency ? 2 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEmergency
            ? BorderSide(color: colorScheme.error.withOpacity(0.5), width: 1.5)
            : BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      color: isEmergency
          ? colorScheme.errorContainer.withOpacity(0.15)
          : colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with Initials
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isEmergency
                        ? colorScheme.error
                        : _avatarColor(contact.name),
                    child: Text(
                      contact.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isEmergency) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emergency,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'PRIMARY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                contact.relationship,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                contact.phoneNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'toggle_emergency' &&
                          onToggleEmergency != null) {
                        onToggleEmergency!(!contact.isEmergency);
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_emergency',
                        child: Row(
                          children: [
                            Icon(
                              contact.isEmergency
                                  ? Icons.star_border
                                  : Icons.star,
                              color: Colors.amber[700],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(contact.isEmergency
                                ? 'Remove from Primary'
                                : 'Set as Primary Emergency'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 10),
                            Text('Edit Contact'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: colorScheme.error, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Contact',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (contact.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: ${contact.notes}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.outline,
                  ),
                ),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),

              // Quick Actions: Call & SMS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onSms,
                    icon: const Icon(Icons.message_outlined, size: 18),
                    label: const Text('Message'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
