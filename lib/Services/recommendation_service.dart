import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Models/recommendation_profile.dart';
import 'package:project_tride/Services/region_resolver.dart';

/// Service untuk menangani fondasi Rekomendasi Personal TRIDE:
/// 1. Pemetaan Profil Rekomendasi Awal (Deterministic Seed).
/// 2. Scoring Engine multi-faktor (0–100).
/// 3. Ranking Destinasi berbasis profil dan tie-breaking deterministik.
class RecommendationService {
  final List<RecommendationProfile> _profiles;
  final FirebaseAuth? auth;

  static RecommendationService? _instance;

  /// Singleton instance default
  static RecommendationService get instance {
    _instance ??= RecommendationService();
    return _instance!;
  }

  /// Factory / Constructor publik untuk inisialisasi kustom (misal pada unit test)
  RecommendationService({
    List<RecommendationProfile>? profiles,
    this.auth,
  })  : _profiles = profiles != null
            ? List.unmodifiable(profiles)
            : RecommendationProfilePresets.defaultProfiles;

  /// Daftar seluruh profil rekomendasi yang tersedia
  List<RecommendationProfile> get availableProfiles => _profiles;

  /// Profil rekomendasi default jika tidak ada profil lain yang cocok
  RecommendationProfile get defaultProfile => _profiles.first;

  // ==========================================
  // EMAIL NORMALIZATION & DETERMINISTIC SEED
  // ==========================================

  /// Menormalisasi email agar deterministik tanpa terpengaruh spasi atau kapitalisasi
  String normalizeEmail(String? email) {
    if (email == null) return '';
    return email.trim().toLowerCase();
  }

  /// Menghasilkan integer seed deterministik dari email menggunakan algoritma FNV-1a 32-bit.
  int generateDeterministicSeed(String? email) {
    final normalized = normalizeEmail(email);
    if (normalized.isEmpty) return 0;

    // FNV-1a 32-bit constants
    int hash = 0x811C9DC5;
    final bytes = utf8.encode(normalized);

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash;
  }

  /// Menghitung indeks profil awal dari email
  int getProfileIndexForEmail(String? email) {
    if (_profiles.isEmpty) return 0;
    final seed = generateDeterministicSeed(email);
    return seed % _profiles.length;
  }

  /// Mengambil profil rekomendasi awal berdasarkan email pengguna
  RecommendationProfile getProfileForEmail(String? email) {
    if (_profiles.isEmpty) {
      throw StateError('Tidak ada RecommendationProfile yang terdaftar dalam service.');
    }
    final index = getProfileIndexForEmail(email);
    return _profiles[index];
  }

  /// Mengambil profil rekomendasi berdasarkan index
  RecommendationProfile getProfileByIndex(int index) {
    if (index < 0 || index >= _profiles.length) {
      return defaultProfile;
    }
    return _profiles[index];
  }

  /// Mengambil profil rekomendasi pengguna yang sedang login saat ini (dari Firebase Auth)
  RecommendationProfile getCurrentUserProfile({String? explicitEmail}) {
    final email = explicitEmail ?? auth?.currentUser?.email ?? FirebaseAuth.instance.currentUser?.email;
    return getProfileForEmail(email);
  }

  // ==========================================
  // SCORING ENGINE (5 FAKTOR PENILAIAN)
  // ==========================================

  /// 1. Category Match (0 – 40)
  /// Membandingkan kategori destinasi dengan preferred categories pada profil.
  double calculateCategoryScore(
    DestinationModel destination,
    RecommendationProfile profile, {
    double maxWeight = 40.0,
  }) {
    final destCat = destination.category.trim().toLowerCase();
    if (destCat.isEmpty) return 0.0;

    final prefCats = profile.preferredCategories
        .map((c) => c.trim().toLowerCase())
        .toList();

    // Map kategori padanan / sinonim
    final categoryAliases = <String, List<String>>{
      'pantai': ['bahari', 'pantai', 'pesisir'],
      'bahari': ['pantai', 'bahari', 'pesisir', 'maritim'],
      'alam': ['alam', 'konservasi', 'pegunungan', 'hutan', 'danau'],
      'konservasi': ['alam', 'konservasi', 'flora fauna', 'satwa'],
      'budaya': ['budaya', 'sejarah', 'edukasi', 'tradisi', 'candi'],
      'sejarah': ['budaya', 'sejarah', 'candi', 'benteng'],
      'edukasi': ['budaya', 'edukasi', 'alam', 'konservasi'],
      'petualangan': ['petualangan', 'alam', 'pegunungan', 'trekking'],
    };

    // A. Cek direct match
    final directIndex = prefCats.indexOf(destCat);
    if (directIndex >= 0) {
      if (directIndex == 0) return maxWeight; // 40.0
      if (directIndex == 1) return maxWeight * 0.875; // 35.0
      return maxWeight * 0.75; // 30.0
    }

    // B. Cek match melalui padanan / sinonim
    final relatedToDest = categoryAliases[destCat] ?? [destCat];
    for (int i = 0; i < prefCats.length; i++) {
      final pref = prefCats[i];
      final relatedToPref = categoryAliases[pref] ?? [pref];
      final hasOverlap = relatedToDest.any((r) => relatedToPref.contains(r));
      if (hasOverlap) {
        if (i == 0) return maxWeight * 0.90; // 36.0
        if (i == 1) return maxWeight * 0.80; // 32.0
        return maxWeight * 0.70; // 28.0
      }
    }

    return 0.0;
  }

