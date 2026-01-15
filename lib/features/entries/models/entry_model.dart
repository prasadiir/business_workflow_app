import 'dart:convert';

class EntryModel {
  final String id;
  final String name;
  final String address;
  final String contactNumber;
  final DateTime createdAt;

  EntryModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory EntryModel.fromJson(String source) =>
      EntryModel.fromMap(json.decode(source));

  String toQrData() {
    return '''
Name: $name
Address: $address
Contact: $contactNumber
Date: ${createdAt.toLocal().toString().split('.')[0]}
''';
  }
}
