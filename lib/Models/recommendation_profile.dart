
import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/destination_model.dart';

/// Level estimasi budget untuk profil rekomendasi
enum BudgetLevel {
  budget,
  moderate,
  premium,
}

/// Konfigurasi pembobotan fitur rekomendasi (untuk ranking di fase selanjutnya)
@immutable
class ProfileWeights {
  final double categoryWeight;
  final double placeTypeWeight;
  final double regionWeight;
  final double budgetWeight;
  final double ratingWeight;

  const ProfileWeights({
    this.categoryWeight = 0.35,
    this.placeTypeWeight = 0.25,
    this.regionWeight = 0.20,
    this.budgetWeight = 0.10,
    this.ratingWeight = 0.10,
  });

  Map<String, dynamic> toMap() {
    return {
      'category_weight': categoryWeight,
      'place_type_weight': placeTypeWeight,
      'region_weight': regionWeight,
      'budget_weight': budgetWeight,
      'rating_weight': ratingWeight,
    };
  }

  factory ProfileWeights.fromMap(Map<String, dynamic> map) {
    return ProfileWeights(
      categoryWeight: (map['category_weight'] as num?)?.toDouble() ?? 0.35,
      placeTypeWeight: (map['place_type_weight'] as num?)?.toDouble() ?? 0.25,
      regionWeight: (map['region_weight'] as num?)?.toDouble() ?? 0.20,
      budgetWeight: (map['budget_weight'] as num?)?.toDouble() ?? 0.10,
      ratingWeight: (map['rating_weight'] as num?)?.toDouble() ?? 0.10,
    );
  }
}

/// Model Profil Rekomendasi Pengguna TRIDE
@immutable
class RecommendationProfile {
  final String id;
  final String name;
  final String description;
  final List<String> preferredCategories;
  final List<String> preferredPlaceTypes;
  final List<String> preferredRegions;
  final BudgetLevel budgetLevel;
  final int minBudget;
  final int maxBudget;
  final ProfileWeights weights;

