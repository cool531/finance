import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luxury_finance_app/Model.dart';
import 'package:luxury_finance_app/finance_provider.dart';

Future<FinanceProvider> loadedProvider() async {
  final provider = FinanceProvider();
  // _init() runs in the constructor; give it a turn of the event loop.
  while (provider.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a fresh install starts empty and needs onboarding', () async {
    final provider = await loadedProvider();

    expect(provider.isOnboarded, isFalse);
    expect(provider.expenses, isEmpty,
        reason: 'demo data must never appear on a real first launch');
    expect(provider.goals, isEmpty);
    expect(provider.monthlyIncome, 0);
    expect(provider.userName, isEmpty);
  });

  test('onboarding stores the numbers and opens the app', () async {
    final provider = await loadedProvider();

    await provider.completeOnboarding(
      name: '  Ploy  ',
      monthlyIncome: 45000,
      savingsGoal: 10000,
    );

    expect(provider.isOnboarded, isTrue);
    expect(provider.userName, 'Ploy');
    expect(provider.hasIncome, isTrue);
    expect(provider.monthlyIncome, 45000);
    expect(provider.savingsGoal, 10000);
    expect(provider.expenses, isEmpty);
  });

  test('onboarding can opt into the sample data', () async {
    final provider = await loadedProvider();

    await provider.completeOnboarding(
      name: 'Ploy',
      monthlyIncome: 32000,
      savingsGoal: 50000,
      withSampleData: true,
    );

    expect(provider.expenses, isNotEmpty);
    expect(provider.goals, isNotEmpty);
    // The demo needs figures to measure against, or the dashboard opens on a
    // negative balance.
    expect(provider.monthlyIncome, greaterThan(0));
    expect(provider.savingsGoal, greaterThan(0));
    expect(provider.totalSavedSelectedMonth, greaterThan(0));
    expect(provider.hasDataForSelectedMonth, isTrue,
        reason: 'the viewed month should jump to where the sample data lives');
  });

  test('a saved expense persists and lands in its own month', () async {
    final provider = await loadedProvider();
    await provider.completeOnboarding(
      name: 'Ploy',
      monthlyIncome: 30000,
      savingsGoal: 5000,
    );

    await provider.createExpense(
      amount: 185,
      category: ExpenseCategory.food,
      title: 'Starbucks',
      date: DateTime(2026, 3, 9),
      necessity: NecessityLevel.wantOnly,
    );

    expect(provider.expenses.length, 1);
    expect(provider.selectedMonth, DateTime(2026, 3));
    expect(provider.totalExpenseSelectedMonth, 185);

    // A second provider reads the same SharedPreferences store.
    final reopened = await loadedProvider();
    expect(reopened.expenses.single.title, 'Starbucks');
    expect(reopened.isOnboarded, isTrue);
  });

  test('clearing data empties everything', () async {
    final provider = await loadedProvider();
    await provider.completeOnboarding(
      name: 'Ploy',
      monthlyIncome: 30000,
      savingsGoal: 5000,
      withSampleData: true,
    );

    await provider.clearAllData();

    expect(provider.expenses, isEmpty);
    expect(provider.goals, isEmpty);
    expect(provider.totalExpenseSelectedMonth, 0);
  });
}
