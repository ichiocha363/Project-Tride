import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_profil.dart';

void main() {
  testWidgets(
    'HalamanProfil renders all UI elements from Stitch design correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: HalamanProfil(user: user)));
      await tester.pumpAndSettle();

      // App bar Title
      expect(find.text('Tride'), findsOneWidget);

      // User Information
      expect(find.text('Andi Setiawan'), findsOneWidget);
      expect(find.text('andi@email.com'), findsOneWidget);

      // Traveler Level Badge & Progress
      expect(find.text('Explorer'), findsOneWidget);
      expect(find.text('Level 4'), findsOneWidget);
      expect(find.text('850 / 1200 pts to Globetrotter'), findsOneWidget);

      // Traveler Stats Card
      expect(find.text('Total Trips'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Destinations'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Saved Places'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);

      // Achievements Section
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('Frequent Flyer'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Nature Lover'), findsOneWidget);

      // Menu List
      expect(find.text('Perjalanan Saya'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help Center'), findsOneWidget);

      // Logout Button & Dialog Test
      final logoutFinder = find.text('Logout');
      expect(logoutFinder, findsOneWidget);
      await tester.ensureVisible(logoutFinder);
      await tester.pumpAndSettle();
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Logout'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        findsOneWidget,
      );
      expect(find.text('Batal'), findsOneWidget);
    },
  );
}
