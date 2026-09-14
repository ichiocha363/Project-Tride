import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Services/itinerary_planner_service.dart';
import 'package:project_tride/Services/local_recommendation_engine.dart';
import 'package:project_tride/Services/region_resolver.dart';
import '../tool/destinations_data.dart';

void main() {
  group('LocalRecommendationEngine Unit Tests', () {
    late LocalRecommendationEngine engine;

    setUp(() {
      engine = LocalRecommendationEngine.instance;
      ItineraryPlannerService.instance.setMode(ItineraryProviderMode.local);
    });

    test('1. Location Matching & Region Priority: Banda Neira itinerary centers on Maluku & Papua region', () async {
      final itinerary = await engine.generateItinerary(
        destination: 'Banda Neira',
        durationDays: 4,
        dates: '18 Sep 2026 - 21 Sep 2026 (4 Hari)',
        companion: 'Solo',
        peopleCount: 1,
        hasChildren: false,
        hasElderly: false,
        styles: ['Relaksasi', 'Budaya', 'Kuliner'],
        budget: 'Mewah',
        budgetCeiling: 15000000,
        pace: 'Seimbang',
        accommodation: 'Hotel',
      );

      expect(itinerary['destination'], 'Banda Neira');
      final schedule = itinerary['schedule'] as List;
      expect(schedule.length, 4);

      final validLocationNames = realIndonesianDestinations.map((d) => d.name).toSet();

      for (final dayItem in schedule) {
        final dayMap = dayItem as Map<String, dynamic>;
        final activities = dayMap['activities'] as List;
        expect(activities.isNotEmpty, isTrue);

        for (final act in activities) {
          final actMap = act as Map<String, dynamic>;
          final loc = actMap['location'] as String;

          // Must be from real database catalog
          expect(validLocationNames.contains(loc), isTrue,
              reason: 'Location "$loc" must exist in TRIDE destinations catalog.');

          // Match destination must be in Maluku & Papua region or Banda Neira
          final matchDest = realIndonesianDestinations.firstWhere((d) => d.name == loc);
          final region = RegionResolver.resolveRegion(matchDest.location);
          expect(region, RegionResolver.malukuPapua,
              reason: 'Destinations for Banda Neira query must be from Maluku & Papua region.');
        }
      }
    });

    test('2. Duration Days Matching: Exactly matches user date range input', () async {
      for (final days in [1, 3, 5, 7]) {
        final itinerary = await engine.generateItinerary(
          destination: 'Bali',
          durationDays: days,
          dates: '1 Sep - $days Sep 2026',
          companion: 'Pasangan',
          peopleCount: 2,
          hasChildren: false,
          hasElderly: false,
          styles: ['Fotografi'],
          budget: 'Menengah',
          budgetCeiling: 7500000,
          pace: 'Seimbang',
          accommodation: 'Villa',
        );

        final schedule = itinerary['schedule'] as List;
        expect(schedule.length, days);
        for (int i = 0; i < days; i++) {
          expect((schedule[i] as Map)['day'], 'Hari ${i + 1}');
        }
      }
    });

    test('3. Travel Style Matching: "Alam" prioritizes Nature / Pegunungan / Beach categories', () async {
      final itinerary = await engine.generateItinerary(
        destination: 'Gunung Bromo',
        durationDays: 3,
        dates: '10 Oct - 12 Oct 2026',
        companion: 'Grup',
        peopleCount: 4,
        hasChildren: false,
        hasElderly: false,
        styles: ['Alam', 'Petualangan'],
        budget: 'Hemat',
        budgetCeiling: 3000000,
        pace: 'Padat',
        accommodation: 'Homestay',
      );

      final schedule = itinerary['schedule'] as List;
      expect(schedule.length, 3);

      final validLocationNames = realIndonesianDestinations.map((d) => d.name).toSet();

      for (final dayItem in schedule) {
        final dayMap = dayItem as Map<String, dynamic>;
        final activities = dayMap['activities'] as List;

        for (final act in activities) {
          final actMap = act as Map<String, dynamic>;
          final loc = actMap['location'] as String;
          expect(validLocationNames.contains(loc), isTrue);
        }
      }
    });

    test('4. No Dummy Destinations: Every generated location traces back to TRIDE database', () async {
      final testQueries = [
        'Banda Neira',
        'Candi Borobudur',
        'Raja Ampat',
        'Danau Toba',
        'Labuan Bajo',
        'Yogyakarta',
      ];

      final validLocationNames = realIndonesianDestinations.map((d) => d.name).toSet();

      for (final query in testQueries) {
        final itinerary = await engine.generateItinerary(
          destination: query,
          durationDays: 3,
          dates: '15 Sep - 17 Sep 2026',
          companion: 'Solo',
          peopleCount: 1,
          hasChildren: false,
          hasElderly: false,
          styles: ['Budaya', 'Kuliner'],
          budget: 'Menengah',
          budgetCeiling: 5000000,
          pace: 'Santai',
          accommodation: 'Hotel',
        );

        final schedule = itinerary['schedule'] as List;
        for (final dayItem in schedule) {
          final activities = (dayItem as Map)['activities'] as List;
          for (final act in activities) {
            final loc = (act as Map)['location'] as String;
            expect(validLocationNames.contains(loc), isTrue,
                reason: 'Location "$loc" for query "$query" must exist in TRIDE database.');
            expect(loc.toLowerCase().contains('kyoto'), isFalse);
            expect(loc.toLowerCase().contains('dummy'), isFalse);
          }
        }
      }
    });

    test('5. TripModel Compatibility: Output itinerary format can be loaded into TripModel.itineraryDays', () async {
      final itinerary = await engine.generateItinerary(
        destination: 'Labuan Bajo',
        durationDays: 4,
        dates: '20 Sep - 23 Sep 2026',
        companion: 'Pasangan',
        peopleCount: 2,
        hasChildren: false,
        hasElderly: false,
        styles: ['Bahari', 'Fotografi'],
        budget: 'Mewah',
        budgetCeiling: 12000000,
        pace: 'Seimbang',
        accommodation: 'Resort',
      );

      final rawSchedule = itinerary['schedule'] as List;
      final itineraryDays = List<Map<String, dynamic>>.from(
        rawSchedule.map((e) => Map<String, dynamic>.from(e as Map)),
      );

      final trip = TripModel(
        userId: 'user_test_123',
        tripName: 'Trip ke Labuan Bajo',
        destinationName: 'Labuan Bajo',
        startDate: '2026-09-20',
        endDate: '2026-09-23',
        budget: 12000000,
        travelStyle: 'Bahari, Fotografi',
        status: 'upcoming',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: itineraryDays,
      );

      expect(trip.itineraryDays, isNotNull);
      expect(trip.itineraryDays!.length, 4);
      expect(trip.itineraryDays![0]['day'], 'Hari 1');
      expect((trip.itineraryDays![0]['activities'] as List).isNotEmpty, isTrue);

      final map = trip.toFirestore();
      expect(map['itinerary_days'], isNotNull);
    });

    test('6. ItineraryPlannerService switches transparently between local and gemini modes', () async {
      final service = ItineraryPlannerService.instance;
      service.setMode(ItineraryProviderMode.local);

      final result = await service.generateItinerary(
        destination: 'Bali',
        durationDays: 2,
        dates: '1 Oct - 2 Oct 2026',
        companion: 'Solo',
        peopleCount: 1,
        hasChildren: false,
        hasElderly: false,
        styles: ['Alam'],
        budget: 'Menengah',
        budgetCeiling: 5000000,
        pace: 'Santai',
        accommodation: 'Hotel',
      );

      expect(result['generated_by'], 'local_engine');
      expect(result['isAiGenerated'], isFalse);
    });
  });
}
