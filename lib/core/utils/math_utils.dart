import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_constants.dart';

/// Математические утилиты для решения квадратных уравнений
class MathUtils {
  /// Нормализация пользовательского ввода
  static String normalizeInput(String value) {
    return value.trim().replaceAll(',', '.');
  }

  /// Безопасный парсинг коэффициента
  static double? tryParseCoefficient(String value) {
    return double.tryParse(normalizeInput(value));
  }

  /// Вычисление дискриминанта
  static double calculateDiscriminant(double a, double b, double c) {
    return b * b - 4 * a * c;
  }

  /// Вычисление корней квадратного уравнения
  static List<double> calculateRoots(double a, double b, double c) {
    final discriminant = calculateDiscriminant(a, b, c);
    
    if (discriminant > 0) {
      final sqrtD = sqrt(discriminant);
      final x1 = (-b + sqrtD) / (2 * a);
      final x2 = (-b - sqrtD) / (2 * a);
      return [x1, x2];
    } else if (discriminant.abs() <= AppConstants.epsilon) {
      final x = -b / (2 * a);
      return [x];
    } else {
      return [];
    }
  }

  /// Определение типа решения
  static SolutionType getSolutionType(double discriminant) {
    if (discriminant > 0) {
      return SolutionType.twoRealRoots;
    } else if (discriminant.abs() <= AppConstants.epsilon) {
      return SolutionType.oneRealRoot;
    } else {
      return SolutionType.noRealRoots;
    }
  }

  /// Форматирование числа для вывода
  static String formatDouble(double value) {
    if (value.abs() < AppConstants.epsilon) {
      return '0';
    }
    if (value == value.truncate()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(AppConstants.decimalPrecision)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Валидация коэффициента
  static String? validateCoefficient(String value, {bool allowZero = false}) {
    final normalized = normalizeInput(value);
    if (normalized.isEmpty) {
      return tr('validation.field_required');
    }
    
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return tr('validation.invalid_number');
    }
    
    if (!allowZero && parsed.abs() <= AppConstants.epsilon) {
      return tr('validation.a_not_zero');
    }
    
    if (parsed.abs() > AppConstants.maxCoefficientValue) {
      return tr(
        'validation.max_value',
        namedArgs: {
          'value': AppConstants.maxCoefficientValue.toStringAsFixed(0),
        },
      );
    }
    
    if (normalized.length > AppConstants.maxCoefficientLength) {
      return tr(
        'validation.max_length',
        namedArgs: {
          'value': AppConstants.maxCoefficientLength.toString(),
        },
      );
    }
    
    return null;
  }

  /// Проверка, можно ли решать уравнение
  static bool canSolve(String a, String b, String c) {
    return a.isNotEmpty && b.isNotEmpty && c.isNotEmpty &&
           validateCoefficient(a) == null &&
           validateCoefficient(b, allowZero: true) == null &&
           validateCoefficient(c, allowZero: true) == null;
  }
}
