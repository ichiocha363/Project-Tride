class FavoriteModel {
  final int? id;
  final int userId;
  final int destinationId;
  final String createdAt;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.destinationId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'destination_id': destinationId,
      'created_at': createdAt,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      destinationId: map['destination_id'] as int? ?? 0,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  FavoriteModel copyWith({
    int? id,
    int? userId,
    int? destinationId,
    String? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinationId: destinationId ?? this.destinationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
