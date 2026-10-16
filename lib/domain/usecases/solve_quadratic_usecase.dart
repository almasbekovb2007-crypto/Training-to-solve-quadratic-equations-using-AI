import '../../data/models/quadratic_coefficients.dart';
import '../../data/models/solution_result.dart';
import '../../core/utils/math_utils.dart';
import '../../core/constants/app_constants.dart';
 
/// Use case для решения квадратных уравнений
class SolveQuadraticUseCase {
  /// Решение квадратного уравнения
  SolutionResult execute(QuadraticCoefficients coefficients) {
    final discriminant = MathUtils.calculateDiscriminant(
      coefficients.a,
      coefficients.b,
      coefficients.c,
    );
 
    final solutionType = MathUtils.getSolutionType(discriminant);
    final roots = MathUtils.calculateRoots(
      coefficients.a,
      coefficients.b,
      coefficients.c,
    );
 
    final steps = _generateSteps(coefficients, discriminant, solutionType, roots);
 
    return SolutionResult(
      discriminant: discriminant,
      type: solutionType,
      roots: roots,
      steps: steps,
    );
  }
 
  /// Валидация и решение из строк
  SolutionResult solveFromStrings(String aStr, String bStr, String cStr) {
    final aError = MathUtils.validateCoefficient(aStr, allowZero: false);
    if (aError != null) {
      return SolutionResult(
        discriminant: 0,
        type: SolutionType.noRealRoots,
        roots: [],
        steps: [aError],
      );
    }
 
    final bError = MathUtils.validateCoefficient(bStr, allowZero: true);
    if (bError != null) {
      return SolutionResult(
        discriminant: 0,
        type: SolutionType.noRealRoots,
        roots: [],
        steps: [bError],
      );
    }
 
    final cError = MathUtils.validateCoefficient(cStr, allowZero: true);
    if (cError != null) {
      return SolutionResult(
        discriminant: 0,
        type: SolutionType.noRealRoots,
        roots: [],
        steps: [cError],
      );
    }
 
    final a = MathUtils.tryParseCoefficient(aStr)!;
    final b = MathUtils.tryParseCoefficient(bStr)!;
    final c = MathUtils.tryParseCoefficient(cStr)!;
 
    final coefficients = QuadraticCoefficients(a: a, b: b, c: c);
    return execute(coefficients);
  }
 
  /// Проверка возможности решения
  bool canSolve(String a, String b, String c) {
    return MathUtils.canSolve(a, b, c);
  }
 
  /// Создание успешного решения
  SolutionResult createSuccess({
    required double a,
    required double b,
    required double c,
  }) {
    final discriminant = MathUtils.calculateDiscriminant(a, b, c);
    final roots = MathUtils.calculateRoots(a, b, c);
    final solutionType = MathUtils.getSolutionType(discriminant);
 
    final steps = <String>[];
 
    steps.add('Дискриминант вычисляется по формуле:');
    steps.add('b² - 4ac');
 
    steps.add('Подставляем значения коэффициентов:');
    steps.add('D = (${MathUtils.formatDouble(b)})² - 4 × (${MathUtils.formatDouble(a)}) × (${MathUtils.formatDouble(c)})');
 
    steps.add('Вычисляем:');
    steps.add('D = ${MathUtils.formatDouble(b * b)} - ${MathUtils.formatDouble(4 * a * c)}');
    steps.add('D = ${MathUtils.formatDouble(discriminant)}');
 
    switch (solutionType) {
      case SolutionType.twoRealRoots:
        steps.add('D > 0, поэтому уравнение имеет два действительных корня:');
        steps.add('x₁ = (-b + √D) / 2a');
        steps.add('x₂ = (-b - √D) / 2a');
        steps.add('x₁ = (${MathUtils.formatDouble(-b)} + √${MathUtils.formatDouble(discriminant)}) / ${MathUtils.formatDouble(2 * a)}');
        steps.add('x₂ = (${MathUtils.formatDouble(-b)} - √${MathUtils.formatDouble(discriminant)}) / ${MathUtils.formatDouble(2 * a)}');
        steps.add('x₁ = ${MathUtils.formatDouble(roots[0])}');
        steps.add('x₂ = ${MathUtils.formatDouble(roots[1])}');
        break;
 
      case SolutionType.oneRealRoot:
        steps.add('D = 0, поэтому уравнение имеет один действительный корень:');
        steps.add('x = -b / 2a');
        steps.add('x = ${MathUtils.formatDouble(-b)} / ${MathUtils.formatDouble(2 * a)}');
        steps.add('x = ${MathUtils.formatDouble(roots[0])}');
        break;
 
      case SolutionType.noRealRoots:
        steps.add('D < 0, поэтому уравнение не имеет действительных корней.');
        break;
    }
 
    return SolutionResult(
      discriminant: discriminant,
      type: solutionType,
      roots: roots,
      steps: steps,
    );
  }
 
  /// Генерация пошагового решения
  List<String> _generateSteps(
    QuadraticCoefficients coefficients,
    double discriminant,
    SolutionType solutionType,
    List<double> roots,
  ) {
    final steps = <String>[];
 
    steps.add('Дискриминант вычисляется по формуле:');
    steps.add('b² - 4ac');
 
    steps.add('Подставляем значения коэффициентов:');
    steps.add('D = (${MathUtils.formatDouble(coefficients.b)})² - 4 × (${MathUtils.formatDouble(coefficients.a)}) × (${MathUtils.formatDouble(coefficients.c)})');
 
    steps.add('Вычисляем:');
    steps.add('D = ${MathUtils.formatDouble(coefficients.b * coefficients.b)} - ${MathUtils.formatDouble(4 * coefficients.a * coefficients.c)}');
    steps.add('D = ${MathUtils.formatDouble(discriminant)}');
 
    switch (solutionType) {
      case SolutionType.twoRealRoots:
        steps.add('D > 0, поэтому уравнение имеет два действительных корня:');
        steps.add('x₁ = (-b + √D) / 2a');
        steps.add('x₂ = (-b - √D) / 2a');
        steps.add('x₁ = (${MathUtils.formatDouble(-coefficients.b)} + √${MathUtils.formatDouble(discriminant)}) / ${MathUtils.formatDouble(2 * coefficients.a)}');
        steps.add('x₂ = (${MathUtils.formatDouble(-coefficients.b)} - √${MathUtils.formatDouble(discriminant)}) / ${MathUtils.formatDouble(2 * coefficients.a)}');
        steps.add('x₁ = ${MathUtils.formatDouble(roots[0])}');
        steps.add('x₂ = ${MathUtils.formatDouble(roots[1])}');
        break;
 
      case SolutionType.oneRealRoot:
        steps.add('D = 0, поэтому уравнение имеет один действительный корень:');
        steps.add('x = -b / 2a');
        steps.add('x = ${MathUtils.formatDouble(-coefficients.b)} / ${MathUtils.formatDouble(2 * coefficients.a)}');
        steps.add('x = ${MathUtils.formatDouble(roots[0])}');
        break;
 
      case SolutionType.noRealRoots:
        steps.add('D < 0, поэтому уравнение не имеет действительных корней.');
        break;
    }
 
    return steps;
  }
}
