import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Views/halaman profile/halaman_pengaturan.dart';
import 'package:project_tride/Views/halaman_privacy_policy.dart';
import 'package:project_tride/Views/halaman_register.dart';
import 'package:project_tride/Views/halaman_terms_of_service.dart';

void main() {
  group('HalamanRegister - Terms of Service & Privacy Policy Integration Tests', () {
    testWidgets('1. Terms and Privacy link text spans are rendered with active recognizers', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(const MaterialApp(home: HalamanRegister()));
        await tester.pumpAndSettle();

        // Check Text widget with textSpan
        final textFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.textSpan != null &&
              widget.textSpan!.toPlainText().contains('Terms of Service') &&
              widget.textSpan!.toPlainText().contains('Privacy Policy'),
        );
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        final span = textWidget.textSpan as TextSpan;
        expect(span.toPlainText(), contains("I agree to the Terms of Service and Privacy Policy"));

        // Verify gesture recognizers exist on children
        final children = span.children!;
        final termsSpan = children.firstWhere(
          (element) => (element as TextSpan).text == 'Terms of Service',
        ) as TextSpan;
        final privacySpan = children.firstWhere(
          (element) => (element as TextSpan).text == 'Privacy Policy',
        ) as TextSpan;

        expect(termsSpan.recognizer, isA<TapGestureRecognizer>());
        expect(privacySpan.recognizer, isA<TapGestureRecognizer>());
      }, _TestHttpOverrides());
    });

    testWidgets('2. Checkbox false -> Create Account disabled; Checkbox true -> Create Account enabled', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(const MaterialApp(home: HalamanRegister()));
        await tester.pumpAndSettle();

        final buttonFinder = find.widgetWithText(ElevatedButton, 'Create Account');
        expect(buttonFinder, findsOneWidget);

        // Initially agreeTerms is false, so button must be disabled (onPressed is null)
        ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNull);

        // Tap the Checkbox
        final checkboxFinder = find.byType(Checkbox);
        expect(checkboxFinder, findsOneWidget);
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();

        // Now button must be enabled (onPressed is non-null)
        button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNotNull);

        // Tap checkbox again to uncheck
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();

        // Button should be disabled again
        button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNull);
      }, _TestHttpOverrides());
    });

    testWidgets('3. Tap Terms of Service opens HalamanTermsOfService and Back preserves form data', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(const MaterialApp(home: HalamanRegister()));
        await tester.pumpAndSettle();

        // Fill form fields
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(4));

        await tester.enterText(textFields.at(0), 'Budi Traveler');
        await tester.enterText(textFields.at(1), 'budi@trideapp.com');
        await tester.enterText(textFields.at(2), 'secretpass123');
        await tester.enterText(textFields.at(3), 'secretpass123');

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap Terms of Service span recognizer
        final textFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.textSpan != null &&
              widget.textSpan!.toPlainText().contains('Terms of Service'),
        );
        final textWidget = tester.widget<Text>(textFinder);
        final span = textWidget.textSpan as TextSpan;
        final termsSpan = span.children!.firstWhere(
          (element) => (element as TextSpan).text == 'Terms of Service',
        ) as TextSpan;
        (termsSpan.recognizer as TapGestureRecognizer).onTap!();

        await tester.pumpAndSettle();

        // Verify HalamanTermsOfService is pushed
        expect(find.byType(HalamanTermsOfService), findsOneWidget);
        expect(find.text('Syarat & Ketentuan'), findsOneWidget);
        expect(find.text('Ketentuan Layanan Tride'), findsOneWidget);
        expect(find.text('1. Penerimaan Ketentuan'), findsOneWidget);
        expect(find.text('3. Fitur AI Travel Planner & Rekomendasi'), findsOneWidget);

        // Tap back button in AppBar
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify returned to HalamanRegister
        expect(find.byType(HalamanTermsOfService), findsNothing);
        expect(find.byType(HalamanRegister), findsOneWidget);

        // Verify form data is preserved
        expect(find.text('Budi Traveler'), findsOneWidget);
        expect(find.text('budi@trideapp.com'), findsOneWidget);
        expect(find.text('secretpass123'), findsNWidgets(2));

        // Verify checkbox state is still true and button is enabled
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);

        final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Create Account'));
        expect(button.onPressed, isNotNull);
      }, _TestHttpOverrides());
    });

    testWidgets('4. Tap Privacy Policy opens HalamanPrivacyPolicy and Back preserves form data', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(const MaterialApp(home: HalamanRegister()));
        await tester.pumpAndSettle();

        // Fill form fields
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Siti Rahma');
        await tester.enterText(textFields.at(1), 'siti@trideapp.com');
        await tester.enterText(textFields.at(2), 'mypassword321');
        await tester.enterText(textFields.at(3), 'mypassword321');

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap Privacy Policy span recognizer
        final textFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.textSpan != null &&
              widget.textSpan!.toPlainText().contains('Privacy Policy'),
        );
        final textWidget = tester.widget<Text>(textFinder);
        final span = textWidget.textSpan as TextSpan;
        final privacySpan = span.children!.firstWhere(
          (element) => (element as TextSpan).text == 'Privacy Policy',
        ) as TextSpan;
        (privacySpan.recognizer as TapGestureRecognizer).onTap!();

        await tester.pumpAndSettle();

        // Verify HalamanPrivacyPolicy is pushed
        expect(find.byType(HalamanPrivacyPolicy), findsOneWidget);
        expect(find.text('Kebijakan Privasi'), findsOneWidget);
        expect(find.text('Keamanan & Privasi Data'), findsOneWidget);
        expect(find.text('1. Informasi yang Kami Kumpulkan'), findsOneWidget);
        expect(find.text('4. Penyimpanan dan Keamanan Data'), findsOneWidget);
        expect(find.text('support@trideapp.com'), findsOneWidget);

        // Tap AppBar back button
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify returned to HalamanRegister
        expect(find.byType(HalamanPrivacyPolicy), findsNothing);
        expect(find.byType(HalamanRegister), findsOneWidget);

        // Verify form data is preserved
        expect(find.text('Siti Rahma'), findsOneWidget);
        expect(find.text('siti@trideapp.com'), findsOneWidget);
        expect(find.text('mypassword321'), findsNWidgets(2));

        // Checkbox is still checked
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      }, _TestHttpOverrides());
    });

    testWidgets('5. Terms & Privacy screens render full contents and bottom action buttons', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        // Test Terms of Service screen standalone
        await tester.pumpWidget(const MaterialApp(home: HalamanTermsOfService()));
        await tester.pumpAndSettle();

        expect(find.text('TRIDE TERMS OF SERVICE'), findsOneWidget);
        expect(find.text('10. Kontak & Dukungan'), findsOneWidget);

        // Test Privacy Policy screen standalone
        await tester.pumpWidget(const MaterialApp(home: HalamanPrivacyPolicy()));
        await tester.pumpAndSettle();

        expect(find.text('TRIDE PRIVACY POLICY'), findsOneWidget);
        expect(find.text('9. Kontak & Narahubung'), findsOneWidget);
      }, _TestHttpOverrides());
    });

    testWidgets('6. HalamanPengaturan terms dialog provides links to Terms and Privacy pages', (WidgetTester tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(const MaterialApp(home: HalamanPengaturan()));
        await tester.pump(const Duration(milliseconds: 500));

        // Tap Ketentuan Layanan & Privasi tile
        final termsTileFinder = find.text('Ketentuan Layanan & Privasi');
        expect(termsTileFinder, findsOneWidget);
        await tester.tap(termsTileFinder);
        await tester.pumpAndSettle();

        // Dialog should be open
        expect(find.text('Ketentuan & Privasi'), findsOneWidget);
        expect(find.text('Syarat & Ketentuan Layanan'), findsOneWidget);
        expect(find.text('Kebijakan Privasi'), findsOneWidget);

        // Tap Syarat & Ketentuan Layanan in dialog
        await tester.tap(find.text('Syarat & Ketentuan Layanan'));
        await tester.pumpAndSettle();

        // Verify HalamanTermsOfService is opened
        expect(find.byType(HalamanTermsOfService), findsOneWidget);
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
