import '../../data/models/quadratic_coefficients.dart';
import '../../data/models/solution_result.dart';

/// Сущность квадратного уравнения
class QuadraticEquation {
  final QuadraticCoefficients coefficients;
  final SolutionResult? solution;

  const QuadraticEquation({
    required this.coefficients,
    this.solution,
  });

  /// Создание уравнения с коэффициентами
  factory QuadraticEquation.fromCoefficients(QuadraticCoefficients coefficients) {
    return QuadraticEquation(coefficients: coefficients);
  }

  /// Создание уравнения с решением
  factory QuadraticEquation.withSolution({
    required QuadraticCoefficients coefficients,
    required SolutionResult solution,
  }) {
    return QuadraticEquation(
      coefficients: coefficients,
      solution: solution,
    );
  }

  /// Проверка, решено ли уравнение
  bool get isSolved => solution != null;

  /// Получение строкового представления уравнения
  String get equation => coefficients.equation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuadraticEquation &&
          runtimeType == other.runtimeType &&
          coefficients == other.coefficients &&
          solution == other.solution;

  @override
  int get hashCode => coefficients.hashCode ^ solution.hashCode;

  @override
  String toString() => 'QuadraticEquation(coefficients: $coefficients, solution: $solution)';
}
