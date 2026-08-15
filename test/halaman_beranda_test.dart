import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman beranda/halaman_beranda.dart';

void main() {
  testWidgets('HalamanBeranda renders all sections correctly',
      (WidgetTester tester) async {
    final user = UserModel(
      id: 1,
      nama: 'Andi',
      email: 'andi@example.com',
      password: 'password123',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HalamanBeranda(user: user),
      ),
    );

    // Verify Header & Greeting
    expect(find.text('Tride'), findsOneWidget);
    expect(find.text('Halo, Andi 👋'), findsOneWidget);
    expect(find.text('Siap menjelajah hari ini?'), findsOneWidget);

    // Verify Search Hint
    expect(find.text('Mau pergi ke mana?'), findsOneWidget);

    // Verify Section Titles
    expect(find.text('Perjalanan Mendatang'), findsOneWidget);
    expect(find.text('Kategori Populer'), findsOneWidget);
    expect(find.text('Rekomendasi Spesial'), findsOneWidget);
    expect(find.text('Inspirasi Liburan'), findsOneWidget);

    // Verify Nav Dock Labels
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Jelajah'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
