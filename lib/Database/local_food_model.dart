import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Kuliner Lokal (Local Food) di destinasi wisata TRIDE.
/// Disimpan pada subkoleksi Firestore: `destinations/{destinationId}/local_foods/{foodId}`
class LocalFoodModel {
  final String? id;
  final String name;
  final String description;
  final String priceRange;
  final String location;
  final String image;
  final String? source;

  LocalFoodModel({
    this.id,
    required this.name,
    required this.description,
    required this.priceRange,
    required this.location,
    required this.image,
    this.source,
  });

  /// Mengonversi model ke Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price_range': priceRange,
      'location': location,
      'image': image,
      if (source != null) 'source': source,
    };
  }

  /// Mengonversi model ke Map JSON
  Map<String, dynamic> toJson() => toMap();

  /// Mengonversi model khusus untuk Cloud Firestore payload
  Map<String, dynamic> toFirestore() => toMap();

  /// Factory untuk parsing Map generik
  factory LocalFoodModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawId = map['id']?.toString() ?? docId;

    return LocalFoodModel(
      id: rawId,
      name: (map['name'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      priceRange: (map['price_range'] ?? map['priceRange'] as String?)?.trim() ?? 'Estimasi harga terjangkau',
      location: (map['location'] as String?)?.trim() ?? '',
      image: (map['image'] as String?)?.trim() ?? '',
      source: (map['source'] as String?)?.trim(),
    );
  }

  /// Factory untuk parsing DocumentSnapshot Cloud Firestore
  factory LocalFoodModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return LocalFoodModel.fromMap(data, doc.id);
  }

  /// Copy with
  LocalFoodModel copyWith({
    String? id,
    String? name,
    String? description,
    String? priceRange,
    String? location,
    String? image,
    String? source,
  }) {
    return LocalFoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceRange: priceRange ?? this.priceRange,
      location: location ?? this.location,
      image: image ?? this.image,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalFoodModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => (id ?? '').hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'LocalFoodModel(id: $id, name: $name, location: $location, priceRange: $priceRange)';
  }
}