  const RecommendationProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.preferredCategories,
    required this.preferredPlaceTypes,
    required this.preferredRegions,
    required this.budgetLevel,
    required this.minBudget,
    required this.maxBudget,
    this.weights = const ProfileWeights(),
  });

  RecommendationProfile copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? preferredCategories,
    List<String>? preferredPlaceTypes,
    List<String>? preferredRegions,
    BudgetLevel? budgetLevel,
    int? minBudget,
    int? maxBudget,
    ProfileWeights? weights,
  }) {
    return RecommendationProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      preferredPlaceTypes: preferredPlaceTypes ?? this.preferredPlaceTypes,
      preferredRegions: preferredRegions ?? this.preferredRegions,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      weights: weights ?? this.weights,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'preferred_categories': preferredCategories,
      'preferred_place_types': preferredPlaceTypes,
      'preferred_regions': preferredRegions,
      'budget_level': budgetLevel.name,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'weights': weights.toMap(),
    };
  }

  factory RecommendationProfile.fromMap(Map<String, dynamic> map) {
    return RecommendationProfile(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      preferredCategories: (map['preferred_categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      preferredPlaceTypes: (map['preferred_place_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      preferredRegions: (map['preferred_regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      budgetLevel: BudgetLevel.values.firstWhere(
        (e) => e.name == (map['budget_level'] as String?),
        orElse: () => BudgetLevel.moderate,
      ),
      minBudget: (map['min_budget'] as num?)?.toInt() ?? 0,
      maxBudget: (map['max_budget'] as num?)?.toInt() ?? 5000000,
      weights: map['weights'] != null
          ? ProfileWeights.fromMap(map['weights'] as Map<String, dynamic>)
          : const ProfileWeights(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RecommendationProfile(id: $id, name: $name, budgetLevel: ${budgetLevel.name})';
}

/// Konfigurasi Preset Profil Rekomendasi Awal TRIDE
/// Terdiri dari minimal 8 profil yang mudah disesuaikan dan diperluas.
class RecommendationProfilePresets {
  const RecommendationProfilePresets._();

  static const List<RecommendationProfile> defaultProfiles = [
    // 1. Nature Explorer
    RecommendationProfile(
      id: 'nature_explorer',
      name: 'Nature Explorer',
      description:
          'Pencinta keindahan lanskap alam terbuka, panorama pegunungan, dan keanekaragaman flora fauna Nusantara.',
      preferredCategories: ['Alam', 'Petualangan'],
      preferredPlaceTypes: ['Pegunungan', 'Pedesaan', 'Alam'],
      preferredRegions: ['Sumatra', 'Kalimantan', 'Sulawesi', 'Maluku & Papua', 'Java'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 0,
      maxBudget: 3500000,
    ),

    // 2. Beach Lover
    RecommendationProfile(
      id: 'beach_lover',
      name: 'Beach Lover',
      description:
          'Pengagum pesona pantai tropis, keindahan bahari, pulau-pulau eksotis, dan deburan ombak laut biru.',
      preferredCategories: ['Pantai', 'Alam'],
      preferredPlaceTypes: ['Pantai', 'Alam'],
      preferredRegions: ['Bali & Nusa Tenggara', 'Sulawesi', 'Maluku & Papua', 'Java'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 0,
      maxBudget: 4000000,
    ),

    // 3. Culture Explorer
    RecommendationProfile(
      id: 'culture_explorer',
      name: 'Culture Explorer',
      description:
          'Penikmat warisan sejarah luhur, candi megah, desa adat, dan kekayaan tradisi budaya Indonesia.',
      preferredCategories: ['Budaya', 'Alam'],
      preferredPlaceTypes: ['Pedesaan', 'Perkotaan'],
      preferredRegions: ['Java', 'Bali & Nusa Tenggara', 'Sumatra', 'Sulawesi'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 0,
      maxBudget: 2500000,
    ),

    // 4. Adventure Traveler
    RecommendationProfile(
      id: 'adventure_traveler',
      name: 'Adventure Traveler',
      description:
          'Pemberani penjelajah rute menantang, pendakian kawah gunung aktif, dan atraksi pemacu adrenalin.',
      preferredCategories: ['Petualangan', 'Alam'],
      preferredPlaceTypes: ['Pegunungan', 'Alam', 'Pantai'],
      preferredRegions: ['Sumatra', 'Java', 'Bali & Nusa Tenggara', 'Maluku & Papua'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 1000000,
      maxBudget: 4500000,
    ),

    // 5. City Explorer
    RecommendationProfile(
      id: 'city_explorer',
      name: 'City Explorer',
      description:
          'Penggemar dinamika perkotaan modern, pusat seni urban, landmark kota bersejarah, dan tempat hiburan ikonik.',
      preferredCategories: ['Budaya', 'Alam', 'Petualangan'],
      preferredPlaceTypes: ['Perkotaan'],
      preferredRegions: ['Java', 'Bali & Nusa Tenggara', 'Sumatra', 'Sulawesi'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 0,
      maxBudget: 3000000,
    ),

    // 6. Family Traveler
    RecommendationProfile(
      id: 'family_traveler',
      name: 'Family Traveler',
      description:
          'Wisatawan yang mengutamakan destinasi ramah keluarga, nyaman, edukatif, dan memiliki fasilitas lengkap.',
      preferredCategories: ['Budaya', 'Pantai', 'Alam'],
      preferredPlaceTypes: ['Pedesaan', 'Pantai', 'Perkotaan'],
      preferredRegions: ['Java', 'Bali & Nusa Tenggara', 'Sumatra'],
      budgetLevel: BudgetLevel.moderate,
      minBudget: 500000,
      maxBudget: 3500000,
    ),

    // 7. Budget Traveler
    RecommendationProfile(
      id: 'budget_traveler',
      name: 'Budget Traveler',
      description:
          'Backpacker cerdas pencari pengalaman berharga dengan efisiensi biaya perjalanan yang sangat terjangkau.',
      preferredCategories: ['Budaya', 'Alam', 'Pantai', 'Petualangan'],
      preferredPlaceTypes: ['Pedesaan', 'Pegunungan', 'Pantai', 'Perkotaan'],
      preferredRegions: ['Java', 'Sumatra', 'Bali & Nusa Tenggara'],
      budgetLevel: BudgetLevel.budget,
      minBudget: 0,
      maxBudget: 1800000,
    ),

    // 8. Premium Traveler
    RecommendationProfile(
      id: 'premium_traveler',
      name: 'Premium Traveler',
      description:
          'Pelancong eksklusif pencari pengalaman wisata prestisius, resort mewah kelas atas, dan surga tersembunyi istimewa.',
      preferredCategories: ['Pantai', 'Alam', 'Budaya', 'Petualangan'],
      preferredPlaceTypes: ['Pantai', 'Perkotaan', 'Pegunungan'],
      preferredRegions: ['Bali & Nusa Tenggara', 'Maluku & Papua', 'Sulawesi', 'Java'],
      budgetLevel: BudgetLevel.premium,
      minBudget: 3000000,
      maxBudget: 10000000,
    ),
  ];
}

/// Konfigurasi bobot penilaian rekomendasi destinasi
@immutable
class RecommendationScoringWeights {
  final double categoryWeight; // Default: 40.0
  final double placeTypeWeight; // Default: 25.0
  final double regionWeight; // Default: 20.0
  final double budgetWeight; // Default: 10.0
  final double ratingWeight; // Default: 5.0

  const RecommendationScoringWeights({
    this.categoryWeight = 40.0,
    this.placeTypeWeight = 25.0,
    this.regionWeight = 20.0,
    this.budgetWeight = 10.0,
    this.ratingWeight = 5.0,
  });

  /// Skor total maksimum (default: 100.0)
  double get maxTotalScore =>
      categoryWeight +
      placeTypeWeight +
      regionWeight +
      budgetWeight +
      ratingWeight;

  Map<String, dynamic> toMap() {
    return {
      'category_weight': categoryWeight,
      'place_type_weight': placeTypeWeight,
      'region_weight': regionWeight,
      'budget_weight': budgetWeight,
      'rating_weight': ratingWeight,
    };
  }

  factory RecommendationScoringWeights.fromMap(Map<String, dynamic> map) {
    return RecommendationScoringWeights(
      categoryWeight: (map['category_weight'] as num?)?.toDouble() ?? 40.0,
      placeTypeWeight: (map['place_type_weight'] as num?)?.toDouble() ?? 25.0,
      regionWeight: (map['region_weight'] as num?)?.toDouble() ?? 20.0,
      budgetWeight: (map['budget_weight'] as num?)?.toDouble() ?? 10.0,
      ratingWeight: (map['rating_weight'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

/// Rincian penilaian rekomendasi destinasi untuk transparansi & debugging
@immutable
class ScoreBreakdown {
  final double categoryScore;
  final double placeTypeScore;
  final double regionScore;
  final double budgetScore;
  final double ratingScore;
  final double totalScore;
  final String? resolvedRegion;
  final String? categoryMatchDetails;
  final String? placeTypeMatchDetails;
  final String? budgetMatchDetails;

  const ScoreBreakdown({
    required this.categoryScore,
    required this.placeTypeScore,
    required this.regionScore,
    required this.budgetScore,
    required this.ratingScore,
    required this.totalScore,
    this.resolvedRegion,
    this.categoryMatchDetails,
    this.placeTypeMatchDetails,
    this.budgetMatchDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'category_score': categoryScore,
      'place_type_score': placeTypeScore,
      'region_score': regionScore,
      'budget_score': budgetScore,
      'rating_score': ratingScore,
      'total_score': totalScore,
      'resolved_region': resolvedRegion,
      'category_match_details': categoryMatchDetails,
      'place_type_match_details': placeTypeMatchDetails,
      'budget_match_details': budgetMatchDetails,
    };
  }

  @override
  String toString() {
    return 'ScoreBreakdown(Total: $totalScore | Category: $categoryScore, PlaceType: $placeTypeScore, Region: $regionScore ($resolvedRegion), Budget: $budgetScore, Rating: $ratingScore)';
  }
}

/// Hasil penilaian destinasi dengan skor dan breakdown lengkap
@immutable
class ScoredDestination {
  final DestinationModel destination;
  final double score;
  final ScoreBreakdown breakdown;

  const ScoredDestination({
    required this.destination,
    required this.score,
    required this.breakdown,
  });

  @override
  String toString() => 'ScoredDestination(name: ${destination.name}, score: $score)';
}

