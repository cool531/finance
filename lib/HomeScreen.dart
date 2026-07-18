import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'finance_provider.dart';
import 'appcolors.dart';
import 'categorydonutchart.dart';
import 'statpill.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeExpenses;
  final VoidCallback onSeeAnalytics;

  const HomeScreen({
    super.key,
    required this.onSeeExpenses,
    required this.onSeeAnalytics,
  });

  String _money(double v) => NumberFormat('#,##0').format(v);

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final greeting = _greeting();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${fp.userName} 👋',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blackTie,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.diamond,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.blackTie),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.sapphire, AppColors.sapphireLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('เงินคงเหลือ',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(width: 6),
                      Icon(Icons.visibility_outlined, size: 16, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '฿${_money(fp.walletBalance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('ดูรายละเอียด >',
                      style: TextStyle(color: AppColors.golden, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: StatPill(
                    label: 'รายรับเดือนนี้',
                    value: '฿${_money(fp.totalIncome)}',
                    valueColor: AppColors.success,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatPill(
                    label: 'รายจ่าย',
                    value: '฿${_money(fp.totalExpense)}',
                    valueColor: AppColors.danger,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatPill(
                    label: 'เก็บแล้ว',
                    value: '฿${_money(fp.totalSaved)}',
                    valueColor: AppColors.golden,
                    icon: Icons.savings_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Goal progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ความคืบหน้าเป้าหมาย',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                        Text('เป้าหมาย ฿${_money(fp.monthlySavingGoal)}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(fp.savingGoalProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.sapphire),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fp.savingGoalProgress.toDouble(),
                        minHeight: 9,
                        backgroundColor: AppColors.icyLake,
                        valueColor: const AlwaysStoppedAnimation(AppColors.golden),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('สัดส่วนรายจ่าย',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                GestureDetector(
                  onTap: onSeeAnalytics,
                  child: const Text('ดูทั้งหมด >',
                      style: TextStyle(fontSize: 12.5, color: AppColors.sapphire, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CategoryDonutChart(
                  data: fp.categoryBreakdown,
                  totalExpense: fp.totalExpense,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }
}