import '../../core/constants/app_constants.dart';
import '../../core/utils/math_utils.dart';

/// Сущность решения квадратного уравнения
class QuadraticSolution {
  final double discriminant;
  final SolutionType type;
  final List<double> roots;
  final String equation;
  final Map<String, dynamic> steps;

  const QuadraticSolution({
    required this.discriminant,
    required this.type,
    required this.roots,
    required this.equation,
    required this.steps,
  });

  /// Создание успешного решения
  factory QuadraticSolution.success({
    required double a,
    required double b,
    required double c,
  }) {
    final discriminant = MathUtils.calculateDiscriminant(a, b, c);
    final roots = MathUtils.calculateRoots(a, b, c);
    final type = MathUtils.getSolutionType(discriminant);

    final equation = '${a}x² + ${b}x + ${c} = 0';

    final steps = {
      'coefficients': {'a': a, 'b': b, 'c': c},
      'discriminant': {
        'formula': AppConstants.discriminantFormula,
        'substitution': 'D = ${b}² - 4(${a})(${c}) = ${MathUtils.formatDouble(discriminant)}',
        'calculation': MathUtils.formatDouble(discriminant),
      },
      'analysis': _getAnalysisText(type, discriminant),
      'roots': _getRootsCalculation(type, a, b, roots),
      'result': _getResultText(type, roots),
    };

    return QuadraticSolution(
      discriminant: discriminant,
      type: type,
      roots: roots,
      equation: equation,
      steps: steps,
    );
  }

  /// Создание решения с ошибкой
  factory QuadraticSolution.error(String error) {
    return QuadraticSolution(
      discriminant: 0,
      type: SolutionType.noRealRoots,
      roots: [],
      equation: '',
      steps: {'error': error},
    );
  }

  /// Получение текста анализа
  static String _getAnalysisText(SolutionType type, double discriminant) {
    switch (type) {
      case SolutionType.twoRealRoots:
        return 'D > 0: Уравнение имеет два действительных корня';
      case SolutionType.oneRealRoot:
        return 'D = 0: Уравнение имеет один действительный корень';
      case SolutionType.noRealRoots:
        return 'D < 0: Уравнение не имеет действительных корней';
    }
  }

  /// Получение расчета корней
  static Map<String, String> _getRootsCalculation(SolutionType type, double a, double b, List<double> roots) {
    switch (type) {
      case SolutionType.twoRealRoots:
        return {
          'formula1': AppConstants.rootFormula1,
          'calculation1': 'x₁ = (-b + √D) / 2a = ${MathUtils.formatDouble(roots[0])}',
          'formula2': AppConstants.rootFormula2,
          'calculation2': 'x₂ = (-b - √D) / 2a = ${MathUtils.formatDouble(roots[1])}',
        };
      case SolutionType.oneRealRoot:
        return {
          'formula': AppConstants.rootFormulaSingle,
          'calculation': 'x = -b / 2a = ${MathUtils.formatDouble(roots[0])}',
        };
      case SolutionType.noRealRoots:
        return {
          'message': 'Действительных корней нет',
        };
    }
  }

  /// Получение текста результата
  static String _getResultText(SolutionType type, List<double> roots) {
    switch (type) {
      case SolutionType.twoRealRoots:
        return 'x₁ = ${MathUtils.formatDouble(roots[0])}, x₂ = ${MathUtils.formatDouble(roots[1])}';
      case SolutionType.oneRealRoot:
        return 'x = ${MathUtils.formatDouble(roots[0])}';
      case SolutionType.noRealRoots:
        return 'Действительных корней нет';
    }
  }

  /// Получение описания корней
  String get rootsDescription {
    return _getResultText(type, roots);
  }
}
