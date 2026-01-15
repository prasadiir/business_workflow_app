import 'package:cloud_firestore/cloud_firestore.dart';

class AuditRecordModel {
  final String? id;
  final String scannedName;
  final String scannedAddress;
  final String scannedContact;
  final String auditNote;
  final String auditorEmail;
  final DateTime scannedAt;

  AuditRecordModel({
    this.id,
    required this.scannedName,
    required this.scannedAddress,
    required this.scannedContact,
    required this.auditNote,
    required this.auditorEmail,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'scannedName': scannedName,
      'scannedAddress': scannedAddress,
      'scannedContact': scannedContact,
      'auditNote': auditNote,
      'auditorEmail': auditorEmail,
      'scannedAt': Timestamp.fromDate(scannedAt),
    };
  }

  factory AuditRecordModel.fromMap(Map<String, dynamic> map, String docId) {
    return AuditRecordModel(
      id: docId,
      scannedName: map['scannedName'] ?? '',
      scannedAddress: map['scannedAddress'] ?? '',
      scannedContact: map['scannedContact'] ?? '',
      auditNote: map['auditNote'] ?? '',
      auditorEmail: map['auditorEmail'] ?? '',
      scannedAt: (map['scannedAt'] as Timestamp).toDate(),
    );
  }

  factory AuditRecordModel.fromQrData(String qrData) {
    // Parse QR data format:
    // Name: xxx
    // Address: xxx
    // Contact: xxx
    // Date: xxx
    final lines = qrData.trim().split('\n');
    String name = '';
    String address = '';
    String contact = '';

    for (final line in lines) {
      if (line.startsWith('Name:')) {
        name = line.substring(5).trim();
      } else if (line.startsWith('Address:')) {
        address = line.substring(8).trim();
      } else if (line.startsWith('Contact:')) {
        contact = line.substring(8).trim();
      }
    }

    return AuditRecordModel(
      scannedName: name,
      scannedAddress: address,
      scannedContact: contact,
      auditNote: '',
      auditorEmail: '',
      scannedAt: DateTime.now(),
    );
  }

  AuditRecordModel copyWith({
    String? id,
    String? scannedName,
    String? scannedAddress,
    String? scannedContact,
    String? auditNote,
    String? auditorEmail,
    DateTime? scannedAt,
  }) {
    return AuditRecordModel(
      id: id ?? this.id,
      scannedName: scannedName ?? this.scannedName,
      scannedAddress: scannedAddress ?? this.scannedAddress,
      scannedContact: scannedContact ?? this.scannedContact,
      auditNote: auditNote ?? this.auditNote,
      auditorEmail: auditorEmail ?? this.auditorEmail,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
}
