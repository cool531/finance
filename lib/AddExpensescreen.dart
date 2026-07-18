import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'categorymodel.dart';
import 'TransactionModel.dart';
import 'finance_provider.dart';
import 'appcolors.dart';

class AddExpenseScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const AddExpenseScreen({super.key, this.onSaved});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  CategoryModel _category = AppCategories.food;
  DateTime _date = DateTime.now();
  Necessity _necessity = Necessity.essential;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: AppColors.diamond,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('เลือกหมวดหมู่',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                ...AppCategories.all.map((c) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: c.color.withOpacity(0.15),
                        child: Icon(c.icon, color: c.color, size: 20),
                      ),
                      title: Text(c.nameTh),
                      onTap: () => Navigator.pop(ctx, c),
                    )),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) setState(() => _category = result);
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _date = result);
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกจำนวนเงินให้ถูกต้อง')),
      );
      return;
    }
    context.read<FinanceProvider>().addTransaction(
          amount: amount,
          categoryId: _category.id,
          detail: _detailCtrl.text.trim().isEmpty ? _category.nameTh : _detailCtrl.text.trim(),
          date: _date,
          necessity: _necessity,
        );
    _amountCtrl.clear();
    _detailCtrl.clear();
    setState(() {
      _category = AppCategories.food;
      _date = DateTime.now();
      _necessity = Necessity.essential;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกรายจ่ายเรียบร้อย')),
    );
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.silver,
      appBar: AppBar(title: const Text('เพิ่มรายจ่าย')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('จำนวนเงิน',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackTie,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                filled: false,
                                hintText: '0',
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text('บาท', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text('หมวดหมู่', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickCategory,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.icyLake,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(_category.icon, color: AppColors.sapphire, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_category.nameTh, style: const TextStyle(fontSize: 15))),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text('รายละเอียด', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _detailCtrl,
                decoration: const InputDecoration(hintText: 'เช่น KFC'),
              ),
              const SizedBox(height: 18),

              const Text('วันที่', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.icyLake,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('d MMMM yyyy').format(_date),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text('จำเป็นหรือไม่?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 8),
              Row(
                children: Necessity.values.map((n) {
                  final selected = _necessity == n;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _necessity = n),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.sapphire : AppColors.icyLake,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            n.labelTh,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppColors.blackTie,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _save,
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}