import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Models/recommendation_profile.dart';
import 'package:project_tride/Services/recommendation_service.dart';
import 'package:project_tride/Services/region_resolver.dart';
import '../tool/destinations_data.dart';

void main() {
  late RecommendationService service;

  setUp(() {
    service = RecommendationService();
  });

  // ===========================================================================
  // GROUP 1: Profil Rekomendasi Configuration (Tahap 1 Baseline)
  // ===========================================================================
  group('Recommendation Profiles Configuration', () {
    test('Must contain at least 8 predefined initial profiles', () {
      expect(service.availableProfiles.length, greaterThanOrEqualTo(8));
    });

    test('Contains all required 8 profile archetypes with valid preferences', () {
      final profiles = service.availableProfiles;
      final profileNames = profiles.map((p) => p.name).toList();

      expect(profileNames, containsAll([
        'Nature Explorer',
        'Beach Lover',
        'Culture Explorer',
        'Adventure Traveler',
        'City Explorer',
        'Family Traveler',
        'Budget Traveler',
        'Premium Traveler',
      ]));

      for (final profile in profiles) {
        expect(profile.id.isNotEmpty, isTrue);
        expect(profile.name.isNotEmpty, isTrue);
        expect(profile.description.isNotEmpty, isTrue);
        expect(profile.preferredCategories.isNotEmpty, isTrue,
            reason: '${profile.name} must have preferred categories');
        expect(profile.preferredPlaceTypes.isNotEmpty, isTrue,
            reason: '${profile.name} must have preferred place types');
        expect(profile.preferredRegions.isNotEmpty, isTrue,
            reason: '${profile.name} must have preferred regions');
        expect(profile.maxBudget, greaterThan(0));
        expect(profile.minBudget, greaterThanOrEqualTo(0));
        expect(profile.maxBudget, greaterThanOrEqualTo(profile.minBudget));
      }
    });

    test('RecommendationProfile serialization and deserialization (toMap/fromMap)', () {
      for (final profile in service.availableProfiles) {
        final map = profile.toMap();
        final reconstructed = RecommendationProfile.fromMap(map);

        expect(reconstructed.id, profile.id);
        expect(reconstructed.name, profile.name);
        expect(reconstructed.description, profile.description);
        expect(reconstructed.preferredCategories, profile.preferredCategories);
        expect(reconstructed.preferredPlaceTypes, profile.preferredPlaceTypes);
        expect(reconstructed.preferredRegions, profile.preferredRegions);
        expect(reconstructed.budgetLevel, profile.budgetLevel);
        expect(reconstructed.minBudget, profile.minBudget);
        expect(reconstructed.maxBudget, profile.maxBudget);
      }
    });
  });

  // ===========================================================================
  // GROUP 2: Deterministic Seed & Email Normalization (Tahap 1 Baseline)
  // ===========================================================================
  group('Deterministic Seed & Email Normalization', () {
    test('1. Email yang sama selalu menghasilkan seed dan profile yang sama', () {
      const email = 'traveler@example.com';
      final seed1 = service.generateDeterministicSeed(email);
      final seed2 = service.generateDeterministicSeed(email);
      final profile1 = service.getProfileForEmail(email);
      final profile2 = service.getProfileForEmail(email);

      expect(seed1, seed2);
      expect(profile1.id, profile2.id);
      expect(profile1.name, profile2.name);
    });

    test('2. Email dengan uppercase/lowercase dan spasi menghasilkan profile yang sama setelah normalisasi', () {
      const emailStandard = 'usera@example.com';
      const emailWithSpaceAndCaps = '  UserA@Example.COM  ';
      const emailWithMixedCaps = 'UserA@EXAMPLE.com';

      expect(service.normalizeEmail(emailWithSpaceAndCaps), emailStandard);
      expect(service.normalizeEmail(emailWithMixedCaps), emailStandard);

      final seedStandard = service.generateDeterministicSeed(emailStandard);
      final seedWithCaps = service.generateDeterministicSeed(emailWithSpaceAndCaps);
      final seedMixed = service.generateDeterministicSeed(emailWithMixedCaps);

      expect(seedWithCaps, seedStandard);
      expect(seedMixed, seedStandard);

      final profileStandard = service.getProfileForEmail(emailStandard);
      final profileWithCaps = service.getProfileForEmail(emailWithSpaceAndCaps);
      final profileMixed = service.getProfileForEmail(emailWithMixedCaps);

      expect(profileWithCaps.id, profileStandard.id);
      expect(profileMixed.id, profileStandard.id);
    });

    test('3. Email berbeda dapat menghasilkan profile yang berbeda (persebaran seed)', () {
      final dummyEmails = [
        'usera@example.com',
        'userb@example.com',
        'userc@example.com',
        'john.doe@test.org',
        'jane.smith@domain.net',
        'budi.santoso@tride.id',
        'siti.rahma@tride.id',
        'adventurer99@nomad.com',
      ];

      final distinctProfiles = <String>{};
      final distinctSeeds = <int>{};

      for (final email in dummyEmails) {
        final seed = service.generateDeterministicSeed(email);
        final profile = service.getProfileForEmail(email);
        distinctSeeds.add(seed);
        distinctProfiles.add(profile.id);
      }

      expect(distinctSeeds.length, dummyEmails.length);
      expect(distinctProfiles.length, greaterThan(1));
    });

    test('4. Seed selalu konsisten di berbagai pemanggilan dan instance', () {
      final service2 = RecommendationService();

      const testEmails = [
        'usera@example.com',
        'userb@example.com',
        'userc@example.com',
      ];

      for (final email in testEmails) {
        final seed1 = service.generateDeterministicSeed(email);
        final seed2 = service2.generateDeterministicSeed(email);
        expect(seed1, seed2, reason: 'Seed must be strictly deterministic across instances for $email');

        final profile1 = service.getProfileForEmail(email);
        final profile2 = service2.getProfileForEmail(email);
        expect(profile1.id, profile2.id);
      }
    });

    test('5. Semua profile index selalu berada dalam rentang valid [0, profiles.length - 1]', () {
      final sampleEmails = [
        '',
        ' ',
        'a@b.c',
        'usera@example.com',
        'userb@example.com',
        'userc@example.com',
        'long.email.address.with.many.subdomains@corp.travel.co.id',
        'special+characters!#\$%@domain.com',
        '123456789@numbers.net',
      ];

      final profileCount = service.availableProfiles.length;

      for (final email in sampleEmails) {
        final index = service.getProfileIndexForEmail(email);
        expect(index, greaterThanOrEqualTo(0));
        expect(index, lessThan(profileCount),
            reason: 'Profile index $index out of bounds for email: "$email"');

        final profile = service.getProfileForEmail(email);
        expect(profile, isNotNull);
        expect(profile.name.isNotEmpty, isTrue);
      }
    });

    test('Fallback gracefully for empty and null email', () {
      final indexNull = service.getProfileIndexForEmail(null);
      final profileNull = service.getProfileForEmail(null);

      expect(indexNull, 0);
      expect(profileNull, service.defaultProfile);

      final indexEmpty = service.getProfileIndexForEmail('');
      final profileEmpty = service.getProfileForEmail('');

      expect(indexEmpty, 0);
      expect(profileEmpty, service.defaultProfile);
    });

    test('Specific mapping validation for user test examples (usera, userb, userc)', () {
      final testEmails = [
        'usera@example.com',
        'userb@example.com',
        'userc@example.com',
      ];

      for (final email in testEmails) {
        final seed = service.generateDeterministicSeed(email);
        final index = service.getProfileIndexForEmail(email);
        final profile = service.getProfileForEmail(email);

        expect(seed, isNonNegative);
        expect(index, inInclusiveRange(0, 7));
        expect(profile.name, isNotEmpty);
      }
    });
  });

  // ===========================================================================
  // GROUP 3: Region Resolver Helper Tests
  // ===========================================================================
  group('RegionResolver Unit Tests', () {
    test('Correctly maps all 50 real Indonesian destinations to their respective regions', () {
      for (final dest in realIndonesianDestinations) {
        final region = RegionResolver.resolveRegion(dest.location);
        expect(region, isNotNull, reason: 'Failed to resolve region for: ${dest.name} (${dest.location})');
        expect(RegionResolver.allRegions.contains(region), isTrue);

        final id = dest.id ?? 0;
        if (id >= 1 && id <= 15) {
          expect(region, RegionResolver.java, reason: 'ID $id ${dest.name} should be Java');
        } else if (id >= 16 && id <= 25) {
          expect(region, RegionResolver.baliNusaTenggara, reason: 'ID $id ${dest.name} should be Bali & Nusa Tenggara');
        } else if (id >= 26 && id <= 33) {
          expect(region, RegionResolver.sumatra, reason: 'ID $id ${dest.name} should be Sumatra');
        } else if (id >= 34 && id <= 38) {
          expect(region, RegionResolver.kalimantan, reason: 'ID $id ${dest.name} should be Kalimantan');
        } else if (id >= 39 && id <= 45) {
          expect(region, RegionResolver.sulawesi, reason: 'ID $id ${dest.name} should be Sulawesi');
        } else if (id >= 46 && id <= 50) {
          expect(region, RegionResolver.malukuPapua, reason: 'ID $id ${dest.name} should be Maluku & Papua');
        }
      }
    });

    test('Returns null for unmapped, unknown, or empty locations', () {
      expect(RegionResolver.resolveRegion(''), isNull);
      expect(RegionResolver.resolveRegion('   '), isNull);
      expect(RegionResolver.resolveRegion(null), isNull);
      expect(RegionResolver.resolveRegion('Tokyo, Japan'), isNull);
      expect(RegionResolver.resolveRegion('Paris, France'), isNull);
    });
  });

  // ===========================================================================
  // GROUP 4: Category Match Scoring Tests (Bobot: 0–40)
  // ===========================================================================
  group('Factor A: Category Match Scoring (0–40)', () {
    final natureProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'nature_explorer'); // ['Alam', 'Petualangan']

    test('Primary preferred category gets maximum score (40.0)', () {
      final destAlam = DestinationModel(
        name: 'Danau Toba',
        location: 'Toba, Sumatera Utara',
        description: 'Danau alami',
        image: 'https://example.com/img.jpg',
        category: 'Alam',
      );

      final score = service.calculateCategoryScore(destAlam, natureProfile);
      expect(score, 40.0);
    });

    test('Secondary preferred category gets proportional high score (35.0)', () {
      final destPetualangan = DestinationModel(
        name: 'Gunung Bromo',
        location: 'Probolinggo, Jawa Timur',
        description: 'Gunung aktif',
        image: 'https://example.com/img.jpg',
        category: 'Petualangan',
      );

      final score = service.calculateCategoryScore(destPetualangan, natureProfile);
      expect(score, 35.0);
    });

    test('Category synonym / related match gives high proportional score', () {
      final destKonservasi = DestinationModel(
        name: 'Taman Nasional Way Kambas',
        location: 'Lampung Timur, Lampung',
        description: 'Konservasi gajah',
        image: 'https://example.com/img.jpg',
        category: 'Konservasi',
      );

      final score = service.calculateCategoryScore(destKonservasi, natureProfile);
      expect(score, 36.0); // Related to 'Alam'
    });

    test('Unmatched category gets 0.0', () {
      final destBudaya = DestinationModel(
        name: 'Candi Borobudur',
        location: 'Magelang, Jawa Tengah',
        description: 'Candi megah',
        image: 'https://example.com/img.jpg',
        category: 'Budaya',
      );

      final score = service.calculateCategoryScore(destBudaya, natureProfile);
      expect(score, 0.0);
    });

    test('Matching is case-insensitive and trims whitespace', () {
      final destCase = DestinationModel(
        name: 'Spot Alam',
        location: 'Jawa',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: '  aLaM  ',
      );

      final score = service.calculateCategoryScore(destCase, natureProfile);
      expect(score, 40.0);
    });
  });

  // ===========================================================================
  // GROUP 5: Place Type Match Scoring Tests (Bobot: 0–25)
  // ===========================================================================
  group('Factor B: Place Type Match Scoring (0–25)', () {
    final natureProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'nature_explorer'); // ['Pegunungan', 'Pedesaan', 'Alam']

    test('Primary place type match gets full 25.0 points', () {
      final destMountain = DestinationModel(
        name: 'Gunung Bromo',
        location: 'Jawa Timur',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Alam',
        placeType: 'Pegunungan',
      );

      final score = service.calculatePlaceTypeScore(destMountain, natureProfile);
      expect(score, 25.0);
    });

    test('Secondary preferred place type gets proportional score (22.0)', () {
      final destRural = DestinationModel(
        name: 'Desa Penglipuran',
        location: 'Bali',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Budaya',
        placeType: 'Pedesaan',
      );

      final score = service.calculatePlaceTypeScore(destRural, natureProfile);
      expect(score, 22.0);
    });

    test('Unmatched place type gets 0.0', () {
      final destUrban = DestinationModel(
        name: 'Kota Lama Semarang',
        location: 'Semarang',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Sejarah',
        placeType: 'Perkotaan',
      );

      final score = service.calculatePlaceTypeScore(destUrban, natureProfile);
      expect(score, 0.0);
    });

    test('Null or empty place type gets 0.0', () {
      final destNull = DestinationModel(
        name: 'Destinasi Tanpa PlaceType',
        location: 'Jawa',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Alam',
        placeType: null,
      );

      expect(service.calculatePlaceTypeScore(destNull, natureProfile), 0.0);
    });
  });

  // ===========================================================================
  // GROUP 6: Region Match Scoring Tests (Bobot: 0–20)
  // ===========================================================================
  group('Factor C: Region Match Scoring (0–20)', () {
    final natureProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'nature_explorer'); // ['Sumatra', 'Kalimantan', 'Sulawesi', 'Maluku & Papua', 'Java']

    test('Top preferred region gives 20.0 points', () {
      final destSumatra = DestinationModel(
        name: 'Danau Toba',
        location: 'Toba, Sumatera Utara',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Alam',
      );

      final score = service.calculateRegionScore(destSumatra, natureProfile);
      expect(score, 20.0);
    });

    test('Secondary preferred region gives proportional score (18.0)', () {
      final destKalimantan = DestinationModel(
        name: 'Tanjung Puting',
        location: 'Kotawaringin Barat, Kalimantan Tengah',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Konservasi',
      );

      final score = service.calculateRegionScore(destKalimantan, natureProfile);
      expect(score, 18.0);
    });

    test('Unpreferred region or unmapped location gets 0.0', () {
      final destBali = DestinationModel(
        name: 'Ubud',
        location: 'Gianyar, Bali', // Bali & Nusa Tenggara is not in nature_explorer preferredRegions
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Budaya',
      );

      final score = service.calculateRegionScore(destBali, natureProfile);
      expect(score, 0.0);

      final destUnknown = DestinationModel(
        name: 'Tempat Antah Berantah',
        location: 'Lokasi Tidak Dikenal',
        description: 'Desc',
        image: 'https://example.com/img.jpg',
        category: 'Alam',
      );

      expect(service.calculateRegionScore(destUnknown, natureProfile), 0.0);
    });
  });

  // ===========================================================================
  // GROUP 7: Budget Compatibility Tests (Bobot: 0–10: +10, +5, +0)
  // ===========================================================================
  group('Factor D: Budget Compatibility (0–10)', () {
    final budgetProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'budget_traveler'); // Level: budget, min: 0, max: 1800000
    final premiumProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'premium_traveler'); // Level: premium, min: 3000000, max: 10000000
    final moderateProfile = RecommendationProfilePresets.defaultProfiles
        .firstWhere((p) => p.id == 'family_traveler'); // Level: moderate, min: 500000, max: 3500000

    test('Budget Traveler: <= 1.8M (+10), 1.8M-2.5M (+5), > 2.5M (+0)', () {
      final destCocok = DestinationModel(
        name: 'Candi Prambanan',
        location: 'Sleman, D.I. Yogyakarta',
        description: 'Desc',
        image: 'img',
        category: 'Budaya',
        estimatedBudget: 1600000,
      );
      expect(service.calculateBudgetScore(destCocok, budgetProfile), 10.0);

      final destMasukAkal = DestinationModel(
        name: 'Kawah Ijen',
        location: 'Banyuwangi',
        description: 'Desc',
        image: 'img',
        category: 'Petualangan',
        estimatedBudget: 2200000,
      );
      expect(service.calculateBudgetScore(destMasukAkal, budgetProfile), 5.0);

      final destTidakCocok = DestinationModel(
        name: 'Raja Ampat',
        location: 'Papua Barat Daya',
        description: 'Desc',
        image: 'img',
        category: 'Bahari',
        estimatedBudget: 8500000,
      );
      expect(service.calculateBudgetScore(destTidakCocok, budgetProfile), 0.0);
    });

    test('Premium Traveler: >= 3M (+10), 2M-3M (+5), < 2M (+0)', () {
      final destPremiumCocok = DestinationModel(
        name: 'Raja Ampat',
        location: 'Papua',
        description: 'Desc',
        image: 'img',
        category: 'Bahari',
        estimatedBudget: 8500000,
      );
      expect(service.calculateBudgetScore(destPremiumCocok, premiumProfile), 10.0);

      final destPremiumMasukAkal = DestinationModel(
        name: 'Gunung Bromo',
        location: 'Jawa Timur',
        description: 'Desc',
        image: 'img',
        category: 'Petualangan',
        estimatedBudget: 2500000,
      );
      expect(service.calculateBudgetScore(destPremiumMasukAkal, premiumProfile), 5.0);

      final destPremiumTidakCocok = DestinationModel(
        name: 'Kebun Raya Bogor',
        location: 'Bogor',
        description: 'Desc',
        image: 'img',
        category: 'Edukasi',
        estimatedBudget: 1100000,
      );
      expect(service.calculateBudgetScore(destPremiumTidakCocok, premiumProfile), 0.0);
    });

    test('Moderate Profile: Dalam range (+10), toleransi wajar (+5), jauh (+0)', () {
      final destIn = DestinationModel(
        name: 'Bromo',
        location: 'Jawa Timur',
        description: 'Desc',
        image: 'img',
        category: 'Petualangan',
        estimatedBudget: 2500000,
      );
      expect(service.calculateBudgetScore(destIn, moderateProfile), 10.0);

      final destSlightlyHigh = DestinationModel(
        name: 'Wae Rebo',
        location: 'Flores',
        description: 'Desc',
        image: 'img',
        category: 'Budaya',
        estimatedBudget: 4000000,
      );
      expect(service.calculateBudgetScore(destSlightlyHigh, moderateProfile), 5.0);

      final destWayTooHigh = DestinationModel(
        name: 'Raja Ampat',
        location: 'Papua',
        description: 'Desc',
        image: 'img',
        category: 'Bahari',
        estimatedBudget: 8500000,
      );
      expect(service.calculateBudgetScore(destWayTooHigh, moderateProfile), 0.0);
    });
  });

  // ===========================================================================
  // GROUP 8: Rating Bonus Tests (Bobot: 0–5)
  // ===========================================================================
  group('Factor E: Rating Bonus (0–5)', () {
    test('4.8 – 5.0 -> +5.0', () {
      final dest = DestinationModel(name: 'A', location: 'L', description: 'D', image: 'I', category: 'C', rating: 4.9);
      expect(service.calculateRatingScore(dest), 5.0);
    });

    test('4.5 – 4.79 -> +4.0', () {
      final dest = DestinationModel(name: 'A', location: 'L', description: 'D', image: 'I', category: 'C', rating: 4.6);
      expect(service.calculateRatingScore(dest), 4.0);
    });

    test('4.0 – 4.49 -> +2.0', () {
      final dest = DestinationModel(name: 'A', location: 'L', description: 'D', image: 'I', category: 'C', rating: 4.2);
      expect(service.calculateRatingScore(dest), 2.0);
    });

    test('< 4.0 -> +0.0', () {
      final dest = DestinationModel(name: 'A', location: 'L', description: 'D', image: 'I', category: 'C', rating: 3.8);
      expect(service.calculateRatingScore(dest), 0.0);
    });

    test('Rating does not overpower major preference mismatches', () {
      final cultureProfile = RecommendationProfilePresets.defaultProfiles
          .firstWhere((p) => p.id == 'culture_explorer');

      // Perfect match for culture explorer with moderate rating
      final perfectCulture = DestinationModel(
        name: 'Candi Prambanan',
        location: 'Sleman, D.I. Yogyakarta',
        description: 'Candi Hindu',
        image: 'img',
        category: 'Budaya',
        placeType: 'Pedesaan',
        estimatedBudget: 1600000,
        rating: 4.5,
      );

      // High rating but completely mismatched for culture explorer
      final mismatchedHighRating = DestinationModel(
        name: 'Raja Ampat',
        location: 'Raja Ampat, Papua Barat Daya',
        description: 'Bahari Papua',
        image: 'img',
        category: 'Bahari',
        placeType: 'Pantai',
        estimatedBudget: 8500000,
        rating: 5.0,
      );

      final scoreCulture = service.scoreDestination(destination: perfectCulture, profile: cultureProfile);
      final scoreMismatched = service.scoreDestination(destination: mismatchedHighRating, profile: cultureProfile);

      expect(scoreCulture.score, greaterThan(scoreMismatched.score),
          reason: 'A perfect preference match must rank significantly higher than an irrelevant 5.0-star destination');
    });
  });

  // ===========================================================================
  // GROUP 9: Total Score, Breakdown & Limits
  // ===========================================================================
  group('Total Score & Breakdown Integrity', () {
    test('Total score never exceeds 100.0 and never drops below 0.0', () {
      for (final profile in service.availableProfiles) {
        for (final dest in realIndonesianDestinations) {
          final scored = service.scoreDestination(destination: dest, profile: profile);
          expect(scored.score, inInclusiveRange(0.0, 100.0));
          expect(scored.breakdown.totalScore, inInclusiveRange(0.0, 100.0));
          expect(scored.breakdown.categoryScore, inInclusiveRange(0.0, 40.0));
          expect(scored.breakdown.placeTypeScore, inInclusiveRange(0.0, 25.0));
          expect(scored.breakdown.regionScore, inInclusiveRange(0.0, 20.0));
          expect(scored.breakdown.budgetScore, inInclusiveRange(0.0, 10.0));
          expect(scored.breakdown.ratingScore, inInclusiveRange(0.0, 5.0));
        }
      }
    });

    test('Score breakdown contains accurate component values and descriptions', () {
      final profile = service.availableProfiles.first;
      final dest = realIndonesianDestinations.first; // Borobudur
      final scored = service.scoreDestination(destination: dest, profile: profile);

      expect(scored.breakdown.resolvedRegion, 'Java');
      expect(scored.breakdown.categoryMatchDetails, isNotNull);
      expect(scored.breakdown.placeTypeMatchDetails, isNotNull);
      expect(scored.breakdown.budgetMatchDetails, isNotNull);
    });
  });

  // ===========================================================================
  // GROUP 10: Ranking Engine & Determinism
  // ===========================================================================
  group('Ranking Engine & Determinism Tests', () {
    test('Empty destination list returns empty list', () {
      final ranked = service.rankDestinations(email: 'user@example.com', destinations: []);
      expect(ranked, isEmpty);

      final breakdown = service.rankDestinationsWithBreakdown(email: 'user@example.com', destinations: []);
      expect(breakdown, isEmpty);
    });

    test('Ranking is 100% deterministic and identical across repeated calls and instances', () {
      const email = 'usera@example.com';
      final service2 = RecommendationService();

      final rank1 = service.rankDestinations(email: email, destinations: realIndonesianDestinations);
      final rank2 = service.rankDestinations(email: email, destinations: realIndonesianDestinations);
      final rank3 = service2.rankDestinations(email: email, destinations: realIndonesianDestinations);

      expect(rank1.length, realIndonesianDestinations.length);
      expect(rank2.length, realIndonesianDestinations.length);
      expect(rank3.length, realIndonesianDestinations.length);

      for (int i = 0; i < rank1.length; i++) {
        expect(rank1[i].id, rank2[i].id);
        expect(rank1[i].id, rank3[i].id);
      }
    });

    test('Tie-breaking is deterministic when scores are identical', () {
      final destA = DestinationModel(id: 101, name: 'Dest A', location: 'Magelang, Jawa Tengah', description: 'D', image: 'I', category: 'Budaya', rating: 4.8, estimatedBudget: 1500000, placeType: 'Pedesaan');
      final destB = DestinationModel(id: 102, name: 'Dest B', location: 'Magelang, Jawa Tengah', description: 'D', image: 'I', category: 'Budaya', rating: 4.8, estimatedBudget: 1500000, placeType: 'Pedesaan');

      const email = 'traveler@test.com';
      final ranked1 = service.rankDestinations(email: email, destinations: [destA, destB]);
      final ranked2 = service.rankDestinations(email: email, destinations: [destB, destA]);

      // Both orders of input produce the exact same tie-break order
      expect(ranked1.first.id, ranked2.first.id);
    });

    test('All 50 real destinations can be ranked for all 8 profiles without errors', () {
      for (final profile in service.availableProfiles) {
        final ranked = service.rankDestinations(
          email: null,
          destinations: realIndonesianDestinations,
          profileOverride: profile,
        );

        expect(ranked.length, 50);
        // Ensure strictly non-ascending score order
        final scoredRank = service.rankDestinationsWithBreakdown(
          email: null,
          destinations: realIndonesianDestinations,
          profileOverride: profile,
        );

        for (int i = 0; i < scoredRank.length - 1; i++) {
          expect(scoredRank[i].score, greaterThanOrEqualTo(scoredRank[i + 1].score));
        }
      }
    });
  });

  // ===========================================================================
  // GROUP 11: Specific Test Emails Validation (usera, userb, userc)
  // ===========================================================================
  group('Specific Test Emails Top 5 Recommendations Validation', () {
    test('usera@example.com (City Explorer) Top 5 recommendations', () {
      const email = 'usera@example.com';
      final profile = service.getProfileForEmail(email);
      expect(profile.id, 'city_explorer');

      final top5 = service.rankDestinationsWithBreakdown(
        email: email,
        destinations: realIndonesianDestinations,
      ).take(5).toList();

      // ignore: avoid_print
      print('\n=== TOP 5 FOR usera@example.com (${profile.name}) ===');
      for (int i = 0; i < top5.length; i++) {
        final item = top5[i];
        // ignore: avoid_print
        print('${i + 1}. ${item.destination.name} | Score: ${item.score} | Cat: ${item.breakdown.categoryScore}, Place: ${item.breakdown.placeTypeScore}, Reg: ${item.breakdown.regionScore}, Bud: ${item.breakdown.budgetScore}, Rat: ${item.breakdown.ratingScore}');
      }

      // Top recommendations must align with urban and cultural interest
      expect(top5.isNotEmpty, isTrue);
      expect(top5.first.score, greaterThanOrEqualTo(90.0));
      final topNames = top5.map((s) => s.destination.name).toList();
      expect(topNames, anyElement(contains('Semarang')));
      expect(topNames, anyElement(contains('Bogor')));
    });

    test('userb@example.com (Family Traveler) Top 5 recommendations', () {
      const email = 'userb@example.com';
      final profile = service.getProfileForEmail(email);
      expect(profile.id, 'family_traveler');

      final top5 = service.rankDestinationsWithBreakdown(
        email: email,
        destinations: realIndonesianDestinations,
      ).take(5).toList();

      // ignore: avoid_print
      print('\n=== TOP 5 FOR userb@example.com (${profile.name}) ===');
      for (int i = 0; i < top5.length; i++) {
        final item = top5[i];
        // ignore: avoid_print
        print('${i + 1}. ${item.destination.name} | Score: ${item.score} | Cat: ${item.breakdown.categoryScore}, Place: ${item.breakdown.placeTypeScore}, Reg: ${item.breakdown.regionScore}, Bud: ${item.breakdown.budgetScore}, Rat: ${item.breakdown.ratingScore}');
      }

      expect(top5.isNotEmpty, isTrue);
      expect(top5.first.score, greaterThanOrEqualTo(90.0));
    });

    test('userc@example.com (Culture Explorer) Top 5 recommendations', () {
      const email = 'userc@example.com';
      final profile = service.getProfileForEmail(email);
      expect(profile.id, 'culture_explorer');

      final top5 = service.rankDestinationsWithBreakdown(
        email: email,
        destinations: realIndonesianDestinations,
      ).take(5).toList();

      // ignore: avoid_print
      print('\n=== TOP 5 FOR userc@example.com (${profile.name}) ===');
      for (int i = 0; i < top5.length; i++) {
        final item = top5[i];
        // ignore: avoid_print
        print('${i + 1}. ${item.destination.name} | Score: ${item.score} | Cat: ${item.breakdown.categoryScore}, Place: ${item.breakdown.placeTypeScore}, Reg: ${item.breakdown.regionScore}, Bud: ${item.breakdown.budgetScore}, Rat: ${item.breakdown.ratingScore}');
      }

      expect(top5.isNotEmpty, isTrue);
      expect(top5.first.score, greaterThanOrEqualTo(95.0));
      final topNames = top5.map((s) => s.destination.name).toList();
      // Borobudur and Prambanan should be among the very top culture destinations in Java
      expect(topNames, anyElement(contains('Borobudur')));
      expect(topNames, anyElement(contains('Prambanan')));
    });
  });
}
