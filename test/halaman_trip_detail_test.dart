import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman beranda/halaman_trip_detail.dart';

void main() {
  testWidgets('HalamanTripDetail renders correctly with default values',
      (WidgetTester tester) async {
    final user = UserModel(
      id: 1,
      nama: 'Budi',
      email: 'budi@example.com',
      password: 'password123',
    );

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

    // Verify Nav Dock Labels
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
