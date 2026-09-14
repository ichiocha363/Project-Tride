import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import 'package:project_tride/Services/itinerary_planner_provider.dart';
import 'package:project_tride/Services/region_resolver.dart';
import 'package:project_tride/Database/destinations_data.dart';

/// Local Recommendation & Itinerary Engine untuk TRIDE.
/// Menghasilkan itinerary terstruktur 100% berbasis destinasi nyata di database TRIDE
/// tanpa bergantung pada Firebase Cloud Function atau Gemini AI.
class LocalRecommendationEngine implements ItineraryPlannerProvider {
  LocalRecommendationEngine._internal();
  static final LocalRecommendationEngine instance = LocalRecommendationEngine._internal();

  /// Mengambil daftar destinasi nyata dari Firestore (via DestinationService),
  /// atau fallback ke dataset 50 destinasi terverifikasi TRIDE jika database offline/kosong.
  Future<List<DestinationModel>> _loadAvailableDestinations() async {
    try {
      final list = await DestinationService.instance.getDestinations();
      if (list.isNotEmpty) {
        return list;
      }
    } catch (e) {
      debugPrint('[LocalRecommendationEngine] Gagal memuat dari Firestore, fallback ke katalog lokal: $e');
    }
    return List<DestinationModel>.from(realIndonesianDestinations);
  }

  /// Menghitung skor kesesuaian destinasi terhadap parameter input user.
  double _scoreDestination({
    required DestinationModel candidate,
    required String userDestNorm,
    required String? userRegion,
    required List<String> styles,
    required String budget,
    required int budgetCeiling,
  }) {
    double score = 0.0;

    final candNameNorm = candidate.name.trim().toLowerCase();
    final candLocNorm = candidate.location.trim().toLowerCase();
    final candRegion = RegionResolver.resolveRegion(candidate.location);

    // 1. Kesesuaian Lokasi & Region (Prioritas Tertinggi)
    if (candNameNorm.contains(userDestNorm) ||
        userDestNorm.contains(candNameNorm) ||
        candLocNorm.contains(userDestNorm) ||
        userDestNorm.contains(candLocNorm)) {
      score += 1000.0; // Direct Location / City / Name Match
    } else if (userRegion != null &&
        candRegion != null &&
        userRegion.toLowerCase() == candRegion.toLowerCase()) {
      score += 500.0; // Same Region Match
    }

    // 2. Kesesuaian Travel Style dengan Category & PlaceType
    final candCategory = candidate.category.trim().toLowerCase();
    final candPlaceType = (candidate.placeType ?? '').trim().toLowerCase();
    final candDesc = candidate.description.trim().toLowerCase();

    for (final style in styles) {
      final styleNorm = style.trim().toLowerCase();
      final styleKeywords = _getStyleKeywords(styleNorm);

      for (final kw in styleKeywords) {
        if (candCategory.contains(kw) || candPlaceType.contains(kw)) {
          score += 30.0;
          break;
        } else if (candDesc.contains(kw)) {
          score += 15.0;
          break;
        }
      }
    }

    // 3. Kesesuaian Budget
    final candBudget = candidate.estimatedBudget;
    if (budgetCeiling > 0) {
      if (candBudget <= budgetCeiling) {
        score += 30.0;
      } else if (candBudget <= (budgetCeiling * 1.3).round()) {
        score += 15.0;
      }
    } else {
      if (budget.toLowerCase() == 'hemat' && candBudget <= 2500000) {
        score += 30.0;
      } else if (budget.toLowerCase() == 'mewah' && candBudget >= 5000000) {
        score += 30.0;
      } else if (budget.toLowerCase() == 'menengah' &&
          candBudget >= 1500000 &&
          candBudget <= 5000000) {
        score += 30.0;
      }
    }

    // 4. Rating Bonus
    score += (candidate.rating * 5.0);

    // 5. Best Time Bonus
    if (candidate.bestTime != null && candidate.bestTime!.isNotEmpty) {
      score += 10.0;
    }

    return score;
  }

