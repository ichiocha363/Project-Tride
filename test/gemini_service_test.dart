import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_tride/Services/gemini_service.dart';

void main() {
  group('GeminiService Tests', () {
    test('generateItinerary parses valid Gemini API JSON response correctly', () async {
      final mockResponseJson = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'destination': 'Bali, Indonesia',
                    'duration': '3 Hari 2 Malam',
                    'styles': 'Fotografi & Alam',
                    'schedule': [
                      {
                        'day': 'Hari 1',
                        'title': 'Kedatangan di Kuta & Sunset Tanah Lot',
                        'activities': [
                          'Check in hotel di Kuta',
                          'Fotografi sunset di Tanah Lot',
                          'Makan malam seafood di Jimbaran'
                        ]
                      },
                      {
                        'day': 'Hari 2',
                        'title': 'Trekking Tegalalang & Kuliner Ubud',
                        'activities': [
                          'Sawah terasering Tegalalang',
                          'Makan siang Nasi Ayam Kedewatan',
                          'Relaksasi di Cafe Ubud'
                        ]
                      },
                      {
                        'day': 'Hari 3',
                        'title': 'Belanja Pasar Seni Ubud & Kepulangan',
                        'activities': [
                          'Belanja kerajinan Pasar Seni Ubud',
                          'Transfer ke Bandara Ngurah Rai'
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

      final mockClient = MockClient((request) async {
        expect(request.url.host, equals('generativelanguage.googleapis.com'));
        expect(request.url.path, contains('gemini-1.5-flash'));
        return http.Response(jsonEncode(mockResponseJson), 200);
      });

      final service = GeminiService.custom(client: mockClient);

      final result = await service.generateItinerary(
        destination: 'Bali, Indonesia',
        durationDays: 3,
        dates: '12 - 14 Sep 2026',
        companion: 'Pasangan',
        peopleCount: 2,
        hasChildren: false,
        hasElderly: false,
        styles: ['Fotografi', 'Alam'],
        budget: 'Menengah',
        budgetCeiling: 5000000,
        pace: 'Seimbang',
        accommodation: 'Hotel',
      );

      expect(result['destination'], equals('Bali, Indonesia'));
      expect(result['duration'], equals('3 Hari 2 Malam'));
      expect(result['styles'], equals('Fotografi & Alam'));
      expect((result['schedule'] as List).length, equals(3));
      expect(result['schedule'][0]['day'], equals('Hari 1'));
      expect(result['schedule'][0]['title'], equals('Kedatangan di Kuta & Sunset Tanah Lot'));
    });

    test('generateItinerary falls back gracefully on HTTP error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = GeminiService.custom(client: mockClient);

      final result = await service.generateItinerary(
        destination: 'Yogyakarta, Indonesia',
        durationDays: 2,
        dates: '1 - 2 Okt 2026',
        companion: 'Solo',
        peopleCount: 1,
        hasChildren: false,
        hasElderly: false,
        styles: ['Budaya'],
        budget: 'Hemat',
        budgetCeiling: 2000000,
        pace: 'Santai',
        accommodation: 'Homestay',
      );

      // Verify fallback response is structured and not null
      expect(result['destination'], equals('Yogyakarta, Indonesia'));
      expect(result['duration'], contains('2 Hari'));
      expect((result['schedule'] as List).length, equals(2));
      expect(result['schedule'][0]['day'], equals('Hari 1'));
    });
  });
}
