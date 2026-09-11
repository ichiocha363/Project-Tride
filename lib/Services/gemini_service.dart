import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Exception khusus untuk penanganan error pada Gemini Service
class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}

/// Service backend untuk menghasilkan rekomendasi itinerary perjalanan
/// menggunakan Google Gemini AI API (model resmi: gemini-2.5-flash via Firebase Cloud Functions).
class GeminiService {
  final http.Client? _injectedClient;
  final FirebaseFunctions? _injectedFunctions;
  String _apiKey;
  String _backendUrl;
  bool? _useCallableFunctionOverride;

  /// Default API Key dari environment variable (--dart-define=GEMINI_API_KEY=xxx)
  static const String envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Default Backend Proxy URL dari environment variable (--dart-define=GEMINI_BACKEND_URL=https://...)
  static const String envBackendUrl = String.fromEnvironment('GEMINI_BACKEND_URL');

  /// Timeout durasi request Gemini API (25 detik untuk perangkat mobile)
  static const Duration requestTimeout = Duration(seconds: 25);

  /// Model resmi aktif yang didukung Google Gemini API
  static const String activeModel = 'gemini-2.5-flash';

  /// Region Cloud Function (Singapore untuk latency terendah Indonesia)
  static const String functionsRegion = 'asia-southeast1';

  GeminiService._internal({
    String? apiKey,
    String? backendUrl,
    http.Client? client,
    FirebaseFunctions? functions,
    bool? useCallableFunction,
  })  : _apiKey = _resolveApiKey(apiKey),
        _backendUrl = _resolveBackendUrl(backendUrl),
        _injectedClient = client,
        _injectedFunctions = functions,
        _useCallableFunctionOverride = useCallableFunction;

  static String _resolveApiKey(String? providedKey) {
    if (providedKey != null && providedKey.trim().isNotEmpty) {
      return providedKey.trim();
    }
    if (envApiKey.isNotEmpty) {
      return envApiKey;
    }
    try {
      final sysEnvKey = Platform.environment['GEMINI_API_KEY'];
      if (sysEnvKey != null && sysEnvKey.trim().isNotEmpty) {
        return sysEnvKey.trim();
      }
    } catch (_) {}
    return '';
  }

  static String _resolveBackendUrl(String? providedUrl) {
    if (providedUrl != null && providedUrl.trim().isNotEmpty) {
      return providedUrl.trim();
    }
    if (envBackendUrl.isNotEmpty) {
      return envBackendUrl;
    }
    try {
      final sysUrl = Platform.environment['GEMINI_BACKEND_URL'];
      if (sysUrl != null && sysUrl.trim().isNotEmpty) {
        return sysUrl.trim();
      }
    } catch (_) {}
    return '';
  }

  /// Override API Key saat runtime (Hanya untuk Development/Testing)
  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  /// Override Backend Proxy URL saat runtime
  void setBackendUrl(String url) {
    _backendUrl = url.trim();
  }

  /// Set mode callable function
  void setUseCallableFunction(bool useCallable) {
    _useCallableFunctionOverride = useCallable;
  }

  String get currentApiKey => _apiKey;
  String get currentBackendUrl => _backendUrl;

  /// Singleton instance utama
  static GeminiService instance = GeminiService._internal();

  /// Factory constructor untuk pengujian (dependency injection)
  factory GeminiService.custom({
    String? apiKey,
    String? backendUrl,
    http.Client? client,
    FirebaseFunctions? functions,
    bool? useCallableFunction,
  }) {
    return GeminiService._internal(
      apiKey: apiKey,
      backendUrl: backendUrl,
      client: client,
      functions: functions,
      useCallableFunction: useCallableFunction,
    );
  }

  /// Membangun prompt terstruktur untuk Gemini AI (digunakan di Direct Dev Mode)
  String _buildPrompt({
    required String destination,
    required int durationDays,
    required String dates,
    required String companion,
    required int peopleCount,
    required bool hasChildren,
    required bool hasElderly,
    required List<String> styles,
    required String budget,
    required int budgetCeiling,
    required String pace,
    required String accommodation,
    String? specialNeeds,
  }) {
    final stylesText = styles.join(', ');
    final companionDetails = [];
    companionDetails.add(companion);
    if (peopleCount > 1) companionDetails.add('$peopleCount orang');
    if (hasChildren) companionDetails.add('ada anak-anak');
    if (hasElderly) companionDetails.add('ada lansia');
    final companionText = companionDetails.join(' (');

    final String budgetStr = budgetCeiling > 0
        ? 'Rp ${budgetCeiling.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Sesuai level $budget';

    return '''Anda adalah Tride AI Itinerary Planner, pakar perencana perjalanan wisata profesional terkemuka di Indonesia.
Buatkan rencana perjalanan (itinerary) yang sangat spesifik, terperinci, realistis, dan informatif dalam format JSON murni.

PARAMETER PERJALANAN:
- Destinasi: $destination
- Durasi: $durationDays Hari (${durationDays - 1 > 0 ? durationDays - 1 : 1} Malam)
- Rentang Tanggal: $dates
- Pendamping: $companionText${companionDetails.length > 1 ? ')' : ''}
- Gaya Perjalanan: $stylesText
- Level Budget: $budget (Pagu: $budgetStr)
- Ritme Perjalanan: $pace
- Preferensi Akomodasi: $accommodation
${specialNeeds != null && specialNeeds.trim().isNotEmpty ? '- Catatan Khusus / Kebutuhan Tambahan: ${specialNeeds.trim()}' : ''}

PETUNJUK OUTPUT WAJIB:
Respond HANYA dengan JSON valid (TANPA kode markdown ```json, TANPA teks tambahan di luar JSON).

Wajib sertakan nama tempat/destinasi yang nyata dan spesifik di $destination, waktu kegiatan, deskripsi kegiatan yang detail, serta tips/rekomendasi biaya/spot foto.

Struktur JSON wajib:
{
  "destination": "$destination",
  "duration": "$durationDays Hari ${durationDays - 1 > 0 ? durationDays - 1 : 1} Malam",
  "styles": "${styles.join(' & ')}",
  "schedule": [
    {
      "day": "Hari 1",
      "title": "Judul Tema Hari 1 (contoh: Eksplorasi Ikonik Danau & Kawah)",
      "activities": [
        {
          "time": "09:00 - 11:30",
          "location": "Nama Tempat / Destinasi Spesifik di $destination",
          "title": "Judul Aktivitas Utama",
          "description": "Penjelasan detail kegiatan yang dilakukan di lokasi ini.",
          "tips": "Tips kunjungan, estimasi budget, atau spot foto."
        }
      ]
    }
  ]
}

Pastikan list "schedule" mencakup tepat $durationDays elemen (Hari 1 hingga Hari $durationDays). Setiap hari berisi 3-5 kegiatan terperinci dengan nama tempat asli di $destination.''';
  }

  /// Menghasilkan itinerary perjalanan berbasis Gemini AI.
  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int durationDays,
    required String dates,
    required String companion,
    required int peopleCount,
    required bool hasChildren,
    required bool hasElderly,
    required List<String> styles,
    required String budget,
    required int budgetCeiling,
    required String pace,
    required String accommodation,
    String? specialNeeds,
    bool allowFallback = false,
    http.Client? client,
  }) async {
    // Tentukan mode eksekusi:
    // Jika _useCallableFunctionOverride true -> Callable Function Mode
    // Jika injectedClient / custom client supplied di test -> Direct / HTTP Test Mode
    // Jika _apiKey non-empty & callable function tidak dipaksa -> Dev Direct REST Mode
    // Default Production -> Firebase Callable Cloud Function Mode
    final bool useCallable = _useCallableFunctionOverride ??
        (_injectedClient == null && client == null && _apiKey.isEmpty);

    debugPrint('=== GEMINI REQUEST ===');
    debugPrint('destination = $destination');
    debugPrint('duration = $durationDays Hari');
    debugPrint('budget = $budget (Pagu: $budgetCeiling)');
    debugPrint('travelStyle = ${styles.join(', ')}');
    debugPrint('mode = ${useCallable ? 'Firebase Callable Cloud Function' : (_backendUrl.isNotEmpty ? 'HTTP Backend Proxy' : 'Direct Gemini REST API')}');

    if (useCallable) {
      return await _generateViaCallableFunction(
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
    }

    if (_backendUrl.isEmpty && _apiKey.isEmpty && !allowFallback) {
      throw GeminiException(
        'API Key / Backend Gemini belum dikonfigurasi. Di Production, Gemini diproses secara otomatis via Firebase Callable Function.',
      );
    }

    final httpClient = client ?? _injectedClient ?? http.Client();
    final bool shouldCloseClient = client == null && _injectedClient == null;

    final promptText = _buildPrompt(
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

    String? lastErrorMsg;

    try {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          http.Response response;

          if (_backendUrl.isNotEmpty) {
            final proxyUri = _backendUrl.contains('/api/')
                ? Uri.parse(_backendUrl)
                : Uri.parse('$_backendUrl/api/generate-itinerary');

            debugPrint('[GeminiService] Mengirim request ke Backend Proxy ($proxyUri) [Percobaan $attempt]...');

            final proxyPayload = jsonEncode({
              'destination': destination,
              'durationDays': durationDays,
              'dates': dates,
              'companion': companion,
              'peopleCount': peopleCount,
              'hasChildren': hasChildren,
              'hasElderly': hasElderly,
              'styles': styles,
              'budget': budget,
              'budgetCeiling': budgetCeiling,
              'pace': pace,
              'accommodation': accommodation,
              'specialNeeds': specialNeeds,
            });

            response = await httpClient.post(
              proxyUri,
              headers: {'Content-Type': 'application/json'},
              body: proxyPayload,
            ).timeout(requestTimeout);

            if (response.statusCode == 200) {
              final Map<String, dynamic> proxyJson = jsonDecode(response.body);
              if (proxyJson['status'] == 'success' && proxyJson['data'] is Map<String, dynamic>) {
                return Map<String, dynamic>.from(proxyJson['data'] as Map);
              }
              final dynamic directData = proxyJson['data'] ?? proxyJson;
              if (directData is Map<String, dynamic> && directData.containsKey('schedule')) {
                return _validateAndFormatItinerary(
                  directData,
                  destination: destination,
                  durationDays: durationDays,
                  styles: styles,
                  sourceText: 'Google Gemini AI ($activeModel via Backend Proxy)',
                );
              }
            }
          } else {
            final uri = Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=$_apiKey');

            debugPrint('[GeminiService] Mengirim request ke Direct Gemini API ($activeModel) [Percobaan $attempt]...');

            final requestBody = jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': promptText}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'responseMimeType': 'application/json',
              }
            });

            response = await httpClient.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            ).timeout(requestTimeout);

            debugPrint('=== GEMINI RESPONSE ===');
            debugPrint('status = ${response.statusCode}');

            if (response.statusCode == 200) {
              final Map<String, dynamic> responseJson = jsonDecode(response.body);
              final candidates = responseJson['candidates'] as List?;

              if (candidates != null && candidates.isNotEmpty) {
                final firstCandidate = candidates.first as Map<String, dynamic>;
                final content = firstCandidate['content'] as Map<String, dynamic>?;
                final parts = content?['parts'] as List?;

                if (parts != null && parts.isNotEmpty) {
                  String rawText = (parts.first as Map<String, dynamic>)['text'] ?? '';
                  rawText = rawText
                      .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
                      .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
                      .trim();

                  final dynamic parsedItinerary = jsonDecode(rawText);
                  if (parsedItinerary is Map<String, dynamic> &&
                      parsedItinerary.containsKey('schedule')) {
                    debugPrint('[GeminiService] Sukses menghasilkan itinerary terstruktur via $activeModel!');
                    return _validateAndFormatItinerary(
                      parsedItinerary,
                      destination: destination,
                      durationDays: durationDays,
                      styles: styles,
                      sourceText: 'Google Gemini AI ($activeModel)',
                    );
                  }
                }
              }
              lastErrorMsg = 'Format respon Gemini AI tidak valid atau tidak memiliki daftar jadwal.';
            }
          }

          if (response.statusCode == 400) {
            lastErrorMsg = 'Request ke Gemini AI tidak valid (HTTP 400). Mohon periksa kembali input perjalanan.';
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            lastErrorMsg = 'Akses Gemini AI ditolak (HTTP ${response.statusCode}). API key tidak valid atau tidak diizinkan.';
          } else if (response.statusCode == 429) {
            lastErrorMsg = 'Batas kuota penggunaan (rate limit/quota) Gemini AI terlampaui (HTTP 429). Silakan coba beberapa saat lagi.';
          } else if (response.statusCode >= 500) {
            lastErrorMsg = 'Layanan Gemini AI sedang mengalami masalah server (HTTP ${response.statusCode}). Silakan coba lagi nanti.';
          } else {
            lastErrorMsg = 'Gemini API Error (HTTP ${response.statusCode}).';
          }
        } catch (err) {
          if (err is GeminiException) rethrow;
          lastErrorMsg = 'Koneksi ke Gemini AI terganggu atau timeout: $err';
          debugPrint('[GeminiService] Percobaan $attempt error: $lastErrorMsg');
        }

        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }

    if (allowFallback) {
      debugPrint('[GeminiService] Menggunakan fallback local itinerary generator untuk $destination.');
      return _generateFallbackItinerary(
        destination: destination,
        durationDays: durationDays,
        styles: styles,
        budget: budget,
        pace: pace,
        accommodation: accommodation,
      );
    }

    throw GeminiException(lastErrorMsg ?? 'Gagal membuat itinerary AI. Silakan coba lagi.');
  }

  /// Eksekusi via Firebase Callable Cloud Function (Production Mode)
  Future<Map<String, dynamic>> _generateViaCallableFunction({
    required String destination,
    required int durationDays,
    required String dates,
    required String companion,
    required int peopleCount,
    required bool hasChildren,
    required bool hasElderly,
    required List<String> styles,
    required String budget,
    required int budgetCeiling,
    required String pace,
    required String accommodation,
    String? specialNeeds,
  }) async {
    try {
      final functions = _injectedFunctions ?? FirebaseFunctions.instanceFor(region: functionsRegion);
      final callable = functions.httpsCallable('generateItinerary');

      final HttpsCallableResult result = await callable.call({
        'destination': destination,
        'durationDays': durationDays,
        'dates': dates,
        'companion': companion,
        'peopleCount': peopleCount,
        'hasChildren': hasChildren,
        'hasElderly': hasElderly,
        'styles': styles,
        'budget': budget,
        'budgetCeiling': budgetCeiling,
        'pace': pace,
        'accommodation': accommodation,
        'specialNeeds': specialNeeds,
      }).timeout(requestTimeout);

      final dynamic data = result.data;
      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        if (mapData['status'] == 'success' && mapData['data'] is Map) {
          return _validateAndFormatItinerary(
            Map<String, dynamic>.from(mapData['data'] as Map),
            destination: destination,
            durationDays: durationDays,
            styles: styles,
            sourceText: 'Google Gemini AI ($activeModel via Firebase Cloud Functions)',
          );
        }
        if (mapData.containsKey('schedule')) {
          return _validateAndFormatItinerary(
            mapData,
            destination: destination,
            durationDays: durationDays,
            styles: styles,
            sourceText: 'Google Gemini AI ($activeModel via Firebase Cloud Functions)',
          );
        }
      }
      throw GeminiException('Respon dari server Gemini AI Planner tidak sesuai format expected.');
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[GeminiService] FirebaseFunctionsException: ${e.code} - ${e.message}');
      String userMsg;
      switch (e.code) {
        case 'unauthenticated':
          userMsg = 'Silakan login terlebih dahulu untuk menggunakan Gemini AI Planner.';
          break;
        case 'invalid-argument':
          userMsg = e.message ?? 'Input parameter perjalanan tidak valid.';
          break;
        case 'resource-exhausted':
          userMsg = 'Batas kuota penggunaan Gemini AI terlampaui. Silakan coba beberapa saat lagi.';
          break;
        case 'unavailable':
          userMsg = 'Layanan server Gemini AI sedang tidak dapat dijangkau. Coba lagi nanti.';
          break;
        case 'permission-denied':
          userMsg = 'Akses ke Gemini AI ditolak oleh server.';
          break;
        default:
          userMsg = e.message ?? 'Gagal memproses rekomendasi AI via server.';
      }
      throw GeminiException(userMsg);
    } catch (e) {
      if (e is GeminiException) rethrow;
      debugPrint('[GeminiService] Callable error: $e');
      throw GeminiException('Koneksi ke server Gemini AI terganggu: ${e.toString()}');
    }
  }

  /// Memvalidasi & memformat response agar sesuai skema UI Tride yang kaya detail
  Map<String, dynamic> _validateAndFormatItinerary(
    Map<String, dynamic> parsed, {
    required String destination,
    required int durationDays,
    required List<String> styles,
    String? sourceText,
  }) {
    final stylesText = styles.join(' & ');
    final String durationText =
        parsed['duration']?.toString() ?? '$durationDays Hari ${durationDays - 1 > 0 ? durationDays - 1 : 1} Malam';
    final List rawSchedule = parsed['schedule'] is List ? parsed['schedule'] as List : [];

    final List<Map<String, dynamic>> formattedSchedule = [];
    for (int i = 0; i < durationDays; i++) {
      final dayNumber = i + 1;
      if (i < rawSchedule.length && rawSchedule[i] is Map) {
        final item = Map<String, dynamic>.from(rawSchedule[i] as Map);
        final rawActivities = item['activities'] is List ? item['activities'] as List : [];

        final List<Map<String, dynamic>> formattedActivities = [];

        for (int aIdx = 0; aIdx < rawActivities.length; aIdx++) {
          final act = rawActivities[aIdx];
          if (act is Map) {
            final actMap = Map<String, dynamic>.from(act);
            formattedActivities.add({
              'time': actMap['time']?.toString() ?? _defaultTimeSlot(aIdx),
              'location': actMap['location']?.toString() ?? destination,
              'title': actMap['title']?.toString() ?? actMap['description']?.toString() ?? 'Aktivitas ${aIdx + 1}',
              'description': actMap['description']?.toString() ?? actMap['title']?.toString() ?? 'Eksplorasi spot populer',
              'tips': actMap['tips']?.toString(),
            });
          } else {
            final actStr = act.toString();
            formattedActivities.add({
              'time': _defaultTimeSlot(aIdx),
              'location': destination,
              'title': actStr,
              'description': actStr,
              'tips': null,
            });
          }
        }

        formattedSchedule.add({
          'day': item['day']?.toString() ?? 'Hari $dayNumber',
          'title': item['title']?.toString() ?? 'Eksplorasi Hari $dayNumber',
          'activities': formattedActivities.isNotEmpty
              ? formattedActivities
              : [_createFallbackActivity(1, destination)],
        });
      } else {
        formattedSchedule.add(_createFallbackDay(dayNumber, destination, stylesText));
      }
    }

    return {
      'destination': parsed['destination']?.toString() ?? destination,
      'duration': durationText,
      'styles': parsed['styles']?.toString() ?? stylesText,
      'schedule': formattedSchedule,
      'isAiGenerated': true,
      'generated_by': 'gemini',
      'source': sourceText ?? 'Google Gemini AI ($activeModel)',
    };
  }

  String _defaultTimeSlot(int index) {
    final slots = ['08:30 - 11:00', '11:30 - 14:00', '15:00 - 18:00', '19:00 - 21:00'];
    if (index < slots.length) return slots[index];
    return 'Flexi Time';
  }

  /// Fallback local generator (Development ONLY jika allowFallback == true)
  Map<String, dynamic> _generateFallbackItinerary({
    required String destination,
    required int durationDays,
    required List<String> styles,
    required String budget,
    required String pace,
    required String accommodation,
  }) {
    final stylesText = styles.join(' & ');
    final List<Map<String, dynamic>> schedule = [];

    for (int day = 1; day <= durationDays; day++) {
      schedule.add(_createFallbackDay(day, destination, stylesText, budget: budget, pace: pace, accommodation: accommodation));
    }

    return {
      'destination': destination,
      'duration': '$durationDays Hari ${durationDays - 1 > 0 ? durationDays - 1 : 1} Malam',
      'styles': stylesText,
      'schedule': schedule,
      'isAiGenerated': false,
      'source': 'Katalog Template Tride',
    };
  }

  Map<String, dynamic> _createFallbackDay(
    int day,
    String destination,
    String stylesText, {
    String budget = 'Menengah',
    String pace = 'Seimbang',
    String accommodation = 'Hotel',
  }) {
    final lowerDest = destination.toLowerCase();

    if (lowerDest.contains('ciwidey') || lowerDest.contains('kawah putih') || lowerDest.contains('bandung')) {
      if (day == 1) {
        return {
          'day': 'Hari 1',
          'title': 'Eksplorasi Ikonik Ciwidey & Danau Kawah',
          'activities': [
            {
              'time': '08:00 - 11:30',
              'location': 'Kawah Putih Ciwidey',
              'title': 'Wisata Alam Danau Kawah Putih',
              'description': 'Menikmati pemandangan danau kawah vulkanik unik dengan air berwarna putih kebiruan dan udara pegunungan sejuk.',
              'tips': 'Gunakan masker penutup hidung karena bau belerang & siapkan jaket tebal.',
            },
            {
              'time': '12:00 - 13:30',
              'location': 'Resto Saung & Kampoeng Daun Ciwidey',
              'title': 'Santap Siang Kuliner Sunda Otentik',
              'description': 'Makan siang dengan sajian menu khas Sunda seperti nasi liwet, gurame bakar, dan lalapan segar.',
              'tips': 'Coba minuman hangat bandrek atau bajigur untuk menghangatkan badan.',
            },
            {
              'time': '14:30 - 17:30',
              'location': 'Situ Patenggang & Glamping Lakeside',
              'title': 'Sesi Foto Pinisi Resto & Situ Patenggang',
              'description': 'Menikmati pemandangan danau alam Situ Patenggang dan berfoto di kapal Pinisi raksasa yang dikelilingi kebun teh.',
              'tips': 'Momen foto terbaik di deck kapal Pinisi saat sore hari.',
            },
          ],
        };
      } else if (day == 2) {
        return {
          'day': 'Hari 2',
          'title': 'Pesona Kebun Teh & Ranca Upas',
          'activities': [
            {
              'time': '08:30 - 11:00',
              'location': 'Ranca Upas (Kampung Cai)',
              'title': 'Pengalaman Memberi Makan Rusa & Perbukitan',
              'description': 'Interaksi langsung memberi makan wortel kepada rusa-rusa di penangkaran Ranca Upas yang dikelilingi perbukitan hijau.',
              'tips': 'Beli pakan wortel di loket masuk dan kenakan sepatu yang nyaman.',
            },
            {
              'time': '11:30 - 13:30',
              'location': 'Kebun Teh Rancabali',
              'title': 'Tea Walk & Fotografi Hamparan Kebun Teh',
              'description': 'Jalan-jalan santai menyusuri hamparan hijau kebun teh Rancabali yang membentang luas.',
              'tips': 'Siapkan baju berwarna cerah agar bagus saat difoto di tengah kebun teh.',
            },
            {
              'time': '14:00 - 17:00',
              'location': 'Kawah Rengganis & Suspension Bridge',
              'title': 'Melintasi Jembatan Gantung & Pemandian Air Panas',
              'description': 'Uji adrenalin melintasi jembatan gantung terpanjang di Asia Tenggara dan berendam air panas alami Kawah Rengganis.',
              'tips': 'Bawa baju ganti jika berencana berendam air panas.',
            },
          ],
        };
      } else if (day == 3) {
        return {
          'day': 'Hari 3',
          'title': 'Agrowisata Stroberi & Belanja Oleh-Oleh',
          'activities': [
            {
              'time': '09:00 - 11:00',
              'location': 'Kebun Stroberi Petik Sendiri Ciwidey',
              'title': 'Agrowisata Petik Stroberi Segar',
              'description': 'Merasakan sensasi memetik buah stroberi segar langsung dari pohonnya di perkebunan warga lokal.',
              'tips': 'Pilih buah stroberi berwarna merah tua merata agar manis.',
            },
            {
              'time': '11:30 - 13:30',
              'location': 'Sentra Oleh-Oleh Bandung / Ciwidey',
              'title': 'Belanja Oleh-Oleh Khas Sunda',
              'description': 'Berbelanja keripik tempe, peuyeum bandung, dodol, dan kerajinan tangan lokal.',
              'tips': 'Cek tanggal kedaluwarsa pada kemasan makanan.',
            },
          ],
        };
      }
    }

    if (lowerDest.contains('penida')) {
      if (day == 1) {
        return {
          'day': 'Hari 1',
          'title': 'Eksplorasi Tebing & Laut Penida Barat',
          'activities': [
            {
              'time': '07:30 - 08:30',
              'location': 'Pelabuhan Sanur ke Banjar Nyuh',
              'title': 'Penyeberangan Fastboat ke Nusa Penida',
              'description': 'Menyeberang Selat Badung dari Sanur menuju Nusa Penida dan bertemu driver lokal.',
              'tips': 'Tiba 30 menit sebelum jadwal keberangkatan.',
            },
            {
              'time': '09:30 - 12:00',
              'location': 'Kelingking Beach & T-Rex Cliff',
              'title': 'Trekking & Sesi Foto Tebing Kelingking',
              'description': 'Menikmati panorama tebing ikonik T-Rex cliff dari puncak view point dan laut biru jernih.',
              'tips': 'Gunakan sepatu anti-selip & siapkan air minum.',
            },
            {
              'time': '14:00 - 17:00',
              'location': 'Broken Beach & Angel\'s Billabong',
              'title': 'Eksplorasi Pasih Uug & Kolam Alami',
              'description': 'Melihat tebing melingkar berlubang raksasa dan foto di infinity pool alami Angel\'s Billabong.',
              'tips': 'Waspada ombak tinggi saat foto di tepi pantai.',
            },
            {
              'time': '17:30 - 19:00',
              'location': 'Crystal Bay Beach',
              'title': 'Sunset di Crystal Bay & Check-in',
              'description': 'Bersantai menikmati pemandangan matahari terbenam di teluk pasir putih Crystal Bay.',
              'tips': 'Siapkan kain pantai untuk duduk di atas pasir.',
            },
          ],
        };
      } else if (day == 2) {
        return {
          'day': 'Hari 2',
          'title': 'Pesona Lanskap Eksotis Penida Timur',
          'activities': [
            {
              'time': '08:30 - 11:30',
              'location': 'Diamond Beach & Atuh Beach',
              'title': 'Eksplorasi Pantai Tebing Mutiara',
              'description': 'Menuruni tangga tebing batu kapur menuju pantai indah Diamond Beach dengan batu intan raksasa.',
              'tips': 'Melangkah hati-hati karena jalur tangga cukup curam.',
            },
            {
              'time': '12:00 - 14:00',
              'location': 'Rumah Pohon Molenteng & Raja Lima',
              'title': 'Foto Ikonik Tree House Molenteng',
              'description': 'Sesi foto di rumah kayu atas pohon berlatar gundukan tebing pulau-pulau kecil Raja Lima.',
              'tips': 'Siapkan tiket antrean foto di spot populer.',
            },
            {
              'time': '15:30 - 18:00',
              'location': 'Bukit Teletubbies Penida',
              'title': 'Panorama Bukit Hijau Teletubbies',
              'description': 'Menikmati gundukan bukit hijau nan asri bernuansa pemandangan lanskap tropis.',
              'tips': 'Momen terbaik saat sore hari sebelum matahari terbenam.',
            },
          ],
        };
      }
    }

    if (lowerDest.contains('bromo')) {
      if (day == 1) {
        return {
          'day': 'Hari 1',
          'title': 'Golden Sunrise & Kawah Bromo',
          'activities': [
            {
              'time': '03:00 - 06:00',
              'location': 'Penanjakan 1 / King Kong Hill Bromo',
              'title': 'Golden Sunrise Bromo dengan Jeep 4x4',
              'description': 'Menikmati momen terbitnya matahari di balik Gunung Bromo dan Batok dengan kabut samudera awan.',
              'tips': 'Gunakan jaket tebal, sarung tangan, dan kupluk hangat.',
            },
            {
              'time': '06:30 - 09:30',
              'location': 'Kawah Bromo & Pura Luhur Poten',
              'title': 'Trekking Kawah Bromo & Pura Poten',
              'description': 'Melintasi lautan pasir Bromo menuju tangga Kawah Bromo aktif serta melihat keunikan Pura Poten.',
              'tips': 'Gunakan masker penutup hidung karena debu pasir.',
            },
            {
              'time': '10:00 - 12:30',
              'location': 'Pasir Berbisik & Savana Bukit Teletubbies',
              'title': 'Sesi Foto Pasir Berbisik & Bukit Savana',
              'description': 'Berfoto dengan jeep 4x4 di tengah padang pasir luas dan bukit savana hijau yang membentang.',
              'tips': 'Siapkan kacamata hitam untuk sesi foto lanskap.',
            },
          ],
        };
      }
    }

    switch (day) {
      case 1:
        return {
          'day': 'Hari 1',
          'title': 'Kedatangan & Eksplorasi Sunset Spot',
          'activities': [
            {
              'time': '09:00 - 11:30',
              'location': 'Titik Kedatangan & Hotel ($destination)',
              'title': 'Penjemputan & Check-in Akomodasi',
              'description': 'Penjemputan armada privat, perjalanan menuju akomodasi ($accommodation), dan proses check-in.',
              'tips': 'Simpan barang bawaan & siapkan kamera untuk sesi foto sore hari.',
            },
            {
              'time': '12:00 - 14:00',
              'location': 'Pusat Kuliner Lokal Khas $destination',
              'title': 'Santap Siang Kuliner Otentik',
              'description': 'Menikmati hidangan makan siang populer khas daerah dengan bahan segar lokal.',
              'tips': 'Estimasi biaya porsi Rp 45.000 - Rp 85.000 per orang (Budget: $budget).',
            },
            {
              'time': '15:30 - 18:30',
              'location': 'Spot Sunset & Pesisir Ikonik $destination',
              'title': 'Golden Hour Photo Walk & Sunset',
              'description': 'Menyusuri area pemandangan terbaik, eksplorasi lanskap alam, dan mengabadikan momen sunset.',
              'tips': 'Gunakan pakaian kasual yang nyaman dan bawa kacamata hitam.',
            },
          ],
        };
      case 2:
        return {
          'day': 'Hari 2',
          'title': 'Eksplorasi Alam & Destinasi Ikonik',
          'activities': [
            {
              'time': '08:00 - 11:30',
              'location': 'Destinasi Wisata Utama $destination',
              'title': 'Eksplorasi Pagi & Wisata Alam',
              'description': 'Memulai hari dengan ritme $pace untuk mengunjungi panorama alam dan ikon populer.',
              'tips': 'Gunakan sunscreen dan bawa botol minum isi ulang.',
            },
            {
              'time': '12:00 - 14:00',
              'location': 'Restoran Panorama Alam',
              'title': 'Santap Siang & Relaksasi',
              'description': 'Makan siang dengan pemandangan lanskap menakjubkan ($stylesText).',
              'tips': 'Pesan tempat di meja tepi pemandangan.',
            },
            {
              'time': '15:00 - 18:00',
              'location': 'Pusat Kebudayaan & Landmark',
              'title': 'Wisata Budaya & Sesi Foto Skenik',
              'description': 'Menjelajahi keunikan budaya lokal dan mengabadikan pemandangan estetis.',
              'tips': 'Patuhi aturan tata krama lokal setempat.',
            },
          ],
        };
      case 3:
        return {
          'day': 'Hari 3',
          'title': 'Wisata Belanja Oleh-Oleh & Kepulangan',
          'activities': [
            {
              'time': '09:00 - 11:30',
              'location': 'Pusat Kerajinan & Oleh-Oleh Khas',
              'title': 'Belanja Suvenir & Oleh-Oleh Otentik',
              'description': 'Berbelanja makanan khas, kain tradisional, dan produk kerajinan tangan lokal.',
              'tips': 'Sediakan tas tambahan untuk tempat suvenir.',
            },
            {
              'time': '12:00 - 14:00',
              'location': 'Restoran Favorit Penutup',
              'title': 'Santap Siang Penutup Perjalanan',
              'description': 'Nikmati hidangan penutup yang lezat sebelum persiapan kepulangan.',
              'tips': 'Cek kembali barang bawaan sebelum meninggalkan lokasi.',
            },
            {
              'time': '14:30 - 17:00',
              'location': 'Titik Kepulangan / Bandara / Stasiun',
              'title': 'Pengantaran Kembali & Perpisahan',
              'description': 'Transfer kembali ke titik kepulangan untuk mengakhiri momen liburan yang menyenangkan.',
              'tips': 'Tiba 2 jam lebih awal jika menggunakan transportasi udara.',
            },
          ],
        };
      default:
        return {
          'day': 'Hari $day',
          'title': 'Eksplorasi Rekreasi Tambahan',
          'activities': [
            _createFallbackActivity(1, destination),
          ],
        };
    }
  }

  Map<String, dynamic> _createFallbackActivity(int index, String destination) {
    return {
      'time': '10:00 - 15:00',
      'location': 'Destinasi Wisata Pilihan di $destination',
      'title': 'Eksplorasi Bebas & Rekreasi',
      'description': 'Menikmati suasana santai di tempat wisata favorit daerah $destination.',
      'tips': 'Sesuaikan dengan preferensi pribadi Anda.',
    };
  }
}
