import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'finance_provider.dart';
import 'HomeScreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(
          onSeeExpenses: () {},
          onSeeAnalytics: () {},
        ),
      ),
    );
  }
}