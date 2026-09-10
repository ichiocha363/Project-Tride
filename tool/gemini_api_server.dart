import 'dart:convert';
import 'dart:io';
import 'package:project_tride/Services/gemini_service.dart';

/// Standalone Backend API Server untuk fitur "Buat Itinerary Saya" (Tride App).
/// 
/// Cara menjalankan:
///   dart run tool/gemini_api_server.dart [port]
///
/// Endpoint:
///   POST /api/generate-itinerary
///   Content-Type: application/json

void main(List<String> args) async {
  int port = 8080;

  // Baca port dari argumen atau environment variable
  if (args.isNotEmpty) {
    port = int.tryParse(args[0]) ?? 8080;
  } else if (Platform.environment.containsKey('PORT')) {
    port = int.tryParse(Platform.environment['PORT']!) ?? 8080;
  }

  HttpServer? server;
  int attempts = 0;

  // Cari port yang tersedia jika 8080 sedang digunakan
  while (server == null && attempts < 5) {
    try {
      server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    } on SocketException catch (_) {
      port++;
      attempts++;
    }
  }

  if (server == null) {
    print('❌ Gagal menjalankan server: Port 8080-8085 sedang digunakan.');
    print('   Silakan tutup proses yang sedang menggunakan port tersebut atau tentukan port lain.');
    exit(1);
  }

  print('==================================================');
  print('🚀 Tride Gemini Backend API Server running on:');
  print('   http://localhost:$port/api/generate-itinerary');
  print('   API Key: ${GeminiService.defaultApiKey.substring(0, 10)}...');
  print('==================================================');

  await for (HttpRequest request in server) {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;

    if (path == '/api/generate-itinerary' && request.method == 'POST') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final Map<String, dynamic> body = jsonDecode(content);

        final destination = body['destination']?.toString() ?? 'Bali, Indonesia';
        final durationDays = int.tryParse(body['durationDays']?.toString() ?? '') ?? 3;
        final dates = body['dates']?.toString() ?? '15 - 17 Sep 2026';
        final companion = body['companion']?.toString() ?? 'Solo';
        final peopleCount = int.tryParse(body['peopleCount']?.toString() ?? '') ?? 1;
        final hasChildren = body['hasChildren'] == true;
        final hasElderly = body['hasElderly'] == true;
        final styles = body['styles'] is List
            ? List<String>.from((body['styles'] as List).map((e) => e.toString()))
            : ['Fotografi', 'Alam'];
        final budget = body['budget']?.toString() ?? 'Menengah';
        final budgetCeiling = int.tryParse(body['budgetCeiling']?.toString() ?? '') ?? 7500000;
        final pace = body['pace']?.toString() ?? 'Seimbang';
        final accommodation = body['accommodation']?.toString() ?? 'Hotel';
        final specialNeeds = body['specialNeeds']?.toString();

        print('📩 Incoming request for itinerary: $destination ($durationDays Hari)');

        final result = await GeminiService.instance.generateItinerary(
          destination: destination,
          durationDays: durationDays,
          dates: dates,
          companion: companion,
          peopleCount: peopleCount,
          hasChildren: hasChildren,
          hasElderly: hasElderly,
          styles: styles,
          budget: budget,
          budgetCeiling: budgetCeiling,
          pace: pace,
          accommodation: accommodation,
          specialNeeds: specialNeeds,
        );

        request.response.headers.contentType = ContentType.json;
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({
          'status': 'success',
          'data': result,
        }));
      } catch (e) {
        request.response.headers.contentType = ContentType.json;
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({
          'status': 'error',
          'message': 'Gagal memproses request: ${e.toString()}',
        }));
      }
    } else if (path == '/health') {
      request.response.headers.contentType = ContentType.json;
      request.response.statusCode = HttpStatus.ok;
      request.response.write(jsonEncode({'status': 'healthy', 'service': 'Tride Gemini API'}));
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Endpoint not found');
    }

    await request.response.close();
  }
}
