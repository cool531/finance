import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model.dart';

/// Central state holder for the whole app: expenses, goals, income, and every
/// derived number the screens display (totals, category splits, the monthly
/// financial score, and the rule-based "AI" recommendations).
///
/// Data is persisted locally on-device with SharedPreferences as plain JSON,
/// so nothing ever leaves the phone and no backend or API key is required.
class FinanceProvider extends ChangeNotifier {
  static const _expensesKey = 'fa_expenses_v1';
  static const _goalsKey = 'fa_goals_v1';
  static const _incomeKey = 'fa_monthly_income_v1';
  static const _savingsGoalKey = 'fa_savings_goal_v1';
  static const _userNameKey = 'fa_user_name_v1';
  static const _onboardedKey = 'fa_onboarded_v1';

  bool isLoading = true;

  /// False until the person finishes the welcome flow, which is what decides
  /// whether the app opens on onboarding or on the dashboard.
  bool isOnboarded = false;

  String userName = '';

  List<Expense> _expenses = [];
  List<Goal> _goals = [];
  double _monthlyIncome = 0;
  double _savingsGoal = 0;

  /// The month currently being viewed across Home / List / Analysis / Report.
  /// Starts on the current month, then [_init] falls back to the most recent
  /// month that actually has data so the app never opens on an empty screen.
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  FinanceProvider() {
    _init();
  }

  // ---------------------------------------------------------------------
  // Public read-only getters
  // ---------------------------------------------------------------------
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Goal> get goals => List.unmodifiable(_goals);
  double get monthlyIncome => _monthlyIncome;
  double get savingsGoal => _savingsGoal;
  DateTime get selectedMonth => _selectedMonth;

  // ---------------------------------------------------------------------
  // Init / persistence
  // ---------------------------------------------------------------------
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // A fresh install starts empty. Sample data only ever arrives because
    // someone asked for it, from onboarding or from Settings.
    final expensesRaw = prefs.getString(_expensesKey);
    if (expensesRaw != null && expensesRaw.isNotEmpty) {
      final list = jsonDecode(expensesRaw) as List;
      _expenses = list
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final goalsRaw = prefs.getString(_goalsKey);
    if (goalsRaw != null && goalsRaw.isNotEmpty) {
      final list = jsonDecode(goalsRaw) as List;
      _goals =
          list.map((g) => Goal.fromJson(g as Map<String, dynamic>)).toList();
    }

    _monthlyIncome = prefs.getDouble(_incomeKey) ?? 0;
    _savingsGoal = prefs.getDouble(_savingsGoalKey) ?? 0;
    userName = prefs.getString(_userNameKey) ?? '';
    isOnboarded = prefs.getBool(_onboardedKey) ?? false;

    if (_expensesForMonth(_selectedMonth).isEmpty) {
      final latest = latestMonthWithData;
      if (latest != null) _selectedMonth = latest;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _persistExpenses([SharedPreferences? p]) async {
    final prefs = p ?? await SharedPreferences.getInstance();
    final raw = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_expensesKey, raw);
  }

  Future<void> _persistGoals([SharedPreferences? p]) async {
    final prefs = p ?? await SharedPreferences.getInstance();
    final raw = jsonEncode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString(_goalsKey, raw);
  }

  // ---------------------------------------------------------------------
  // Expense CRUD
  // ---------------------------------------------------------------------
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _persistExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
      await _persistExpenses();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persistExpenses();
  }

