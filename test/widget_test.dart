import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/main.dart';
import 'package:test/theme/luxury_theme.dart';

void main() {
  testWidgets('AetherCalc app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AetherCalcApp());
    expect(find.text('AETHER'), findsOneWidget);
    expect(find.text('Scientific'), findsOneWidget);
  });

  testWidgets('Theme toggle switches between Dark and Light mode', (WidgetTester tester) async {
    LuxuryTheme.isDarkNotifier.value = true;
    await tester.pumpWidget(const AetherCalcApp());

    // Initially in Dark mode, toggle button shows 'LIGHT' (to switch to light mode)
    expect(LuxuryTheme.isDark, true);
    expect(find.text('LIGHT'), findsOneWidget);

    // Tap theme toggle button
    await tester.tap(find.text('LIGHT'));
    await tester.pump(const Duration(milliseconds: 300));

    // Now in Light mode, toggle button shows 'DARK' (to switch to dark mode)
    expect(LuxuryTheme.isDark, false);
    expect(find.text('DARK'), findsOneWidget);

    // Tap again to switch back to Dark mode
    await tester.tap(find.text('DARK'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(LuxuryTheme.isDark, true);
    expect(find.text('LIGHT'), findsOneWidget);
  });

  testWidgets('Haptics and SFX toggle button switches between SFX ON and MUTED', (WidgetTester tester) async {
    await tester.pumpWidget(const AetherCalcApp());

    expect(find.text('SFX ON'), findsOneWidget);

    await tester.tap(find.text('SFX ON'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MUTED'), findsOneWidget);

    await tester.tap(find.text('MUTED'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SFX ON'), findsOneWidget);
  });

  testWidgets('Tapping brand logo opens About System Modal', (WidgetTester tester) async {
    await tester.pumpWidget(const AetherCalcApp());

    await tester.tap(find.text('AETHER'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('AETHERCALC PRO'), findsOneWidget);
    expect(find.text('Version 1.0.0 Enterprise • com.aethercalc.pro'), findsOneWidget);

    // Dismiss bottom sheet via Navigator pop
    final modalContext = tester.element(find.text('AETHERCALC PRO'));
    Navigator.of(modalContext).pop();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('AETHERCALC PRO'), findsNothing);
  });
}
