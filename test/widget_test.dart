import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/main.dart';

void main() {
  testWidgets('App launches and renders splash brand elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the initial splash / brand screen is rendered
    expect(find.text('TRIDE'), findsOneWidget);
    expect(find.text('Discover. Plan. Go.'), findsOneWidget);
  });
}
