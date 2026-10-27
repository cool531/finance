import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'MainNavigation.dart';
import 'Model.dart';
import 'Picker.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final goals = provider.goals;
    final saved = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final target = goals.fold<double>(0, (s, g) => s + g.targetAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('เป้าหมายการออม'),
        actions: [
          IconButton(
            tooltip: 'เพิ่มเป้าหมาย',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showGoalEditor(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, kBottomBarInset),
          children: [
            _GoalsSummaryCard(
              saved: saved,
              target: target,
              count: goals.length,
              completed: goals.where((g) => g.isComplete).length,
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'เป้าหมายของคุณ',
              subtitle: goals.isEmpty ? null : '${goals.length} รายการ',
            ),
            const SizedBox(height: 10),
            if (goals.isEmpty)
              AppCard(
                child: EmptyState(
                  icon: Icons.flag_rounded,
                  title: 'ยังไม่มีเป้าหมาย',
                  message: 'ตั้งเป้าหมายแรกของคุณ เช่น เงินสำรองฉุกเฉิน',
                  actionLabel: 'เพิ่มเป้าหมาย',
                  onAction: () => showGoalEditor(context),
                ),
              )
            else
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GoalCard(goal: goal),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalsSummaryCard extends StatelessWidget {
  final double saved;
  final double target;
  final int count;
  final int completed;

  const _GoalsSummaryCard({
    required this.saved,
    required this.target,
    required this.count,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);

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
            color: AppColors.navy.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          ScoreRing(
            value: progress,
            size: 92,
            stroke: 9,
            gradient: AppColors.goldGradient,
            center: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เก็บเงินได้รวม',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 2),
                AnimatedAmount(
                  value: saved,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'จากเป้าหมายรวม ${formatCompactBaht(target)}  ·  สำเร็จ $completed/$count',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final color = goal.iconType.color;

    return AppCard(
      onTap: () => showGoalEditor(context, existing: goal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: context.isDark ? 0.22 : 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(goal.iconType.icon, color: color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (goal.isComplete)
                      const TagChip(
                        label: 'สำเร็จแล้ว',
                        color: AppColors.success,
                        icon: Icons.check_rounded,
                      )
                    else if (goal.deadline != null)
                      TagChip(
                        label: formatDeadlineThai(goal.deadline!),
                        color: AppColors.gold,
                        icon: Icons.schedule_rounded,
                      )
                    else
                      Text(
                        goal.iconType.label,
                        style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.cs.onSurfaceVariant,
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    showGoalEditor(context, existing: goal);
                  } else if (value == 'delete') {
                    await _confirmDelete(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                  PopupMenuItem(value: 'delete', child: Text('ลบเป้าหมาย')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: formatBaht(goal.currentAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(text: ' / ${formatBaht(goal.targetAmount)}'),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppProgressBar(value: goal.progress, fillColor: color),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.isComplete
                      ? 'ครบเป้าหมายแล้ว 🎉'
                      : 'เหลืออีก ${formatBaht(goal.remaining)}',
                  style: context.tt.bodySmall,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showContributeSheet(context, goal),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('เพิ่มเงิน'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: color.withValues(alpha: 0.14),
                  foregroundColor: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<FinanceProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบเป้าหมายนี้?'),
        content: Text(goal.title),
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
    if (confirmed == true) await provider.deleteGoal(goal.id);
  }
}

/// Quick-add money to a goal, with preset amounts.
void _showContributeSheet(BuildContext context, Goal goal) {
  final provider = context.read<FinanceProvider>();
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('เพิ่มเงินเข้า "${goal.title}"',
              style: context.tt.titleLarge),
          const SizedBox(height: 4),
          Text(
            'เหลืออีก ${formatBaht(goal.remaining)} จะครบเป้าหมาย',
            style: context.tt.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0',
              prefixText: '฿ ',
              suffixText: 'บาท',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [500, 1000, 2000, 5000]
                .map(
                  (amount) => ActionChip(
                    label: Text(formatCompactBaht(amount.toDouble())),
                    onPressed: () => controller.text = amount.toString(),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) return;
              provider.contributeToGoal(goal.id, value);
              Navigator.of(sheetContext).pop();
            },
            child: const Text('เพิ่มเงิน'),
          ),
        ],
      ),
    ),
  );
}

/// Create or edit a goal.
void showGoalEditor(BuildContext context, {Goal? existing}) {
  final provider = context.read<FinanceProvider>();
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final targetCtrl = TextEditingController(
    text: existing == null ? '' : existing.targetAmount.toStringAsFixed(0),
  );
  var iconType = existing?.iconType ?? GoalIconType.other;
  DateTime? deadline = existing?.deadline;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'เพิ่มเป้าหมายใหม่' : 'แก้ไขเป้าหมาย',
                style: context.tt.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: existing == null,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเป้าหมาย',
                  hintText: 'เช่น ท่องเที่ยวญี่ปุ่น',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงินเป้าหมาย',
                  prefixText: '฿ ',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SheetTile(
                      icon: iconType.icon,
                      iconColor: iconType.color,
                      label: iconType.label,
                      onTap: () async {
                        final picked = await showGoalIconPicker(
                          sheetContext,
                          current: iconType,
                        );
                        if (picked != null) {
                          setSheetState(() => iconType = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetTile(
                      icon: Icons.event_rounded,
                      label: deadline == null
                          ? 'ไม่มีกำหนด'
                          : formatFullDateThai(deadline!),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: deadline ??
                              DateTime.now().add(const Duration(days: 180)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => deadline = picked);
                        }
                      },
                      onClear: deadline == null
                          ? null
                          : () => setSheetState(() => deadline = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final target = double.tryParse(targetCtrl.text.trim());
                  if (title.isEmpty || target == null || target <= 0) return;

                  if (existing == null) {
                    provider.addGoal(
                      Goal(
                        id: 'goal_${DateTime.now().microsecondsSinceEpoch}',
                        title: title,
                        targetAmount: target,
                        currentAmount: 0,
                        iconType: iconType,
                        deadline: deadline,
                      ),
                    );
                  } else {
                    provider.updateGoal(
                      existing.copyWith(
                        title: title,
                        targetAmount: target,
                        iconType: iconType,
                        deadline: deadline,
                        clearDeadline: deadline == null,
                      ),
                    );
                  }
                  Navigator.of(sheetContext).pop();
                },
                child: Text(existing == null ? 'เพิ่มเป้าหมาย' : 'บันทึก'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? cs.onSurfaceVariant),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
