import 'package:flutter/foundation.dart';
import 'package:project_tride/Services/gemini_service.dart';
import 'package:project_tride/Services/itinerary_planner_provider.dart';
import 'package:project_tride/Services/local_recommendation_engine.dart';

enum ItineraryProviderMode {
  local,
  gemini,
}

/// Service Orchestrator untuk AI Planner TRIDE.
/// Menyediakan abstraksi rapi antara LocalRecommendationEngine (Engine Lokal)
/// dan GeminiService (Google Gemini AI via Cloud Functions).
class ItineraryPlannerService implements ItineraryPlannerProvider {
  ItineraryPlannerService._internal();

  static final ItineraryPlannerService instance = ItineraryPlannerService._internal();

  /// Mode aktif saat ini (Default: `ItineraryProviderMode.local` selama Firebase belum Blaze)
  ItineraryProviderMode activeMode = ItineraryProviderMode.local;

  /// Mengatur provider mode secara dinamis saat runtime
  void setMode(ItineraryProviderMode mode) {
    activeMode = mode;
    debugPrint('[ItineraryPlannerService] Mode diubah ke: $mode');
  }

  @override
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
  }) async {
    if (activeMode == ItineraryProviderMode.gemini) {
      try {
        debugPrint('[ItineraryPlannerService] Mencoba membuat itinerary via Gemini AI...');
        return await GeminiService.instance.generateItinerary(
          destination: destination,
          durationDays: durationDays,
          dates: dates,
          companion: companion,
          peopleCount: peopleCount,
          hasChildren: hasChildren,
          hasElderly: hasElderly,
          styles: styles,
          budget: budget,
          budgetCeiling: budgetCeiling,
          pace: pace,
          accommodation: accommodation,
          specialNeeds: specialNeeds,
        );
      } catch (e) {
        debugPrint(
            '[ItineraryPlannerService] Gemini Service / Cloud Function gagal: $e. Memakai fallback LocalRecommendationEngine.');
      }
    }

    debugPrint('[ItineraryPlannerService] Memproses itinerary via LocalRecommendationEngine TRIDE...');
    return await LocalRecommendationEngine.instance.generateItinerary(
      destination: destination,
      durationDays: durationDays,
      dates: dates,
      companion: companion,
      peopleCount: peopleCount,
      hasChildren: hasChildren,
      hasElderly: hasElderly,
      styles: styles,
      budget: budget,
      budgetCeiling: budgetCeiling,
      pace: pace,
      accommodation: accommodation,
      specialNeeds: specialNeeds,
    );
  }
}
