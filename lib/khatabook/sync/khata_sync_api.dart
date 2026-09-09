import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'khata_sync_types.dart';

const int kKhataBatchLimit = 400;
const int kKhataPullLimit = 1000;

/// Cloud backup/restore for the ledger. Every document lives under
/// `vendors/{uid}/...` where `uid` comes from the signed-in Firebase user and
/// never from client data, so one vendor can never address another's ledger.
class FirestoreKhataSyncApi implements KhataSyncApi {
  FirestoreKhataSyncApi({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) throw StateError('sign-in required');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _col(KhataEntity entity) =>
      _db.collection('vendors').doc(_uid).collection(entity.name);

  @override
  Future<KhataPushResult> push(List<KhataSyncRecord> records) async {
    if (records.isEmpty) return const KhataPushResult(accepted: {});
    try {
      for (var i = 0; i < records.length; i += kKhataBatchLimit) {
        final batch = _db.batch();
        for (final record in records.skip(i).take(kKhataBatchLimit)) {
          final doc = _col(record.entity).doc(record.uuid);
          if (record.kind == KhataOpKind.delete) {
            batch.delete(doc);
          } else {
            batch.set(doc, {
              ...record.data,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
        await batch.commit();
      }
      return KhataPushResult(accepted: records.map((r) => r.key).toSet());
    } catch (error) {
      return KhataPushResult(accepted: const {}, error: _reason(error));
    }
  }

  @override
  Future<KhataPullPage> pull({DateTime? since}) async {
    final records = <KhataSyncRecord>[];
    DateTime? newest;
    for (final entity in KhataEntity.values) {
      Query<Map<String, dynamic>> query = _col(entity).orderBy('updatedAt');
      if (since != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }
      for (final doc in (await query.limit(kKhataPullLimit).get()).docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final stamp = data.remove('updatedAt');
        final at = stamp is Timestamp ? stamp.toDate() : null;
        if (at != null && (newest == null || at.isAfter(newest))) newest = at;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        final record = sanitizeKhataRecord(
          KhataSyncRecord(
            entity: entity,
            uuid: doc.id,
            data: data,
            updatedAt: at,
          ),
        );
        if (record != null) records.add(record);
      }
    }
    return KhataPullPage(records: records, cursor: newest);
  }

  /// Surfaces a coarse code only: raw backend errors can carry ids and paths.
  String _reason(Object error) =>
      error is FirebaseException ? error.code : 'sync-unavailable';
}
