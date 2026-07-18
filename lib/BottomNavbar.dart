import 'package:flutter/material.dart';
import 'AppColors.dart';

enum AppTab { home, expense, add, analytics, goal }

class BottomNavBar extends StatelessWidget {
  final AppTab current;
  final ValueChanged<AppTab> onTap;

  const BottomNavBar({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.diamond,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'หน้าหลัก',
              selected: current == AppTab.home,
              onTap: () => onTap(AppTab.home),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'รายจ่าย',
              selected: current == AppTab.expense,
              onTap: () => onTap(AppTab.expense),
            ),
            _AddButton(onTap: () => onTap(AppTab.add)),
            _NavItem(
              icon: Icons.auto_graph_rounded,
              label: 'วิเคราะห์',
              selected: current == AppTab.analytics,
              onTap: () => onTap(AppTab.analytics),
            ),
            _NavItem(
              icon: Icons.flag_rounded,
              label: 'เป้าหมาย',
              selected: current == AppTab.goal,
              onTap: () => onTap(AppTab.goal),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.sapphire : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.sapphire,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.diamond, size: 26),
      ),
    );
  }
}