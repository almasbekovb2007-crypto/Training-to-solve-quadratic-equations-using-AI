import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../../data/models/solution_result.dart';
import '../../domain/usecases/solve_quadratic_usecase.dart';


/// Репозиторий для работы с квадратными уравнениями
class QuadraticRepository {
  final SolveQuadraticUseCase _solveQuadraticUseCase;

  QuadraticRepository({
    required SolveQuadraticUseCase solveQuadraticUseCase,
  }) : _solveQuadraticUseCase = solveQuadraticUseCase;

  SolveQuadraticUseCase get solveQuadraticUseCase => _solveQuadraticUseCase;

  /// Решение квадратного уравнения
  Future<SolutionResult> solveEquation(String a, String b, String c) async {
    try {
      return Future.value(
        _solveQuadraticUseCase.solveFromStrings(a, b, c) as FutureOr<SolutionResult>?,
      );
    } catch (e) {
      return Future.value(
        SolutionResult(
          discriminant: 0,
          type: SolutionType.noRealRoots,
          roots: const [],
          steps: ['Ошибка решения: ${e.toString()}'],
        ),
      );
    }
  }

  /// Проверка возможности решения
  bool canSolve(String a, String b, String c) {
    return _solveQuadraticUseCase.canSolve(a, b, c);
  }
}
