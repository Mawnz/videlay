import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:videlay_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app starts and displays the home page.
    expect(find.text('OpenCV Demo Home'), findsOneWidget);
    expect(find.text('Go to Camera View'), findsOneWidget);
  });
}