  /// 2. Place Type Match (0 – 25)
  /// Membandingkan placeType destinasi dengan preferred place types profil.
  double calculatePlaceTypeScore(
    DestinationModel destination,
    RecommendationProfile profile, {
    double maxWeight = 25.0,
  }) {
    final destType = (destination.placeType ?? '').trim().toLowerCase();
    if (destType.isEmpty) return 0.0;

    final prefTypes = profile.preferredPlaceTypes
        .map((t) => t.trim().toLowerCase())
        .toList();

    final matchIndex = prefTypes.indexOf(destType);
    if (matchIndex < 0) return 0.0;

    if (matchIndex == 0) return maxWeight; // 25.0
    if (matchIndex == 1) return maxWeight * 0.88; // 22.0
    if (matchIndex == 2) return maxWeight * 0.80; // 20.0
    return maxWeight * 0.72; // 18.0
  }

  /// 3. Region Match (0 – 20)
  /// Memetakan lokasi ke 6 Region Utama dan mencocokkan dengan preferred regions profil.
  double calculateRegionScore(
    DestinationModel destination,
    RecommendationProfile profile, {
    double maxWeight = 20.0,
  }) {
    final resolvedRegion = RegionResolver.resolveRegion(destination.location);
    if (resolvedRegion == null) return 0.0;

    final prefRegions = profile.preferredRegions
        .map((r) => r.trim().toLowerCase())
        .toList();

    final matchIndex = prefRegions.indexOf(resolvedRegion.toLowerCase());
    if (matchIndex < 0) return 0.0;

    if (matchIndex == 0) return maxWeight; // 20.0
    if (matchIndex == 1) return maxWeight * 0.90; // 18.0
    if (matchIndex == 2) return maxWeight * 0.80; // 16.0
    if (matchIndex == 3) return maxWeight * 0.70; // 14.0
    return maxWeight * 0.60; // 12.0
  }

  /// 4. Budget Compatibility (0 – 10)
  /// Menilai kecocokan estimasi budget destinasi dengan profil:
  /// - Sangat cocok: +10.0
  /// - Masih masuk akal: +5.0
  /// - Tidak cocok: +0.0
  double calculateBudgetScore(
    DestinationModel destination,
    RecommendationProfile profile, {
    double maxWeight = 10.0,
  }) {
    final budget = destination.estimatedBudget;

    if (budget <= 0) {
      return profile.budgetLevel == BudgetLevel.budget ? maxWeight : maxWeight * 0.5;
    }

    switch (profile.budgetLevel) {
      case BudgetLevel.budget:
        if (budget <= profile.maxBudget) {
          return maxWeight; // Sangat cocok (+10)
        } else if (budget <= (profile.maxBudget * 1.4).round()) {
          return maxWeight * 0.5; // Masih masuk akal (+5)
        } else {
          return 0.0; // Tidak cocok (+0)
        }

      case BudgetLevel.premium:
        if (budget >= profile.minBudget) {
          return maxWeight; // Sangat cocok (+10)
        } else if (budget >= (profile.minBudget * 0.65).round()) {
          return maxWeight * 0.5; // Masih masuk akal (+5)
        } else {
          return 0.0; // Tidak cocok (+0)
        }

      case BudgetLevel.moderate:
        if (budget >= profile.minBudget && budget <= profile.maxBudget) {
          return maxWeight; // Sangat cocok (+10)
        } else if (budget <= (profile.maxBudget * 1.35).round() &&
            budget >= (profile.minBudget * 0.7).round()) {
          return maxWeight * 0.5; // Masih masuk akal (+5)
        } else {
          return 0.0; // Tidak cocok (+0)
        }
    }
  }

