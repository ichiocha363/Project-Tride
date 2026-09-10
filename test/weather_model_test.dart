import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/weather_model.dart';

void main() {
  group('WeatherModel Unit Tests', () {
    test('1. JSON valid standard Open-Meteo response', () {
      final json = {
        'latitude': -7.625,
        'longitude': 110.25,
        'generationtime_ms': 0.05,
        'utc_offset_seconds': 25200,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-09-10T10:00',
          'interval': 900,
          'temperature_2m': 28.4,
          'weather_code': 0,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 28.4);
      expect(model.weatherCode, 0);
      expect(model.condition, 'Cerah');
      expect(model.weatherIcon, 'sunny');
      expect(model.iconData, Icons.wb_sunny_rounded);
    });

    test('2. Temperature integer in JSON parsed to double', () {
      final json = {
        'current': {
          'temperature_2m': 25,
          'weather_code': 1,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 25.0);
      expect(model.weatherCode, 1);
      expect(model.condition, 'Berawan');
    });

    test('3. Temperature double in JSON', () {
      final json = {
        'current': {
          'temperature_2m': 31.75,
          'weather_code': 2,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 31.75);
      expect(model.weatherCode, 2);
      expect(model.condition, 'Berawan');
    });

    test('4. Weather code valid', () {
      final json = {
        'current': {
          'temperature_2m': 22.0,
          'weather_code': 61,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.weatherCode, 61);
      expect(model.condition, 'Hujan');
      expect(model.iconData, Icons.water_drop_rounded);
    });

    test('5. Weather code unknown defaults to Cuaca tidak diketahui', () {
      final json = {
        'current': {
          'temperature_2m': 20.0,
          'weather_code': 999,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.weatherCode, 999);
      expect(model.condition, 'Cuaca tidak diketahui');
      expect(model.weatherIcon, 'unknown');
      expect(model.iconData, Icons.wb_cloudy_outlined);
    });

    test('6. Missing current field falls back gracefully', () {
      final json = <String, dynamic>{
        'latitude': -7.625,
        'longitude': 110.25,
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 0.0);
      expect(model.weatherCode, -1);
      expect(model.condition, 'Cuaca tidak diketahui');
    });

    test('7. Missing temperature field defaults to 0.0', () {
      final json = {
        'current': {
          'weather_code': 3,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 0.0);
      expect(model.weatherCode, 3);
      expect(model.condition, 'Berawan');
    });

    test('8. Missing weather_code field defaults to -1 and unknown condition', () {
      final json = {
        'current': {
          'temperature_2m': 26.5,
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 26.5);
      expect(model.weatherCode, -1);
      expect(model.condition, 'Cuaca tidak diketahui');
    });

    test('9. Invalid response (empty map, null fields, corrupted types)', () {
      final emptyModel = WeatherModel.fromJson({});
      expect(emptyModel.temperature, 0.0);
      expect(emptyModel.weatherCode, -1);
      expect(emptyModel.condition, 'Cuaca tidak diketahui');

      final stringNumberJson = {
        'current': {
          'temperature_2m': '29.3',
          'weather_code': '80',
        },
      };
      final parsedStringModel = WeatherModel.fromJson(stringNumberJson);
      expect(parsedStringModel.temperature, 29.3);
      expect(parsedStringModel.weatherCode, 80);
      expect(parsedStringModel.condition, 'Hujan deras');

      final corruptedJson = {
        'current': {
          'temperature_2m': 'not_a_number',
          'weather_code': null,
        },
      };
      final corruptedModel = WeatherModel.fromJson(corruptedJson);
      expect(corruptedModel.temperature, 0.0);
      expect(corruptedModel.weatherCode, -1);
      expect(corruptedModel.condition, 'Cuaca tidak diketahui');
    });

    test('10. Mapping all WMO weather codes to Indonesian conditions', () {
      // 0 → Cerah
      expect(WeatherModel.getWeatherCondition(0), 'Cerah');

      // 1, 2, 3 → Berawan
      expect(WeatherModel.getWeatherCondition(1), 'Berawan');
      expect(WeatherModel.getWeatherCondition(2), 'Berawan');
      expect(WeatherModel.getWeatherCondition(3), 'Berawan');

      // 45, 48 → Berkabut
      expect(WeatherModel.getWeatherCondition(45), 'Berkabut');
      expect(WeatherModel.getWeatherCondition(48), 'Berkabut');

      // 51, 53, 55 → Gerimis
      expect(WeatherModel.getWeatherCondition(51), 'Gerimis');
      expect(WeatherModel.getWeatherCondition(53), 'Gerimis');
      expect(WeatherModel.getWeatherCondition(55), 'Gerimis');

      // 56, 57 → Gerimis beku
      expect(WeatherModel.getWeatherCondition(56), 'Gerimis beku');
      expect(WeatherModel.getWeatherCondition(57), 'Gerimis beku');

      // 61, 63, 65 → Hujan
      expect(WeatherModel.getWeatherCondition(61), 'Hujan');
      expect(WeatherModel.getWeatherCondition(63), 'Hujan');
      expect(WeatherModel.getWeatherCondition(65), 'Hujan');

      // 66, 67 → Hujan beku
      expect(WeatherModel.getWeatherCondition(66), 'Hujan beku');
      expect(WeatherModel.getWeatherCondition(67), 'Hujan beku');

      // 71, 73, 75 → Salju
      expect(WeatherModel.getWeatherCondition(71), 'Salju');
      expect(WeatherModel.getWeatherCondition(73), 'Salju');
      expect(WeatherModel.getWeatherCondition(75), 'Salju');

      // 77 → Butiran salju
      expect(WeatherModel.getWeatherCondition(77), 'Butiran salju');

      // 80, 81, 82 → Hujan deras
      expect(WeatherModel.getWeatherCondition(80), 'Hujan deras');
      expect(WeatherModel.getWeatherCondition(81), 'Hujan deras');
      expect(WeatherModel.getWeatherCondition(82), 'Hujan deras');

      // 85, 86 → Badai salju
      expect(WeatherModel.getWeatherCondition(85), 'Badai salju');
      expect(WeatherModel.getWeatherCondition(86), 'Badai salju');

      // 95 → Badai petir
      expect(WeatherModel.getWeatherCondition(95), 'Badai petir');

      // 96, 99 → Badai petir + hujan es
      expect(WeatherModel.getWeatherCondition(96), 'Badai petir + hujan es');
      expect(WeatherModel.getWeatherCondition(99), 'Badai petir + hujan es');

      // Unknown / null
      expect(WeatherModel.getWeatherCondition(-1), 'Cuaca tidak diketahui');
      expect(WeatherModel.getWeatherCondition(null), 'Cuaca tidak diketahui');
      expect(WeatherModel.getWeatherCondition(100), 'Cuaca tidak diketahui');
    });

    test('11. toMap, toJson, and copyWith serialization', () {
      const model = WeatherModel(
        temperature: 27.5,
        weatherCode: 0,
        condition: 'Cerah',
        weatherIcon: 'sunny',
      );

      final map = model.toMap();
      expect(map['temperature'], 27.5);
      expect(map['weather_code'], 0);
      expect(map['condition'], 'Cerah');
      expect(map['weather_icon'], 'sunny');

      final fromMapModel = WeatherModel.fromMap(map);
      expect(fromMapModel, equals(model));

      final updated = model.copyWith(temperature: 29.0);
      expect(updated.temperature, 29.0);
      expect(updated.condition, 'Cerah');
    });
  });
}
