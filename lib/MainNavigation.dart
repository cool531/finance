import 'package:flutter/material.dart';

import 'AddExpensescreen.dart';
import 'AnalysisScreen.dart';
import 'BottomNavbar.dart';
import 'Expenselistscreen.dart';
import 'GoalsScreen.dart';
import 'HomeScreen.dart';

/// Space the floating nav bar takes away from the bottom of every screen.
const double kBottomBarInset = 96;

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  void _goToTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  Future<void> _openAddExpense() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onNavigateToTab: _goToTab, onAddExpense: _openAddExpense),
          ExpenseListScreen(onAddExpense: _openAddExpense),
          const AnalysisScreen(),
          const GoalsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTabSelected: _goToTab,
        onAddPressed: _openAddExpense,
      ),
    );
  }
}
