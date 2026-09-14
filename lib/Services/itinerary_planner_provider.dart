/// Contract interface untuk provider perencana itinerary TRIDE.
/// Memungkinkan perpindahan transisi yang mulus antara LocalRecommendationEngine
/// dan GeminiService (AI API / Cloud Functions) tanpa mengubah UI AI Planner.
abstract class ItineraryPlannerProvider {
  /// Menghasilkan rencana perjalanan (itinerary) terstruktur berdasarkan input user.
  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int durationDays,
    required String dates,
    required String companion,
    required int peopleCount,
    required bool hasChildren,
    required bool hasElderly,
    required List<String> styles,
    required String budget,
    required int budgetCeiling,
    required String pace,
    required String accommodation,
    String? specialNeeds,
  });
}
