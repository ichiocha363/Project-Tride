/// Model untuk data detail destinasi (Short Description, Attractions, Accommodations, Local Foods)
class DestinationDetailEntry {
  final int id;
  final String shortDescription;
  final List<Map<String, dynamic>> attractions;
  final List<Map<String, dynamic>> accommodations;
  final List<Map<String, dynamic>> localFoods;

  const DestinationDetailEntry({
    required this.id,
    required this.shortDescription,
    required this.attractions,
    required this.accommodations,
    required this.localFoods,
  });
}
