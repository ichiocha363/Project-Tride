import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Models/weather_model.dart';

/// Entry cache untuk menyimpan data cuaca dengan TTL (Time-To-Live).
class _WeatherCacheEntry {
  final WeatherModel model;
  final DateTime timestamp;

  _WeatherCacheEntry({required this.model, required this.timestamp});

  bool isExpired(Duration ttl) =>
      DateTime.now().difference(timestamp) > ttl;
}

/// Service untuk mengambil data cuaca real-time dari Open-Meteo Forecast API.
class WeatherService {
  static final WeatherService instance = WeatherService();

  final http.Client? _injectedClient;

  WeatherService({http.Client? client}) : _injectedClient = client;

  /// Cache in-memory berdasar koordinat spesifik
  final Map<String, _WeatherCacheEntry> _cache = {};

  /// Durasi TTL cache cuaca (10 menit)
  static const Duration cacheTtl = Duration(minutes: 10);

  /// Timeout request HTTP Open-Meteo (8 detik)
  static const Duration requestTimeout = Duration(seconds: 8);

  /// Menghasilkan cache key unik berbasis latitude & longitude 4 desimal (~11 meter presisi)
  String _generateCacheKey(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }

  /// Membersihkan seluruh data cache cuaca (berguna untuk testing atau force refresh)
  void clearCache() {
    _cache.clear();
  }

  /// Mengambil data cuaca saat ini untuk koordinat destinasi tertentu.
  /// Mengembalikan `WeatherModel` jika berhasil, atau `null` jika terjadi error/offline/timeout.
  Future<WeatherModel?> getCurrentWeather({
    required double latitude,
    required double longitude,
    http.Client? client,
  }) async {
    // 1. Validasi koordinat geografis
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.isInfinite ||
        longitude.isInfinite ||
        latitude < -90.0 ||
        latitude > 90.0 ||
        longitude < -180.0 ||
        longitude > 180.0) {
      debugPrint(
        '[WeatherService] Koordinat tidak valid: ($latitude, $longitude)',
      );
      return null;
    }

    // 2. Cek Cache in-memory
    final cacheKey = _generateCacheKey(latitude, longitude);
    final cachedEntry = _cache[cacheKey];
    if (cachedEntry != null && !cachedEntry.isExpired(cacheTtl)) {
      debugPrint(
        '[WeatherService] Mengembalikan cuaca dari cache untuk ($latitude, $longitude): ${cachedEntry.model}',
      );
      return cachedEntry.model;
    }

    // 3. Bangun Endpoint Open-Meteo Forecast API
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      },
    );

    final httpClient = client ?? _injectedClient ?? http.Client();
    final bool shouldCloseClient = client == null && _injectedClient == null;

    try {
      debugPrint('[WeatherService] Fetching cuaca dari Open-Meteo: $uri');
      final response = await httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Tride-App/1.0',
        },
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body);
        if (decodedJson is Map<String, dynamic>) {
          final model = WeatherModel.fromJson(decodedJson);
          // Simpan ke cache
          _cache[cacheKey] = _WeatherCacheEntry(
            model: model,
            timestamp: DateTime.now(),
          );
          debugPrint('[WeatherService] Sukses memuat cuaca: $model');
          return model;
        } else {
          debugPrint(
            '[WeatherService] Format JSON response bukan Map: ${response.body}',
          );
          return null;
        }
      } else {
        debugPrint(
          '[WeatherService] Open-Meteo HTTP Error ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('[WeatherService] Offline / Socket error: $e');
      return null;
    } on http.ClientException catch (e) {
      debugPrint('[WeatherService] HTTP Client error: $e');
      return null;
    } on FormatException catch (e) {
      debugPrint('[WeatherService] JSON parsing error: $e');
      return null;
    } catch (e) {
      debugPrint('[WeatherService] Unknown exception saat mengambil cuaca: $e');
      return null;
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }
}
