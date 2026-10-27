import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AddExpensescreen.dart';
import 'AppColors.dart';
import 'MainNavigation.dart';
import 'Model.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';

class ExpenseListScreen extends StatefulWidget {
  final VoidCallback? onAddExpense;
  const ExpenseListScreen({super.key, this.onAddExpense});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ExpenseCategory? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final results = provider.searchSelectedMonth(_query, category: _category);
    final total = results.fold<double>(0, (s, e) => s + e.amount);
    final grouped = _groupByDay(results);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายจ่ายทั้งหมด'),
        actions: [
          IconButton(
            tooltip: 'เพิ่มรายจ่าย',
            icon: const Icon(Icons.add_rounded),
            onPressed: widget.onAddExpense ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddExpenseScreen(),
                      ),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      MonthSwitcher(
                        month: provider.selectedMonth,
                        onPrevious: provider.previousMonth,
                        onNext: provider.nextMonth,
                        compact: true,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${results.length} รายการ',
                            style: context.tt.bodySmall,
                          ),
                          Text(
                            formatBaht(total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ค้นหารายการ เช่น Starbucks',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            _CategoryFilterBar(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: grouped.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, kBottomBarInset),
                      children: [
                        AppCard(
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: _query.isEmpty && _category == null
                                ? 'ยังไม่มีรายจ่ายในเดือนนี้'
                                : 'ไม่พบรายการที่ค้นหา',
                            message: _query.isEmpty && _category == null
                                ? 'กดปุ่ม + เพื่อเริ่มบันทึกรายการแรก'
                                : 'ลองเปลี่ยนคำค้นหรือหมวดหมู่',
                            actionLabel: _query.isEmpty && _category == null
                                ? 'เพิ่มรายจ่าย'
                                : 'ล้างตัวกรอง',
                            onAction: () {
                              if (_query.isEmpty && _category == null) {
                                widget.onAddExpense?.call();
                              } else {
                                _searchCtrl.clear();
                                setState(() {
                                  _query = '';
                                  _category = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, kBottomBarInset),
                      itemCount: grouped.length,
                      itemBuilder: (context, i) {
                        final day = grouped.keys.elementAt(i);
                        final items = grouped[day]!;
                        final dayTotal =
                            items.fold<double>(0, (s, e) => s + e.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                              child: Row(
                                children: [
                                  Text(
                                    formatRelativeDayThai(day),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatWeekdayThai(day),
                                    style: context.tt.bodySmall
                                        ?.copyWith(fontSize: 11.5),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatBaht(dayTotal),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      color: context.cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Column(
                                children: [
                                  for (var j = 0; j < items.length; j++) ...[
                                    if (j > 0)
                                      Divider(
                                        height: 1,
                                        indent: 12,
                                        endIndent: 12,
                                        color: context.cs.outlineVariant,
                                      ),
                                    ExpenseTile(
                                      expense: items[j],
                                      showDate: false,
                                      dismissible: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<Expense>> _groupByDay(List<Expense> list) {
    final sorted = list.toList()..sort((a, b) => b.date.compareTo(a.date));
    final map = <DateTime, List<Expense>>{};
    for (final e in sorted) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    return map;
  }
}

/// Horizontally scrolling "ทั้งหมด / อาหาร / เดินทาง ..." filter chips.
class _CategoryFilterBar extends StatelessWidget {
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory?> onChanged;

  const _CategoryFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'ทั้งหมด',
            color: context.cs.primary,
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          ...ExpenseCategory.values.map(
            (c) => _Chip(
              label: c.label,
              icon: c.icon,
              color: c.color,
              selected: selected == c,
              onTap: () => onChanged(selected == c ? null : c),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? Colors.white : color,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One expense row. Used on Home, in the list, and in the report.
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final bool showDate;
  final bool dismissible;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.showDate = true,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddExpenseScreen(existing: expense),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        child: Row(
          children: [
            CategoryIconBubble(category: expense.category, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${expense.category.label} · '),
                        if (showDate)
                          TextSpan(text: formatDayMonthThai(expense.date))
                        else
                          TextSpan(
                            text: expense.necessity.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: expense.necessity.color,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '-${formatBaht(expense.amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );

    if (!dismissible) return row;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        final provider = context.read<FinanceProvider>();
        final removed = expense;
        provider.deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบ "${removed.title}" แล้ว'),
            action: SnackBarAction(
              label: 'เลิกทำ',
              onPressed: () => provider.addExpense(removed),
            ),
          ),
        );
      },
      child: row,
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: Text('"${expense.title}" ${formatBaht(expense.amount)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
