import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman profile/halaman_profil.dart';

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
      await tester.pump(const Duration(milliseconds: 500));

      // App bar Title Badge
      expect(find.text('Tride'), findsOneWidget);

      // User Information
      expect(find.text('Andi Setiawan'), findsOneWidget);
      expect(find.text('andi@email.com'), findsOneWidget);

      // Explorer Subtitle
      expect(find.text('Explorer Level 4'), findsOneWidget);
      expect(find.text("Member '21"), findsOneWidget);

      // Airy Traveler Stats Row
      expect(find.text('14'), findsOneWidget);
      expect(find.text('TRIPS'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('COUNTRIES'), findsOneWidget);
      expect(find.text('24k'), findsOneWidget);
      expect(find.text('MILES'), findsOneWidget);

      // Journey Highlights Section & Milestones
      expect(find.text('Journey Highlights'), findsOneWidget);
      expect(find.text('First Solo Trip'), findsOneWidget);
      expect(find.text('Patagonia, Argentina • Oct 2022'), findsOneWidget);
      expect(find.text('Eco Traveler Certified'), findsOneWidget);
      expect(find.text('Offset 10,000 miles • Mar 2023'), findsOneWidget);
      expect(find.text('Peak Bagger'), findsOneWidget);
      expect(find.text('Mt. Fuji Summit • Aug 2023'), findsOneWidget);

      // Preferences Section Menu
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);

      // Logout / Sign Out Button & Dialog Test
      final logoutFinder = find.text('SIGN OUT');
      expect(logoutFinder, findsOneWidget);
      await tester.ensureVisible(logoutFinder);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(logoutFinder);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Konfirmasi Logout'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin keluar dari aplikasi Tride?'),
        findsOneWidget,
      );
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
    },
  );
}
