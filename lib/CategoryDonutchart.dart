import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'finance_provider.dart';
import 'appcolors.dart';

class CategoryDonutChart extends StatelessWidget {
  final List<CategorySpend> data;
  final double totalExpense;

  const CategoryDonutChart({
    super.key,
    required this.data,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'ยังไม่มีรายจ่ายในเดือนนี้',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    sections: data
                        .map((c) => PieChartSectionData(
                              value: c.amount,
                              color: c.category.color,
                              radius: 26,
                              showTitle: false,
                            ))
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '฿${totalExpense.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.blackTie,
                      ),
                    ),
                    const Text(
                      'รวมรายจ่าย',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: data.take(5).map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: c.category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.category.nameTh,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.blackTie),
                        ),
                      ),
                      Text(
                        '${c.percent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackTie,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}