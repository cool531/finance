import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'CategoryDonutchart.dart';
import 'Expenselistscreen.dart';
import 'MainNavigation.dart';
import 'Model.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'theme_controller.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onAddExpense;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
    required this.onAddExpense,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final categoryTotals = provider.categoryTotalsSelectedMonth;
        final recent = provider.expensesForSelectedMonth.take(4).toList();

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, kBottomBarInset),
                children: [
                  _Header(provider: provider),
                  const SizedBox(height: 18),
                  _HeroBalanceCard(
                    provider: provider,
                    hidden: _balanceHidden,
                    onToggleHidden: () =>
                        setState(() => _balanceHidden = !_balanceHidden),
                  ),
                  const SizedBox(height: 14),
                  _StatsRow(provider: provider, hidden: _balanceHidden),
                  const SizedBox(height: 22),
                  _InsightCard(
                    provider: provider,
                    onSeeAll: () => widget.onNavigateToTab(2),
                  ),
                  const SizedBox(height: 22),
                  _SavingsGoalCard(provider: provider),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'สัดส่วนรายจ่าย',
                    subtitle: formatMonthYearThai(provider.selectedMonth),
                    actionLabel: 'ดูทั้งหมด',
                    onAction: () => widget.onNavigateToTab(2),
                  ),
                  const SizedBox(height: 12),
                  _DonutSection(
                    totals: categoryTotals,
                    total: provider.totalExpenseSelectedMonth,
                    onAdd: widget.onAddExpense,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'รายการล่าสุด',
                    actionLabel: 'ดูทั้งหมด',
                    onAction: () => widget.onNavigateToTab(1),
                  ),
                  const SizedBox(height: 8),
                  if (recent.isEmpty)
                    AppCard(
                      child: EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'ยังไม่มีรายการในเดือนนี้',
                        message: 'เริ่มบันทึกรายจ่ายรายการแรกของเดือนได้เลย',
                        actionLabel: 'เพิ่มรายจ่าย',
                        onAction: widget.onAddExpense,
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < recent.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                indent: 12,
                                endIndent: 12,
                                color: context.cs.outlineVariant,
                              ),
                            ExpenseTile(expense: recent[i]),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  final FinanceProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final initials = provider.userName.trim().isEmpty
        ? '?'
        : provider.userName.trim().substring(0, 1).toUpperCase();

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.goldGradient,
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: context.tt.bodySmall),
              Text(
                provider.userName,
                style: context.tt.titleLarge?.copyWith(fontSize: 19),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        HeaderIconButton(
          icon: context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          tooltip: 'สลับธีม (${theme.label})',
          onTap: () => theme.toggle(context),
        ),
        const SizedBox(width: 8),
        HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'การแจ้งเตือน',
          showBadge: provider.aiRecommendations.isNotEmpty,
          onTap: () => showInsightsSheet(context, provider),
        ),
      ],
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'สวัสดีตอนเช้า 🌤';
    if (hour < 17) return 'สวัสดีตอนบ่าย ☀️';
    return 'สวัสดีตอนเย็น 🌙';
  }
}

// ---------------------------------------------------------------------------
// Hero balance card
// ---------------------------------------------------------------------------
class _HeroBalanceCard extends StatelessWidget {
  final FinanceProvider provider;
  final bool hidden;
  final VoidCallback onToggleHidden;

  const _HeroBalanceCard({
    required this.provider,
    required this.hidden,
    required this.onToggleHidden,
  });

