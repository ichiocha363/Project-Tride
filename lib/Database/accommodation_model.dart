import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Tempat Menginap (Accommodation) di destinasi wisata TRIDE.
/// Disimpan pada subkoleksi Firestore: `destinations/{destinationId}/accommodations/{accommodationId}`
class AccommodationModel {
  final String? id;
  final String name;
  final String type;
  final String location;
  final String priceRange;
  final double rating;
  final String image;
  final String? source;

  AccommodationModel({
    this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.priceRange,
    this.rating = 0.0,
    required this.image,
    this.source,
  });

  /// Mengonversi model ke Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'location': location,
      'price_range': priceRange,
      'rating': rating,
      'image': image,
      if (source != null) 'source': source,
    };
  }

  /// Mengonversi model ke Map JSON
  Map<String, dynamic> toJson() => toMap();

  /// Mengonversi model khusus untuk Cloud Firestore payload
  Map<String, dynamic> toFirestore() => toMap();

  /// Helper internal untuk parsing double
  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim()) ?? 0.0;
    return 0.0;
  }

  /// Factory untuk parsing Map generik
  factory AccommodationModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawId = map['id']?.toString() ?? docId;

    return AccommodationModel(
      id: rawId,
      name: (map['name'] as String?)?.trim() ?? '',
      type: (map['type'] as String?)?.trim() ?? 'Hotel',
      location: (map['location'] as String?)?.trim() ?? '',
      priceRange: (map['price_range'] ?? map['priceRange'] as String?)?.trim() ?? 'Estimasi harga tersedia',
      rating: _parseDouble(map['rating']),
      image: (map['image'] as String?)?.trim() ?? '',
      source: (map['source'] as String?)?.trim(),
    );
  }

  /// Factory untuk parsing DocumentSnapshot Cloud Firestore
  factory AccommodationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AccommodationModel.fromMap(data, doc.id);
  }

  /// Copy with
  AccommodationModel copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    String? priceRange,
    double? rating,
    String? image,
    String? source,
  }) {
    return AccommodationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      priceRange: priceRange ?? this.priceRange,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccommodationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => (id ?? '').hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'AccommodationModel(id: $id, name: $name, type: $type, location: $location, rating: $rating)';
  }
}
