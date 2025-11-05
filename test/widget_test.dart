// Basic Flutter widget test for Seizure시계 app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epi_care_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EpiCareApp());

    // Verify that the app loads with the main navigation
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
