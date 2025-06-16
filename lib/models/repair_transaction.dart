// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'repair_part.dart';

class RepairTransaction {
  final String id;
  final String phoneModel;
  final String repairDetails;
  final List<RepairPart> parts;
  final bool isPaid;
  final DateTime createdAt;
  final String userId;
  final String? clientName;
  final String? clientPhone;

  RepairTransaction({
    required this.id,
    required this.phoneModel,
    required this.repairDetails,
    required this.parts,
    required this.isPaid,
    required this.createdAt,
    required this.userId,
    this.clientName,
    this.clientPhone,
  });

  double get totalPartsCost =>
      parts.fold(0, (sum, part) => sum + part.costPrice);
  double get totalPartsSellingPrice =>
      parts.fold(0, (sum, part) => sum + part.sellingPrice);
  double get serviceCost =>
      parts.fold(0, (sum, part) => sum + (part.sellingPrice - part.costPrice));
  double get totalCost => totalPartsCost;
  double get totalSellingPrice => totalPartsSellingPrice;
  double get totalProfit => totalSellingPrice - totalCost;

  Map<String, dynamic> toMap() {
    return {
      'phoneModel': phoneModel,
      'repairDetails': repairDetails,
      'parts': parts.map((part) => part.toMap()).toList(),
      'isPaid': isPaid,
      'createdAt': createdAt,
      'userId': userId,
      'clientName': clientName,
      'clientPhone': clientPhone,
    };
  }

  factory RepairTransaction.fromMap(String id, Map<String, dynamic> map) {
    print('RepairTransaction.fromMap: ID=$id, Phone=${map['phoneModel']}');

    final partsList = (map['parts'] as List<dynamic>?) ?? [];
    print('Parts count in transaction: ${partsList.length}');

    final parts = partsList.map((part) {
      // Use the id from the part map if available
      final partId = part['id']?.toString() ?? '';
      print('Part in transaction: ID="${partId}", Name="${part['name']}');
      return RepairPart.fromMap(partId, part);
    }).toList();

    return RepairTransaction(
      id: id,
      phoneModel: map['phoneModel'] ?? '',
      repairDetails: map['repairDetails'] ?? '',
      parts: parts,
      isPaid: map['isPaid'] ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] ?? '',
      clientName: map['clientName'],
      clientPhone: map['clientPhone'],
    );
  }
}
