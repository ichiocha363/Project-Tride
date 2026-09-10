import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman budget/halaman_budget.dart';

class TestHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets(
    'HalamanBudget renders all elements from Stitch design correctly with active trip',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi',
        email: 'andi@example.com',
        password: 'password123',
      );

      final trip = TripModel(
        id: 'trip_bali_101',
        userId: 'user_auth_123',
        tripName: 'Liburan Tropis Bali',
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        budget: 10000000,
        createdAt: '2026-09-10T00:00:00.000Z',
      );

      await tester.pumpWidget(MaterialApp(home: HalamanBudget(user: user, trip: trip)));
      await tester.pumpAndSettle();

      // Header & Titles
      expect(find.text('Anggaran'), findsWidgets);
      expect(find.text('JURNAL PERJALANAN'), findsOneWidget);
      expect(find.text('Liburan Tropis Bali'), findsOneWidget);

      // Summary Card Details
      expect(find.text('TOTAL ANGGARAN TRIP'), findsOneWidget);
      expect(find.text('SISA ANGGARAN'), findsOneWidget);
      expect(find.text('Rp 10.000.000'), findsNWidgets(2)); // Total and Remaining

      // Category / Spending Highlights
      expect(find.text('Ringkasan Pengeluaran'), findsOneWidget);
      expect(find.text('Penginapan'), findsOneWidget);
      expect(find.text('Kuliner'), findsOneWidget);
      expect(find.text('Transportasi'), findsOneWidget);

      // Recent Transactions
      expect(find.text('Riwayat Transaksi'), findsOneWidget);
      expect(find.text('Belum ada pengeluaran dicatat.'), findsOneWidget);

      // FAB Button & Modal Test
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Pengeluaran'), findsOneWidget);
      expect(find.text('Simpan Pengeluaran'), findsOneWidget);
    },
  );

  testWidgets(
    'HalamanBudget renders empty state when no trip is active',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Budi',
        email: 'budi@example.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: HalamanBudget(user: user)));
      await tester.pumpAndSettle();

      expect(find.text('Anggaran'), findsWidgets);
      expect(find.text('TOTAL ANGGARAN TRIP'), findsOneWidget);
    },
  );
}
