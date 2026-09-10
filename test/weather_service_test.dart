import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:project_tride/Services/weather_service.dart';

/// Fake HTTP Client untuk menguji WeatherService secara deterministik tanpa live network request
class FakeHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;

  FakeHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  group('WeatherService Unit Tests', () {
    late WeatherService weatherService;

    setUp(() {
      weatherService = WeatherService();
      weatherService.clearCache();
    });

    test('1. HTTP 200 valid response returns parsed WeatherModel', () async {
      final fakeClient = FakeHttpClient((request) async {
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['latitude'], '-7.607874');
        expect(request.url.queryParameters['longitude'], '110.203751');
        expect(request.url.queryParameters['current'], 'temperature_2m,weather_code');
        expect(request.url.queryParameters['timezone'], 'auto');

        final responseBody = json.encode({
          'latitude': -7.61,
          'longitude': 110.20,
          'timezone': 'Asia/Jakarta',
          'current': {
            'time': '2026-09-10T12:00',
            'temperature_2m': 27.6,
            'weather_code': 0,
          },
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final result = await weatherService.getCurrentWeather(
        latitude: -7.607874,
        longitude: 110.203751,
        client: fakeClient,
      );

      expect(result, isNotNull);
      expect(result!.temperature, 27.6);
      expect(result.weatherCode, 0);
      expect(result.condition, 'Cerah');
    });

    test('2. HTTP error (500 Internal Server Error) returns null safely', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Internal Server Error')),
          500,
        );
      });

      final result = await weatherService.getCurrentWeather(
        latitude: -7.942494,
        longitude: 112.953012,
        client: fakeClient,
      );

      expect(result, isNull);
    });

    test('3. HTTP 404 Not Found returns null safely', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('{"error": true, "reason": "Not Found"}')),
          404,
        );
      });

      final result = await weatherService.getCurrentWeather(
        latitude: -8.506854,
        longitude: 115.262474,
        client: fakeClient,
      );

      expect(result, isNull);
    });

    test('4. Timeout exception returns null safely without throwing', () async {
      final fakeClient = FakeHttpClient((request) async {
        // Simulasi network delay melebihi timeout
        throw TimeoutException('Request timeout');
      });

      final result = await weatherService.getCurrentWeather(
        latitude: -8.506854,
        longitude: 115.262474,
        client: fakeClient,
      );

      expect(result, isNull);
    });

    test('5. Invalid / corrupted JSON returns null safely', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('<html><body>Bad Gateway</body></html>')),
          200,
          headers: {'content-type': 'text/html'},
        );
      });

      final result = await weatherService.getCurrentWeather(
        latitude: -8.506854,
        longitude: 115.262474,
        client: fakeClient,
      );

      expect(result, isNull);
    });

    test('6. Invalid coordinates return null without making HTTP call', () async {
      int requestCount = 0;
      final fakeClient = FakeHttpClient((request) async {
        requestCount++;
        return http.StreamedResponse(
          Stream.value(utf8.encode('{}')),
          200,
        );
      });

      // Latitude > 90
      final result1 = await weatherService.getCurrentWeather(
        latitude: 95.0,
        longitude: 100.0,
        client: fakeClient,
      );
      expect(result1, isNull);

      // Longitude > 180
      final result2 = await weatherService.getCurrentWeather(
        latitude: 10.0,
        longitude: 195.0,
        client: fakeClient,
      );
      expect(result2, isNull);

      // NaN
      final result3 = await weatherService.getCurrentWeather(
        latitude: double.nan,
        longitude: 100.0,
        client: fakeClient,
      );
      expect(result3, isNull);

      expect(requestCount, 0, reason: 'No network request should be dispatched for invalid coordinates');
    });

    test('7. In-memory caching returns cached model on subsequent calls with same coordinates', () async {
      int requestCount = 0;
      final fakeClient = FakeHttpClient((request) async {
        requestCount++;
        final responseBody = json.encode({
          'current': {
            'temperature_2m': 29.0,
            'weather_code': 1,
          },
        });
        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          200,
        );
      });

      // First call -> triggers network request
      final result1 = await weatherService.getCurrentWeather(
        latitude: -7.607874,
        longitude: 110.203751,
        client: fakeClient,
      );
      expect(result1, isNotNull);
      expect(result1!.temperature, 29.0);
      expect(requestCount, 1);

      // Second call with same coordinates -> served from cache
      final result2 = await weatherService.getCurrentWeather(
        latitude: -7.607874,
        longitude: 110.203751,
        client: fakeClient,
      );
      expect(result2, isNotNull);
      expect(result2!.temperature, 29.0);
      expect(requestCount, 1, reason: 'Cache should have served the second request without calling HTTP');

      // Call for different destination coordinates -> triggers new network request
      final result3 = await weatherService.getCurrentWeather(
        latitude: -8.506854,
        longitude: 115.262474,
        client: fakeClient,
      );
      expect(result3, isNotNull);
      expect(requestCount, 2, reason: 'New coordinates must dispatch a separate request');
    });
  });
}
