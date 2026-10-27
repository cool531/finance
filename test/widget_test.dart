import 'package:flutter_test/flutter_test.dart';
import 'package:luxury_finance_app/Model.dart';
import 'package:luxury_finance_app/formatters.dart';

void main() {
  group('formatters', () {
    test('whole baht amounts drop the decimals', () {
      expect(formatBaht(1234), '\u0e3f1,234');
      expect(formatBaht(1234.5), '\u0e3f1,234.50');
      expect(formatBaht(-250), '-\u0e3f250');
    });

    test('compact amounts shorten thousands and millions', () {
      expect(formatCompactBaht(1500), '\u0e3f1.5K');
      expect(formatCompactBaht(32000), '\u0e3f32K');
      expect(formatCompactBaht(2500000), '\u0e3f2.5M');
    });

    test('Thai dates render day and month', () {
      expect(formatDayMonthThai(DateTime(2026, 7, 17)), '17 \u0e01.\u0e04.');
      expect(
        formatRelativeDayThai(
          DateTime(2026, 7, 16),
          now: DateTime(2026, 7, 17),
        ),
        '\u0e40\u0e21\u0e37\u0e48\u0e2d\u0e27\u0e32\u0e19',
      );
    });
  });

  group('Goal', () {
    test('progress is clamped and remaining never goes negative', () {
      const goal = Goal(
        id: 'g',
        title: 'test',
        targetAmount: 1000,
        currentAmount: 1500,
        iconType: GoalIconType.other,
      );
      expect(goal.progress, 1.0);
      expect(goal.remaining, 0.0);
      expect(goal.isComplete, isTrue);
    });
  });

  group('Expense', () {
    test('survives a JSON round trip', () {
      final expense = Expense(
        id: 'e1',
        amount: 185,
        category: ExpenseCategory.food,
        title: 'Starbucks',
        date: DateTime(2026, 7, 17),
        necessity: NecessityLevel.wantOnly,
      );
      final copy = Expense.fromJson(expense.toJson());
      expect(copy.id, expense.id);
      expect(copy.amount, expense.amount);
      expect(copy.category, expense.category);
      expect(copy.necessity, expense.necessity);
      expect(copy.date, expense.date);
    });
  });
}
