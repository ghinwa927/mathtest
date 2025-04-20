import 'package:flutter_test/flutter_test.dart';
import 'package:mathtest/main.dart';  // Corrected import path

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      themeName: 'Light',
      appBarColorIndex: 0,
    ));

    // Verify that our app has the title.
    expect(find.text('Memory Match'), findsOneWidget);
  });
}
