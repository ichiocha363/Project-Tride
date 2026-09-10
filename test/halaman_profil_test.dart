import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman profile/halaman_profil.dart';

void main() {
  testWidgets(
    'HalamanProfil renders real user profile UI elements without dummy data',
    (WidgetTester tester) async {
      final user = UserModel(
        id: 1,
        nama: 'Andi Setiawan',
        email: 'andi@email.com',
        password: 'password123',
      );

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(MaterialApp(home: HalamanProfil(user: user)));
        await tester.pump(const Duration(milliseconds: 500));

        // App bar Title Badge
        expect(find.text('Tride'), findsOneWidget);

        // Real User Information
        expect(find.text('Andi Setiawan'), findsOneWidget);
        expect(find.text('andi@email.com'), findsOneWidget);

        // Airy Traveler Stats Row (Real Labels)
        expect(find.text('PERJALANAN'), findsOneWidget);
        expect(find.text('TEMPAT TERSIMPAN'), findsOneWidget);

        // Ensure dummy stats like "8 NEGARA" and "14 PERJALANAN" are NOT hardcoded
        expect(find.text('NEGARA'), findsNothing);

        // Journey Highlights Section
        expect(find.text('Sorotan Perjalanan'), findsOneWidget);

        // Ensure dummy milestones are removed
        expect(find.text('First Solo Trip'), findsNothing);
        expect(find.text('Eco Traveler Certified'), findsNothing);
        expect(find.text('Peak Bagger'), findsNothing);

        // Real Preferences Section Menu
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Informasi Pribadi'), findsOneWidget);
        expect(find.text('Tempat Tersimpan'), findsOneWidget);
        expect(find.text('Personal Travel Data'), findsOneWidget);

        // Ensure dummy preference switches are removed
        expect(find.text('Metode Pembayaran'), findsNothing);
        expect(find.text('Pengaturan Aplikasi'), findsNothing);

        // Settings Icon Button in AppBar
        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

        // Logout / Sign Out Button & Dialog Test
        final logoutFinder = find.text('SIGN OUT');
        expect(logoutFinder, findsOneWidget);
        await tester.ensureVisible(logoutFinder);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(logoutFinder);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Konfirmasi Logout'), findsOneWidget);
        expect(
          find.text('Apakah Anda yakin ingin keluar dari aplikasi Tride?'),
          findsOneWidget,
        );
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Keluar'), findsOneWidget);
      }, _TestHttpOverrides());
    },
  );
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
