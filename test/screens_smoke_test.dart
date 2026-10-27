import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luxury_finance_app/AddExpensescreen.dart';
import 'package:luxury_finance_app/AnalysisScreen.dart';
import 'package:luxury_finance_app/AppTheme.dart';
import 'package:luxury_finance_app/Expenselistscreen.dart';
import 'package:luxury_finance_app/GoalsScreen.dart';
import 'package:luxury_finance_app/HomeScreen.dart';
import 'package:luxury_finance_app/MainNavigation.dart';
import 'package:luxury_finance_app/finance_provider.dart';
import 'package:luxury_finance_app/onboarding_screen.dart';
import 'package:luxury_finance_app/report_screen.dart';
import 'package:luxury_finance_app/settings_screen.dart';
import 'package:luxury_finance_app/theme_controller.dart';

/// Every screen is pumped in both themes on a phone-sized surface: a layout
/// overflow or a build error fails the test instead of showing up as a blank
/// screen on the device.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreen(WidgetTester tester, Widget screen, Brightness b) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FinanceProvider()),
          ChangeNotifierProvider(create: (_) => ThemeController()),
        ],
        child: MaterialApp(
          theme: b == Brightness.dark ? AppTheme.dark : AppTheme.light,
          home: screen,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  }

  for (final brightness in Brightness.values) {
    final name = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('home renders ($name)', (tester) async {
      await pumpScreen(
        tester,
        HomeScreen(onNavigateToTab: (_) {}, onAddExpense: () {}),
        brightness,
      );
    });

    testWidgets('expense list renders ($name)', (tester) async {
      await pumpScreen(tester, const ExpenseListScreen(), brightness);
    });

    testWidgets('analysis renders ($name)', (tester) async {
      await pumpScreen(tester, const AnalysisScreen(), brightness);
    });

    testWidgets('goals renders ($name)', (tester) async {
      await pumpScreen(tester, const GoalsScreen(), brightness);
    });

    testWidgets('report renders ($name)', (tester) async {
      await pumpScreen(tester, const ReportScreen(), brightness);
    });

    testWidgets('settings renders ($name)', (tester) async {
      await pumpScreen(tester, const SettingsScreen(), brightness);
    });

    testWidgets('add expense renders ($name)', (tester) async {
      await pumpScreen(tester, const AddExpenseScreen(), brightness);
    });

    testWidgets('main navigation renders ($name)', (tester) async {
      await pumpScreen(tester, const MainNavigation(), brightness);
    });

    testWidgets('onboarding renders ($name)', (tester) async {
      await pumpScreen(tester, const OnboardingScreen(), brightness);
    });
  }
}
