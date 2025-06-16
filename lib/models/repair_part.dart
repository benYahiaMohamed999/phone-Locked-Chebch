import 'package:cloud_firestore/cloud_firestore.dart';

class RepairPart {
  final String id;
  final String name;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final DateTime createdAt;
  final bool isCostPaid;

  RepairPart({
    required this.id,
    required this.name,
    required this.description,
    required this.costPrice,
    required this.sellingPrice,
    required this.createdAt,
    this.isCostPaid = false,
  });

  double get profit => sellingPrice - costPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'createdAt': createdAt,
      'isCostPaid': isCostPaid,
    };
  }

  factory RepairPart.fromMap(String id, Map<String, dynamic> map) {
    // Debug log
    print('RepairPart.fromMap:');
    print('  ID passed in: $id');
    print('  ID in map: ${map['id']}');
    print('  Name: ${map['name']}');
    print('  isCostPaid raw: ${map['isCostPaid']}');
    print('  isCostPaid type: ${map['isCostPaid']?.runtimeType}');

    // Handle different types of isCostPaid values
    bool isCostPaid = false;
    if (map['isCostPaid'] != null) {
      if (map['isCostPaid'] is bool) {
        isCostPaid = map['isCostPaid'];
      } else if (map['isCostPaid'] is int) {
        isCostPaid = map['isCostPaid'] == 1;
      } else if (map['isCostPaid'] is String) {
        isCostPaid = map['isCostPaid'].toLowerCase() == 'true';
      }
    }

    print('  isCostPaid processed: $isCostPaid');

    // Use the id from the map if available, otherwise use the passed id
    final String partId = map['id']?.toString() ?? id;

    return RepairPart(
      id: partId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      costPrice: (map['costPrice'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isCostPaid: isCostPaid,
    );
  }
}
