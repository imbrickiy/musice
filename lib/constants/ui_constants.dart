import 'package:flutter/material.dart';

class UIConstants {
  // 🎨 Цвета
  static const Color primaryColor = Color(0xFF5A189A); // Фиолетовый
  static const Color accentColor = Color(0xFFF72585);  // Розовый
  static const Color backgroundColor = Color(0xFF3A0CA3); // Тёмно-фиолетовый
  static const Color cardColor = Color(0xFFF8F9FA);     // Светлый фон
  static const Color textColor = Color(0xFF212529);     // Тёмный текст

  // 📐 Отступы
  static const double paddingXS = 8.0;
  static const double paddingS = 12.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // 🟦 Закругления
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(8));
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(24));

  // 🔤 Шрифты
  static const String fontFamily = 'SF Pro'; // Подходит для macOS и iOS

  static TextStyle headingStyle(BuildContext context) => TextStyle(
    fontSize: isLargeScreen(context) ? 28 : 22,
    fontWeight: FontWeight.bold,
    color: textColor,
    fontFamily: fontFamily,
  );

  static TextStyle bodyStyle(BuildContext context) => TextStyle(
    fontSize: isLargeScreen(context) ? 18 : 16,
    color: textColor,
    fontFamily: fontFamily,
  );

  // 📱 Адаптивность
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;
}