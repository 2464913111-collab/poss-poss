import 'package:flutter/material.dart';

class AppTheme {
  // 主色系
  static const Color primary = Color(0xFFA8D8EA);
  static const Color primaryLight = Color(0xFFB8E0F0);
  static const Color primaryBg = Color(0xFFE3F2FD);
  static const Color primaryDark = Color(0xFF64B4D2);

  // 中性色
  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF737373);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color pageBg = Color(0xFFF5FAFC);

  // 功能色
  static const Color aiMode = Color(0xFFFF9500);
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);
  static const Color disabled = Color(0xFF8E8E93);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardBg,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: pageBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      fontFamily: null, // 使用系统默认字体（SF Pro / Roboto）
    );
  }
}
