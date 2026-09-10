import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Perjalanan (Trip) di Tride.
/// Mendukung Cloud Firestore (`users/{uid}/trips/{tripId}`) sebagai Source of Truth utama
/// serta kompatibel dengan SQLite / local cache.
class TripModel {
  final String? id;
  final String userId;
  final String tripName;
  final dynamic destinationId;
  final String? destinationName;
  final String? destinationLocation;
  final String? imageUrl;
  final String startDate;
  final String endDate;
  final int budget;
  final int spentBudget;
  final String? travelStyle;
  final String? notes;
  final String status;
  final String createdAt;
  final dynamic updatedAt;
  final List<Map<String, dynamic>>? itineraryDays;

  TripModel({
    this.id,
    required this.userId,
    required this.tripName,
    this.destinationId,
    this.destinationName,
    this.destinationLocation,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.budget = 0,
    this.spentBudget = 0,
    this.travelStyle,
    this.notes,
    this.status = 'upcoming',
    required this.createdAt,
    this.updatedAt,
    this.itineraryDays,
  });

  /// Helper getter untuk kompatibilitas SQLite ID (integer)
  int? get sqliteId => id != null ? int.tryParse(id!) : null;

  /// Helper internal untuk parse integer secara aman
  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  /// Helper internal untuk parse String secara aman
  static String? _parseString(dynamic val) {
    if (val == null) return null;
    return val.toString();
  }

  /// Mengonversi model ke Map untuk penyimpanan Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'trip_name': tripName,
      if (destinationId != null) 'destination_id': destinationId,
      if (destinationName != null) 'destination_name': destinationName,
      if (destinationLocation != null) 'destination_location': destinationLocation,
      if (imageUrl != null) 'image_url': imageUrl,
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'spent_budget': spentBudget,
      if (travelStyle != null) 'travel_style': travelStyle,
      if (notes != null) 'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
      if (itineraryDays != null) 'itinerary_days': itineraryDays,
    };
  }

  /// Mengonversi model ke Map untuk SQLite / generic Map
  Map<String, dynamic> toMap() {
    return {
      if (sqliteId != null) 'id': sqliteId,
      'user_id': int.tryParse(userId) ?? userId,
      'trip_name': tripName,
      'destination_id': destinationId is num
          ? (destinationId as num).toInt()
          : int.tryParse(destinationId?.toString() ?? ''),
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'travel_style': travelStyle,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
    };
  }

  /// Alias toJson()
  Map<String, dynamic> toJson() => toFirestore();

  /// Factory untuk membuat TripModel dari dokumen Cloud Firestore
  factory TripModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TripModel.fromMap(data, doc.id);
  }

  /// Factory untuk membuat TripModel dari Map generic / SQLite
  factory TripModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawId = docId ?? map['id']?.toString() ?? map['trip_id']?.toString();
    final rawUserId = map['user_id']?.toString() ?? map['uid']?.toString() ?? '';

    List<Map<String, dynamic>>? parsedDays;
    final rawDays = map['itinerary_days'] ?? map['itineraryDays'] ?? map['itinerary'];
    if (rawDays is List) {
      try {
        parsedDays = rawDays
            .map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else if (item is String && item.trim().isNotEmpty) {
                return <String, dynamic>{
                  'day': item,
                  'title': item,
                  'activities': <dynamic>[],
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (_) {
        parsedDays = null;
      }
    } else if (rawDays is Map) {
      try {
        parsedDays = [Map<String, dynamic>.from(rawDays)];
      } catch (_) {
        parsedDays = null;
      }
    }

    return TripModel(
      id: rawId,
      userId: rawUserId,
      tripName: map['trip_name'] as String? ?? '',
      destinationId: map['destination_id'],
      destinationName: _parseString(map['destination_name']),
      destinationLocation: _parseString(map['destination_location']),
      imageUrl: _parseString(map['image_url'] ?? map['image']),
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      budget: _parseInt(map['budget'], 0),
      spentBudget: _parseInt(map['spent_budget'], 0),
      travelStyle: map['travel_style'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'upcoming',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'],
      itineraryDays: parsedDays,
    );
  }

  TripModel copyWith({
    String? id,
    String? userId,
    String? tripName,
    dynamic destinationId,
    String? destinationName,
    String? destinationLocation,
    String? imageUrl,
    String? startDate,
    String? endDate,
    int? budget,
    int? spentBudget,
    String? travelStyle,
    String? notes,
    String? status,
    String? createdAt,
    dynamic updatedAt,
    List<Map<String, dynamic>>? itineraryDays,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripName: tripName ?? this.tripName,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spentBudget: spentBudget ?? this.spentBudget,
      travelStyle: travelStyle ?? this.travelStyle,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itineraryDays: itineraryDays ?? this.itineraryDays,
    );
  }
}
