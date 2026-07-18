import 'package:flutter/material.dart';
import 'CategoryModel.dart';
import 'GoalModel.dart';
import 'TransactionModel.dart';

class CategorySpend {
  final CategoryModel category;
  final double amount;
  final double percent; // 0-100

  CategorySpend({
    required this.category,
    required this.amount,
    required this.percent,
  });
}

class AIRecommendation {
  final IconData icon;
  final String title;
  final String detail;

  AIRecommendation({
    required this.icon,
    required this.title,
    required this.detail,
  });
}

/// Central app state: transactions, goals, monthly targets, and all the
/// derived numbers the UI needs (totals, category breakdown, AI insights).
class FinanceProvider extends ChangeNotifier {
  FinanceProvider() {
    _seedData();
  }

  final String userName = 'Patchanon';

  double monthlySavingGoal = 50000; // เป้าหมายเก็บเงินต่อเดือน
  DateTime selectedMonth = DateTime(2026, 7);

  final List<TransactionModel> _transactions = [];
  final List<GoalModel> _goals = [];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<GoalModel> get goals => List.unmodifiable(_goals);

  // ---------------------------------------------------------------------
  // Seed data matching the mock-up so the app looks alive on first run.
  // ---------------------------------------------------------------------
  void _seedData() {
    final m = selectedMonth;
    _transactions.addAll([
      TransactionModel(
        id: 't1',
        amount: 185,
        categoryId: AppCategories.food.id,
        detail: 'Starbucks',
        date: DateTime(m.year, m.month, 1),
        necessity: Necessity.nonEssential,
      ),
      TransactionModel(
        id: 't2',
        amount: 45,
        categoryId: AppCategories.transport.id,
        detail: 'BTS',
        date: DateTime(m.year, m.month, 2),
        necessity: Necessity.essential,
      ),
      TransactionModel(
        id: 't3',
        amount: 3200,
        categoryId: AppCategories.shopping.id,
        detail: 'Nike',
        date: DateTime(m.year, m.month, 3),
        necessity: Necessity.justWanted,
      ),
      TransactionModel(
        id: 't4',
        amount: 279,
        categoryId: AppCategories.subscription.id,
        detail: 'Netflix',
        date: DateTime(m.year, m.month, 4),
        necessity: Necessity.nonEssential,
      ),
      TransactionModel(
        id: 't5',
        amount: 5000,
        categoryId: AppCategories.investment.id,
        detail: 'ลงทุนหุ้น',
        date: DateTime(m.year, m.month, 5),
        necessity: Necessity.essential,
      ),
      TransactionModel(
        id: 't6',
        amount: 89,
        categoryId: AppCategories.food.id,
        detail: '7-Eleven',
        date: DateTime(m.year, m.month, 6),
        necessity: Necessity.essential,
      ),
      TransactionModel(
        id: 't7',
        amount: 120,
        categoryId: AppCategories.transport.id,
        detail: 'Grab',
        date: DateTime(m.year, m.month, 7),
        necessity: Necessity.nonEssential,
      ),
      // extra history so "17 ครั้ง" coffee stat has something behind it
      for (int i = 0; i < 16; i++)
        TransactionModel(
          id: 'coffee$i',
          amount: 150 + (i % 4) * 10,
          categoryId: AppCategories.food.id,
          detail: 'กาแฟเช้า',
          date: DateTime(m.year, m.month, 1 + (i % 27)),
          necessity: Necessity.nonEssential,
        ),
      TransactionModel(
        id: 'income1',
        amount: 32000,
        categoryId: AppCategories.other.id,
        detail: 'เงินเดือน',
        date: DateTime(m.year, m.month, 1),
        necessity: Necessity.essential,
        type: TxType.income,
      ),
    ]);

    _goals.addAll([
      GoalModel(
        id: 'g1',
        title: 'ซื้อรถยนต์',
        targetAmount: 150000,
        currentAmount: 67500,
        icon: Icons.directions_car_filled_rounded,
        deadline: DateTime(2027, 12, 31),
      ),
      GoalModel(
        id: 'g2',
        title: 'ท่องเที่ยวญี่ปุ่น',
        targetAmount: 50000,
        currentAmount: 18400,
        icon: Icons.flight_takeoff_rounded,
        deadline: DateTime(2026, 11, 30),
      ),
      const GoalModel(
        id: 'g3',
        title: 'เงินสำรองฉุกเฉิน',
        targetAmount: 50000,
        currentAmount: 25000,
        icon: Icons.shield_rounded,
        deadline: null,
      ),
    ]);
  }

