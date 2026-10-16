import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/theme/app_theme.dart';

class QuadraticEquationApp extends StatelessWidget {
  const QuadraticEquationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quadratic Equation Solver',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
