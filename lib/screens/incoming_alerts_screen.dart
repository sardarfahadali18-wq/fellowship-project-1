import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows SOS alerts raised by people who have this user as a trusted
/// contact, updating live as new ones arrive.
class IncomingAlertsScreen extends StatelessWidget {
  const IncomingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body:
          uid == null
              ? const Center(child: Text('Sign in to see incoming alerts.'))
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('incoming_alerts')
                        .orderBy('triggeredAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No alerts yet.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data();
                      final status = data['status'] as String? ?? 'active';
                      final message =
                          data['message'] as String? ?? 'SOS alert';
                      final triggeredAt =
                          DateTime.tryParse(
                            data['triggeredAt'] as String? ?? '',
                          ) ??
                          DateTime.now();
                      final mapsLink = data['latitude'] != null
                              && data['longitude'] != null
                          ? 'https://maps.google.com/?q=${data['latitude']},${data['longitude']}'
                          : null;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_amber_rounded,
                            color:
                                status == 'active' ? Colors.red : Colors.grey,
                          ),
                          title: Text(message),
                          subtitle: Text(
                            '${status[0].toUpperCase()}${status.substring(1)}'
                            ' · ${triggeredAt.toLocal()}',
                          ),
                          trailing:
                              mapsLink == null
                                  ? null
                                  : IconButton(
                                    icon: const Icon(Icons.map_outlined),
                                    tooltip: 'Open location',
                                    onPressed:
                                        () => launchUrl(Uri.parse(mapsLink)),
                                  ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
