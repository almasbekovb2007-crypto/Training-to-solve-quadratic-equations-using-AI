import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'presentation/providers/quadratic_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация зависимостей
  await DependencyInjection.init();
  
  // Инициализация локализации
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en'), Locale('ky')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<QuadraticProvider>(
            create: (_) => DependencyInjection.quadraticProvider,
          ),
        ],
        child: const QuadraticEquationApp(),
      ),
    ),
  );
}
