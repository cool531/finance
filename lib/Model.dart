import 'package:flutter/material.dart';

import 'AppColors.dart';

/// ---------------------------------------------------------------------------
/// Expense categories
/// ---------------------------------------------------------------------------
enum ExpenseCategory {
  food,
  transport,
  shopping,
  investment,
  subscription,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'อาหาร';
      case ExpenseCategory.transport:
        return 'เดินทาง';
      case ExpenseCategory.shopping:
        return 'ช้อปปิ้ง';
      case ExpenseCategory.investment:
        return 'ลงทุน';
      case ExpenseCategory.subscription:
        return 'ค่าสมาชิก';
      case ExpenseCategory.other:
        return 'อื่นๆ';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_bus_filled_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.investment:
        return Icons.trending_up_rounded;
      case ExpenseCategory.subscription:
        return Icons.autorenew_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.catFood;
      case ExpenseCategory.transport:
        return AppColors.catTransport;
      case ExpenseCategory.shopping:
        return AppColors.catShopping;
      case ExpenseCategory.investment:
        return AppColors.catInvest;
      case ExpenseCategory.subscription:
        return AppColors.catSubscription;
      case ExpenseCategory.other:
        return AppColors.catOther;
    }
  }
}

/// ---------------------------------------------------------------------------
/// Necessity level — the "จำเป็น / ไม่จำเป็น / อยากได้เฉยๆ" toggle
/// ---------------------------------------------------------------------------
enum NecessityLevel { necessary, notNecessary, wantOnly }

extension NecessityLevelX on NecessityLevel {
  String get label {
    switch (this) {
      case NecessityLevel.necessary:
        return 'จำเป็น';
      case NecessityLevel.notNecessary:
        return 'ไม่จำเป็น';
      case NecessityLevel.wantOnly:
        return 'อยากได้เฉยๆ';
    }
  }

  Color get color {
    switch (this) {
      case NecessityLevel.necessary:
        return AppColors.success;
      case NecessityLevel.notNecessary:
        return AppColors.danger;
      case NecessityLevel.wantOnly:
        return AppColors.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case NecessityLevel.necessary:
        return Icons.verified_rounded;
      case NecessityLevel.notNecessary:
        return Icons.do_not_disturb_on_rounded;
      case NecessityLevel.wantOnly:
        return Icons.favorite_rounded;
    }
  }
}

/// ---------------------------------------------------------------------------
/// Goal icon type — keeps the Goal model JSON-serializable (no raw IconData)
/// ---------------------------------------------------------------------------
enum GoalIconType { car, travel, emergency, home, education, gadget, other }

extension GoalIconTypeX on GoalIconType {
  IconData get icon {
    switch (this) {
      case GoalIconType.car:
        return Icons.directions_car_filled_rounded;
      case GoalIconType.travel:
        return Icons.flight_takeoff_rounded;
      case GoalIconType.emergency:
        return Icons.shield_rounded;
      case GoalIconType.home:
        return Icons.home_rounded;
      case GoalIconType.education:
        return Icons.school_rounded;
      case GoalIconType.gadget:
        return Icons.devices_rounded;
      case GoalIconType.other:
        return Icons.savings_rounded;
    }
  }

  Color get color {
    switch (this) {
      case GoalIconType.car:
        return AppColors.catTransport;
      case GoalIconType.travel:
        return AppColors.gold;
      case GoalIconType.emergency:
        return AppColors.success;
      case GoalIconType.home:
        return AppColors.catFood;
      case GoalIconType.education:
        return AppColors.catSubscription;
      case GoalIconType.gadget:
        return AppColors.catShopping;
      case GoalIconType.other:
        return AppColors.teal;
    }
  }

  String get label {
    switch (this) {
      case GoalIconType.car:
        return 'ยานพาหนะ';
      case GoalIconType.travel:
        return 'ท่องเที่ยว';
      case GoalIconType.emergency:
        return 'เงินสำรอง';
      case GoalIconType.home:
        return 'ที่อยู่อาศัย';
      case GoalIconType.education:
        return 'การศึกษา';
      case GoalIconType.gadget:
        return 'อุปกรณ์';
      case GoalIconType.other:
        return 'อื่นๆ';
    }
  }
}

/// ---------------------------------------------------------------------------
/// Expense
/// ---------------------------------------------------------------------------
class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String title;
  final DateTime date;
  final NecessityLevel necessity;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.title,
    required this.date,
    required this.necessity,
  });

  Expense copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    String? title,
    DateTime? date,
    NecessityLevel? necessity,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      title: title ?? this.title,
      date: date ?? this.date,
      necessity: necessity ?? this.necessity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'title': title,
        'date': date.toIso8601String(),
        'necessity': necessity.name,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: ExpenseCategory.values.byName(json['category'] as String),
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        necessity: NecessityLevel.values.byName(json['necessity'] as String),
      );
}

/// ---------------------------------------------------------------------------
/// Goal
/// ---------------------------------------------------------------------------
class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final GoalIconType iconType;

  const Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.iconType,
    this.deadline,
  });

  double get progress => targetAmount <= 0
      ? 0.0
      : (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();

  double get remaining =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity).toDouble();

  bool get isComplete => currentAmount >= targetAmount;

  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool clearDeadline = false,
    GoalIconType? iconType,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      iconType: iconType ?? this.iconType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'iconType': iconType.name,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        iconType: GoalIconType.values.byName(json['iconType'] as String),
      );
}

/// ---------------------------------------------------------------------------
/// Recommendation — a single rule-based insight card
/// ---------------------------------------------------------------------------
enum RecommendationType { warning, tip, praise }

extension RecommendationTypeX on RecommendationType {
  Color get color {
    switch (this) {
      case RecommendationType.warning:
        return AppColors.danger;
      case RecommendationType.tip:
        return AppColors.gold;
      case RecommendationType.praise:
        return AppColors.success;
    }
  }

  String get label {
    switch (this) {
      case RecommendationType.warning:
        return 'ควรระวัง';
      case RecommendationType.tip:
        return 'เคล็ดลับ';
      case RecommendationType.praise:
        return 'ทำได้ดี';
    }
  }
}

class Recommendation {
  final String title;
  final String message;
  final IconData icon;
  final RecommendationType type;

  const Recommendation({
    required this.title,
    required this.message,
    required this.icon,
    required this.type,
  });
}
