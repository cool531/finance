import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'Model.dart';
import 'Picker.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';

/// Add a new expense, or edit/delete an existing one when [existing] is given.
class AddExpenseScreen extends StatefulWidget {
  final Expense? existing;
  const AddExpenseScreen({super.key, this.existing});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _titleCtrl;
  late ExpenseCategory _category;
  late NecessityLevel _necessity;
  late DateTime _date;
  bool _showAmountError = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(
      text: e == null
          ? ''
          : (e.amount == e.amount.roundToDouble()
              ? e.amount.toStringAsFixed(0)
              : e.amount.toString()),
    );
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _category = e?.category ?? ExpenseCategory.food;
    _necessity = e?.necessity ?? NecessityLevel.necessary;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  double? get _amount {
    final raw = _amountCtrl.text.replaceAll(',', '').trim();
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _bump(double by) {
    final current = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _amountCtrl.text = (current + by).toStringAsFixed(0);
      _showAmountError = false;
    });
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _date = DateTime(
            result.year,
            result.month,
            result.day,
            _date.hour,
            _date.minute,
          ));
    }
  }

  Future<void> _save() async {
    final amount = _amount;
    if (amount == null) {
      setState(() => _showAmountError = true);
      return;
    }

    final provider = context.read<FinanceProvider>();
    final title = _titleCtrl.text.trim().isEmpty
        ? _category.label
        : _titleCtrl.text.trim();

    if (_isEditing) {
      await provider.updateExpense(
        widget.existing!.copyWith(
          amount: amount,
          category: _category,
          title: title,
          date: _date,
          necessity: _necessity,
        ),
      );
    } else {
      await provider.createExpense(
        amount: amount,
        category: _category,
        title: title,
        date: _date,
        necessity: _necessity,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'แก้ไขรายการแล้ว' : 'บันทึกรายจ่ายแล้ว'),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: const Text('การลบไม่สามารถย้อนกลับได้'),
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

    if (confirmed != true || !mounted) return;
    await context.read<FinanceProvider>().deleteExpense(widget.existing!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขรายจ่าย' : 'เพิ่มรายจ่าย'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'ลบรายการ',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  // --- Amount ---------------------------------------------
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.heroGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'จำนวนเงิน',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '฿',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _amountCtrl,
                                autofocus: !_isEditing,
                                textAlign: TextAlign.left,
                                cursorColor: Colors.white,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                onChanged: (_) {
                                  if (_showAmountError) {
                                    setState(() => _showAmountError = false);
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                                decoration: const InputDecoration(
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final step in [20, 50, 100, 500])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => _bump(step.toDouble()),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '+$step',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _amountCtrl.clear()),
                              borderRadius: BorderRadius.circular(10),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.backspace_outlined,
                                  color: Colors.white70,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_showAmountError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 6),
                      child: Text(
                        'กรุณากรอกจำนวนเงินให้มากกว่า 0',
                        style: TextStyle(color: cs.error, fontSize: 12.5),
                      ),
                    ),
                  const SizedBox(height: 22),

                  // --- Category -------------------------------------------
                  const _FieldLabel('หมวดหมู่'),
                  const SizedBox(height: 10),
                  CategoryGridSelector(
                    value: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: 22),

                  // --- Detail ---------------------------------------------
                  const _FieldLabel('รายละเอียด'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'เช่น ข้าวมันไก่, Starbucks',
                      prefixIcon: Icon(_category.icon, size: 19),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // --- Date -----------------------------------------------
                  const _FieldLabel('วันที่'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _DateChip(
                          label: 'วันนี้',
                          selected: _isSameDay(_date, today),
                          onTap: () => setState(() => _date = today),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _DateChip(
                          label: 'เมื่อวาน',
                          selected: _isSameDay(_date, yesterday),
                          onTap: () => setState(() => _date = yesterday),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: _DateChip(
                          label: formatFullDateThai(_date),
                          icon: Icons.calendar_today_rounded,
                          selected: !_isSameDay(_date, today) &&
                              !_isSameDay(_date, yesterday),
                          onTap: _pickDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // --- Necessity ------------------------------------------
                  const _FieldLabel(
                    'จำเป็นไหม?',
                    hint: 'ใช้คำนวณคะแนนสุขภาพการเงินของคุณ',
                  ),
                  const SizedBox(height: 10),
                  NecessitySelector(
                    value: _necessity,
                    onChanged: (n) => setState(() => _necessity = n),
                  ),
                ],
              ),
            ),

            // --- Save ---------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: softShadow(context, strength: 1.2),
              ),
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(
                  _isEditing ? Icons.check_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(_isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายจ่าย'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final String? hint;
  const _FieldLabel(this.text, {this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(text, style: context.tt.titleMedium),
        if (hint != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint!,
              style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
