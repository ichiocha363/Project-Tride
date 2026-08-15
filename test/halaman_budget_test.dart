import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman budget/halaman_budget.dart';

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
      expect(find.text('Trips'), findsWidgets);
      expect(find.text('TRAVEL JOURNAL'), findsOneWidget);
      expect(find.text('Kyoto Getaway'), findsOneWidget);

      // Summary Card Details
      expect(find.text('TOTAL TRIP BUDGET'), findsOneWidget);
      expect(find.text('\$2,000'), findsOneWidget);
      expect(find.text('REMAINING'), findsOneWidget);
      expect(find.text('\$760'), findsOneWidget);

      // Category / Spending Highlights
      expect(find.text('Spending Highlights'), findsOneWidget);
      expect(find.text('Lodging'), findsWidgets);
      expect(find.text('Dining'), findsWidgets);
      expect(find.text('Transit'), findsWidgets);

      // Recent Memories
      expect(find.text('Recent Memories'), findsOneWidget);
      expect(find.text('Ichiran Ramen'), findsOneWidget);

      // FAB Button & Modal Test
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Pengeluaran'), findsOneWidget);
      expect(find.text('Simpan Pengeluaran'), findsOneWidget);
    },
  );
}
