import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_tables.dart';

/// Model representasi data Destinasi Wisata di Tride.
/// Mendukung database lokal (SQLite) dan Cloud Firestore secara toleran.
class DestinationModel {
  final int? id;
  final String name;
  final String location;
  final String description;
  final String image;
  final String category;
  final double rating;
  final int estimatedBudget;
  final String? bestTime;
  final double? latitude;
  final double? longitude;
  final String? placeType;
  final String? shortDescription;

  DestinationModel({
    this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.image,
    required this.category,
    this.rating = 0.0,
    this.estimatedBudget = 0,
    this.bestTime,
    this.latitude,
    this.longitude,
    this.placeType,
    this.shortDescription,
  });

  /// Mengonversi model ke Map untuk penyimpanan SQLite / Local DB
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image': image,
      'category': category,
      'rating': rating,
      'estimated_budget': estimatedBudget,
      'best_time': bestTime,
      'latitude': latitude,
      'longitude': longitude,
      DestinationColumns.placeType: placeType,
      if (shortDescription != null) DestinationColumns.shortDescription: shortDescription,
    };
  }

  /// Mengonversi model ke Map untuk JSON / Firestore
  Map<String, dynamic> toJson() => toMap();

  /// Mengonversi model ke Map khusus penyimpanan Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image': image,
      'category': category,
      'rating': rating,
      'estimated_budget': estimatedBudget,
      'best_time': bestTime,
      'latitude': latitude,
      'longitude': longitude,
      'place_type': placeType,
      if (shortDescription != null) 'short_description': shortDescription,
    };
  }

  /// Helper internal untuk parsing angka double secara aman dari num/String
  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim());
    return null;
  }

  /// Helper internal untuk parsing angka integer secara aman dari num/String
  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim());
    return null;
  }

  /// Factory untuk parsing Map dari SQLite atau generic JSON
  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'] ?? map['destination_id'];
    final int? parsedId = _parseInt(rawId);

    return DestinationModel(
      id: parsedId,
      name: (map['name'] as String?)?.trim() ?? '',
      location: (map['location'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      image: (map['image'] as String?)?.trim() ?? '',
      category: (map['category'] as String?)?.trim() ?? '',
      rating: _parseDouble(map['rating']) ?? 0.0,
      estimatedBudget:
          _parseInt(
            map['estimated_budget'] ?? map['estimatedBudget'] ?? map['budget'],
          ) ??
          0,
      bestTime: (map['best_time'] ?? map['bestTime']) as String?,
      latitude: _parseDouble(map['latitude'] ?? map['lat']),
      longitude: _parseDouble(map['longitude'] ?? map['lng'] ?? map['long']),
      placeType:
          (map[DestinationColumns.placeType] ??
                  map['place_type'] ??
                  map['placeType'])
              as String?,
      shortDescription:
          (map[DestinationColumns.shortDescription] ??
                  map['short_description'] ??
                  map['shortDescription'])
              as String?,
    );
  }

  /// Factory alias untuk parsing JSON
  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      DestinationModel.fromMap(json);

  /// Factory untuk parsing DocumentSnapshot Cloud Firestore secara aman & toleran
  factory DestinationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final docIdNum = int.tryParse(doc.id);
    final rawId = data['id'] ?? data['destination_id'] ?? docIdNum;
    final int? id = _parseInt(rawId);

    return DestinationModel(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      location: (data['location'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      image: (data['image'] as String?)?.trim() ?? '',
      category: (data['category'] as String?)?.trim() ?? '',
      rating: _parseDouble(data['rating']) ?? 0.0,
      estimatedBudget:
          _parseInt(
            data['estimated_budget'] ??
                data['estimatedBudget'] ??
                data['budget'],
          ) ??
          0,
      bestTime: (data['best_time'] ?? data['bestTime']) as String?,
      latitude: _parseDouble(data['latitude'] ?? data['lat']),
      longitude: _parseDouble(data['longitude'] ?? data['lng'] ?? data['long']),
      placeType: (data['place_type'] ?? data['placeType']) as String?,
      shortDescription:
          (data['short_description'] ?? data['shortDescription']) as String?,
    );
  }

  /// Factory untuk parsing Map dari Cloud Firestore REST / JSON data dengan opsi fallback docId
  factory DestinationModel.fromFirestoreData(
    Map<String, dynamic> data, [
    dynamic docId,
  ]) {
    final docIdNum = _parseInt(docId);
    final rawId = data['id'] ?? data['destination_id'] ?? docIdNum;
    final int? id = _parseInt(rawId);

    return DestinationModel(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      location: (data['location'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      image: (data['image'] as String?)?.trim() ?? '',
      category: (data['category'] as String?)?.trim() ?? '',
      rating: _parseDouble(data['rating']) ?? 0.0,
      estimatedBudget:
          _parseInt(
            data['estimated_budget'] ??
                data['estimatedBudget'] ??
                data['budget'],
          ) ??
          0,
      bestTime: (data['best_time'] ?? data['bestTime']) as String?,
      latitude: _parseDouble(data['latitude'] ?? data['lat']),
      longitude: _parseDouble(data['longitude'] ?? data['lng'] ?? data['long']),
      placeType: (data['place_type'] ?? data['placeType']) as String?,
      shortDescription:
          (data['short_description'] ?? data['shortDescription']) as String?,
    );
  }

  /// Membuat salinan objek dengan modifikasi atribut tertentu
  DestinationModel copyWith({
    int? id,
    String? name,
    String? location,
    String? description,
    String? image,
    String? category,
    double? rating,
    int? estimatedBudget,
    String? bestTime,
    double? latitude,
    double? longitude,
    String? placeType,
    String? shortDescription,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      bestTime: bestTime ?? this.bestTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeType: placeType ?? this.placeType,
      shortDescription: shortDescription ?? this.shortDescription,
    );
  }

  // ==========================================
  // EQUALITY & DEBUG UTILITIES
  // ==========================================

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => (id ?? 0).hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'DestinationModel(id: $id, name: $name, location: $location, category: $category, rating: $rating, placeType: $placeType, shortDescription: $shortDescription)';
  }
}