  /// Kata kunci padanan gaya perjalanan
  List<String> _getStyleKeywords(String styleNorm) {
    if (styleNorm.contains('alam') || styleNorm.contains('nature')) {
      return ['alam', 'nature', 'pegunungan', 'pantai', 'danau', 'hutan', 'konservasi', 'pedesaan'];
    }
    if (styleNorm.contains('budaya') || styleNorm.contains('culture')) {
      return ['budaya', 'culture', 'sejarah', 'heritage', 'candi', 'temple', 'museum', 'edukasi', 'tradisi'];
    }
    if (styleNorm.contains('kuliner') || styleNorm.contains('culinary')) {
      return ['kuliner', 'culinary', 'makanan', 'resto', 'pasar', 'otentik'];
    }
    if (styleNorm.contains('petualangan') || styleNorm.contains('adventure')) {
      return ['petualangan', 'adventure', 'trekking', 'pegunungan', 'kawah', 'arung jeram'];
    }
    if (styleNorm.contains('relaksasi') || styleNorm.contains('relaxation')) {
      return ['relaksasi', 'relaxation', 'pantai', 'resort', 'pedesaan', 'spa', 'santai'];
    }
    if (styleNorm.contains('fotografi') || styleNorm.contains('photography')) {
      return ['fotografi', 'photography', 'view', 'pemandangan', 'sunset', 'sunrise', 'spot'];
    }
    if (styleNorm.contains('bahari') || styleNorm.contains('beach')) {
      return ['bahari', 'pantai', 'beach', 'laut', 'terumbu karang', 'snorkeling', 'diving'];
    }
    return [styleNorm];
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
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
    final allDestinations = await _loadAvailableDestinations();

    final userDestNorm = destination.trim().toLowerCase();
    final userRegion = RegionResolver.resolveRegion(destination);

    // Skor seluruh destinasi
    final scoredList = allDestinations.map((d) {
      final score = _scoreDestination(
        candidate: d,
        userDestNorm: userDestNorm,
        userRegion: userRegion,
        styles: styles,
        budget: budget,
        budgetCeiling: budgetCeiling,
      );
      return MapEntry(d, score);
    }).toList();

    // Sort berdasarkan skor tertinggi
    scoredList.sort((a, b) => b.value.compareTo(a.value));

    // Kelompokkan kandidat relevan
    final primaryMatches = scoredList.where((e) => e.value >= 500.0).map((e) => e.key).toList();
    final fallbackMatches = scoredList.map((e) => e.key).toList();

    final selectedPool = primaryMatches.isNotEmpty ? primaryMatches : fallbackMatches;

    // Tentukan jumlah aktivitas per hari berdasarkan pace
    int actsPerDay = 3;
    if (pace.toLowerCase() == 'santai') {
      actsPerDay = 2;
    } else if (pace.toLowerCase() == 'padat') {
      actsPerDay = 4;
    }

    final String stylesText = styles.join(' & ');
    final List<Map<String, dynamic>> schedule = [];

    final totalDays = durationDays > 0 ? durationDays : 1;

    for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
      final dayNumber = dayIndex + 1;
      final List<Map<String, dynamic>> dayActivities = [];

      final dayPrimaryDest = selectedPool[dayIndex % selectedPool.length];

      for (int actIndex = 0; actIndex < actsPerDay; actIndex++) {
        final currentDest = selectedPool[(dayIndex * actsPerDay + actIndex) % selectedPool.length];

        String timeSlot;
        String activityTitle;
        String activityDesc;

        if (actIndex == 0) {
          timeSlot = '08:30 - 11:30';
          activityTitle = 'Eksplorasi ${currentDest.name}';
          activityDesc = currentDest.description;
        } else if (actIndex == 1) {
          timeSlot = '12:00 - 14:00';
          activityTitle = 'Santap Siang & Kuliner Khas di area ${currentDest.name}';
          activityDesc =
              'Menikmati hidangan kuliner lokal otentik khas ${currentDest.location} dalam suasana khas setempat.';
        } else if (actIndex == 2) {
          timeSlot = '15:00 - 18:00';
          activityTitle = 'Sesi Foto & Panorama ${currentDest.name}';
          activityDesc =
              'Menikmati keindahan alam dan lanskap di ${currentDest.name} (${currentDest.location}) pada momen sore hari.';
        } else {
          timeSlot = '19:00 - 21:00';
          activityTitle = 'Relaksasi Malam & Suasana Lokal ${currentDest.location}';
          activityDesc =
              'Bersantai dan menikmati suasana malam sejuk di sekitar lokasi ${currentDest.name}.';
        }

        final String tips =
            'Estimasi budget: Rp ${_formatCurrency(currentDest.estimatedBudget)}. Kategori: ${currentDest.category}. Waktu terbaik: ${currentDest.bestTime ?? 'Sepanjang tahun'}.';

        dayActivities.add({
          'time': timeSlot,
          'location': currentDest.name,
          'title': activityTitle,
          'description': activityDesc,
          'tips': tips,
        });
      }

      schedule.add({
        'day': 'Hari $dayNumber',
        'title': 'Eksplorasi ${dayPrimaryDest.name} & Sekitarnya',
        'activities': dayActivities,
      });
    }

    return {
      'destination': destination,
      'duration': '$totalDays Hari ${totalDays - 1 > 0 ? totalDays - 1 : 1} Malam',
      'styles': stylesText,
      'schedule': schedule,
      'isAiGenerated': false,
      'generated_by': 'local_engine',
      'source': 'Local TRIDE Engine (Katalog Firestore)',
    };
  }
}
