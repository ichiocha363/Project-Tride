class ExpenseModel {
  final int? id;
  final int tripId;
  final String category;
  final int amount;
  final String date;
  final String? description;

  ExpenseModel({
    this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      date: map['date'] as String? ?? '',
      description: map['description'] as String?,
    );
  }

  ExpenseModel copyWith({
    int? id,
    int? tripId,
    String? category,
    int? amount,
    String? date,
    String? description,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
