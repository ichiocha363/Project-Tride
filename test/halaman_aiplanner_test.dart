import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/gemini_service.dart';
import 'package:project_tride/Views/halaman Ai Planner/halaman_aiplanner_step1.dart';
import 'package:project_tride/Views/halaman Ai Planner/halaman_aiplanner_step2.dart' as step2;
import 'package:project_tride/Views/halaman Ai Planner/halaman_aiplanner_step3.dart' as step3;
import 'package:project_tride/Views/halaman Ai Planner/halaman_aiplanner_step4.dart' as step4;

class TestHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    final mockClient = MockClient((request) async {
      final mockJson = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'destination': 'Lombok, Indonesia',
                    'duration': '5 Hari 4 Malam',
                    'styles': 'Photography & Nature',
                    'schedule': [
                      {
                        'day': 'Hari 1',
                        'title': 'Eksplorasi Pantai Kuta Lombok',
                        'activities': [
                          {
                            'time': '09:00 - 12:00',
                            'location': 'Pantai Kuta Lombok',
                            'title': 'Wisata Pantai & Foto Air Jernih',
                            'description': 'Menikmati keindahan pasir merica',
                            'tips': 'Sewa papan surfing'
                          }
                        ]
                      }
                    ]
                  })
                }
              ]
            }
          }
        ]
      };
      return http.Response(jsonEncode(mockJson), 200);
    });
    GeminiService.instance = GeminiService.custom(apiKey: 'mock-test-key', client: mockClient);
  });

  testWidgets(
    'HalamanAiPlanner renders all UI elements from Stitch design Step 1 correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: HalamanAiPlanner(user: user)));
      await tester.pump(const Duration(milliseconds: 500));

      // App Bar title
      expect(find.text('Home'), findsOneWidget);

      // Step & Header text
      expect(find.text('STEP 1 OF 4'), findsOneWidget);
      expect(find.text('Mau liburan ke mana?'), findsOneWidget);
      expect(
        find.text(
          'Kasih tahu aku rencana dasarnya, sisanya biar aku yang bantu susun.',
        ),
        findsOneWidget,
      );

      // Input field & AI chip
      expect(find.text('Cari destinasi...'), findsOneWidget);
      expect(
        find.text('Belum tahu tujuannya? Kasih rekomendasi'),
        findsOneWidget,
      );

      // Date cards
      expect(find.text('BERANGKAT'), findsOneWidget);
      expect(find.text('PULANG'), findsOneWidget);
      expect(find.text('Tanggal masih fleksibel'), findsOneWidget);

      // Companion choices
      expect(find.text('Siapa yang ikut?'), findsOneWidget);
      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Pasangan'), findsOneWidget);
      expect(find.text('Keluarga'), findsOneWidget);
      expect(find.text('Grup'), findsOneWidget);

      // Continue Button
      expect(find.text('Lanjut'), findsOneWidget);
    },
  );

  testWidgets(
    'HalamanAiPlanner Step 2 renders all UI elements from Stitch design correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: step2.HalamanAiPlanner(user: user)));
      await tester.pump(const Duration(milliseconds: 500));

      // App Bar title
      expect(find.text('Explore'), findsOneWidget);

      // Step & Header text
      expect(find.text('STEP 2 OF 4'), findsOneWidget);
      expect(find.text('Gaya liburan kamu yang mana?'), findsOneWidget);
      expect(
        find.text(
          'Pilih vibe yang paling bikin kamu excited, nanti itinerary-nya aku sesuaikan.',
        ),
        findsOneWidget,
      );

      // 2x2 Grid Style choices
      expect(find.text('Fotografi'), findsOneWidget);
      expect(find.text('Kuliner'), findsOneWidget);
      expect(find.text('Alam'), findsOneWidget);
      expect(find.text('Petualangan'), findsOneWidget);

      // Continue Button
      expect(find.text('Lanjut'), findsOneWidget);
    },
  );

  testWidgets(
    'HalamanAiPlanner Step 3 renders all UI elements from Stitch design correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: step3.HalamanAiPlanner(user: user)));
      await tester.pump(const Duration(milliseconds: 500));

      // Step & Header text
      expect(find.text('STEP 3 OF 4'), findsOneWidget);
      expect(find.text('Berapa budget dan ritme perjalanannya?'), findsOneWidget);
      expect(
        find.text(
          'Ini bantu aku nyusun itinerary yang pas sama gaya kamu.',
        ),
        findsOneWidget,
      );

      // Budget levels
      expect(find.text('Level Budget'), findsOneWidget);
      expect(find.text('Hemat'), findsOneWidget);
      expect(find.text('Menengah'), findsOneWidget);
      expect(find.text('Mewah'), findsOneWidget);

      // Pace levels
      expect(find.text('Ritme Perjalanan'), findsOneWidget);
      expect(find.text('Santai'), findsOneWidget);
      expect(find.text('Seimbang'), findsOneWidget);
      expect(find.text('Padat'), findsOneWidget);

      // Accommodations
      expect(find.text('Preferensi Akomodasi'), findsOneWidget);
      expect(find.text('Pilih 1+'), findsOneWidget);
      expect(find.text('Hotel'), findsOneWidget);
      expect(find.text('Hostel'), findsOneWidget);
      expect(find.text('Homestay'), findsOneWidget);
      expect(find.text('Villa'), findsOneWidget);

      // Continue Button
      expect(find.text('Lanjut'), findsOneWidget);
    },
  );

  testWidgets(
    'HalamanAiPlanner Step 4 renders all UI elements from Stitch design correctly',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await tester.pumpWidget(MaterialApp(home: step4.HalamanAiPlanner(user: user)));
      await tester.pump(const Duration(milliseconds: 500));

      // Header text
      expect(find.text('STEP 4 OF 4'), findsOneWidget);
      expect(find.text('Tambahkan detail'), findsOneWidget);
      expect(
        find.text(
          'Ada kebutuhan khusus? Lalu cek lagi sebelum aku buatkan itinerary-nya.',
        ),
        findsOneWidget,
      );

      // Kebutuhan khusus section
      expect(find.text('Kebutuhan khusus (opsional)'), findsOneWidget);

      // Ringkasan Perjalanan card
      expect(find.text('Ringkasan Perjalanan'), findsOneWidget);
      expect(find.text('Destinasi'), findsOneWidget);
      expect(find.text('Bali, Indonesia'), findsOneWidget);
      expect(find.text('Tanggal'), findsOneWidget);
      expect(find.text('Gaya Perjalanan'), findsOneWidget);
      expect(find.text('Photography'), findsOneWidget);
      expect(find.text('Nature'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Menengah'), findsOneWidget);
      expect(find.text('Pace'), findsOneWidget);
      expect(find.text('Seimbang'), findsOneWidget);
      expect(find.text('Akomodasi'), findsOneWidget);
      expect(find.text('Hotel (Utama)'), findsOneWidget);

      // Action Button
      expect(find.text('Buat Itinerary Saya'), findsOneWidget);
    },
  );

  testWidgets(
    'AI Planner flow connects Step 1 to Step 4 and generates result',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      // Start at Step 1
      await tester.pumpWidget(MaterialApp(home: HalamanAiPlanner(user: user)));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter destination
      await tester.enterText(find.byType(TextField).first, 'Lombok, Indonesia');
      await tester.pump();

      // Scroll down to tap Lanjut in Step 1
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut').first);
      await tester.pumpAndSettle();

      // We should be in Step 2 now
      expect(find.text('STEP 2 OF 4'), findsOneWidget);
      expect(find.text('Gaya liburan kamu yang mana?'), findsOneWidget);

      // Scroll down to tap Lanjut in Step 2
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut').first);
      await tester.pumpAndSettle();

      // We should be in Step 3 now
      expect(find.text('STEP 3 OF 4'), findsOneWidget);
      expect(find.text('Berapa budget dan ritme perjalanannya?'), findsOneWidget);

      // Scroll down to tap Lanjut in Step 3
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut').first);
      await tester.pumpAndSettle();

      // We should be in Step 4 now
      expect(find.text('STEP 4 OF 4'), findsOneWidget);
      expect(find.text('Tambahkan detail'), findsOneWidget);
      expect(find.text('Lombok, Indonesia'), findsOneWidget);

      // Scroll down & Click "Buat Itinerary Saya" in Step 4
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Itinerary Saya').first);
      await tester.pump(); // Start loading
      await tester.pump(const Duration(seconds: 1)); // Wait for AI generation
      await tester.pumpAndSettle(); // Settle bottom sheet

      // Verify AI Generated Itinerary bottom sheet result is displayed!
      expect(find.textContaining('Itinerary'), findsAtLeastNWidgets(1));
      expect(find.text('Simpan Rencana Perjalanan'), findsOneWidget);
    },
  );
}
