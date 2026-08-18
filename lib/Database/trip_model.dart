class TripModel {
  final int? id;
  final int userId;
  final String tripName;
  final int? destinationId;
  final String startDate;
  final String endDate;
  final int budget;
  final String? travelStyle;
  final String? notes;
  final String status;
  final String createdAt;

  TripModel({
    this.id,
    required this.userId,
    required this.tripName,
    this.destinationId,
    required this.startDate,
    required this.endDate,
    this.budget = 0,
    this.travelStyle,
    this.notes,
    this.status = 'upcoming',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'trip_name': tripName,
      'destination_id': destinationId,
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'travel_style': travelStyle,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      tripName: map['trip_name'] as String? ?? '',
      destinationId: map['destination_id'] as int?,
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      budget: map['budget'] as int? ?? 0,
      travelStyle: map['travel_style'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'upcoming',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  TripModel copyWith({
    int? id,
    int? userId,
    String? tripName,
    int? destinationId,
    String? startDate,
    String? endDate,
    int? budget,
    String? travelStyle,
    String? notes,
    String? status,
    String? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripName: tripName ?? this.tripName,
      destinationId: destinationId ?? this.destinationId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      travelStyle: travelStyle ?? this.travelStyle,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