  // ---------------------------------------------------------------------
  // Goal CRUD
  // ---------------------------------------------------------------------
  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    notifyListeners();
    await _persistGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      notifyListeners();
      await _persistGoals();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    await _persistGoals();
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final newAmount = (goal.currentAmount + amount)
          .clamp(0.0, goal.targetAmount)
          .toDouble();
      _goals[index] = goal.copyWith(currentAmount: newAmount);
      notifyListeners();
      await _persistGoals();
    }
  }

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------
  Future<void> setMonthlyIncome(double value) async {
    _monthlyIncome = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_incomeKey, value);
  }

  Future<void> setSavingsGoal(double value) async {
    _savingsGoal = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_savingsGoalKey, value);
  }

  Future<void> setUserName(String value) async {
    userName = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, value);
  }

  // ---------------------------------------------------------------------
  // Month navigation
  // ---------------------------------------------------------------------
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void jumpToMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  DateTime get _previousMonthDate =>
      DateTime(_selectedMonth.year, _selectedMonth.month - 1);

  // ---------------------------------------------------------------------
  // Derived data - selected month
  // ---------------------------------------------------------------------
  List<Expense> _expensesForMonth(DateTime month) {
    final list = _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Expense> get expensesForSelectedMonth => _expensesForMonth(_selectedMonth);
  List<Expense> get expensesForPreviousMonth => _expensesForMonth(_previousMonthDate);

  double get totalExpenseSelectedMonth =>
      expensesForSelectedMonth.fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpensePreviousMonth =>
      expensesForPreviousMonth.fold(0.0, (sum, e) => sum + e.amount);

  /// Simplified model: income is a flat figure the person sets, rather than
  /// itemised entries (matching the "add expense only" scope of the design).
  double get totalIncomeSelectedMonth => _monthlyIncome;

  double get totalSavedSelectedMonth =>
      totalIncomeSelectedMonth - totalExpenseSelectedMonth;

  double get savingsGoalProgress => _savingsGoal <= 0
      ? 0.0
      : (totalSavedSelectedMonth / _savingsGoal).clamp(0.0, 1.0).toDouble();

  Map<ExpenseCategory, double> get categoryTotalsSelectedMonth {
    final map = <ExpenseCategory, double>{};
    for (final e in expensesForSelectedMonth) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sortedEntries) e.key: e.value};
  }

  /// Positive = spent more than last month, negative = spent less (good).
  double get monthOverMonthChangePercent {
    final prev = totalExpensePreviousMonth;
    if (prev <= 0) return 0;
    return ((totalExpenseSelectedMonth - prev) / prev) * 100;
  }

  double _sumWhere(bool Function(Expense) test) =>
      expensesForSelectedMonth.where(test).fold(0.0, (s, e) => s + e.amount);

  double get necessaryTotalSelectedMonth =>
      _sumWhere((e) => e.necessity == NecessityLevel.necessary);
  double get notNecessaryTotalSelectedMonth =>
      _sumWhere((e) => e.necessity == NecessityLevel.notNecessary);
  double get wantOnlyTotalSelectedMonth =>
      _sumWhere((e) => e.necessity == NecessityLevel.wantOnly);

  // ---------------------------------------------------------------------
  // Financial score (0-100)
  // ---------------------------------------------------------------------
  int get financialScore {
    final income = totalIncomeSelectedMonth;
    if (income <= 0) return 0;
    final expense = totalExpenseSelectedMonth;
    final savingsRate = (income - expense) / income;
    final goodSpendRatio = expense > 0
        ? ((necessaryTotalSelectedMonth + wantOnlyTotalSelectedMonth * 0.5) /
            expense)
        : 1.0;

    double score = 0;
    score += savingsRate.clamp(0.0, 1.0) * 55;
    score += goodSpendRatio.clamp(0.0, 1.0) * 30;
    score += expense <= income ? 15 : 0;
    if (savingsRate < 0) score -= 20;

    return score.clamp(0, 100).round();
  }

  String get financialScoreLabel {
    final s = financialScore;
    if (s >= 85) return 'ดีเยี่ยม';
    if (s >= 70) return 'ดี';
    if (s >= 50) return 'ปานกลาง';
    return 'ควรปรับปรุง';
  }

  int get financialScoreStars =>
      (financialScore / 20).round().clamp(0, 5).toInt();

  // ---------------------------------------------------------------------
  // "AI" recommendations - rule-based, computed from real data
  // ---------------------------------------------------------------------
  List<Recommendation> get aiRecommendations {
    final recs = <Recommendation>[];
    final totals = categoryTotalsSelectedMonth;
    final totalExpense = totalExpenseSelectedMonth;
    if (totalExpense <= 0) {
      recs.add(const Recommendation(
        title: 'เริ่มบันทึกรายจ่าย',
        message: 'ยังไม่มีรายจ่ายในเดือนนี้ ลองเพิ่มรายการแรกเพื่อให้ระบบเริ่มวิเคราะห์ได้',
        icon: Icons.edit_note_rounded,
        type: RecommendationType.tip,
      ));
      return recs;
    }

    if (totalExpense > totalIncomeSelectedMonth) {
      recs.add(const Recommendation(
        title: 'ใช้จ่ายเกินรายรับ',
        message: 'เดือนนี้รายจ่ายมากกว่ารายรับ ลองทบทวนรายการที่ไม่จำเป็นก่อนเป็นอันดับแรก',
        icon: Icons.warning_amber_rounded,
        type: RecommendationType.warning,
      ));
    }

    if (totals.isNotEmpty) {
      final top = totals.entries.first;
      final pct = top.value / totalExpense * 100;
      if (pct >= 28) {
        recs.add(Recommendation(
          title: 'คุณใช้เงินกับ ${top.key.label} มากกว่าค่าเฉลี่ย ${pct.toStringAsFixed(0)}%',
          message:
              'คิดเป็น ฿${top.value.toStringAsFixed(0)} ของรายจ่ายทั้งหมด ลองตั้งงบให้หมวดนี้ อาจช่วยเพิ่มเงินออมได้พอสมควร',
          icon: top.key.icon,
          type: RecommendationType.warning,
        ));
      }
    }

    final coffeeShops = ['starbucks', 'คาเฟ่', 'กาแฟ', 'coffee', 'อเมซอน'];
    final coffeeExpenses = expensesForSelectedMonth
        .where((e) => coffeeShops.any((k) => e.title.toLowerCase().contains(k)))
        .toList();
    if (coffeeExpenses.length >= 4) {
      final total = coffeeExpenses.fold(0.0, (s, e) => s + e.amount);
      final avg = total / coffeeExpenses.length;
      final targetCount = (coffeeExpenses.length / 2).floor();
      final saving = avg * (coffeeExpenses.length - targetCount);
      recs.add(Recommendation(
        title: 'คุณซื้อกาแฟไปแล้ว ${coffeeExpenses.length} ครั้ง',
        message:
            'รวม ฿${total.toStringAsFixed(0)} หากลดเหลือ $targetCount ครั้งต่อเดือน จะประหยัดได้ประมาณ ฿${saving.toStringAsFixed(0)}',
        icon: Icons.coffee_rounded,
        type: RecommendationType.tip,
      ));
    }

    final wantOnly = wantOnlyTotalSelectedMonth;
    if (wantOnly / totalExpense >= 0.18) {
      recs.add(Recommendation(
        title: 'รายจ่ายแบบ "อยากได้เฉยๆ" ค่อนข้างสูง',
        message:
            'คิดเป็น ${(wantOnly / totalExpense * 100).toStringAsFixed(0)}% ของรายจ่ายทั้งหมด (฿${wantOnly.toStringAsFixed(0)}) ลองรอ 24 ชั่วโมงก่อนตัดสินใจซื้อครั้งถัดไป',
        icon: Icons.favorite_border_rounded,
        type: RecommendationType.tip,
      ));
    }

    final income = totalIncomeSelectedMonth;
    final saved = totalSavedSelectedMonth;
    if (income > 0 && saved > 0 && (saved / income) >= 0.3) {
      recs.add(Recommendation(
        title: 'ออมเงินได้ดีมาก',
        message:
            'เดือนนี้คุณออมได้ ${((saved / income) * 100).toStringAsFixed(0)}% ของรายรับ ลองพิจารณานำเงินส่วนเกินไปลงทุนต่อเนื่อง',
        icon: Icons.savings_rounded,
        type: RecommendationType.praise,
      ));
    }

    final invested = totals[ExpenseCategory.investment] ?? 0.0;
    if (invested > 0) {
      recs.add(Recommendation(
        title: 'มีการลงทุนต่อเนื่อง',
        message: 'เดือนนี้คุณจัดสรรเงิน ฿${invested.toStringAsFixed(0)} ไปกับการลงทุน ทำได้ดีต่อไปเรื่อยๆ',
        icon: Icons.trending_up_rounded,
        type: RecommendationType.praise,
      ));
    }

    return recs;
  }

  List<String> get whatWentWell {
    final list = <String>[];
    final saved = totalSavedSelectedMonth;
    final income = totalIncomeSelectedMonth;
    if (saved > 0) {
      list.add('ออมเงินได้ ฿${saved.toStringAsFixed(0)} ในเดือนนี้');
    }
    if (totalExpenseSelectedMonth <= income) {
      list.add('ไม่ใช้เงินเกินรายรับ');
    }
    final invested =
        categoryTotalsSelectedMonth[ExpenseCategory.investment] ?? 0.0;
    if (invested > 0) {
      list.add('มีการลงทุนอย่างต่อเนื่อง');
    }
    final necessaryRatio = totalExpenseSelectedMonth > 0
        ? necessaryTotalSelectedMonth / totalExpenseSelectedMonth
        : 0.0;
    if (necessaryRatio >= 0.5) {
      list.add('รายจ่ายส่วนใหญ่เป็นของที่จำเป็น');
    }
    if (list.isEmpty) {
      list.add('เริ่มบันทึกรายจ่ายได้อย่างสม่ำเสมอแล้ว');
    }
    return list;
  }

  List<String> get whatToImprove {
    final list = <String>[];
    final totals = categoryTotalsSelectedMonth;
    final totalExpense = totalExpenseSelectedMonth;
    if (totals.isNotEmpty && totalExpense > 0) {
      final top = totals.entries.first;
      if (top.value / totalExpense >= 0.28) {
        list.add('ลดค่าใช้จ่ายในหมวด ${top.key.label}');
      }
    }
    final coffeeCount = expensesForSelectedMonth
        .where((e) => e.title.toLowerCase().contains('starbucks'))
        .length;
    if (coffeeCount >= 4) {
      list.add('ลดการซื้อกาแฟนอกบ้าน');
    }
    if (totalExpense > 0 && wantOnlyTotalSelectedMonth / totalExpense >= 0.18) {
      list.add('ตั้งงบสำหรับรายจ่าย "อยากได้เฉยๆ" ต่อเดือน');
    }
    if (totalExpense > totalIncomeSelectedMonth) {
      list.add('ควบคุมรายจ่ายให้ไม่เกินรายรับ');
    }
    if (list.isEmpty) {
      list.add('รักษาพฤติกรรมการใช้เงินแบบนี้ต่อไป');
    }
    return list;
  }

  // ---------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------
  List<Expense> _seedExpenses() {
    int counter = 0;
    String nextId() => 'seed_${counter++}';
    Expense e(int y, int m, int d, String title, double amount,
            ExpenseCategory cat, NecessityLevel n) =>
        Expense(
          id: nextId(),
          amount: amount,
          category: cat,
          title: title,
          date: DateTime(y, m, d),
          necessity: n,
        );

    const food = ExpenseCategory.food;
    const transport = ExpenseCategory.transport;
    const shopping = ExpenseCategory.shopping;
    const investment = ExpenseCategory.investment;
    const subscription = ExpenseCategory.subscription;

    const nec = NecessityLevel.necessary;
    const notNec = NecessityLevel.notNecessary;
    const want = NecessityLevel.wantOnly;

    return [
      // --- June 2026 (previous month, complete) ---
      e(2026, 6, 1, '7-Eleven', 65, food, nec),
      e(2026, 6, 1, 'Netflix', 279, subscription, want),
      e(2026, 6, 2, 'ข้าวแกงปากซอย', 45, food, nec),
      e(2026, 6, 2, 'BTS', 45, transport, nec),
      e(2026, 6, 3, 'Starbucks', 175, food, want),
      e(2026, 6, 3, 'Uniqlo', 1290, shopping, want),
      e(2026, 6, 4, 'ก๋วยเตี๋ยวเรือ', 60, food, nec),
      e(2026, 6, 5, 'Grab', 150, transport, want),
      e(2026, 6, 5, 'ลงทุนหุ้นรายเดือน', 3000, investment, nec),
      e(2026, 6, 5, 'iCloud+', 65, subscription, nec),
      e(2026, 6, 6, '7-Eleven', 89, food, nec),
      e(2026, 6, 7, 'KFC', 259, food, notNec),
      e(2026, 6, 8, 'เติมน้ำมัน', 500, transport, nec),
      e(2026, 6, 9, 'Starbucks', 180, food, want),
      e(2026, 6, 9, 'Nike', 2890, shopping, want),
      e(2026, 6, 10, 'ตลาดสด', 450, food, nec),
      e(2026, 6, 11, 'BTS', 45, transport, nec),
      e(2026, 6, 12, 'ข้าวมันไก่', 50, food, nec),
      e(2026, 6, 14, 'Starbucks', 175, food, want),
      e(2026, 6, 15, 'Grab', 180, transport, want),
      e(2026, 6, 16, 'ชาบูมื้อเย็น', 550, food, want),
      e(2026, 6, 17, 'Lazada - เคสมือถือ', 650, shopping, notNec),
      e(2026, 6, 18, '7-Eleven', 72, food, nec),
      e(2026, 6, 19, 'MRT', 35, transport, nec),
      e(2026, 6, 20, "McDonald's", 220, food, notNec),
      e(2026, 6, 20, 'กองทุนสำรองเลี้ยงชีพ', 1000, investment, nec),
      e(2026, 6, 22, 'Starbucks', 190, food, want),
      e(2026, 6, 23, 'เติมน้ำมัน', 500, transport, nec),
      e(2026, 6, 24, 'IKEA - ของใช้บ้าน', 1850, shopping, nec),
      e(2026, 6, 25, 'ตลาดสด', 380, food, nec),
      e(2026, 6, 26, 'Grab', 120, transport, want),
      e(2026, 6, 27, '7-Eleven', 65, food, nec),
      e(2026, 6, 28, 'BTS', 45, transport, nec),
      e(2026, 6, 29, 'ส้มตำไก่ย่าง', 120, food, nec),

      // --- July 2026 (current month, through the 17th) ---
      e(2026, 7, 1, 'Starbucks', 185, food, want),
      e(2026, 7, 2, 'BTS', 45, transport, nec),
      e(2026, 7, 3, 'Nike', 3200, shopping, notNec),
      e(2026, 7, 4, 'Netflix', 279, subscription, want),
      e(2026, 7, 5, 'ลงทุนหุ้นรายเดือน', 3000, investment, nec),
      e(2026, 7, 6, '7-Eleven', 89, food, nec),
      e(2026, 7, 7, 'Grab', 120, transport, want),
      e(2026, 7, 8, 'Starbucks', 175, food, want),
      e(2026, 7, 8, 'ข้าวมันไก่', 50, food, nec),
      e(2026, 7, 9, 'BTS', 45, transport, nec),
      e(2026, 7, 9, 'Lazada - เคสมือถือ', 390, shopping, want),
      e(2026, 7, 10, 'ตลาดสด', 420, food, nec),
      e(2026, 7, 10, 'Spotify', 149, subscription, want),
      e(2026, 7, 11, 'Grab', 130, transport, want),
      e(2026, 7, 11, 'ก๋วยเตี๋ยว', 55, food, nec),
      e(2026, 7, 12, '7-Eleven', 68, food, nec),
      e(2026, 7, 12, 'เติมน้ำมัน', 500, transport, nec),
      e(2026, 7, 13, 'Starbucks', 185, food, want),
      e(2026, 7, 13, 'H&M', 1590, shopping, notNec),
      e(2026, 7, 14, 'ส้มตำไก่ย่าง', 180, food, nec),
      e(2026, 7, 14, 'BTS', 45, transport, nec),
      e(2026, 7, 15, 'ซูชิมื้อเย็น', 650, food, want),
      e(2026, 7, 15, 'iCloud+', 65, subscription, nec),
      e(2026, 7, 16, '7-Eleven', 75, food, nec),
      e(2026, 7, 16, 'กองทุนสำรองเลี้ยงชีพ', 1000, investment, nec),
      e(2026, 7, 17, 'Starbucks', 185, food, want),
      e(2026, 7, 17, 'KFC', 250, food, notNec),
      e(2026, 7, 17, 'Grab', 110, transport, want),
    ];
  }

  List<Goal> _seedGoals() {
    return [
      Goal(
        id: 'goal_car',
        title: 'ซื้อรถยนต์',
        targetAmount: 150000,
        currentAmount: 68000,
        deadline: DateTime(2027, 12, 31),
        iconType: GoalIconType.car,
      ),
      Goal(
        id: 'goal_japan',
        title: 'ท่องเที่ยวญี่ปุ่น',
        targetAmount: 50000,
        currentAmount: 19500,
        deadline: DateTime(2026, 11, 30),
        iconType: GoalIconType.travel,
      ),
      const Goal(
        id: 'goal_emergency',
        title: 'เงินสำรองฉุกเฉิน',
        targetAmount: 60000,
        currentAmount: 32000,
        iconType: GoalIconType.emergency,
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // Derived data used by the charts and the report
  // ---------------------------------------------------------------------

  /// Every month that has at least one expense, newest first.
  List<DateTime> get monthsWithData {
    final keys = <String, DateTime>{};
    for (final e in _expenses) {
      final month = DateTime(e.date.year, e.date.month);
      keys['${month.year}-${month.month}'] = month;
    }
    final list = keys.values.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  DateTime? get latestMonthWithData {
    final months = monthsWithData;
    return months.isEmpty ? null : months.first;
  }

  bool get hasDataForSelectedMonth => expensesForSelectedMonth.isNotEmpty;

  /// True until the person records a monthly income; the dashboard shows what
  /// they spent rather than a negative "money left" until then.
  bool get hasIncome => _monthlyIncome > 0;

  /// Total spent on each day of the selected month, indexed day 1..n.
  List<double> get dailyTotalsSelectedMonth {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final totals = List<double>.filled(daysInMonth, 0);
    for (final e in expensesForSelectedMonth) {
      totals[e.date.day - 1] += e.amount;
    }
    return totals;
  }

  /// Expenses grouped by day, newest day first — what the list screen renders.
  Map<DateTime, List<Expense>> get expensesGroupedByDay {
    final map = <DateTime, List<Expense>>{};
    for (final e in expensesForSelectedMonth) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    return map;
  }

  List<Expense> topExpensesSelectedMonth({int limit = 5}) {
    final list = expensesForSelectedMonth.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list.take(limit).toList();
  }

  Map<NecessityLevel, double> get necessityTotalsSelectedMonth => {
        NecessityLevel.necessary: necessaryTotalSelectedMonth,
        NecessityLevel.notNecessary: notNecessaryTotalSelectedMonth,
        NecessityLevel.wantOnly: wantOnlyTotalSelectedMonth,
      };

  Map<ExpenseCategory, double> get categoryTotalsPreviousMonth {
    final map = <ExpenseCategory, double>{};
    for (final e in expensesForPreviousMonth) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  /// Average spend per day so far in the selected month.
  double get averagePerDaySelectedMonth {
    final list = expensesForSelectedMonth;
    if (list.isEmpty) return 0;
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _selectedMonth.year && now.month == _selectedMonth.month;
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final elapsed = isCurrentMonth
        ? now.day
        : list.map((e) => e.date.day).reduce((a, b) => a > b ? a : b);
    return totalExpenseSelectedMonth / elapsed.clamp(1, lastDay);
  }

  /// Rough end-of-month projection based on the current burn rate.
  double get projectedMonthTotal {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return averagePerDaySelectedMonth * lastDay;
  }

  /// Text search inside the selected month (title or category name).
  List<Expense> searchSelectedMonth(String query, {ExpenseCategory? category}) {
    final q = query.trim().toLowerCase();
    return expensesForSelectedMonth.where((e) {
      final matchesCategory = category == null || e.category == category;
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.category.label.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // ---------------------------------------------------------------------
  // Convenience writes
  // ---------------------------------------------------------------------

  /// Creates an expense with a generated id and saves it.
  Future<Expense> createExpense({
    required double amount,
    required ExpenseCategory category,
    required String title,
    required DateTime date,
    required NecessityLevel necessity,
  }) async {
    final expense = Expense(
      id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      category: category,
      title: title,
      date: date,
      necessity: necessity,
    );
    await addExpense(expense);
    jumpToMonth(date);
    return expense;
  }

  /// Finishes the welcome flow: stores the person's own numbers and flips the
  /// app over to the dashboard.
  Future<void> completeOnboarding({
    required String name,
    required double monthlyIncome,
    required double savingsGoal,
    bool withSampleData = false,
  }) async {
    userName = name.trim().isEmpty ? 'คุณ' : name.trim();
    // The sample data is a demo of a full month, so it needs figures to be
    // measured against — otherwise the dashboard opens on a negative balance.
    _monthlyIncome =
        (withSampleData && monthlyIncome <= 0) ? 32000 : monthlyIncome;
    _savingsGoal = (withSampleData && savingsGoal <= 0) ? 50000 : savingsGoal;
    isOnboarded = true;

    if (withSampleData) {
      _expenses = _seedExpenses();
      _goals = _seedGoals();
      final latest = latestMonthWithData;
      if (latest != null) _selectedMonth = latest;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
    await prefs.setDouble(_incomeKey, _monthlyIncome);
    await prefs.setDouble(_savingsGoalKey, _savingsGoal);
    await prefs.setBool(_onboardedKey, true);
    await _persistExpenses(prefs);
    await _persistGoals(prefs);
  }

  /// Wipes expenses and goals and loads the sample data.
  Future<void> restoreSampleData() async {
    _expenses = _seedExpenses();
    _goals = _seedGoals();
    final latest = latestMonthWithData;
    if (latest != null) _selectedMonth = latest;
    notifyListeners();
    await _persistExpenses();
    await _persistGoals();
  }

  /// Removes every expense and goal from the device.
  Future<void> clearAllData() async {
    _expenses = [];
    _goals = [];
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    notifyListeners();
    await _persistExpenses();
    await _persistGoals();
  }

}