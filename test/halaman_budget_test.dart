import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_budget.dart';

void main() {
  testWidgets(
    'HalamanBudget renders all elements from Stitch design correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi',
        email: 'andi@example.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: HalamanBudget(user: user)));

      // Header & Titles
      expect(find.text('Tride'), findsOneWidget);
      expect(find.text('Budget Trip'), findsOneWidget);
      expect(find.text('Kelola pengeluaran perjalanan Anda'), findsOneWidget);

      // Summary Card Details
      expect(find.text('Total Budget'), findsOneWidget);
      expect(find.text('Rp 5.000.000'), findsOneWidget);
      expect(find.text('Rp 3.5M Sisa'), findsOneWidget);
      expect(find.text('Terpakai'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);

      // Category Grid Items
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Transportasi'), findsWidgets);
      expect(find.text('Akomodasi'), findsWidgets);
      expect(find.text('Makanan'), findsWidgets);
      expect(find.text('Wisata'), findsOneWidget);

      // Recent Expenses
      expect(find.text('Pengeluaran Terakhir'), findsOneWidget);
      expect(find.text('Makan Siang'), findsOneWidget);
      expect(find.text('Tiket Pesawat'), findsOneWidget);
      expect(find.text('DP Hotel'), findsOneWidget);

      // FAB Button & Modal Test
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Pengeluaran'), findsOneWidget);
      expect(find.text('Simpan Pengeluaran'), findsOneWidget);
    },
  );
}