  @override
  Widget build(BuildContext context) {
    final balance = provider.totalSavedSelectedMonth;
    final change = provider.monthOverMonthChangePercent;
    final spentLess = change <= 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'เงินเหลือใช้',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onToggleHidden,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white70,
                      size: 17,
                    ),
                  ),
                  const Spacer(),
                  MonthPillSwitcher(provider: provider),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedAmount(
                        value: balance,
                        hidden: hidden,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  if (provider.totalExpensePreviousMonth > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            spentLess
                                ? Icons.trending_down_rounded
                                : Icons.trending_up_rounded,
                            size: 13,
                            color: spentLess
                                ? AppColors.goldLight
                                : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatSignedPercent(change),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Flexible(
                    child: _HeroMiniStat(
                      icon: Icons.south_west_rounded,
                      label: 'รายรับ',
                      value: provider.totalIncomeSelectedMonth,
                      hidden: hidden,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: _HeroMiniStat(
                      icon: Icons.north_east_rounded,
                      label: 'รายจ่าย',
                      value: provider.totalExpenseSelectedMonth,
                      hidden: hidden,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ดูรายงาน',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool hidden;

  const _HeroMiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.hidden,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        AnimatedAmount(
          value: value,
          hidden: hidden,
          compact: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Compact month stepper that sits on the dark hero card.
class MonthPillSwitcher extends StatelessWidget {
  final FinanceProvider provider;
  const MonthPillSwitcher({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _arrow(Icons.chevron_left_rounded, provider.previousMonth),
          Text(
            formatMonthYearShortThai(provider.selectedMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          _arrow(Icons.chevron_right_rounded, provider.nextMonth),
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------
class _StatsRow extends StatelessWidget {
  final FinanceProvider provider;
  final bool hidden;

  const _StatsRow({required this.provider, required this.hidden});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'รายรับ',
            amount: provider.totalIncomeSelectedMonth,
            icon: Icons.account_balance_wallet_rounded,
            amountColor: context.cs.primary,
            hidden: hidden,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'รายจ่าย',
            amount: provider.totalExpenseSelectedMonth,
            icon: Icons.shopping_cart_rounded,
            amountColor: AppColors.danger,
            hidden: hidden,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'เก็บได้',
            amount: provider.totalSavedSelectedMonth,
            icon: Icons.savings_rounded,
            amountColor: AppColors.success,
            hidden: hidden,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Insight card — the top rule-based recommendation
// ---------------------------------------------------------------------------
class _InsightCard extends StatelessWidget {
  final FinanceProvider provider;
  final VoidCallback onSeeAll;

  const _InsightCard({required this.provider, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final recs = provider.aiRecommendations;
    if (recs.isEmpty) return const SizedBox.shrink();
    final rec = recs.first;

    return AppCard(
      onTap: () => showInsightsSheet(context, provider),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: rec.type.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(rec.icon, color: rec.type.color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TagChip(label: rec.type.label, color: rec.type.color),
                    const SizedBox(width: 6),
                    Text(
                      '${recs.length} ข้อแนะนำ',
                      style: context.tt.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  rec.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.message,
                  style: context.tt.bodySmall?.copyWith(height: 1.45),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet listing every recommendation for the selected month.
void showInsightsSheet(BuildContext context, FinanceProvider provider) {
  final recs = provider.aiRecommendations;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ข้อแนะนำสำหรับคุณ', style: context.tt.titleLarge),
            const SizedBox(height: 2),
            Text(
              formatMonthYearThai(provider.selectedMonth),
              style: context.tt.bodySmall,
            ),
            const SizedBox(height: 14),
            if (recs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: 'ยังไม่มีข้อแนะนำ',
                  message: 'บันทึกรายจ่ายเพิ่มอีกสักหน่อย ระบบจะเริ่มวิเคราะห์ให้',
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: recs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final rec = recs[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(rec.icon, color: rec.type.color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rec.message,
                                  style: context.tt.bodySmall
                                      ?.copyWith(height: 1.45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Savings goal
// ---------------------------------------------------------------------------
class _SavingsGoalCard extends StatelessWidget {
  final FinanceProvider provider;
  const _SavingsGoalCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final progress = provider.savingsGoalProgress;

    return AppCard(
      onTap: () => showEditNumberDialog(
        context,
        title: 'เป้าหมายเงินออมต่อเดือน',
        initialValue: provider.savingsGoal,
        onSave: provider.setSavingsGoal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, size: 17, color: AppColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'เป้าหมายเงินออมเดือนนี้',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(value: progress, gradient: AppColors.goldGradient),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'ออมแล้ว ${formatBaht(provider.totalSavedSelectedMonth)}',
                  style: context.tt.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'เป้า ${formatBaht(provider.savingsGoal)}',
                style: context.tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.edit_rounded, size: 13),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Donut
// ---------------------------------------------------------------------------
class _DonutSection extends StatelessWidget {
  final Map<ExpenseCategory, double> totals;
  final double total;
  final VoidCallback onAdd;

  const _DonutSection({
    required this.totals,
    required this.total,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.donut_large_rounded,
          title: 'ยังไม่มีรายจ่ายเดือนนี้',
          message: 'เพิ่มรายการแรกเพื่อดูสัดส่วนการใช้เงินของคุณ',
          actionLabel: 'เพิ่มรายจ่าย',
          onAction: onAdd,
        ),
      );
    }

    return AppCard(
      child: Row(
        children: [
          DonutChart(
            data: totals,
            size: 136,
            strokeWidth: 22,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCompactBaht(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'รวมรายจ่าย',
                  style: context.tt.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: totals.entries.take(6).map((entry) {
                final pct = total > 0 ? entry.value / total * 100 : 0.0;
                return LegendRow(
                  color: entry.key.color,
                  label: entry.key.label,
                  trailing: '${pct.toStringAsFixed(0)}%',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared dialogs
// ---------------------------------------------------------------------------
void showEditNumberDialog(
  BuildContext context, {
  required String title,
  required double initialValue,
  required Future<void> Function(double) onSave,
  String suffix = 'บาท',
}) {
  final controller = TextEditingController(
    text: initialValue == initialValue.roundToDouble()
        ? initialValue.toStringAsFixed(0)
        : initialValue.toString(),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: context.tt.titleMedium),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(suffixText: suffix),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(controller.text.trim());
            if (value != null && value >= 0) {
              onSave(value);
              Navigator.of(context).pop();
            }
          },
          child: const Text('บันทึก'),
        ),
      ],
    ),
  );
}

void showEditTextDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  required Future<void> Function(String) onSave,
}) {
  final controller = TextEditingController(text: initialValue);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: context.tt.titleMedium),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) {
              onSave(value);
              Navigator.of(context).pop();
            }
          },
          child: const Text('บันทึก'),
        ),
      ],
    ),
  );
}
