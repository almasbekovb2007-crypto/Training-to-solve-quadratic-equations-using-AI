import 'package:flutter_test/flutter_test.dart';
import 'package:quadratic_equation_solver/core/constants/app_constants.dart';
import 'package:quadratic_equation_solver/core/utils/math_utils.dart';
import 'package:quadratic_equation_solver/data/models/quadratic_coefficients.dart';
import 'package:quadratic_equation_solver/domain/usecases/solve_quadratic_usecase.dart';

void main() {
  final useCase = SolveQuadraticUseCase();

  test('supports decimal comma parsing', () {
    expect(MathUtils.tryParseCoefficient('1,5'), 1.5);
  });

  test('solves equation with two real roots', () {
    final result = useCase.execute(
      const QuadraticCoefficients(a: 1, b: -3, c: 2),
    );

    expect(result.type, SolutionType.twoRealRoots);
    expect(result.discriminant, 1);
    expect(result.roots, [2, 1]);
  });

  test('solves equation with one real root', () {
    final result = useCase.execute(
      const QuadraticCoefficients(a: 1, b: -2, c: 1),
    );

    expect(result.type, SolutionType.oneRealRoot);
    expect(result.discriminant.abs() <= AppConstants.epsilon, isTrue);
    expect(result.roots, [1]);
  });

  test('solves equation without real roots', () {
    final result = useCase.execute(
      const QuadraticCoefficients(a: 1, b: 0, c: 1),
    );

    expect(result.type, SolutionType.noRealRoots);
    expect(result.roots, isEmpty);
  });
}
