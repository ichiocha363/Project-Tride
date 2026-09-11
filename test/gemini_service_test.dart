import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Services/gemini_service.dart';

void main() {
  group('GeminiService & AI Planner Core Audit Tests', () {
    test('1. Prompt formed from user input in Dev Mode and includes all user preferences', () async {
      String? capturedPrompt;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final contents = body['contents'] as List;
        final parts = contents.first['parts'] as List;
        capturedPrompt = parts.first['text'] as String;

        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'destination': 'Raja Ampat',
                      'duration': '4 Hari 3 Malam',
                      'styles': 'Nature & Petualangan',
                      'schedule': [
                        {
                          'day': 'Hari 1',
                          'title': 'Kedatangan di Sorong',
                          'activities': [
                            {
                              'time': '09:00 - 12:00',
                              'location': 'Pelabuhan Sorong',
                              'title': 'Penjemputan & Speedboat ke Piaynemo',
                              'description': 'Perjalanan laut menuju gugusan pulau karang',
                              'tips': 'Gunakan sunscreen dan jaket pelampung',
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

        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = GeminiService.custom(apiKey: 'test-api-key', client: mockClient);

      final result = await service.generateItinerary(
        destination: 'Raja Ampat',
        durationDays: 4,
        dates: '10 - 14 Okt 2026',
        companion: 'Grup',
        peopleCount: 4,
        hasChildren: true,
        hasElderly: false,
        styles: ['Nature', 'Petualangan'],
        budget: 'Mewah',
        budgetCeiling: 15000000,
        pace: 'Padat',
        accommodation: 'Resort / Homestay',
        specialNeeds: 'Sensitif mabuk laut',
      );

      expect(capturedPrompt, contains('Destinasi: Raja Ampat'));
      expect(capturedPrompt, contains('Durasi: 4 Hari'));
      expect(capturedPrompt, contains('Gaya Perjalanan: Nature, Petualangan'));
      expect(capturedPrompt, contains('Level Budget: Mewah'));
      expect(capturedPrompt, contains('Sensitif mabuk laut'));

      expect(result['destination'], equals('Raja Ampat'));
      expect(result['isAiGenerated'], isTrue);
      expect(result['generated_by'], equals('gemini'));
      expect(result['source'], contains('Google Gemini AI (gemini-2.5-flash)'));
    });

    test('2. Clean markdown code fences (```json ... ```) and parse structured JSON', () async {
      final mockClient = MockClient((request) async {
        final markdownResponse = '''
```json
{
  "destination": "Yogyakarta",
  "duration": "2 Hari 1 Malam",
  "styles": "Budaya",
  "schedule": [
    {
      "day": "Hari 1",
      "title": "Eksplorasi Malioboro & Keraton",
      "activities": [
        {
          "time": "09:00 - 11:30",
          "location": "Keraton Yogyakarta",
          "title": "Kunjungan Keraton",
          "description": "Mengenal budaya Jawa",
          "tips": "Patuhi tata krama"
        }
      ]
    },
    {
      "day": "Hari 2",
      "title": "Sunset Candi Ratu Boko",
      "activities": [
        {
          "time": "15:00 - 18:00",
          "location": "Candi Ratu Boko",
          "title": "Golden Hour Photo",
          "description": "Foto gerbang candi",
          "tips": "Bawa kamera"
        }
      ]
    }
  ]
}
```
''';

        final mockJson = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': markdownResponse}
                ]
              }
            }
          ]
        };

        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = GeminiService.custom(apiKey: 'test-api-key', client: mockClient);

      final result = await service.generateItinerary(
        destination: 'Yogyakarta',
        durationDays: 2,
        dates: '1 - 2 Nov 2026',
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

      expect(result['destination'], equals('Yogyakarta'));
      expect((result['schedule'] as List).length, equals(2));
      expect(result['schedule'][0]['title'], equals('Eksplorasi Malioboro & Keraton'));
      expect(result['schedule'][1]['title'], equals('Sunset Candi Ratu Boko'));
    });

    test('3. HTTP Error status codes throw GeminiException with Indonesian error messages (No Silent Fallback)', () async {
      final mockClient401 = MockClient((request) async => http.Response('Unauthorized', 401));
      final service401 = GeminiService.custom(apiKey: 'invalid-key', client: mockClient401);

      expect(
        () async => await service401.generateItinerary(
          destination: 'Bali',
          durationDays: 3,
          dates: '1 - 3 Des 2026',
          companion: 'Solo',
          peopleCount: 1,
          hasChildren: false,
          hasElderly: false,
          styles: ['Alam'],
          budget: 'Menengah',
          budgetCeiling: 5000000,
          pace: 'Seimbang',
          accommodation: 'Hotel',
        ),
        throwsA(isA<GeminiException>().having((e) => e.message, 'message', contains('401'))),
      );

      final mockClient429 = MockClient((request) async => http.Response('Rate Limit Exceeded', 429));
      final service429 = GeminiService.custom(apiKey: 'test-key', client: mockClient429);

      expect(
        () async => await service429.generateItinerary(
          destination: 'Bali',
          durationDays: 3,
          dates: '1 - 3 Des 2026',
          companion: 'Solo',
          peopleCount: 1,
          hasChildren: false,
          hasElderly: false,
          styles: ['Alam'],
          budget: 'Menengah',
          budgetCeiling: 5000000,
          pace: 'Seimbang',
          accommodation: 'Hotel',
        ),
        throwsA(isA<GeminiException>().having((e) => e.message, 'message', contains('429'))),
      );
    });

    test('4. Unconfigured / Empty API Key & Backend URL throws GeminiException in REST mode', () async {
      final service = GeminiService.custom(apiKey: '', backendUrl: '', useCallableFunction: false);

      expect(
        () async => await service.generateItinerary(
          destination: 'Bandung',
          durationDays: 2,
          dates: '1 - 2 Des 2026',
          companion: 'Solo',
          peopleCount: 1,
          hasChildren: false,
          hasElderly: false,
          styles: ['Kuliner'],
          budget: 'Hemat',
          budgetCeiling: 2000000,
          pace: 'Santai',
          accommodation: 'Hotel',
        ),
        throwsA(isA<GeminiException>()),
      );
    });

    test('5. Backend Proxy URL routes requests securely to server-side endpoint', () async {
      bool proxyCalled = false;
      final mockClient = MockClient((request) async {
        if (request.url.toString().startsWith('https://backend-proxy.example.com')) {
          proxyCalled = true;
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'destination': 'Bali',
                'duration': '3 Hari 2 Malam',
                'styles': 'Alam & Kuliner',
                'schedule': [
                  {
                    'day': 'Hari 1',
                    'title': 'Pantai Pandawa & Seafood Jimbaran',
                    'activities': [
                      {
                        'time': '16:00 - 19:00',
                        'location': 'Jimbaran',
                        'title': 'Makan Malam Seafood',
                        'description': 'Santap seafood segar di pinggir pantai',
                        'tips': 'Datang saat sunset',
                      }
                    ]
                  }
                ],
                'isAiGenerated': true,
                'generated_by': 'gemini',
                'source': 'Google Gemini AI (gemini-2.5-flash via Backend Proxy)',
              }
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = GeminiService.custom(
        backendUrl: 'https://backend-proxy.example.com',
        client: mockClient,
      );

      final result = await service.generateItinerary(
        destination: 'Bali',
        durationDays: 3,
        dates: '1 - 3 Nov 2026',
        companion: 'Pasangan',
        peopleCount: 2,
        hasChildren: false,
        hasElderly: false,
        styles: ['Alam', 'Kuliner'],
        budget: 'Menengah',
        budgetCeiling: 5000000,
        pace: 'Seimbang',
        accommodation: 'Hotel',
      );

      expect(proxyCalled, isTrue);
      expect(result['destination'], equals('Bali'));
      expect(result['source'], contains('Backend Proxy'));
    });

    test('6. Validation test for inputs A (Bali 3 Hari Alam+Kuliner), B (Yogyakarta 3 Hari Budaya), C (Raja Ampat 4 Hari Nature)', () async {
      final capturedDestinations = <String>[];

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final contents = body['contents'] as List;
        final prompt = contents.first['parts'].first['text'] as String;

        String dest = 'Unknown';
        if (prompt.contains('Destinasi: Bali')) dest = 'Bali';
        if (prompt.contains('Destinasi: Yogyakarta')) dest = 'Yogyakarta';
        if (prompt.contains('Destinasi: Raja Ampat')) dest = 'Raja Ampat';
        capturedDestinations.add(dest);

        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'destination': dest,
                        'duration': '3 Hari',
                        'styles': 'Custom',
                        'schedule': [
                          {
                            'day': 'Hari 1',
                            'title': 'Judul $dest',
                            'activities': [{'title': 'Aktivitas di $dest'}]
                          }
                        ]
                      })
                    }
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = GeminiService.custom(apiKey: 'test-key', client: mockClient);

      // Input A: Bali
      final resA = await service.generateItinerary(
        destination: 'Bali',
        durationDays: 3,
        dates: '1 - 3 Des 2026',
        companion: 'Pasangan',
        peopleCount: 2,
        hasChildren: false,
        hasElderly: false,
        styles: ['Alam', 'Kuliner'],
        budget: 'Menengah',
        budgetCeiling: 5000000,
        pace: 'Seimbang',
        accommodation: 'Resort',
      );

      // Input B: Yogyakarta
      final resB = await service.generateItinerary(
        destination: 'Yogyakarta',
        durationDays: 3,
        dates: '5 - 7 Des 2026',
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

      // Input C: Raja Ampat
      final resC = await service.generateItinerary(
        destination: 'Raja Ampat',
        durationDays: 4,
        dates: '10 - 13 Des 2026',
        companion: 'Grup',
        peopleCount: 4,
        hasChildren: false,
        hasElderly: false,
        styles: ['Nature'],
        budget: 'Mewah',
        budgetCeiling: 15000000,
        pace: 'Padat',
        accommodation: 'Resort',
      );

      expect(resA['destination'], equals('Bali'));
      expect(resB['destination'], equals('Yogyakarta'));
      expect(resC['destination'], equals('Raja Ampat'));
      expect(capturedDestinations, equals(['Bali', 'Yogyakarta', 'Raja Ampat']));
    });

    test('7. Gemini parsed itinerary integrates cleanly into TripModel.itineraryDays', () async {
      final mockResponse = {
        'destination': 'Bali',
        'duration': '2 Hari 1 Malam',
        'styles': 'Fotografi',
        'schedule': [
          {
            'day': 'Hari 1',
            'title': 'Arrival Ubud',
            'activities': [
              {
                'time': '10:00',
                'location': 'Tegalalang',
                'title': 'Rice Terrace Walk',
                'description': 'Walk around green rice paddies',
                'tips': 'Best photo at 10 AM',
              }
            ]
          }
        ]
      };

      final trip = TripModel(
        userId: 'user-gemini-test',
        tripName: 'Trip ke Bali',
        startDate: '2026-09-12',
        endDate: '2026-09-14',
        budget: 5000000,
        createdAt: DateTime.now().toIso8601String(),
        itineraryDays: List<Map<String, dynamic>>.from(
          (mockResponse['schedule'] as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        ),
      );

      expect(trip.itineraryDays, isNotNull);
      expect(trip.itineraryDays!.length, equals(1));
      expect(trip.itineraryDays![0]['day'], equals('Hari 1'));
      expect(trip.itineraryDays![0]['title'], equals('Arrival Ubud'));
      final acts = trip.itineraryDays![0]['activities'] as List;
      expect(acts.first['title'], equals('Rice Terrace Walk'));
      expect(acts.first['tips'], equals('Best photo at 10 AM'));

      final firestoreMap = trip.toFirestore();
      expect(firestoreMap['itinerary_days'], isNotNull);
      expect(firestoreMap['itinerary_days'][0]['day'], equals('Hari 1'));
    });
  });
}
