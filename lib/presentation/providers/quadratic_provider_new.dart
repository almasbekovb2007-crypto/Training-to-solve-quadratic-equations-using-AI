import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/solution_result.dart';
import '../../data/repositories/quadratic_repository.dart';
/// Provider для управления состоянием квадратного уравнения
class QuadraticProviderNew extends ChangeNotifier {
  final QuadraticRepository _repository;
  
  QuadraticProviderNew({
    required QuadraticRepository repository,
  }) : _repository = repository;

  // State variables
  AppState _state = AppState.initial;
  SolutionResult? _solution;
  String? _errorMessage;
  String _coefficientA = '';
  String _coefficientB = '';
  String _coefficientC = '';

  // Getters
  AppState get state => _state;
  SolutionResult? get solution => _solution;
  String? get errorMessage => _errorMessage;
  String get coefficientA => _coefficientA;
  String get coefficientB => _coefficientB;
  String get coefficientC => _coefficientC;

  /// Установка коэффициента A
  void setCoefficientA(String value) {
    _coefficientA = value;
    _clearError();
    _updateState();
    notifyListeners();
  }

  /// Установка коэффициента B
  void setCoefficientB(String value) {
    _coefficientB = value;
    _clearError();
    _updateState();
    notifyListeners();
  }

  /// Установка коэффициента C
  void setCoefficientC(String value) {
    _coefficientC = value;
    _clearError();
    _updateState();
    notifyListeners();
  }

  /// Решение уравнения
  Future<void> solveEquation() async {
    if (!_repository.canSolve(_coefficientA, _coefficientB, _coefficientC)) {
      _setError('Проверьте правильность введенных данных');
      return;
    }

    _setState(AppState.solving);
    notifyListeners();

    try {
      _solution = await _repository.solveEquation(_coefficientA, _coefficientB, _coefficientC);
      _setState(AppState.solved);
    } catch (e) {
      _setError('Ошибка при решении: ${e.toString()}');
    }
    
    notifyListeners();
  }

  /// Сброс решения
  void resetSolution() {
    _solution = null;
    _errorMessage = null;
    _setState(AppState.input);
    notifyListeners();
  }

  /// Полный сброс
  void reset() {
    _solution = null;
    _errorMessage = null;
    _coefficientA = '';
    _coefficientB = '';
    _coefficientC = '';
    _setState(AppState.initial);
    notifyListeners();
  }

  /// Проверка, можно ли решать уравнение
  bool get canSolve => 
      _coefficientA.isNotEmpty && 
      _coefficientB.isNotEmpty && 
      _coefficientC.isNotEmpty &&
      _state != AppState.solving;

  /// Установка состояния
  void _setState(AppState newState) {
    _state = newState;
  }

  /// Установка ошибки
  void _setError(String message) {
    _errorMessage = message;
    _state = AppState.error;
  }

  /// Очистка ошибки
  void _clearError() {
    _errorMessage = null;
    if (_state == AppState.error) {
      _state = AppState.input;
    }
  }

  /// Обновление состояния на основе ввода
  void _updateState() {
    if (_coefficientA.isNotEmpty || _coefficientB.isNotEmpty || _coefficientC.isNotEmpty) {
      if (_state == AppState.initial) {
        _state = AppState.input;
      }
    } else if (_coefficientA.isEmpty && _coefficientB.isEmpty && _coefficientC.isEmpty) {
      _state = AppState.initial;
    }
  }
}