  /// 5. Rating Bonus (0 – 5)
  /// - 4.8–5.0 -> +5.0
  /// - 4.5–4.79 -> +4.0
  /// - 4.0–4.49 -> +2.0
  /// - <4.0 -> +0.0
  double calculateRatingScore(
    DestinationModel destination, {
    double maxWeight = 5.0,
  }) {
    final rating = destination.rating;
    if (rating >= 4.8) {
      return maxWeight; // +5.0
    } else if (rating >= 4.5) {
      return maxWeight * 0.8; // +4.0
    } else if (rating >= 4.0) {
      return maxWeight * 0.4; // +2.0
    } else {
      return 0.0; // +0.0
    }
  }

  /// Menghitung skor lengkap dan breakdown untuk satu destinasi berdasarkan profil
  ScoredDestination scoreDestination({
    required DestinationModel destination,
    required RecommendationProfile profile,
    String? email,
    RecommendationScoringWeights weights = const RecommendationScoringWeights(),
  }) {
    final catScore = calculateCategoryScore(
      destination,
      profile,
      maxWeight: weights.categoryWeight,
    );
    final placeScore = calculatePlaceTypeScore(
      destination,
      profile,
      maxWeight: weights.placeTypeWeight,
    );
    final regScore = calculateRegionScore(
      destination,
      profile,
      maxWeight: weights.regionWeight,
    );
    final budScore = calculateBudgetScore(
      destination,
      profile,
      maxWeight: weights.budgetWeight,
    );
    final ratScore = calculateRatingScore(
      destination,
      maxWeight: weights.ratingWeight,
    );

    final total = (catScore + placeScore + regScore + budScore + ratScore)
        .clamp(0.0, weights.maxTotalScore);

    final resolvedRegion = RegionResolver.resolveRegion(destination.location);

    final breakdown = ScoreBreakdown(
      categoryScore: catScore,
      placeTypeScore: placeScore,
      regionScore: regScore,
      budgetScore: budScore,
      ratingScore: ratScore,
      totalScore: total,
      resolvedRegion: resolvedRegion,
      categoryMatchDetails:
          'Dest: ${destination.category} vs Pref: ${profile.preferredCategories}',
      placeTypeMatchDetails:
          'Dest: ${destination.placeType} vs Pref: ${profile.preferredPlaceTypes}',
      budgetMatchDetails:
          'Dest: Rp ${destination.estimatedBudget} vs Level: ${profile.budgetLevel.name} (${profile.minBudget}-${profile.maxBudget})',
    );

    return ScoredDestination(
      destination: destination,
      score: total,
      breakdown: breakdown,
    );
  }

  // ==========================================
  // RANKING & DETERMINISTIC TIE-BREAKING API
  // ==========================================

  /// Menghitung seed hash kunci tie-break deterministik (email seed + destination ID/name)
  int _computeTieBreakKey(String? email, DestinationModel destination) {
    final normEmail = normalizeEmail(email);
    final destKey = destination.id != null
        ? 'id_${destination.id}'
        : 'name_${destination.name}';
    return generateDeterministicSeed('${normEmail}_$destKey');
  }

  /// Mengurutkan destinasi dan mengembalikan hasil lengkap beserta breakdown skor
  List<ScoredDestination> rankDestinationsWithBreakdown({
    required String? email,
    required List<DestinationModel> destinations,
    RecommendationProfile? profileOverride,
    RecommendationScoringWeights weights = const RecommendationScoringWeights(),
  }) {
    if (destinations.isEmpty) return <ScoredDestination>[];

    final profile = profileOverride ?? getProfileForEmail(email);

    final scored = destinations.map((d) {
      return scoreDestination(
        destination: d,
        profile: profile,
        email: email,
        weights: weights,
      );
    }).toList();

    scored.sort((a, b) {
      final diff = b.score - a.score;
      if (diff.abs() > 0.0001) {
        return diff > 0 ? 1 : -1;
      }
      // Deterministic tie-breaking
      final tieA = _computeTieBreakKey(email, a.destination);
      final tieB = _computeTieBreakKey(email, b.destination);
      return tieA.compareTo(tieB);
    });

    return scored;
  }

  /// API Publik Utama:
  /// Mengambil profil berdasarkan email, menghitung skor setiap destinasi,
  /// mengurutkan secara deterministik, dan mengembalikan `List<DestinationModel>`.
  List<DestinationModel> rankDestinations({
    required String? email,
    required List<DestinationModel> destinations,
    RecommendationProfile? profileOverride,
    RecommendationScoringWeights weights = const RecommendationScoringWeights(),
  }) {
    final rankedScored = rankDestinationsWithBreakdown(
      email: email,
      destinations: destinations,
      profileOverride: profileOverride,
      weights: weights,
    );

    return rankedScored.map((s) => s.destination).toList();
  }
}
