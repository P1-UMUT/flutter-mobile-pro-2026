// test/widget/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('login screen renders form fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Tekrar hoş geldiniz'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
