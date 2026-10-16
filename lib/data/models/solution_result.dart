import '../../core/constants/app_constants.dart';
import '../../core/utils/math_utils.dart';
import 'package:easy_localization/easy_localization.dart';


// Результат решения квадратного уравнения
class SolutionResult {
  final double discriminant;
  final SolutionType type;
  final List<double> roots;
  final List<String> steps;

  const SolutionResult({
    required this.discriminant,
    required this.type,
    required this.roots,
    required this.steps,
  });

  /// Создание из JSON
  factory SolutionResult.fromJson(Map<String, dynamic> json) {
    return SolutionResult(
      discriminant: (json['discriminant'] as num).toDouble(),
      type: SolutionType.values.firstWhere(
        (e) => e.toString() == 'SolutionType.${json['type']}',
        orElse: () => SolutionType.noRealRoots,
      ),
      roots: (json['roots'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      steps: (json['steps'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'discriminant': discriminant,
      'type': type.toString().split('.').last,
      'roots': roots,
      'steps': steps,
    };
  }

  /// Получение описания типа решения
  String get typeDescription {
    switch (type) {
      case SolutionType.twoRealRoots:
        return tr('result.two_roots');
      case SolutionType.oneRealRoot:
        return tr('result.one_root');
      case SolutionType.noRealRoots:
        return tr('result.no_roots');
    }
  }

  /// Получение строкового представления корней
  String get rootsDescription {
    switch (type) {
      case SolutionType.twoRealRoots:
        return 'x₁ = ${MathUtils.formatDouble(roots[0])}, x₂ = ${MathUtils.formatDouble(roots[1])}';
      case SolutionType.oneRealRoot:
        return 'x = ${MathUtils.formatDouble(roots[0])}';
      case SolutionType.noRealRoots:
        return tr('result.no_roots');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionResult &&
          runtimeType == other.runtimeType &&
          discriminant == other.discriminant &&
          type == other.type &&
          _listEquals(roots, other.roots);

  @override
  int get hashCode => discriminant.hashCode ^ type.hashCode ^ roots.hashCode;

  /// Сравнение списков
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'SolutionResult(discriminant: $discriminant, type: $type, roots: $roots)';
}
