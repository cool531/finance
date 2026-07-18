import 'AppColors.dart';
import 'package:flutter/material.dart';

/// A spending/income category, e.g. อาหาร, เดินทาง, Shopping ...
class CategoryModel {
  final String id;
  final String nameTh;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.nameTh,
    required this.icon,
    required this.color,
  });
}

/// The fixed list of categories available in the app.
class AppCategories {
  AppCategories._();

  static const food = CategoryModel(
    id: 'food',
    nameTh: 'อาหาร',
    icon: Icons.restaurant_rounded,
    color: AppColors.catFood,
  );

  static const transport = CategoryModel(
    id: 'transport',
    nameTh: 'เดินทาง',
    icon: Icons.directions_bus_filled_rounded,
    color: AppColors.catTransport,
  );

  static const shopping = CategoryModel(
    id: 'shopping',
    nameTh: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: AppColors.catShopping,
  );

  static const subscription = CategoryModel(
    id: 'subscription',
    nameTh: 'Subscription',
    icon: Icons.subscriptions_rounded,
    color: AppColors.catSubscription,
  );

  static const investment = CategoryModel(
    id: 'investment',
    nameTh: 'ลงทุน',
    icon: Icons.show_chart_rounded,
    color: AppColors.catInvest,
  );

  static const other = CategoryModel(
    id: 'other',
    nameTh: 'อื่นๆ',
    icon: Icons.category_rounded,
    color: AppColors.catOther,
  );

  static const List<CategoryModel> all = [
    food,
    transport,
    shopping,
    subscription,
    investment,
    other,
  ];

  static CategoryModel byId(String id) {
    return all.firstWhere((c) => c.id == id, orElse: () => other);
  }
}