import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class PossPossApp extends StatelessWidget {
  const PossPossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POSS POSS',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
