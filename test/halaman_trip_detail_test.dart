import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman beranda/halaman_trip_detail.dart';

void main() {
  final user = UserModel(
    id: 1,
    nama: 'Budi',
    email: 'budi@example.com',
    password: 'password123',
  );

  group('HalamanTripDetail & Itinerary Parsing Tests', () {
    testWidgets('1. Renders correctly with default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user),
        ),
      );

      // Verify Title & Subtitles
      expect(find.text('Bali Escape'), findsOneWidget);
      expect(find.text('12 - 16 Sep 2024'), findsOneWidget);

      // Verify Status & Countdown
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('COUNTDOWN'), findsOneWidget);
      expect(find.text('10 Hari'), findsOneWidget);

      // Verify Budget Snapshot
      expect(find.text('Budget Snapshot'), findsOneWidget);
      expect(find.text('Rp 4.5M / Rp 10M'), findsOneWidget);
      expect(find.text('Sisa Rp 5.500.000'), findsOneWidget);

      // Verify Section Header
      expect(find.text('Rencana Perjalanan'), findsOneWidget);

      // Verify Days & Activities
      expect(find.text('D 01'), findsOneWidget);
      expect(find.text('Kamis, 12 Sep'), findsOneWidget);
      expect(find.text('Tiba di Bandara Ngurah Rai'), findsOneWidget);
      expect(find.text('Makan Siang Nasi Kedewatan'), findsOneWidget);
      expect(find.text('Check-in Padma Resort'), findsOneWidget);

      // Verify Action Button
      expect(find.text('Edit Rencana'), findsOneWidget);
    });

    testWidgets('2. Trip with AI Planner String Activities renders WITHOUT crash (Fix for type String is not subtype of int index)',
        (WidgetTester tester) async {
      final tripWithAiItinerary = TripModel(
        id: 'trip-ai-123',
        userId: 'user-1',
        tripName: 'Trip ke Raja Ampat',
        startDate: '2025-06-01',
        endDate: '2025-06-05',
        budget: 15000000,
        spentBudget: 3500000,
        status: 'upcoming',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Kedatangan di Sorong & Transfer Boat',
            'activities': [
              'Penjemputan di Bandara DEO Sorong',
              'Transfer speedboat menuju resort di Waigeo',
              'Sunset photo walk & makan malam seafood',
            ],
          },
          {
            'day': 'Hari 2',
            'title': 'Eksplorasi Piaynemo & Snorkeling',
            'activities': [
              'Trekking ke viewpoint Piaynemo',
              'Snorkeling di Sauwandarek',
              'Istirahat di homestay tepi pantai',
            ],
          },
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(
            user: user,
            trip: tripWithAiItinerary,
          ),
        ),
      );
      await tester.pump();

      // Verify Trip Name
      expect(find.text('Trip ke Raja Ampat'), findsOneWidget);

      // Verify Day 1 & Day 2 badges & titles
      expect(find.text('D 01'), findsOneWidget);
      expect(find.text('Hari 1 · Kedatangan di Sorong & Transfer Boat'), findsOneWidget);
      expect(find.text('D 02'), findsOneWidget);
      expect(find.text('Hari 2 · Eksplorasi Piaynemo & Snorkeling'), findsOneWidget);

      // Verify String Activities rendered as timeline items
      expect(find.text('Penjemputan di Bandara DEO Sorong'), findsOneWidget);
      expect(find.text('Transfer speedboat menuju resort di Waigeo'), findsOneWidget);
      expect(find.text('Trekking ke viewpoint Piaynemo'), findsOneWidget);
      expect(find.text('Snorkeling di Sauwandarek'), findsOneWidget);
    });

    testWidgets('3. Trip without itinerary (empty/null) renders empty state without crashing',
        (WidgetTester tester) async {
      final emptyTrip = TripModel(
        id: 'trip-empty-1',
        userId: 'user-1',
        tripName: 'Trip Solo Backpacker',
        startDate: '2025-08-10',
        endDate: '2025-08-12',
        budget: 2000000,
        spentBudget: 0,
        status: 'upcoming',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(
            user: user,
            trip: emptyTrip,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Trip Solo Backpacker'), findsOneWidget);
      expect(find.text('Belum ada itinerary'), findsOneWidget);
      expect(
        find.text('Jadwal aktivitas perjalanan akan muncul di sini setelah dibuat.'),
        findsOneWidget,
      );
    });

    test('4. TripModel.fromMap & toFirestore preserves itinerary_days safely', () {
      final rawFirestoreData = {
        'id': 'test-doc-1',
        'user_id': 'u100',
        'trip_name': 'Liburan Jogja',
        'start_date': '2025-05-01',
        'end_date': '2025-05-03',
        'budget': 5000000,
        'spent_budget': 1200000,
        'status': 'upcoming',
        'created_at': '2025-04-01T10:00:00.000',
        'itinerary_days': [
          {
            'day': 'Hari 1',
            'title': 'Candi & Kuliner',
            'activities': ['Candi Prambanan', 'Gudeg Yu Djum'],
          },
        ],
      };

      final model = TripModel.fromMap(rawFirestoreData, 'test-doc-1');
      expect(model.tripName, 'Liburan Jogja');
      expect(model.itineraryDays, isNotNull);
      expect(model.itineraryDays!.length, 1);
      expect(model.itineraryDays![0]['day'], 'Hari 1');
      expect(model.itineraryDays![0]['activities'], ['Candi Prambanan', 'Gudeg Yu Djum']);

      final toFirestoreMap = model.toFirestore();
      expect(toFirestoreMap['itinerary_days'], isNotNull);
      expect(toFirestoreMap['itinerary_days'].length, 1);
    });

    testWidgets('5. Delete button is rendered when trip.id is valid and triggers confirmation dialog',
        (WidgetTester tester) async {
      final tripWithId = TripModel(
        id: 'trip-valid-id-123',
        userId: 'user-auth-uid-1',
        tripName: 'Liburan Labuan Bajo',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        budget: 8000000,
        spentBudget: 1500000,
        status: 'upcoming',
        createdAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(
            user: user,
            trip: tripWithId,
          ),
        ),
      );
      await tester.pump();

      // Find Delete IconButton by tooltip or icon
      final deleteIconButton = find.byTooltip('Hapus Trip');
      expect(deleteIconButton, findsOneWidget);

      // Tap Delete Icon
      await tester.tap(deleteIconButton);
      await tester.pumpAndSettle();

      // Verify Confirmation Dialog is shown
      expect(find.text('Hapus Trip'), findsOneWidget);
      expect(
        find.text("Apakah Anda yakin ingin menghapus rencana perjalanan 'Liburan Labuan Bajo'?"),
        findsOneWidget,
      );
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Verify dialog is closed and trip detail page is still open
      expect(find.text('Liburan Labuan Bajo'), findsOneWidget);
    });

    testWidgets('6. Delete button is NOT rendered when trip.id is null or empty',
        (WidgetTester tester) async {
      final tripWithoutId = TripModel(
        id: '',
        userId: 'user-auth-uid-1',
        tripName: 'Trip Tanpa ID',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        createdAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(
            user: user,
            trip: tripWithoutId,
          ),
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Hapus Trip'), findsNothing);
    });
  });
}

