import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Services/weather_service.dart';
import 'package:project_tride/Views/halaman beranda/halaman_destination_detail.dart';

void main() {
  group('HalamanDestinationDetail Weather Integration Tests', () {
    setUp(() {
      WeatherService.instance.clearCache();
    });

    testWidgets('1. Renders weather card and Open-Meteo attribution',
        (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final dest = DestinationModel(
          id: 1,
          name: 'Candi Borobudur',
          location: 'Magelang, Jawa Tengah',
          description: 'Candi Buddha terbesar di dunia.',
          image: 'https://images.unsplash.com/photo-1620549146396-9024d914cd99?w=800',
          category: 'Budaya',
          rating: 4.9,
          estimatedBudget: 1800000,
          latitude: -7.607874,
          longitude: 110.203751,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: HalamanDestinationDetail(
              destinationId: 1,
              destination: dest,
              destinationTitle: 'Candi Borobudur',
            ),
          ),
        );
        await tester.pump();

        // Verify UI elements exist
        expect(find.text('Rating'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
        expect(find.text('Estimasi Biaya'), findsOneWidget);
        expect(find.text('Weather data by Open-Meteo'), findsOneWidget);
      }, _TestHttpOverrides());
    });

    testWidgets('2. Shows Cuaca tidak tersedia when coordinates are missing',
        (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final destNoCoords = DestinationModel(
          id: 999,
          name: 'Destinasi Tanpa Koordinat',
          location: 'Indonesia',
          description: 'Deskripsi tes.',
          image: '',
          category: 'Alam',
          rating: 4.5,
          estimatedBudget: 1000000,
          latitude: null,
          longitude: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: HalamanDestinationDetail(
              destinationId: 999,
              destination: destNoCoords,
              destinationTitle: 'Destinasi Tanpa Koordinat',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Cuaca tidak tersedia'), findsOneWidget);
        expect(find.text('--°C'), findsOneWidget);
      }, _TestHttpOverrides());
    });
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];
