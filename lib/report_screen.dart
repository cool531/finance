import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'Model.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';

/// A calm, readable month-in-review: the numbers, what went well, and what to
/// work on next month.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปรายเดือน')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: MonthSwitcher(
              month: provider.selectedMonth,
              onPrevious: provider.previousMonth,
              onNext: provider.nextMonth,
            ),
          ),
          const SizedBox(height: 20),
          _SummaryCard(provider: provider),
          const SizedBox(height: 22),
          const SectionHeader(title: 'สิ่งที่ทำได้ดี'),
          const SizedBox(height: 10),
          _BulletCard(
            items: provider.whatWentWell,
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'สิ่งที่ควรปรับปรุง'),
          const SizedBox(height: 10),
          _BulletCard(
            items: provider.whatToImprove,
            color: AppColors.warning,
            icon: Icons.lightbulb_rounded,
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'ข้อแนะนำจากข้อมูลของคุณ'),
          const SizedBox(height: 10),
          ...provider.aiRecommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: rec.type.color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(rec.icon, color: rec.type.color, size: 19),
                    ),
                    const SizedBox(width: 13),
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
                            style: context.tt.bodySmall?.copyWith(height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final FinanceProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final income = provider.totalIncomeSelectedMonth;
    final expense = provider.totalExpenseSelectedMonth;
    final saved = provider.totalSavedSelectedMonth;
    final rate = income > 0 ? (saved / income * 100) : 0.0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatMonthYearThai(provider.selectedMonth),
            style: context.tt.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            '${provider.expensesForSelectedMonth.length} รายการ · คะแนน ${provider.financialScore}/100 (${provider.financialScoreLabel})',
            style: context.tt.bodySmall,
          ),
          const SizedBox(height: 18),
          _Row(label: 'รายรับ', value: income, color: context.cs.primary),
          Divider(height: 22, color: context.cs.outlineVariant),
          _Row(label: 'รายจ่าย', value: expense, color: AppColors.danger),
          Divider(height: 22, color: context.cs.outlineVariant),
          _Row(
            label: 'คงเหลือ / เก็บได้',
            value: saved,
            color: saved >= 0 ? AppColors.success : AppColors.danger,
            bold: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.cs.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded,
                    size: 17, color: AppColors.success),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'อัตราการออม ${rate.toStringAsFixed(0)}% ของรายรับ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'เฉลี่ย ${formatCompactBaht(provider.averagePerDaySelectedMonth)}/วัน',
                  style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;

  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          formatBaht(value),
          style: TextStyle(
            fontSize: bold ? 19 : 16,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _BulletCard extends StatelessWidget {
  final List<String> items;
  final Color color;
  final IconData icon;

  const _BulletCard({
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 17, color: color),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 13.5, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
