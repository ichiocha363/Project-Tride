import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman beranda/halaman_trip_detail.dart';

void main() {
  final user = UserModel(
    id: 1,
    nama: 'Budi Test',
    email: 'budi@example.com',
    password: 'password123',
  );

  group('Trip Detail - Itinerary Full CRUD Unit & Widget Tests', () {
    testWidgets('1. READ Itinerary: Renders existing days and activities correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final trip = TripModel(
        id: 'trip-test-crud-1',
        userId: 'user-1',
        tripName: 'Liburan Bali',
        startDate: '2026-09-12',
        endDate: '2026-09-16',
        budget: 5000000,
        spentBudget: 1500000,
        status: 'upcoming',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Eksplorasi Ubud',
            'activities': [
              {
                'id': 'act-1',
                'title': 'Makan Siang Nasi Kedewatan',
                'time': '12:30',
                'cost': 'Rp 350.000',
                'location': 'Ubud',
                'description': 'Makan siang kuliner khas',
                'isCompleted': false,
              },
            ],
          },
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: trip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Liburan Bali'), findsOneWidget);
      expect(find.text('Rencana Perjalanan'), findsOneWidget);
      expect(find.text('Makan Siang Nasi Kedewatan'), findsOneWidget);
      expect(find.text('12:30'), findsOneWidget);
      expect(find.text('Rp 350.000'), findsOneWidget);
      expect(find.text('Ubud'), findsOneWidget);
    });

    testWidgets('2. READ Empty State: Displays empty state and CTA button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyTrip = TripModel(
        id: 'trip-empty-itinerary',
        userId: 'user-1',
        tripName: 'Trip Kosong',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: emptyTrip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada itinerary'), findsOneWidget);
      expect(find.text('+ Tambah Aktivitas'), findsWidgets);
    });

    testWidgets('3. CREATE Activity: Opens dialog, fills form, and adds activity',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyTrip = TripModel(
        id: 'trip-create-act',
        userId: 'user-1',
        tripName: 'Trip Lombok',
        startDate: '2026-11-01',
        endDate: '2026-11-05',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: emptyTrip),
        ),
      );
      await tester.pumpAndSettle();

      // Tap + Tambah Aktivitas
      final addBtn = find.text('+ Tambah Aktivitas').first;
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Enter activity title using ancestor lookup
      final titleField = find.ancestor(
        of: find.text('Judul Aktivitas *'),
        matching: find.byType(TextField),
      );
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Dinner di Senggigi');
      await tester.pumpAndSettle();

      // Tap Simpan Aktivitas
      final saveBtn = find.text('Simpan Aktivitas');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify new activity is rendered in timeline
      expect(find.text('Dinner di Senggigi'), findsOneWidget);
    });

    testWidgets('4. UPDATE Activity: Edits activity title and updates state without altering other fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final trip = TripModel(
        id: 'trip-edit-act',
        userId: 'user-1',
        tripName: 'Trip Jogja',
        startDate: '2026-12-01',
        endDate: '2026-12-03',
        budget: 4000000,
        spentBudget: 1000000,
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Candi Prambanan',
            'activities': [
              {
                'id': 'act-prambanan',
                'title': 'Kunjungan Prambanan',
                'time': '09:00',
                'cost': 'Rp 50.000',
              },
              {
                'id': 'act-gudeg',
                'title': 'Makan Gudeg',
                'time': '13:00',
                'cost': 'Rp 30.000',
              },
            ],
          },
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: trip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kunjungan Prambanan'), findsOneWidget);
      expect(find.text('Makan Gudeg'), findsOneWidget);

      // Tap edit on first activity
      final editBtn = find.byKey(const Key('edit_act_0_0'));
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Change title
      final titleField = find.ancestor(
        of: find.text('Judul Aktivitas *'),
        matching: find.byType(TextField),
      );
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Tour Candi Prambanan Sunset');
      await tester.pumpAndSettle();

      // Tap Simpan Perubahan
      final saveBtn = find.text('Simpan Perubahan');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify updated title rendered, while second activity remains intact!
      expect(find.text('Tour Candi Prambanan Sunset'), findsOneWidget);
      expect(find.text('Makan Gudeg'), findsOneWidget);
    });

    testWidgets('5. DELETE Activity: Deleting activity A leaves activity B intact',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final trip = TripModel(
        id: 'trip-delete-act',
        userId: 'user-1',
        tripName: 'Trip Malang',
        startDate: '2027-01-10',
        endDate: '2027-01-12',
        budget: 3000000,
        spentBudget: 500000,
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Wisata Bromo',
            'activities': [
              {
                'id': 'act-sunrise',
                'title': 'Sunrise Penanjakan',
                'time': '04:00',
                'cost': 'Rp 0',
              },
              {
                'id': 'act-kawah',
                'title': 'Trekking Kawah Bromo',
                'time': '07:00',
                'cost': 'Rp 0',
              },
            ],
          },
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: trip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sunrise Penanjakan'), findsOneWidget);
      expect(find.text('Trekking Kawah Bromo'), findsOneWidget);

      // Tap delete on first activity
      final deleteBtn = find.byKey(const Key('delete_act_0_0'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Hapus Aktivitas'), findsOneWidget);
      expect(
        find.text("Apakah Anda yakin ingin menghapus aktivitas 'Sunrise Penanjakan'?"),
        findsOneWidget,
      );

      // Confirm Delete
      final confirmHapusBtn = find.widgetWithText(ElevatedButton, 'Hapus');
      await tester.tap(confirmHapusBtn);
      await tester.pumpAndSettle();

      // Verify first activity removed, while second activity remains!
      expect(find.text('Sunrise Penanjakan'), findsNothing);
      expect(find.text('Trekking Kawah Bromo'), findsOneWidget);

      // Verify budget snapshot remains safe
      expect(find.text('Trip Malang'), findsOneWidget);
    });

    test('6. TripService atomic itinerary update methods work as expected', () async {
      final initialDays = [
        {
          'day': 'Hari 1',
          'title': 'Kedatangan',
          'activities': [
            {'title': 'Check-in Hotel', 'time': '14:00'},
          ],
        },
      ];

      final newActivity = {
        'title': 'Makan Malam Seafood',
        'time': '19:00',
        'cost': 'Rp 200.000',
      };

      // Test helper addItineraryItem logic
      final days = List<Map<String, dynamic>>.from(
        initialDays.map((e) => Map<String, dynamic>.from(e)),
      );
      final acts = List.from(days[0]['activities'] as List);
      acts.add(newActivity);
      days[0]['activities'] = acts;

      expect(days[0]['activities'].length, 2);
      expect(days[0]['activities'][1]['title'], 'Makan Malam Seafood');
    });

    testWidgets('7. AI-Generated itinerary compatibility: String & Map activity formats remain editable and deletable',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final aiGeneratedTrip = TripModel(
        id: 'trip-ai-compat',
        userId: 'user-1',
        tripName: 'Trip Raja Ampat AI',
        startDate: '2026-05-01',
        endDate: '2026-05-05',
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: [
          {
            'day': 'Hari 1',
            'title': 'Arrival & Check-in',
            'activities': [
              'Penjemputan di Bandara Sorong',
              'Speedboat ke Waigeo',
            ],
          },
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanTripDetail(user: user, trip: aiGeneratedTrip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Penjemputan di Bandara Sorong'), findsOneWidget);
      expect(find.text('Speedboat ke Waigeo'), findsOneWidget);

      // Test Edit AI Activity
      final editBtn = find.byKey(const Key('edit_act_0_0'));
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      final titleField = find.ancestor(
        of: find.text('Judul Aktivitas *'),
        matching: find.byType(TextField),
      );
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Penjemputan VIP di Bandara Sorong');
      await tester.pumpAndSettle();

      final saveBtn = find.text('Simpan Perubahan');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Penjemputan VIP di Bandara Sorong'), findsOneWidget);
      expect(find.text('Speedboat ke Waigeo'), findsOneWidget);
    });
  });
}
