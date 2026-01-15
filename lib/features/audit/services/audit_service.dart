import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_record_model.dart';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'audit_records';

  Future<void> addAuditRecord(AuditRecordModel record) async {
    await _firestore.collection(_collection).add(record.toMap());
  }

  Future<List<AuditRecordModel>> getAuditRecords() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('scannedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AuditRecordModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<AuditRecordModel>> getAuditRecordsByAuditor(String email) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('auditorEmail', isEqualTo: email)
        .orderBy('scannedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AuditRecordModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteAuditRecord(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<AuditRecordModel>> streamAuditRecords() {
    return _firestore
        .collection(_collection)
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditRecordModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
