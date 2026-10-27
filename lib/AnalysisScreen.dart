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

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final totals = provider.categoryTotalsSelectedMonth;
    final total = provider.totalExpenseSelectedMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('วิเคราะห์การใช้เงิน')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, kBottomBarInset),
          children: [
            Center(
              child: MonthSwitcher(
                month: provider.selectedMonth,
                onPrevious: provider.previousMonth,
                onNext: provider.nextMonth,
              ),
            ),
            const SizedBox(height: 18),
            _ScoreCard(provider: provider),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'รายจ่ายรายวัน',
              subtitle:
                  'เฉลี่ย ${formatBaht(provider.averagePerDaySelectedMonth.roundToDouble())} ต่อวัน',
            ),
            const SizedBox(height: 12),
            _DailyBarChartCard(provider: provider),
            const SizedBox(height: 22),
            const SectionHeader(title: 'แยกตามหมวดหมู่'),
            const SizedBox(height: 12),
            if (totals.isEmpty)
              const AppCard(
                child: EmptyState(
                  icon: Icons.donut_large_rounded,
                  title: 'ยังไม่มีข้อมูลเดือนนี้',
                  message: 'เพิ่มรายจ่ายเพื่อดูการวิเคราะห์',
                ),
              )
            else
              _CategoryBreakdownCard(provider: provider, totals: totals, total: total),
            const SizedBox(height: 22),
            const SectionHeader(
              title: 'จำเป็น vs ไม่จำเป็น',
              subtitle: 'ดูว่าเงินหมดไปกับอะไรจริงๆ',
            ),
            const SizedBox(height: 12),
            _NecessityCard(provider: provider),
            const SizedBox(height: 22),
            const SectionHeader(title: '5 รายการที่จ่ายมากที่สุด'),
            const SizedBox(height: 8),
            _TopExpensesCard(provider: provider),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _ScoreCard extends StatelessWidget {
  final FinanceProvider provider;
  const _ScoreCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final score = provider.financialScore;
    final stars = provider.financialScoreStars;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ScoreRing(
            value: score / 100,
            size: 116,
            stroke: 11,
            gradient: score >= 70
                ? const [AppColors.success, AppColors.aqua]
                : score >= 50
                    ? const [AppColors.warning, AppColors.gold]
                    : const [AppColors.danger, Color(0xFFF08C6A)],
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    v.round().toString(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Text(
                  'จาก 100',
                  style: context.tt.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สุขภาพการเงิน', style: context.tt.bodySmall),
                const SizedBox(height: 2),
                Text(
                  provider.financialScoreLabel,
                  style: context.tt.headlineMedium?.copyWith(fontSize: 21),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 17,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'คาดว่าสิ้นเดือนจะใช้ราว ${formatCompactBaht(provider.projectedMonthTotal)}',
                  style: context.tt.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _DailyBarChartCard extends StatelessWidget {
  final FinanceProvider provider;
  const _DailyBarChartCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final daily = provider.dailyTotalsSelectedMonth;
    final maxValue = daily.isEmpty ? 0.0 : daily.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.bar_chart_rounded,
          title: 'ยังไม่มีรายจ่ายเดือนนี้',
          message: 'กราฟจะแสดงเมื่อมีรายการแล้ว',
        ),
      );
    }

    final busiestDay = daily.indexOf(maxValue) + 1;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatBaht(maxValue),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'สูงสุดวันที่ $busiestDay',
                style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gap = daily.length > 28 ? 2.0 : 3.0;
                final barWidth =
                    (constraints.maxWidth - gap * (daily.length - 1)) /
                        daily.length;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < daily.length; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      _Bar(
                        width: barWidth,
                        heightFactor: daily[i] / maxValue,
                        amount: daily[i],
                        day: i + 1,
                        highlight: daily[i] == maxValue,
                        month: provider.selectedMonth,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: context.tt.bodySmall?.copyWith(fontSize: 10.5)),
              Text(
                '${(daily.length / 2).round()}',
                style: context.tt.bodySmall?.copyWith(fontSize: 10.5),
              ),
              Text(
                '${daily.length}',
                style: context.tt.bodySmall?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double heightFactor;
  final double amount;
  final int day;
  final bool highlight;
  final DateTime month;

  const _Bar({
    required this.width,
    required this.heightFactor,
    required this.amount,
    required this.day,
    required this.highlight,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final bar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: heightFactor.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => FractionallySizedBox(
        heightFactor: amount <= 0 ? 0.02 : (v * 0.95 + 0.05),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width / 2),
            gradient: amount <= 0
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: highlight
                        ? const [AppColors.gold, AppColors.goldLight]
                        : [cs.primary, cs.primary.withValues(alpha: 0.45)],
                  ),
            color: amount <= 0 ? cs.surfaceContainerHighest : null,
          ),
        ),
      ),
    );

    return SizedBox(
      width: width,
      height: double.infinity,
      child: Tooltip(
        message: amount <= 0
            ? '$day ${formatMonthYearShortThai(month)} · ไม่มีรายจ่าย'
            : '$day ${formatMonthYearShortThai(month)} · ${formatBaht(amount)}',
        child: Align(alignment: Alignment.bottomCenter, child: bar),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _CategoryBreakdownCard extends StatelessWidget {
  final FinanceProvider provider;
  final Map<ExpenseCategory, double> totals;
  final double total;

  const _CategoryBreakdownCard({
    required this.provider,
    required this.totals,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final previous = provider.categoryTotalsPreviousMonth;

    return AppCard(
      child: Column(
        children: [
          Center(
            child: DonutChart(
              data: totals,
              size: 156,
              strokeWidth: 24,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatCompactBaht(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${provider.expensesForSelectedMonth.length} รายการ',
                    style: context.tt.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...totals.entries.map((entry) {
            final pct = total > 0 ? entry.value / total : 0.0;
            final prev = previous[entry.key] ?? 0;
            final delta = prev > 0 ? (entry.value - prev) / prev * 100 : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(entry.key.icon, size: 15, color: entry.key.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.label,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (delta != null && delta.abs() >= 1) ...[
                        TagChip(
                          label: formatSignedPercent(delta),
                          color: delta > 0
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        formatBaht(entry.value),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  AppProgressBar(
                    value: pct,
                    fillColor: entry.key.color,
                    height: 7,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _NecessityCard extends StatelessWidget {
  final FinanceProvider provider;
  const _NecessityCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totals = provider.necessityTotalsSelectedMonth;
    final total = totals.values.fold<double>(0, (s, v) => s + v);

    if (total <= 0) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.balance_rounded,
          title: 'ยังไม่มีข้อมูล',
          message: 'ระบุว่าแต่ละรายการจำเป็นหรือไม่ เพื่อดูสัดส่วนนี้',
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Row(
                children: totals.entries
                    .where((e) => e.value > 0)
                    .map(
                      (e) => Expanded(
                        flex: (e.value / total * 1000).round().clamp(1, 1000),
                        child: Container(color: e.key.color),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...totals.entries.map((e) {
            final pct = e.value / total * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(e.key.icon, size: 15, color: e.key.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.key.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatBaht(e.value),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _TopExpensesCard extends StatelessWidget {
  final FinanceProvider provider;
  const _TopExpensesCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final top = provider.topExpensesSelectedMonth();

    if (top.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.format_list_numbered_rounded,
          title: 'ยังไม่มีรายการ',
          message: 'เพิ่มรายจ่ายเพื่อดูอันดับการใช้เงิน',
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < top.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: context.cs.outlineVariant,
              ),
            ExpenseTile(expense: top[i]),
          ],
        ],
      ),
    );
  }
}
