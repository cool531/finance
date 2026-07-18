import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final IconData icon;

  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    this.deadline,
  });

  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  GoalModel copyWith({double? currentAmount}) {
    return GoalModel(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon,
      deadline: deadline,
    );
  }
}