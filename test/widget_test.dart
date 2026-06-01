// Basistest für die ZFA Lernapp.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zfa_lernapp/widgets/cinematic_background.dart';

void main() {
  testWidgets('CinematicBackground rendert sein Kind',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CinematicBackground(
          child: Text('ZFA', textDirection: TextDirection.ltr),
        ),
      ),
    );

    expect(find.text('ZFA'), findsOneWidget);
  });
}
