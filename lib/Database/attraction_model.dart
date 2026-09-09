import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representasi data Hal Menarik (Attraction) di destinasi wisata TRIDE.
/// Disimpan pada subkoleksi Firestore: `destinations/{destinationId}/attractions/{attractionId}`
class AttractionModel {
  final String? id;
  final String name;
  final String description;
  final String image;
  final String category;
  final int estimatedCost;
  final String? source;

  AttractionModel({
    this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    this.estimatedCost = 0,
    this.source,
  });

  /// Mengonversi model ke Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'estimated_cost': estimatedCost,
      if (source != null) 'source': source,
    };
  }

  /// Mengonversi model ke Map JSON
  Map<String, dynamic> toJson() => toMap();

  /// Mengonversi model khusus untuk Cloud Firestore payload
  Map<String, dynamic> toFirestore() => toMap();

  /// Helper internal untuk parsing integer
  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? 0;
    return 0;
  }

  /// Factory untuk parsing Map generik
  factory AttractionModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawId = map['id']?.toString() ?? docId;

    return AttractionModel(
      id: rawId,
      name: (map['name'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      image: (map['image'] as String?)?.trim() ?? '',
      category: (map['category'] as String?)?.trim() ?? 'Aktivitas',
      estimatedCost: _parseInt(map['estimated_cost'] ?? map['estimatedCost'] ?? map['cost']),
      source: (map['source'] as String?)?.trim(),
    );
  }

  /// Factory untuk parsing DocumentSnapshot Cloud Firestore
  factory AttractionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttractionModel.fromMap(data, doc.id);
  }

  /// Copy with
  AttractionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? category,
    int? estimatedCost,
    String? source,
  }) {
    return AttractionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttractionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => (id ?? '').hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'AttractionModel(id: $id, name: $name, category: $category, estimatedCost: $estimatedCost)';
  }
}
