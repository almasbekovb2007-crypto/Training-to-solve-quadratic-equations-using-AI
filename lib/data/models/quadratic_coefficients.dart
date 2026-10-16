import '../../core/utils/math_utils.dart';

/// Модель для хранения коэффициентов квадратного уравнения
class QuadraticCoefficients {
  final double a;
  final double b;
  final double c;

  const QuadraticCoefficients({
    required this.a,
    required this.b,
    required this.c,
  });

  /// Создание из JSON
  factory QuadraticCoefficients.fromJson(Map<String, dynamic> json) {
    return QuadraticCoefficients(
      a: (json['a'] as num).toDouble(),
      b: (json['b'] as num).toDouble(),
      c: (json['c'] as num).toDouble(),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
      'c': c,
    };
  }

  /// Валидация коэффициентов
  String? validate() {
    if (a == 0) {
      return 'Коэффициент a не может быть равен нулю';
    }
    return null;
  }

  /// Получение строкового представления уравнения
  String get equation {
    final parts = <String>[];
    final formattedA = MathUtils.formatDouble(a);
    final formattedB = MathUtils.formatDouble(b.abs());
    final formattedC = MathUtils.formatDouble(c.abs());
    
    // Коэффициент a
    if (a == 1) {
      parts.add('x²');
    } else if (a == -1) {
      parts.add('-x²');
    } else {
      parts.add('${formattedA}x²');
    }
    
    // Коэффициент b
    if (b > 0) {
      if (b == 1) {
        parts.add('+ x');
      } else {
        parts.add('+ ${formattedB}x');
      }
    } else if (b < 0) {
      if (b == -1) {
        parts.add('- x');
      } else {
        parts.add('- ${formattedB}x');
      }
    }
    
    // Коэффициент c
    if (c > 0) {
      parts.add('+ $formattedC');
    } else if (c < 0) {
      parts.add('- $formattedC');
    }
    
    parts.add('= 0');
    
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuadraticCoefficients &&
          runtimeType == other.runtimeType &&
          a == other.a &&
          b == other.b &&
          c == other.c;

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode;

  @override
  String toString() => 'QuadraticCoefficients(a: $a, b: $b, c: $c)';
}
