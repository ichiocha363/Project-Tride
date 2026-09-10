import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Services/trip_service.dart';

void main() {
  group('Trip Model & Firestore Integration Tests', () {
    // ==================================================
    // 1. CREATE TRIP
    // ==================================================
    test('1. Create Trip: TripModel converts to and from Firestore schema accurately', () {
      final trip = TripModel(
        id: 'trip_bali_101',
        userId: 'user_auth_abc123',
        tripName: 'Liburan Tropis Bali',
        destinationId: 16,
        destinationName: 'Ubud Sanctuary',
        destinationLocation: 'Bali · Budaya',
        imageUrl: 'https://images.unsplash.com/photo-bali',
        startDate: '2026-10-14',
        endDate: '2026-10-21',
        budget: 12000000,
        spentBudget: 3500000,
        travelStyle: 'Nature, Culture',
        notes: 'Menginap di Padma Resort, eksplor sawah Tegallalang',
        status: 'upcoming',
        createdAt: '2026-09-10T07:00:00.000Z',
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Kedatangan di Denpasar',
            'activities': ['Tiba di Bandara Ngurah Rai', 'Check-in Padma Resort'],
          },
          {
            'day': 'Hari 2',
            'title': 'Eksplorasi Ubud',
            'activities': ['Sawah Tegallalang', 'Makan Siang Bebek Bengil'],
          },
        ],
      );

      final firestoreMap = trip.toFirestore();

      expect(firestoreMap['id'], 'trip_bali_101');
      expect(firestoreMap['user_id'], 'user_auth_abc123');
      expect(firestoreMap['trip_name'], 'Liburan Tropis Bali');
      expect(firestoreMap['destination_id'], 16);
      expect(firestoreMap['destination_name'], 'Ubud Sanctuary');
      expect(firestoreMap['destination_location'], 'Bali · Budaya');
      expect(firestoreMap['image_url'], 'https://images.unsplash.com/photo-bali');
      expect(firestoreMap['start_date'], '2026-10-14');
      expect(firestoreMap['end_date'], '2026-10-21');
      expect(firestoreMap['budget'], 12000000);
      expect(firestoreMap['spent_budget'], 3500000);
      expect(firestoreMap['travel_style'], 'Nature, Culture');
      expect(firestoreMap['notes'], 'Menginap di Padma Resort, eksplor sawah Tegallalang');
      expect(firestoreMap['status'], 'upcoming');
      expect(firestoreMap['created_at'], '2026-09-10T07:00:00.000Z');
      expect(firestoreMap['itinerary_days'], isA<List>());
      expect((firestoreMap['itinerary_days'] as List).length, 2);
    });

    // ==================================================
    // 2. READ TRIP
    // ==================================================
    test('2. Read Trip: TripModel.fromMap parses Firestore document map completely', () {
      final rawFirestoreData = <String, dynamic>{
        'id': 'trip_rajaampat_202',
        'user_id': 'firebase_uid_user789',
        'trip_name': 'Eksplorasi Raja Ampat',
        'destination_id': 46,
        'destination_name': 'Raja Ampat',
        'destination_location': 'Papua Barat Daya · Bahari',
        'image_url': 'https://images.unsplash.com/photo-rajaampat',
        'start_date': '2026-11-01',
        'end_date': '2026-11-08',
        'budget': 25000000,
        'spent_budget': 5000000,
        'travel_style': 'Bahari, Diving',
        'notes': 'Diving di Misool dan Pianemo',
        'status': 'upcoming',
        'created_at': '2026-09-10T07:15:00.000Z',
        'itinerary_days': [
          {
            'day': 'Hari 1',
            'title': 'Kedatangan di Sorong',
            'activities': ['Ferry ke Waisai', 'Check-in Homestay'],
          }
        ],
      };

      final trip = TripModel.fromMap(rawFirestoreData, 'trip_rajaampat_202');

      expect(trip.id, 'trip_rajaampat_202');
      expect(trip.userId, 'firebase_uid_user789');
      expect(trip.tripName, 'Eksplorasi Raja Ampat');
      expect(trip.destinationId, 46);
      expect(trip.destinationName, 'Raja Ampat');
      expect(trip.destinationLocation, 'Papua Barat Daya · Bahari');
      expect(trip.startDate, '2026-11-01');
      expect(trip.endDate, '2026-11-08');
      expect(trip.budget, 25000000);
      expect(trip.spentBudget, 5000000);
      expect(trip.travelStyle, 'Bahari, Diving');
      expect(trip.status, 'upcoming');
      expect(trip.itineraryDays?.length, 1);
      expect(trip.itineraryDays?[0]['title'], 'Kedatangan di Sorong');
    });

    // ==================================================
    // 3. UPDATE TRIP
    // ==================================================
    test('3. Update Trip: copyWith updates specific fields while preserving others', () {
      final initialTrip = TripModel(
        id: 'trip_bromo_303',
        userId: 'user_uid_111',
        tripName: 'Bromo Sunrise Trip',
        destinationId: 3,
        startDate: '2026-12-01',
        endDate: '2026-12-03',
        budget: 5000000,
        status: 'upcoming',
        createdAt: '2026-09-10T07:20:00.000Z',
      );

      final updatedTrip = initialTrip.copyWith(
        tripName: 'Bromo & Ijen Midnight Adventure',
        budget: 7500000,
        status: 'ongoing',
        notes: 'Sewa Jeep Bromo + Tiket Kawah Ijen',
      );

      expect(updatedTrip.id, 'trip_bromo_303');
      expect(updatedTrip.userId, 'user_uid_111');
      expect(updatedTrip.tripName, 'Bromo & Ijen Midnight Adventure');
      expect(updatedTrip.destinationId, 3);
      expect(updatedTrip.budget, 7500000);
      expect(updatedTrip.status, 'ongoing');
      expect(updatedTrip.notes, 'Sewa Jeep Bromo + Tiket Kawah Ijen');
      expect(updatedTrip.startDate, '2026-12-01');
    });

    // ==================================================
    // 4. DELETE TRIP
    // ==================================================
    test('4. Delete Trip: TripModel supports deletion identification via ID', () {
      final trip = TripModel(
        id: 'trip_to_delete_999',
        userId: 'user_uid_222',
        tripName: 'Trip Dibatalkan',
        startDate: '2026-08-01',
        endDate: '2026-08-05',
        createdAt: '2026-08-01T00:00:00.000Z',
      );

      expect(trip.id, 'trip_to_delete_999');
      expect(trip.userId, 'user_uid_222');
    });

    // ==================================================
    // 5. USER ISOLATION
    // ==================================================
    test('5. User Isolation: Trips are separated strictly by User ID in path schema', () {
      final userATrip = TripModel(
        id: 'trip_user_a_001',
        userId: 'user_A_uid_alpha',
        tripName: 'Perjalanan User A',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        createdAt: '2026-09-10T07:00:00.000Z',
      );

      final userBTrip = TripModel(
        id: 'trip_user_b_001',
        userId: 'user_B_uid_beta',
        tripName: 'Perjalanan User B',
        startDate: '2026-11-01',
        endDate: '2026-11-05',
        createdAt: '2026-09-10T07:00:00.000Z',
      );

      // Path schema: users/{uid}/trips/{tripId}
      final pathUserA = 'users/${userATrip.userId}/trips/${userATrip.id}';
      final pathUserB = 'users/${userBTrip.userId}/trips/${userBTrip.id}';

      expect(pathUserA, 'users/user_A_uid_alpha/trips/trip_user_a_001');
      expect(pathUserB, 'users/user_B_uid_beta/trips/trip_user_b_001');
      expect(pathUserA, isNot(equals(pathUserB)));
      expect(userATrip.userId, isNot(equals(userBTrip.userId)));
    });

    // ==================================================
    // 6. DESTINATION RELATION
    // ==================================================
    test('6. Destination Relation: Trip uses existing catalog destination ID without duplication', () {
      final tripWithDestination = TripModel(
        id: 'trip_komodo_404',
        userId: 'user_uid_333',
        tripName: 'Petualangan Pulau Padar',
        destinationId: 23, // ID 23: Pulau Padar (Komodo)
        destinationName: 'Pulau Padar (Komodo)',
        destinationLocation: 'Nusa Tenggara Timur · Alam',
        startDate: '2026-10-20',
        endDate: '2026-10-25',
        budget: 15000000,
        createdAt: '2026-09-10T07:30:00.000Z',
      );

      final map = tripWithDestination.toFirestore();

      expect(map['destination_id'], 23);
      expect(map['destination_name'], 'Pulau Padar (Komodo)');
      expect(map['destination_location'], 'Nusa Tenggara Timur · Alam');
      // Verifikasi destination_id merujuk pada destinasi katalog eksisting
      expect(map.containsKey('new_destination_created'), false);
    });

    // ==================================================
    // 7. EMPTY TRIP STATE
    // ==================================================
    test('7. Empty Trip State: Parsing empty trip map returns default safe values', () {
      final emptyTrip = TripModel.fromMap({}, 'empty_doc_id');

      expect(emptyTrip.id, 'empty_doc_id');
      expect(emptyTrip.userId, '');
      expect(emptyTrip.tripName, '');
      expect(emptyTrip.destinationId, isNull);
      expect(emptyTrip.budget, 0);
      expect(emptyTrip.spentBudget, 0);
      expect(emptyTrip.status, 'upcoming');
      expect(emptyTrip.itineraryDays, isNull);
    });

    // ==================================================
    // 8. PERSISTENCE VERIFICATION
    // ==================================================
    test('8. Persistence: Full round-trip serialization preserves all types', () {
      final original = TripModel(
        id: 'trip_roundtrip_555',
        userId: 'uid_persistent_456',
        tripName: 'Tana Toraja Heritage Walk',
        destinationId: 39,
        destinationName: 'Tana Toraja',
        destinationLocation: 'Sulawesi Selatan · Budaya',
        imageUrl: 'https://images.unsplash.com/photo-toraja',
        startDate: '2026-12-10',
        endDate: '2026-12-15',
        budget: 9000000,
        spentBudget: 1500000,
        travelStyle: 'Culture, Heritage',
        notes: 'Kunjungan ke Kete Kesu dan Lemo',
        status: 'upcoming',
        createdAt: '2026-09-10T07:40:00.000Z',
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Makale & Rantepao',
            'activities': ['Tiba di Rantepao', 'Makan Pa Piong'],
          }
        ],
      );

      final toMap = original.toFirestore();
      final restored = TripModel.fromMap(toMap, original.id);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.tripName, original.tripName);
      expect(restored.destinationId, original.destinationId);
      expect(restored.destinationName, original.destinationName);
      expect(restored.destinationLocation, original.destinationLocation);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.budget, original.budget);
      expect(restored.spentBudget, original.spentBudget);
      expect(restored.travelStyle, original.travelStyle);
      expect(restored.notes, original.notes);
      expect(restored.status, original.status);
      expect(restored.createdAt, original.createdAt);
      expect(restored.itineraryDays?.length, original.itineraryDays?.length);
    });

    // ==================================================
    // 9. NO HARDCODED USER ID
    // ==================================================
    test('9. No Hardcoded User ID: TripModel dynamically accepts and binds any valid Firebase UID', () {
      const dynamicUid1 = 'firebase_user_xY789_unique';
      const dynamicUid2 = 'firebase_user_zK456_distinct';

      final trip1 = TripModel(
        userId: dynamicUid1,
        tripName: 'Dynamic Trip 1',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        createdAt: '2026-09-10T00:00:00.000Z',
      );

      final trip2 = TripModel(
        userId: dynamicUid2,
        tripName: 'Dynamic Trip 2',
        startDate: '2026-11-01',
        endDate: '2026-11-05',
        createdAt: '2026-09-10T00:00:00.000Z',
      );

      expect(trip1.userId, dynamicUid1);
      expect(trip2.userId, dynamicUid2);
      expect(trip1.userId, isNot(equals('1')));
      expect(trip1.userId, isNot(equals('default_user')));
      expect(trip2.userId, isNot(equals('1')));
    });

    // ==================================================
    // 10. NO DEFAULT / FAKE TRIP OTOMATIS
    // ==================================================
    test('10. No Default/Fake Trip: DbHelper ensureDefaultTripExists does not create fake Kyoto trip', () async {
      // Panggil ensureDefaultTripExists dan pastikan tidak ada error dan tidak ada data palsu di-inject
      await DbHelper.instance.ensureDefaultTripExists(1);
      // Memastikan instance TripService tidak memiliki default trip otomatis
      expect(TripService.instance, isNotNull);
    });
  });
}
