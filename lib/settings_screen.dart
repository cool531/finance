import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'HomeScreen.dart' show showEditNumberDialog, showEditTextDialog;
import 'common_widgets.dart';
import 'finance_provider.dart';
import 'formatters.dart';
import 'theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final theme = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _ProfileHeader(name: provider.userName),
          const SizedBox(height: 22),
          const SectionHeader(title: 'ข้อมูลการเงิน'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.badge_rounded,
                  title: 'ชื่อผู้ใช้',
                  value: provider.userName,
                  onTap: () => showEditTextDialog(
                    context,
                    title: 'แก้ไขชื่อผู้ใช้',
                    initialValue: provider.userName,
                    onSave: provider.setUserName,
                  ),
                ),
                const _RowDivider(),
                _SettingRow(
                  icon: Icons.payments_rounded,
                  title: 'รายรับต่อเดือน',
                  value: formatBaht(provider.monthlyIncome),
                  onTap: () => showEditNumberDialog(
                    context,
                    title: 'รายรับต่อเดือน',
                    initialValue: provider.monthlyIncome,
                    onSave: provider.setMonthlyIncome,
                  ),
                ),
                const _RowDivider(),
                _SettingRow(
                  icon: Icons.savings_rounded,
                  title: 'เป้าหมายเงินออมต่อเดือน',
                  value: formatBaht(provider.savingsGoal),
                  onTap: () => showEditNumberDialog(
                    context,
                    title: 'เป้าหมายเงินออมต่อเดือน',
                    initialValue: provider.savingsGoal,
                    onSave: provider.setSavingsGoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'หน้าตาแอป'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ธีม',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded, size: 17),
                      label: Text('สว่าง'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded, size: 17),
                      label: Text('มืด'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_iphone_rounded, size: 17),
                      label: Text('ระบบ'),
                    ),
                  ],
                  selected: {theme.mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (set) => theme.setMode(set.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'ข้อมูลในเครื่อง'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.restore_rounded,
                  title: 'โหลดข้อมูลตัวอย่างใหม่',
                  value: '${provider.expenses.length} รายการ',
                  onTap: () => _confirm(
                    context,
                    title: 'โหลดข้อมูลตัวอย่างใหม่?',
                    message: 'รายการและเป้าหมายที่มีอยู่จะถูกแทนที่ทั้งหมด',
                    confirmLabel: 'โหลดใหม่',
                    onConfirm: provider.restoreSampleData,
                  ),
                ),
                const _RowDivider(),
                _SettingRow(
                  icon: Icons.delete_sweep_rounded,
                  iconColor: AppColors.danger,
                  title: 'ลบข้อมูลทั้งหมด',
                  value: 'เริ่มต้นใหม่',
                  onTap: () => _confirm(
                    context,
                    title: 'ลบข้อมูลทั้งหมด?',
                    message: 'รายจ่ายและเป้าหมายทั้งหมดจะถูกลบออกจากเครื่องนี้',
                    confirmLabel: 'ลบทั้งหมด',
                    danger: true,
                    onConfirm: provider.clearAllData,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AppCard(
            color: context.cs.surfaceContainer,
            child: Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: context.cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ข้อมูลทั้งหมดถูกเก็บไว้ในเครื่องของคุณเท่านั้น ไม่มีการส่งออกไปที่ใด',
                    style: context.tt.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (result == true) await onConfirm();
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  const _ProfileHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials =
        name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'จัดการการเงินส่วนตัวของคุณ',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final color = iconColor ?? cs.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: context.tt.bodySmall?.copyWith(fontSize: 12.5),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 62,
      endIndent: 14,
      color: context.cs.outlineVariant,
    );
  }
}
