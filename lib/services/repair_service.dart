import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/repair_transaction.dart';
import '../models/repair_part.dart';
import '../models/client.dart';

enum RepairStatus {
  unpaid,
  paid,
  all,
}

class RepairService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get repairs with optional date filtering
  Stream<List<RepairTransaction>> getRepairs(
    String userId, {
    RepairStatus status = RepairStatus.all,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    print('Debug: Getting repairs with date range: $startDate to $endDate');

    Query query =
        _firestore.collection('repairs').where('userId', isEqualTo: userId);

    // First add ordering by createdAt (required for range filters)
    query = query.orderBy('createdAt', descending: true);

    // Apply date filters if present
    if (startDate != null) {
      final startTimestamp = Timestamp.fromDate(startDate);
      query = query.where('createdAt', isGreaterThanOrEqualTo: startTimestamp);
    }

    if (endDate != null) {
      final endTimestamp = Timestamp.fromDate(endDate);
      query = query.where('createdAt', isLessThanOrEqualTo: endTimestamp);
    }

    print('Debug: Executing Firestore query');

    // Stream of repairs
    Stream<List<RepairTransaction>> repairsStream =
        query.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => RepairTransaction.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      print('Debug: Got ${results.length} repair transactions');

      // Filter by payment status in memory if needed
      if (status != RepairStatus.all) {
        return results
            .where((repair) => repair.isPaid == (status == RepairStatus.paid))
            .toList();
      }

      return results;
    });

    return repairsStream;
  }

  // Get repairs for a specific client
  Stream<List<RepairTransaction>> getClientRepairs(
    String userId,
    String clientId, {
    RepairStatus status = RepairStatus.all,
  }) {
    Query query =
        _firestore.collection('repairs').where('userId', isEqualTo: userId);

    // Create client identifier to search with
    String clientIdentifier = clientId;

    // If clientId is a composite hash, we need to search by client name or phone
    if (clientId.length > 8 && int.tryParse(clientId) != null) {
      // It's likely a hash, so get the client details first
      return _firestore
          .collection('clients')
          .doc(clientId)
          .get()
          .asStream()
          .map((snapshot) {
        if (!snapshot.exists) return <RepairTransaction>[];

        final clientData = snapshot.data()!;
        final clientName = clientData['name'] as String?;

        if (clientName == null) return <RepairTransaction>[];

        // Now search repairs by client name
        return _firestore
            .collection('repairs')
            .where('userId', isEqualTo: userId)
            .where('clientName', isEqualTo: clientName)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => RepairTransaction.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          // Filter by payment status in memory if needed
          if (status != RepairStatus.all) {
            return results
                .where(
                    (repair) => repair.isPaid == (status == RepairStatus.paid))
                .toList();
          }

          return results;
        }).first;
      }).asyncExpand((event) => Stream<List<RepairTransaction>>.value(
              event as List<RepairTransaction>));
    }

    // Otherwise, search directly with the client ID
    query = query
        .where('clientName', isEqualTo: clientId)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => RepairTransaction.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by payment status in memory if needed
      if (status != RepairStatus.all) {
        return results
            .where((repair) => repair.isPaid == (status == RepairStatus.paid))
            .toList();
      }

      return results;
    });
  }

  // Get total earnings from paid repairs
  Stream<double> getTotalEarnings(String userId) {
    return _firestore
        .collection('repairs')
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.fold(0.0,
            (total, doc) => total + (doc.data()['totalSellingPrice'] ?? 0.0)));
  }

  // Add a new repair transaction
  Future<void> addRepairTransaction(RepairTransaction transaction) async {
    // Create a new document in the repairs collection
    final repairRef = _firestore.collection('repairs').doc();

    // Store the generated repair ID
    String repairId = repairRef.id;

    // Create a new transaction with the generated ID
    final RepairTransaction updatedTransaction = RepairTransaction(
      id: repairId,
      phoneModel: transaction.phoneModel,
      repairDetails: transaction.repairDetails,
      parts: transaction.parts,
      isPaid: transaction.isPaid,
      createdAt: transaction.createdAt,
      userId: transaction.userId,
      clientName: transaction.clientName,
      clientPhone: transaction.clientPhone,
    );

    // Add to repairs collection
    await repairRef.set(updatedTransaction.toMap());

    // If client details exist, update or create client document
    if (updatedTransaction.clientName != null &&
        updatedTransaction.clientName!.isNotEmpty) {
      // Look for existing client by name and phone
      QuerySnapshot clientQuery;
      if (updatedTransaction.clientPhone != null) {
        clientQuery = await _firestore
            .collection('clients')
            .where('name', isEqualTo: updatedTransaction.clientName)
            .where('phone', isEqualTo: updatedTransaction.clientPhone)
            .limit(1)
            .get();
      } else {
        clientQuery = await _firestore
            .collection('clients')
            .where('name', isEqualTo: updatedTransaction.clientName)
            .limit(1)
            .get();
      }

      DocumentReference clientRef;

      if (clientQuery.docs.isEmpty) {
        // Create new client
        clientRef = _firestore.collection('clients').doc();
        await clientRef.set({
          'name': updatedTransaction.clientName,
          'phone': updatedTransaction.clientPhone,
          'userId': updatedTransaction.userId,
          'lastRepairDate': updatedTransaction.createdAt,
          'totalRepairs': 1,
        });
      } else {
        // Update existing client
        clientRef = clientQuery.docs.first.reference;
        await clientRef.update({
          'lastRepairDate': updatedTransaction.createdAt,
          'totalRepairs': FieldValue.increment(1),
        });
      }
    }
  }

  // Update repair details
  Future<void> updateRepairTransaction(
      String transactionId, String phoneModel, String repairDetails,
      {String? clientName, String? clientPhone}) async {
    Map<String, dynamic> updateData = {
      'phoneModel': phoneModel,
      'repairDetails': repairDetails,
    };

    // Only add client info if they are provided
    if (clientName != null) {
      updateData['clientName'] = clientName;
    }

    if (clientPhone != null) {
      updateData['clientPhone'] = clientPhone;
    }

    // Update the repair document
    await _firestore
        .collection('repairs')
        .doc(transactionId)
        .update(updateData);

    // If client info was updated, update the client document too
    if (clientName != null || clientPhone != null) {
      // Get the repair to find the old client info
      final repairDoc =
          await _firestore.collection('repairs').doc(transactionId).get();

      if (!repairDoc.exists) return;

      final repairData = repairDoc.data()!;
      final oldClientName = repairData['clientName'] as String?;

      if (oldClientName != null) {
        // Look up client by name
        final clientQuery = await _firestore
            .collection('clients')
            .where('name', isEqualTo: oldClientName)
            .limit(1)
            .get();

        if (clientQuery.docs.isNotEmpty) {
          Map<String, dynamic> clientUpdateData = {};
          if (clientName != null) clientUpdateData['name'] = clientName;
          if (clientPhone != null) clientUpdateData['phone'] = clientPhone;

          await clientQuery.docs.first.reference.update(clientUpdateData);
        }
      }
    }
  }

  // Update payment status of a repair transaction
  Future<void> updatePaymentStatus(String transactionId, bool isPaid) async {
    await _firestore
        .collection('repairs')
        .doc(transactionId)
        .update({'isPaid': isPaid});
  }

  // Delete a repair transaction
  Future<void> deleteRepairTransaction(String transactionId) async {
    // Get the repair document to check if it has client info
    final repairDoc =
        await _firestore.collection('repairs').doc(transactionId).get();

    if (!repairDoc.exists) return;

    final repairData = repairDoc.data()!;
    final clientName = repairData['clientName'] as String?;

    // Delete the repair document
    await _firestore.collection('repairs').doc(transactionId).delete();

    // If there's client info, update the client's total repairs count
    if (clientName != null) {
      final clientQuery = await _firestore
          .collection('clients')
          .where('name', isEqualTo: clientName)
          .limit(1)
          .get();

      if (clientQuery.docs.isNotEmpty) {
        await clientQuery.docs.first.reference
            .update({'totalRepairs': FieldValue.increment(-1)});
      }
    }
  }

  // Update a repair part's cost paid status
  Future<void> updatePartCostPaidStatus(
    String transactionId,
    String partId,
    bool isCostPaid,
  ) async {
    try {
      print('Updating part cost paid status:');
      print('TransactionID: $transactionId');
      print('PartID: $partId');
      print('New status: $isCostPaid');

      // Get the repair document
      final repairDoc =
          await _firestore.collection('repairs').doc(transactionId).get();

      if (!repairDoc.exists) {
        print('Repair transaction not found');
        throw Exception('Repair transaction not found');
      }

      final data = repairDoc.data() as Map<String, dynamic>;
      final parts = List<Map<String, dynamic>>.from(data['parts'] ?? []);

      // Find the part and update its status
      bool partFound = false;
      for (int i = 0; i < parts.length; i++) {
        if (parts[i]['id'] == partId ||
            (parts[i]['id'] == null || parts[i]['id'] == '') &&
                parts[i]['name'] == partId) {
          // Ensure part has an ID
          if (parts[i]['id'] == null || parts[i]['id'] == '') {
            parts[i]['id'] = partId;
          }

          parts[i]['isCostPaid'] = isCostPaid;
          partFound = true;
          break;
        }
      }

      if (!partFound) {
        print('Part not found in repair transaction');
        throw Exception('Part not found in repair transaction');
      }

      // Update repair document
      await _firestore
          .collection('repairs')
          .doc(transactionId)
          .update({'parts': parts});

      print('Firestore documents updated successfully');
    } catch (e) {
      print('Error updating part cost paid status: $e');
      throw e;
    }
  }

  // Add a new part to a repair transaction
  Future<void> addPartToRepair(
    String transactionId,
    RepairPart part,
  ) async {
    try {
      // Get the repair document
      final repairDoc =
          await _firestore.collection('repairs').doc(transactionId).get();

      if (!repairDoc.exists) {
        throw Exception('Repair transaction not found');
      }

      final data = repairDoc.data() as Map<String, dynamic>;
      final parts = List<Map<String, dynamic>>.from(data['parts'] ?? []);

      // Add the new part
      parts.add(part.toMap());

      // Calculate new totals
      double totalCost = 0;
      double totalSellingPrice = 0;

      for (final part in parts) {
        totalCost += (part['costPrice'] as num).toDouble();
        totalSellingPrice += (part['sellingPrice'] as num).toDouble();
      }

      // Update repair document
      await _firestore.collection('repairs').doc(transactionId).update({
        'parts': parts,
        'totalCost': totalCost,
        'totalSellingPrice': totalSellingPrice,
        'totalProfit': totalSellingPrice - totalCost,
      });
    } catch (e) {
      print('Error adding part to repair: $e');
      throw e;
    }
  }

  // Delete a part from a repair transaction
  Future<void> deletePartFromRepair(
    String transactionId,
    String partId,
  ) async {
    try {
      print('Deleting part from repair:');
      print('TransactionID: $transactionId');
      print('PartID to delete: $partId');

      // Get the repair document
      final repairDoc =
          await _firestore.collection('repairs').doc(transactionId).get();

      if (!repairDoc.exists) {
        print('Repair transaction not found');
        throw Exception('Repair transaction not found');
      }

      final data = repairDoc.data() as Map<String, dynamic>;
      final parts = List<Map<String, dynamic>>.from(data['parts'] ?? []);

      // Find and remove the part
      int partIndex = -1;
      double removedPartCost = 0;
      double removedPartSellingPrice = 0;

      for (int i = 0; i < parts.length; i++) {
        final currentId = parts[i]['id']?.toString() ?? '';
        if (currentId == partId) {
          removedPartCost = (parts[i]['costPrice'] as num).toDouble();
          removedPartSellingPrice =
              (parts[i]['sellingPrice'] as num).toDouble();
          partIndex = i;
          break;
        }
      }

      if (partIndex >= 0) {
        parts.removeAt(partIndex);
      } else {
        throw Exception('Part not found in repair transaction');
      }

      // Calculate new totals
      double totalCost = 0;
      double totalSellingPrice = 0;

      for (final part in parts) {
        totalCost += (part['costPrice'] as num).toDouble();
        totalSellingPrice += (part['sellingPrice'] as num).toDouble();
      }

      // Update repair document
      await _firestore.collection('repairs').doc(transactionId).update({
        'parts': parts,
        'totalCost': totalCost,
        'totalSellingPrice': totalSellingPrice,
        'totalProfit': totalSellingPrice - totalCost,
      });

      print('Firestore documents updated successfully after part deletion');
    } catch (e) {
      print('Error deleting part from repair: $e');
      throw e;
    }
  }

  // Get all clients for a user
  Stream<List<Client>> getClients(String userId) {
    return _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get client repair history parts
  Stream<List<RepairPart>> getClientParts(String userId, String clientId) {
    // First get the client info
    return _firestore.collection('clients').doc(clientId).get().asStream().map(
        (snapshot) {
      if (!snapshot.exists) return <RepairPart>[];

      final clientData = snapshot.data()!;
      final clientName = clientData['name'] as String?;

      if (clientName == null) return <RepairPart>[];

      // Then get repairs for this client
      return _firestore
          .collection('repairs')
          .where('userId', isEqualTo: userId)
          .where('clientName', isEqualTo: clientName)
          .snapshots()
          .map((repairsSnapshot) {
        List<RepairPart> allParts = [];

        for (var doc in repairsSnapshot.docs) {
          final repairData = doc.data();
          final parts =
              List<Map<String, dynamic>>.from(repairData['parts'] ?? []);

          for (var partData in parts) {
            final part =
                RepairPart.fromMap(partData['id']?.toString() ?? '', partData);
            allParts.add(part);
          }
        }

        // Sort parts by date
        allParts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return allParts;
      }).first;
    }).asyncExpand(
        (event) => Stream<List<RepairPart>>.value(event as List<RepairPart>));
  }

  // Get a specific client by ID
  Future<Client?> getClientById(String userId, String clientId) async {
    try {
      final doc = await _firestore.collection('clients').doc(clientId).get();

      if (!doc.exists) {
        return null;
      }

      return Client.fromMap(doc.id, doc.data()!);
    } catch (e) {
      print('Error getting client: $e');
      return null;
    }
  }

  // Create or update a client
  Future<String> createOrUpdateClient(String userId, Client client) async {
    try {
      DocumentReference clientRef;

      if (client.id.isEmpty) {
        // New client
        clientRef = _firestore.collection('clients').doc();
      } else {
        // Existing client
        clientRef = _firestore.collection('clients').doc(client.id);
      }

      final clientData = {
        ...client.toMap(),
        'userId': userId,
      };

      await clientRef.set(
        clientData,
        SetOptions(merge: true),
      );

      return clientRef.id;
    } catch (e) {
      print('Error saving client: $e');
      throw e;
    }
  }

  // Search for clients by name or phone
  Future<List<Client>> searchClients(String userId, String searchTerm) async {
    if (searchTerm.isEmpty) {
      return [];
    }

    // Firestore doesn't support real text search, so we use a simple startsWith approach
    // For production app, consider using Algolia or other search service
    final nameResults = await _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .startAt([searchTerm]).endAt(
            [searchTerm + '\uf8ff']) // Unicode "end of string" character
        .get();

    final phoneResults = await _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .orderBy('phone')
        .startAt([searchTerm]).endAt([searchTerm + '\uf8ff']).get();

    // Combine results, ensuring no duplicates
    final Map<String, Client> uniqueResults = {};

    for (var doc in nameResults.docs) {
      uniqueResults[doc.id] = Client.fromMap(doc.id, doc.data());
    }

    for (var doc in phoneResults.docs) {
      uniqueResults[doc.id] = Client.fromMap(doc.id, doc.data());
    }

    return uniqueResults.values.toList();
  }
}
