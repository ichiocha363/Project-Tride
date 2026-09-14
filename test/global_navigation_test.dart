import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Database/user_model.dart' as db_user;
import 'package:project_tride/Views/halaman_utama.dart';
import 'package:project_tride/Views/halaman beranda/halaman_beranda.dart';
import 'package:project_tride/Views/halaman beranda/halaman_destination_detail.dart';
import 'package:project_tride/Views/halaman profile/halaman_personal_info.dart';

void main() {
  final testUser = UserModel(
    id: 1,
    nama: 'Budi Santoso',
    email: 'budi@example.com',
    password: 'password123',
  );

  group('Global Navigation Stack & Tab Architecture Tests', () {
    testWidgets('1. App Start: HalamanUtama root launches on Home with NO back arrow', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HalamanUtama(user: testUser),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        // Verify Home is active
        expect(find.byType(HalamanBeranda), findsOneWidget);
        expect(find.text('Trips'), findsOneWidget);

        // Verify NO back button in Home
        expect(find.byType(BackButton), findsNothing);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      }, _TestHttpOverrides());
    });

    testWidgets('2. Home -> Profile avatar tap switches tab without pushing duplicate routes', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HalamanUtama(user: testUser),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        // Tap Profile avatar in Home top bar
        final avatarFinder = find.byType(GFAvatar);
        expect(avatarFinder, findsOneWidget);
        await tester.tap(avatarFinder);
        await tester.pump(const Duration(milliseconds: 500));

        // Verify we switched to Profile
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Informasi Pribadi'), findsOneWidget);

        // Verify Profile has NO back button because it is an embedded tab
        expect(find.byType(BackButton), findsNothing);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

        // Tap Beranda tab in bottom bar to switch back
        await tester.tap(find.text('Beranda'));
        await tester.pump(const Duration(milliseconds: 500));

        // Verify Home is displayed with NO back arrow
        expect(find.text('Trips'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      }, _TestHttpOverrides());
    });

    testWidgets('3. Profile -> Personal Info (child route) shows back arrow and returns cleanly', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanPersonalInfo(
                          user: db_user.UserModel(
                            id: testUser.id,
                            nama: testUser.nama,
                            email: testUser.email,
                            password: testUser.password,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Personal Info'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Tap to open Personal Info as child route
        await tester.tap(find.text('Open Personal Info'));
        await tester.pumpAndSettle();

        // Verify Child page is active and shows back button
        expect(find.byType(HalamanPersonalInfo), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify we returned to parent
        expect(find.byType(HalamanPersonalInfo), findsNothing);
        expect(find.text('Open Personal Info'), findsOneWidget);
      }, _TestHttpOverrides());
    });

    testWidgets('4. Child Route (Destination Detail) has back arrow and pops back to parent', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HalamanDestinationDetail(
              user: testUser,
              destinationTitle: 'Bromo Mountain, East Java',
              categoryTag: 'Gunung',
              imageUrl: 'https://example.com/bromo.jpg',
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        // Verify Destination Detail has back arrow
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      }, _TestHttpOverrides());
    });

    testWidgets('5. Android Back Button on non-zero tab returns to Tab 0 (Home)', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: HalamanUtama(user: testUser, initialTab: 1), // Jelajah tab
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        // Simulate Android back button invocation
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify user is returned to Tab 0 (Home)
        expect(find.text('Trips'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      }, _TestHttpOverrides());
    });

    testWidgets('6. Register -> Login -> Home flow resets navigation stack, ensuring Home is root with NO back arrow', (tester) async {
      await HttpOverrides.runWithHttpOverrides(() async {
        late BuildContext savedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                savedContext = context;
                return const Scaffold(body: Text('Login Screen Mock'));
              },
            ),
          ),
        );
        await tester.pump();

        // 1. Simulate tap Register from Login (pushReplacement to Register)
        Navigator.pushReplacement(
          savedContext,
          MaterialPageRoute(
            builder: (context) {
              savedContext = context;
              return const Scaffold(body: Text('Register Screen Mock'));
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Register Screen Mock'), findsOneWidget);

        // 2. Simulate complete Register (pushReplacement to Login)
        Navigator.pushReplacement(
          savedContext,
          MaterialPageRoute(
            builder: (context) {
              savedContext = context;
              return const Scaffold(body: Text('Login Screen Mock 2'));
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Login Screen Mock 2'), findsOneWidget);

        // 3. Simulate Login Success (pushAndRemoveUntil to HalamanUtama)
        Navigator.pushAndRemoveUntil(
          savedContext,
          MaterialPageRoute(
            builder: (context) => HalamanUtama(user: testUser),
          ),
          (route) => false,
        );
        await tester.pumpAndSettle();

        // Verify HalamanUtama is displayed
        expect(find.byType(HalamanUtama), findsOneWidget);
        expect(find.text('Trips'), findsOneWidget);

        // Verify NO back button exists
        expect(find.byType(BackButton), findsNothing);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

        // Verify Navigator stack has no route to pop
        expect(Navigator.canPop(tester.element(find.byType(HalamanUtama))), isFalse);
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
