import 'database_tables.dart';
import 'db_helper.dart';

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
  });

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
    };
  }

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    return DestinationModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
      category: map['category'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      estimatedBudget: map['estimated_budget'] as int? ?? 0,
      bestTime: map['best_time'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      placeType: map[DestinationColumns.placeType] as String? ?? map['place_type'] as String?,
    );
  }

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
    );
  }

  static Future<List<DestinationModel>> getAll() async {
    return await DbHelper.instance.getDestinations();
  }

  static Future<List<DestinationModel>> getByPlaceType(String placeType) async {
    final db = await DbHelper.instance.database;
    final result = await db.query(
      DatabaseTables.tableDestinations,
      where: '${DestinationColumns.placeType} = ?',
      whereArgs: [placeType],
    );
    return result.map((json) => DestinationModel.fromMap(json)).toList();
  }
}
