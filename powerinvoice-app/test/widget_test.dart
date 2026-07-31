// PowerInvoice app widget test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:powerinvoice/main.dart';
import 'package:powerinvoice/services/app_protection.dart';

void main() {
  testWidgets('PowerInvoice app shows activation screen when not activated', (WidgetTester tester) async {
    // Initialize SharedPreferences with no activation
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame
    await tester.pumpWidget(const PowerInvoiceApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the Activation screen is shown
    expect(find.text('PowerInvoice'), findsWidgets);
    expect(find.text('App Activation Required'), findsOneWidget);
    expect(find.text('Activation Code'), findsOneWidget);
  });

  testWidgets('PowerInvoice app shows main screen when activated', (WidgetTester tester) async {
    // Enable test mode to skip device ID verification
    AppProtection.enableTestMode();

    // Initialize SharedPreferences with activation enabled
    SharedPreferences.setMockInitialValues({
      'app_activated': true,
      'device_id': 'test_device_123',
    });

    // Build our app and trigger a frame
    await tester.pumpWidget(const PowerInvoiceApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the Dashboard is shown
    expect(find.text('Dashboard'), findsWidgets);

    // Verify bottom navigation items exist
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);

    // Cleanup: disable test mode
    AppProtection.disableTestMode();
  });
}
