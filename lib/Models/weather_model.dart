import 'package:flutter/material.dart';

/// Model representasi data cuaca real-time dari Open-Meteo API.
class WeatherModel {
  final double temperature;
  final int weatherCode;
  final String condition;
  final String? weatherIcon;

  const WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.condition,
    this.weatherIcon,
  });

  /// Helper untuk memetakan kode cuaca WMO Open-Meteo ke Bahasa Indonesia
  static String getWeatherCondition(int? code) {
    if (code == null) return 'Cuaca tidak diketahui';
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis beku';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 66:
      case 67:
        return 'Hujan beku';
      case 71:
      case 73:
      case 75:
        return 'Salju';
      case 77:
        return 'Butiran salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan deras';
      case 85:
      case 86:
        return 'Badai salju';
      case 95:
        return 'Badai petir';
      case 96:
      case 99:
        return 'Badai petir + hujan es';
      default:
        return 'Cuaca tidak diketahui';
    }
  }

  /// Helper untuk mendapatkan nama icon representasi cuaca
  static String getWeatherIconKey(int? code) {
    if (code == null) return 'unknown';
    switch (code) {
      case 0:
        return 'sunny';
      case 1:
      case 2:
      case 3:
        return 'cloudy';
      case 45:
      case 48:
        return 'foggy';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'drizzle';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'rain';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'snow';
      case 80:
      case 81:
      case 82:
        return 'heavy_rain';
      case 95:
      case 96:
      case 99:
        return 'thunderstorm';
      default:
        return 'unknown';
    }
  }

  /// Helper untuk mendapatkan IconData Flutter yang serasi dengan UI Tride
  static IconData getWeatherIconData(int? code) {
    if (code == null) return Icons.wb_cloudy_outlined;
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
      case 3:
        return Icons.wb_cloudy_rounded;
      case 45:
      case 48:
        return Icons.cloud_queue_rounded;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  /// IconData instance getter
  IconData get iconData => getWeatherIconData(weatherCode);

  /// Helper internal konversi angka double secara aman
  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim());
    return null;
  }

  /// Helper internal konversi angka int secara aman
  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim());
    return null;
  }

  /// Factory untuk parsing JSON dari response Open-Meteo API atau JSON Map umum
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final dynamic currentRaw = json['current'];
    final Map<String, dynamic> current =
        currentRaw is Map<String, dynamic> ? currentRaw : <String, dynamic>{};

    final double parsedTemperature = _parseDouble(
          current['temperature_2m'] ??
              current['temperature'] ??
              json['temperature_2m'] ??
              json['temperature'],
        ) ??
        0.0;

    final int parsedWeatherCode = _parseInt(
          current['weather_code'] ??
              current['weatherCode'] ??
              json['weather_code'] ??
              json['weatherCode'],
        ) ??
        -1;

    final String? explicitCondition =
        (json['condition'] ?? current['condition']) as String?;
    final String parsedCondition = explicitCondition != null &&
            explicitCondition.trim().isNotEmpty
        ? explicitCondition.trim()
        : getWeatherCondition(parsedWeatherCode);

    final String? explicitIcon =
        (json['weather_icon'] ?? json['weatherIcon'] ?? current['weather_icon'])
            as String?;
    final String parsedIcon = explicitIcon != null &&
            explicitIcon.trim().isNotEmpty
        ? explicitIcon.trim()
        : getWeatherIconKey(parsedWeatherCode);

    return WeatherModel(
      temperature: parsedTemperature,
      weatherCode: parsedWeatherCode,
      condition: parsedCondition,
      weatherIcon: parsedIcon,
    );
  }

  /// Factory alias untuk fromMap
  factory WeatherModel.fromMap(Map<String, dynamic> map) =>
      WeatherModel.fromJson(map);

  /// Mengonversi model ke Map serialisasi
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'weather_code': weatherCode,
      'condition': condition,
      if (weatherIcon != null) 'weather_icon': weatherIcon,
    };
  }

  /// Mengonversi model ke JSON
  Map<String, dynamic> toJson() => toMap();

  /// Membuat salinan objek dengan atribut yang diubah
  WeatherModel copyWith({
    double? temperature,
    int? weatherCode,
    String? condition,
    String? weatherIcon,
  }) {
    return WeatherModel(
      temperature: temperature ?? this.temperature,
      weatherCode: weatherCode ?? this.weatherCode,
      condition: condition ?? this.condition,
      weatherIcon: weatherIcon ?? this.weatherIcon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModel &&
          runtimeType == other.runtimeType &&
          (temperature - other.temperature).abs() < 0.001 &&
          weatherCode == other.weatherCode &&
          condition == other.condition;

  @override
  int get hashCode =>
      temperature.hashCode ^ weatherCode.hashCode ^ condition.hashCode;

  @override
  String toString() {
    return 'WeatherModel(temperature: $temperature°C, code: $weatherCode, condition: $condition, icon: $weatherIcon)';
  }
}
