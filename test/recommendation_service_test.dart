import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/recommendation_profile.dart';
import 'package:project_tride/Services/recommendation_service.dart';

void main() {
  late RecommendationService service;

  setUp(() {
    service = RecommendationService();
  });

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

      // Pastikan semua seed email berbeda menghasilkan nilai seed yang unik
      expect(distinctSeeds.length, dummyEmails.length);
      // Pastikan menghasilkan variasi profil (lebih dari 1 profil)
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

        // Print results for observation during test runs
        // ignore: avoid_print
        print('Email: $email -> Seed: $seed -> Index: $index -> Profile: "${profile.name}" (${profile.id})');

        // Verification of properties
        expect(seed, isNonNegative);
        expect(index, inInclusiveRange(0, 7));
        expect(profile.name, isNotEmpty);
      }
    });
  });
}
