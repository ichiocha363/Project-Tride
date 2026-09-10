import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Pengeluaran / Expense di Tride.
/// Mendukung Cloud Firestore (`users/{uid}/trips/{tripId}/expenses/{expenseId}`) sebagai Source of Truth utama
/// serta kompatibel dengan SQLite / local storage.
class ExpenseModel {
  final String? id;
  final String tripId;
  final String category;
  final int amount;
  final String date;
  final String? description;
  final String createdAt;
  final dynamic updatedAt;

  ExpenseModel({
    this.id,
    required dynamic tripId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    String? createdAt,
    this.updatedAt,
  })  : tripId = tripId.toString(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// Helper getter untuk kompatibilitas SQLite ID (integer)
  int? get sqliteId => id != null ? int.tryParse(id!) : null;

  /// Helper getter untuk kompatibilitas tripId (integer) pada SQLite
  int get tripIdAsInt => int.tryParse(tripId) ?? 0;

  /// Helper internal untuk parsing integer secara aman (int, double, num, String)
  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) {
      final cleaned = val.replaceAll(RegExp(r'[^\d.-]'), '');
      return int.tryParse(cleaned) ?? double.tryParse(cleaned)?.toInt() ?? fallback;
    }
    return fallback;
  }

  /// Helper internal untuk parsing String secara aman
  static String? _parseString(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate().toIso8601String();
    return val.toString();
  }

  /// Helper internal untuk parsing tanggal / timestamp
  static String _parseDate(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    if (val is Timestamp) return val.toDate().toIso8601String();
    if (val is DateTime) return val.toIso8601String();
    return val.toString();
  }

  /// Mengonversi model ke Map untuk penyimpanan Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'category': category,
      'amount': amount,
      'date': date,
      if (description != null) 'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Mengonversi model ke Map untuk SQLite / generic Map
  Map<String, dynamic> toMap() {
    return {
      if (sqliteId != null) 'id': sqliteId,
      'trip_id': tripIdAsInt,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  /// Alias toJson()
  Map<String, dynamic> toJson() => toFirestore();

  /// Factory untuk membuat ExpenseModel dari dokumen Cloud Firestore
  factory ExpenseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExpenseModel.fromMap(data, doc.id);
  }

  /// Factory untuk membuat ExpenseModel dari Map generic / SQLite
  factory ExpenseModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawId = docId ?? map['id']?.toString() ?? map['expense_id']?.toString();
    final rawTripId = map['trip_id']?.toString() ?? map['tripId']?.toString() ?? '0';

    return ExpenseModel(
      id: rawId,
      tripId: rawTripId,
      category: map['category'] as String? ?? '',
      amount: _parseInt(map['amount'], 0),
      date: _parseDate(map['date'], ''),
      description: _parseString(map['description']),
      createdAt: _parseDate(map['created_at'], DateTime.now().toIso8601String()),
      updatedAt: map['updated_at'],
    );
  }

  ExpenseModel copyWith({
    String? id,
    dynamic tripId,
    String? category,
    int? amount,
    String? date,
    String? description,
    String? createdAt,
    dynamic updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
