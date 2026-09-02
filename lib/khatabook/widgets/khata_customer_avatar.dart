import 'dart:io';

import 'package:flutter/material.dart';

/// Circular customer avatar: shows the attached photo if present, otherwise
/// falls back to initials on a tinted background (matches the contact card
/// avatar style used elsewhere in the app).
class KhataCustomerAvatar extends StatelessWidget {
  const KhataCustomerAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.radius = 24,
  });

  final String name;
  final String? photoPath;
  final double radius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (photoPath != null && File(photoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(photoPath!)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _initials,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
