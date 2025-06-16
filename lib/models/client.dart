import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String? phone;
  final DateTime lastRepairDate;
  final int totalRepairs;

  Client({
    required this.id,
    required this.name,
    this.phone,
    required this.lastRepairDate,
    required this.totalRepairs,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'lastRepairDate': lastRepairDate,
      'totalRepairs': totalRepairs,
    };
  }

  factory Client.fromMap(String id, Map<String, dynamic> map) {
    return Client(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'],
      lastRepairDate: (map['lastRepairDate'] is Timestamp)
          ? (map['lastRepairDate'] as Timestamp).toDate()
          : DateTime.now(),
      totalRepairs: map['totalRepairs'] ?? 0,
    );
  }
}
