import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/trip_service.dart';
import 'package:project_tride/Views/halaman beranda/halaman_trip_detail.dart';
import 'package:project_tride/Views/halaman Ai Planner/halaman_aiplanner_step4.dart' as step4;
import 'package:project_tride/Views/halaman_utama.dart';
import 'package:project_tride/Widgets/custom_floating_nav_bar.dart';

class TestHttpOverrides extends HttpOverrides {}

class MockTripService implements TripService {
  List<TripModel> mockTrips = [];
  bool shouldFailSave = false;
  int createTripCallCount = 0;
  final StreamController<List<TripModel>> _tripsController =
      StreamController<List<TripModel>>.broadcast();

  @override
  String? get currentUserId => 'mock_user_123';

  @override
  bool get isAuthenticated => true;

  @override
  Future<TripModel?> createTrip(TripModel trip, {String? uid}) async {
    createTripCallCount++;
    if (shouldFailSave) {
      return null;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    final created = trip.copyWith(id: 'trip_${mockTrips.length + 1}');
    mockTrips.add(created);
    _tripsController.add(mockTrips);
    return created;
  }

  @override
  Future<List<TripModel>> getTrips({String? uid}) async => mockTrips;

  @override
  Future<TripModel?> getTripById(String tripId, {String? uid}) async {
    return mockTrips.firstWhere((t) => t.id == tripId, orElse: () => mockTrips.first);
  }

  @override
  Future<TripModel?> getUpcomingTrip({String? uid}) async {
    if (mockTrips.isEmpty) return null;
    return mockTrips.first;
  }

  @override
  Stream<List<TripModel>> streamTrips({String? uid}) {
    return _tripsController.stream;
  }

  @override
  Stream<TripModel?> streamUpcomingTrip({String? uid}) {
    return streamTrips(uid: uid).map((list) => list.isNotEmpty ? list.first : null);
  }

  @override
  Future<bool> updateTrip(TripModel trip, {String? uid}) async => true;

  @override
  Future<bool> deleteTrip(String tripId, {String? uid, String? tripName}) async => true;

  @override
  Future<bool> updateItineraryDays(String tripId, List<Map<String, dynamic>> itineraryDays, {String? uid}) async => true;

  @override
  Future<bool> addItineraryItem(String tripId, {required int dayIndex, required Map<String, dynamic> activity, String? newDayTitle, String? uid}) async => true;

  @override
  Future<bool> updateItineraryItem(String tripId, {required int dayIndex, required int activityIndex, required Map<String, dynamic> updatedActivity, String? uid}) async => true;

  @override
  Future<bool> deleteItineraryItem(String tripId, {required int dayIndex, required int activityIndex, String? uid}) async => true;
}

void main() {
  late UserModel testUser;
  late MockTripService mockService;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    testUser = UserModel(
      id: 1,
      nama: 'Budi Test',
      email: 'budi@test.com',
      password: 'password123',
    );
    mockService = MockTripService();
    TripService.instance = mockService;
  });

  group('TRIDE UI/UX Flow Tests', () {
    testWidgets('A. Trip Detail does NOT render CustomFloatingNavBar bottom dock and pops back correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HalamanTripDetail(user: testUser),
                    ),
                  );
                },
                child: const Text('Open Trip Detail'),
              ),
            ),
          ),
        ),
      );

      // Open Trip Detail
      await tester.tap(find.text('Open Trip Detail'));
      await tester.pumpAndSettle();

      // Verify Trip Detail appears
      expect(find.text('TRIP DETAIL'), findsOneWidget);
      expect(find.text('Bali Escape'), findsOneWidget);

      // Verify bottom navigation dock is NOT rendered
      expect(find.byType(CustomFloatingNavBar), findsNothing);

      // Tap Back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verify popped back to previous screen
      expect(find.text('Open Trip Detail'), findsOneWidget);
      expect(find.text('TRIP DETAIL'), findsNothing);
    });

    testWidgets('B. AI Planner Step 4 save flow saves trip and navigates directly to Home with auto-refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: step4.HalamanAiPlanner(
            user: testUser,
            destination: 'Yogyakarta',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down & Tap "Buat Itinerary Saya" to generate AI itinerary
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Itinerary Saya').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify result sheet is shown
      expect(find.text('Simpan Rencana Perjalanan'), findsOneWidget);

      // Tap "Simpan Rencana Perjalanan"
      await tester.tap(find.text('Simpan Rencana Perjalanan'));
      await tester.pump(); // Start save process
      await tester.pump(const Duration(milliseconds: 200)); // Complete async save
      await tester.pumpAndSettle();

      // Verify directly navigated to HalamanUtama (Home)
      expect(find.byType(HalamanUtama), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Upcoming Trip'), findsOneWidget);

      // Verify saved trip name appears on Home without restarting app
      expect(find.text('Trip ke Yogyakarta'), findsOneWidget);
    });

    testWidgets('C. Duplicate protection prevents multi-clicks on Simpan button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: step4.HalamanAiPlanner(
            user: testUser,
            destination: 'Bandung',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down & Tap "Buat Itinerary Saya"
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Itinerary Saya').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final saveButton = find.text('Simpan Rencana Perjalanan');
      expect(saveButton, findsOneWidget);

      // Tap Save button once and pump frame so disabled state is set
      await tester.tap(saveButton);
      await tester.pump();

      // Attempt second tap while in loading state
      final loadingIndicator = find.text('Menyimpan...');
      expect(loadingIndicator, findsOneWidget);
      await tester.tap(loadingIndicator, warnIfMissed: false);
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Verify only 1 trip was created via TripService
      expect(mockService.createTripCallCount, 1);
      expect(mockService.mockTrips.length, 1);
    });

    testWidgets('D. Save failure keeps user on itinerary sheet and displays error',
        (WidgetTester tester) async {
      mockService.shouldFailSave = true;

      await tester.pumpWidget(
        MaterialApp(
          home: step4.HalamanAiPlanner(
            user: testUser,
            destination: 'Solo',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down & Tap "Buat Itinerary Saya"
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Itinerary Saya').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Tap "Simpan Rencana Perjalanan"
      await tester.tap(find.text('Simpan Rencana Perjalanan'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify user is NOT navigated to Home
      expect(find.byType(HalamanUtama), findsNothing);

      // Verify error message is shown and user remains on itinerary sheet
      expect(find.textContaining('Gagal menyimpan trip'), findsOneWidget);
      expect(find.text('Simpan Rencana Perjalanan'), findsOneWidget);
    });
  });
}
