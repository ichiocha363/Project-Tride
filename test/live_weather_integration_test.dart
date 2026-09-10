import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Services/weather_service.dart';

void main() {
  group('Live Open-Meteo Integration Test (5 Destinations)', () {
    final destinations = [
      {'name': 'Candi Borobudur', 'lat': -7.607874, 'lng': 110.203751},
      {'name': 'Gunung Bromo', 'lat': -7.942494, 'lng': 112.953012},
      {'name': 'Ubud Cultural Sanctuary', 'lat': -8.506854, 'lng': 115.262474},
      {'name': 'Danau Toba & Samosir', 'lat': 2.6845, 'lng': 98.8756},
      {'name': 'Kepulauan Raja Ampat', 'lat': -0.233333, 'lng': 130.516667},
    ];

    for (final dest in destinations) {
      test('Live weather fetch for ${dest['name']}', () async {
        final name = dest['name'] as String;
        final lat = dest['lat'] as double;
        final lng = dest['lng'] as double;

        final weather = await WeatherService.instance.getCurrentWeather(
          latitude: lat,
          longitude: lng,
        );

        expect(weather, isNotNull, reason: 'Failed to fetch weather for $name');
        expect(weather!.temperature, isA<double>());
        expect(weather.temperature, inInclusiveRange(-10.0, 50.0));
        expect(weather.condition, isNotEmpty);
        expect(weather.condition, isNot('Cuaca tidak diketahui'));
        expect(weather.weatherCode, inInclusiveRange(0, 99));

        debugPrint('[$name] Temp: ${weather.temperature}°C (${weather.temperature.round()}°C), Condition: ${weather.condition}, Code: ${weather.weatherCode}, Icon: ${weather.weatherIcon}');
      });
    }
  });
}
