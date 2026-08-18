class ItineraryModel {
  final int? id;
  final int tripId;
  final int day;
  final String title;
  final String location;
  final String startTime;
  final int duration;
  final String category;
  final String? transportation;
  final int estimatedCost;
  final String? notes;

  ItineraryModel({
    this.id,
    required this.tripId,
    required this.day,
    required this.title,
    required this.location,
    required this.startTime,
    this.duration = 0,
    required this.category,
    this.transportation,
    this.estimatedCost = 0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'day': day,
      'title': title,
      'location': location,
      'start_time': startTime,
      'duration': duration,
      'category': category,
      'transportation': transportation,
      'estimated_cost': estimatedCost,
      'notes': notes,
    };
  }

  factory ItineraryModel.fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int? ?? 0,
      day: map['day'] as int? ?? 1,
      title: map['title'] as String? ?? '',
      location: map['location'] as String? ?? '',
      startTime: map['start_time'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      transportation: map['transportation'] as String?,
      estimatedCost: map['estimated_cost'] as int? ?? 0,
      notes: map['notes'] as String?,
    );
  }

  ItineraryModel copyWith({
    int? id,
    int? tripId,
    int? day,
    String? title,
    String? location,
    String? startTime,
    int? duration,
    String? category,
    String? transportation,
    int? estimatedCost,
    String? notes,
  }) {
    return ItineraryModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      day: day ?? this.day,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      transportation: transportation ?? this.transportation,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
    );
  }
}
