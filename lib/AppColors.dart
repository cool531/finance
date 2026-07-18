import 'package:flutter/material.dart';
 
/// Luxury color palette used across the whole app.
class AppColors {
  AppColors._();
 
  static const Color diamond = Color(0xFFFFFFFF); // Card background
  static const Color silver = Color(0xFFEFEFEF); // Screen background
  static const Color icyLake = Color(0xFFDFE6E6); // Input background
  static const Color sapphire = Color(0xFF234F60); // Primary
  static const Color golden = Color(0xFFD4A052); // Accent
  static const Color blackTie = Color(0xFF121111); // Primary text
 
  // Supporting tones derived for charts / states
  static const Color sapphireLight = Color(0xFF3D6E82);
  static const Color goldenLight = Color(0xFFE6C08A);
  static const Color success = Color(0xFF3F8F5F);
  static const Color danger = Color(0xFFC0554A);
  static const Color textSecondary = Color(0xFF6B6D6D);
  static const Color divider = Color(0xFFE3E3E3);
 
  // Category colors (used in donut chart / lists)
  static const Color catFood = golden;
  static const Color catTransport = sapphire;
  static const Color catShopping = Color(0xFFB6784B);
  static const Color catInvest = Color(0xFF3F8F5F);
  static const Color catSubscription = Color(0xFF8E6BA8);
  static const Color catOther = Color(0xFF9AA3A3);
}
 
 