  // ---------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------
  void addTransaction({
    required double amount,
    required String categoryId,
    required String detail,
    required DateTime date,
    required Necessity necessity,
    TxType type = TxType.expense,
  }) {
    _transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amount,
        categoryId: categoryId,
        detail: detail,
        date: date,
        necessity: necessity,
        type: type,
      ),
    );
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateGoalProgress(String goalId, double newCurrentAmount) {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return;
    _goals[idx] = _goals[idx].copyWith(currentAmount: newCurrentAmount);
    notifyListeners();
  }

  void addGoal(GoalModel goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void setMonthlySavingGoal(double value) {
    monthlySavingGoal = value;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth = month;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Derived data for the selected month
  // ---------------------------------------------------------------------
  List<TransactionModel> get monthTransactions => _transactions
      .where((t) =>
          t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  double get totalIncome => monthTransactions
      .where((t) => t.type == TxType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => monthTransactions
      .where((t) => t.type == TxType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalSaved => totalIncome - totalExpense;

  /// Overall wallet balance shown on the home screen (income - expense).
  double get walletBalance => totalSaved;

  double get savingGoalProgress =>
      monthlySavingGoal <= 0 ? 0 : (totalSaved / monthlySavingGoal).clamp(0, 1);

  List<CategorySpend> get categoryBreakdown {
    final expenses = monthTransactions.where((t) => t.type == TxType.expense);
    final Map<String, double> totals = {};
    for (final t in expenses) {
      totals.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final total = totals.values.fold(0.0, (a, b) => a + b);
    final list = totals.entries.map((e) {
      final pct = total <= 0 ? 0.0 : (e.value / total) * 100;
      return CategorySpend(
        category: AppCategories.byId(e.key),
        amount: e.value,
        percent: pct,
      );
    }).toList();
    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  double get nonEssentialTotal => monthTransactions
      .where((t) =>
          t.type == TxType.expense && t.necessity != Necessity.essential)
      .fold(0, (sum, t) => sum + t.amount);

  double get essentialTotal => monthTransactions
      .where((t) =>
          t.type == TxType.expense && t.necessity == Necessity.essential)
      .fold(0, (sum, t) => sum + t.amount);

  /// Simple rule-based "AI" recommendations derived from spending patterns.
  List<AIRecommendation> get aiRecommendations {
    final recs = <AIRecommendation>[];
    final breakdown = categoryBreakdown;

    // 1. Warn if any single category eats too much of the budget.
    for (final c in breakdown) {
      if (c.percent >= 25 && c.category.id != AppCategories.investment.id) {
        recs.add(AIRecommendation(
          icon: c.category.icon,
          title:
              'คุณใช้เงินหมวด ${c.category.nameTh} มากกว่าค่าเฉลี่ย ${c.percent.toStringAsFixed(0)}%',
          detail:
              'ควรลดงบประมาณลง ${(c.amount * 0.15).toStringAsFixed(0)} บาท จะช่วยเพิ่มเงินออมได้ ${(c.amount * 0.15).toStringAsFixed(0)} บาท/เดือน',
        ));
      }
    }

    // 2. Frequent small purchases (e.g. coffee) detection.
    final coffeeTx = monthTransactions
        .where((t) => t.detail.contains('กาแฟ') || t.detail.contains('Starbucks'))
        .toList();
    if (coffeeTx.length >= 5) {
      final coffeeTotal = coffeeTx.fold(0.0, (s, t) => s + t.amount);
      recs.add(AIRecommendation(
        icon: Icons.coffee_rounded,
        title: 'คุณซื้อกาแฟแพงไปแล้ว ${coffeeTx.length} ครั้ง',
        detail:
            'รวม ${coffeeTotal.toStringAsFixed(0)} บาท หากลดเหลือสัปดาห์ละ 2 ครั้ง จะประหยัดได้ ${(coffeeTotal * 0.5).toStringAsFixed(0)} บาท/เดือน',
      ));
    }

    // 3. Non-essential ratio warning.
    if (totalExpense > 0 && (nonEssentialTotal / totalExpense) > 0.35) {
      recs.add(AIRecommendation(
        icon: Icons.warning_amber_rounded,
        title: 'รายจ่ายที่ไม่จำเป็นสูงถึง '
            '${((nonEssentialTotal / totalExpense) * 100).toStringAsFixed(0)}%',
        detail: 'ลองตั้งงบ "อยากได้เฉยๆ" ไม่เกิน 20% ของรายจ่ายทั้งหมด',
      ));
    }

    // 4. Positive reinforcement when saving well.
    if (totalIncome > 0 && (totalSaved / totalIncome) >= 0.3) {
      recs.add(AIRecommendation(
        icon: Icons.emoji_events_rounded,
        title: 'เยี่ยมมาก! เดือนนี้คุณออมได้ '
            '${((totalSaved / totalIncome) * 100).toStringAsFixed(0)}% ของรายรับ',
        detail: 'รักษาระดับนี้ไว้ อีก ${_monthsToReachGoal()} เดือนจะถึงเป้าหมายที่ตั้งไว้',
      ));
    }

    if (recs.isEmpty) {
      recs.add(AIRecommendation(
        icon: Icons.thumb_up_rounded,
        title: 'การใช้จ่ายเดือนนี้อยู่ในเกณฑ์ดี',
        detail: 'ไม่มีหมวดที่ใช้จ่ายเกินเกณฑ์ ลองตั้งเป้าหมายใหม่เพื่อสร้างแรงจูงใจเพิ่มเติม',
      ));
    }
    return recs;
  }

  int _monthsToReachGoal() {
    if (totalSaved <= 0) return 0;
    final remain =
        goals.fold(0.0, (s, g) => s + (g.targetAmount - g.currentAmount));
    if (remain <= 0) return 0;
    return (remain / totalSaved).ceil();
  }

  /// A 0-100 "financial health" score used in the monthly report.
  int get financialScore {
    if (totalIncome <= 0) return 0;
    final saveRatio = (totalSaved / totalIncome).clamp(0, 1);
    final essentialRatio =
        totalExpense <= 0 ? 1 : (essentialTotal / totalExpense).clamp(0, 1);
    final score = (saveRatio * 60) + (essentialRatio * 40);
    return score.clamp(0, 100).round();
  }

  List<String> get scoreStrengths {
    final list = <String>[];
    if (totalIncome > 0 && totalSaved / totalIncome >= 0.2) {
      list.add('ออมเงินได้มากขึ้น');
    }
    if (totalExpense > 0 && totalExpense <= totalIncome) {
      list.add('ไม่ใช้เงินเกินรายรับ');
    }
    if (categoryBreakdown.any((c) => c.category.id == AppCategories.investment.id)) {
      list.add('มีการลงทุน');
    }
    if (list.isEmpty) list.add('เริ่มบันทึกรายจ่ายอย่างสม่ำเสมอ');
    return list;
  }

  List<String> get scoreImprovements {
    final list = <String>[];
    final shopping = categoryBreakdown
        .where((c) => c.category.id == AppCategories.shopping.id)
        .toList();
    if (shopping.isNotEmpty && shopping.first.percent > 20) {
      list.add('ลดค่าใช้จ่ายในหมวด Shopping');
    }
    final coffeeCount = monthTransactions
        .where((t) => t.detail.contains('กาแฟ') || t.detail.contains('Starbucks'))
        .length;
    if (coffeeCount >= 5) list.add('ลดการซื้อกาแฟ');
    list.add('ตั้งงบอาหารต่อวัน');
    return list;
  }
}