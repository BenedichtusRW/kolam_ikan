// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/simple_login_screen.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: SimpleLoginScreen()));

    // Verify that our login screen elements are present
    expect(find.text('Kolam Ikan Monitor'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(2)); // Email and password fields
    expect(find.text('Masuk'), findsOneWidget); // Login button
  });

  testWidgets('Form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SimpleLoginScreen()));

    // Find the login button and tap it without filling the form
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    await tester.pump();

    // Check for validation errors
    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('Email validation works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SimpleLoginScreen()));

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    
    // Tap login button
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    await tester.pump();

    // Check for email validation error
    expect(find.text('Format email tidak valid'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SimpleLoginScreen()));

    // Find the visibility toggle
    final visibilityToggle = find.byIcon(Icons.visibility);

    // Verify password is initially obscured
    expect(visibilityToggle, findsOneWidget);

    // Tap the visibility toggle
    await tester.tap(visibilityToggle);
    await tester.pump();

    // Verify the icon changed to visibility_off
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('Valid form submission shows success message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SimpleLoginScreen()));

    // Enter valid credentials
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    
    // Tap login button
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    await tester.pump();

    // Wait for any animations/snackbar to appear
    await tester.pump(Duration(milliseconds: 100));

    // Check for success message
    expect(find.text('Login berhasil!'), findsOneWidget);
  });
}
