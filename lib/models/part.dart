class Part {
  final String id;
  final String name;
  final double cost;
  final double sellingPrice;
  final int quantity;
  final String userId;

  Part({
    required this.id,
    required this.name,
    required this.cost,
    required this.sellingPrice,
    required this.quantity,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'userId': userId,
    };
  }

  factory Part.fromMap(String id, Map<String, dynamic> map) {
    return Part(
      id: id,
      name: map['name'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      userId: map['userId'] ?? '',
    );
  }

  double get profit => sellingPrice - cost;
  double get totalValue => cost * quantity;
  double get potentialProfit => profit * quantity;
}
