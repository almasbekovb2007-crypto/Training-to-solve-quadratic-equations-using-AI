import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/quadratic_coefficients.dart';
import '../../data/models/solution_result.dart';
import '../../data/models/image_analysis_result.dart';
import '../../domain/usecases/solve_quadratic_usecase.dart';
import '../../data/repositories/image_analysis_repository.dart';
import '../../core/utils/math_utils.dart';

/// Состояние приложения
enum AppState1 {
  initial,
  loading,
  solving,
  solved,
  error,
  analyzingImage,
  imageAnalyzed,
}

/// Provider для управления состоянием квадратного уравнения
class QuadraticProvider extends ChangeNotifier {
  final SolveQuadraticUseCase _solveQuadraticUseCase;
  final ImageAnalysisRepository _imageAnalysisRepository;

  QuadraticProvider({
    required SolveQuadraticUseCase solveQuadraticUseCase,
    required ImageAnalysisRepository imageAnalysisRepository,
  })  : _solveQuadraticUseCase = solveQuadraticUseCase,
        _imageAnalysisRepository = imageAnalysisRepository;

  // State variables
  AppState1 _state = AppState1.initial;
  QuadraticCoefficients? _coefficients;
  SolutionResult? _solution;
  String? _errorMessage;
  ImageAnalysisResult? _imageAnalysisResult;
  dynamic _selectedImage; // Can be File (mobile/desktop) or XFile (web)
  Uint8List? _selectedImageBytes;
  String _coefficientA = '';
  String _coefficientB = '';
  String _coefficientC = '';
  String? _coefficientAError;
  String? _coefficientBError;
  String? _coefficientCError;

  // Getters
  AppState1 get state => _state;
  QuadraticCoefficients? get coefficients => _coefficients;
  SolutionResult? get solution => _solution;
  String? get errorMessage => _errorMessage;
  ImageAnalysisResult? get imageAnalysisResult => _imageAnalysisResult;
  dynamic get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String get coefficientA => _coefficientA;
  String get coefficientB => _coefficientB;
  String get coefficientC => _coefficientC;
  String? get coefficientAError => _coefficientAError;
  String? get coefficientBError => _coefficientBError;
  String? get coefficientCError => _coefficientCError;

  /// Установка коэффициента A
  void setCoefficientA(String value) {
    _coefficientA = value;
    _coefficientAError = MathUtils.validateCoefficient(value);
    _solution = null;
    _coefficients = null;
    _clearErrorIfNeeded();
    notifyListeners();
  }

  /// Установка коэффициента B
  void setCoefficientB(String value) {
    _coefficientB = value;
    _coefficientBError = MathUtils.validateCoefficient(value, allowZero: true);
    _solution = null;
    _coefficients = null;
    _clearErrorIfNeeded();
    notifyListeners();
  }

  /// Установка коэффициента C
  void setCoefficientC(String value) {
    _coefficientC = value;
    _coefficientCError = MathUtils.validateCoefficient(value, allowZero: true);
    _solution = null;
    _coefficients = null;
    _clearErrorIfNeeded();
    notifyListeners();
  }

  /// Валидация и создание коэффициентов
  String? validateAndCreateCoefficients() {
    _coefficientAError = MathUtils.validateCoefficient(_coefficientA);
    _coefficientBError = MathUtils.validateCoefficient(
      _coefficientB,
      allowZero: true,
    );
    _coefficientCError = MathUtils.validateCoefficient(
      _coefficientC,
      allowZero: true,
    );

    final errors = [
      _coefficientAError,
      _coefficientBError,
      _coefficientCError,
    ].whereType<String>().toList();

    if (errors.isNotEmpty) {
      notifyListeners();
      return errors.first;
    }

    final a = MathUtils.tryParseCoefficient(_coefficientA);
    final b = MathUtils.tryParseCoefficient(_coefficientB);
    final c = MathUtils.tryParseCoefficient(_coefficientC);

    if (a == null || b == null || c == null) {
      return tr('validation.input_error');
    }

    _coefficients = QuadraticCoefficients(a: a, b: b, c: c);
    return null;
  }

  /// Решение квадратного уравнения
  Future<void> solveEquation() async {
    final validationError = validateAndCreateCoefficients();
    if (validationError != null) {
      _setError(validationError);
      return;
    }

    if (_coefficients == null) {
      _setError(tr('validation.coefficients_not_set'));
      return;
    }

    _setState(AppState1.solving);
    try {
      _solution = _solveQuadraticUseCase.execute(_coefficients!);
      _setState(AppState1.solved);
    } catch (e) {
      _setError('${tr('validation.solve_error')}: ${e.toString()}');
    }
  }

  /// Сброс решения
  void resetSolution() {
    _solution = null;
    _errorMessage = null;
    _coefficients = null;
    _setState(AppState1.initial);
  }

  /// Полный сброс
  void reset() {
    _coefficients = null;
    _solution = null;
    _errorMessage = null;
    _imageAnalysisResult = null;
    _selectedImage = null;
    _selectedImageBytes = null;
    _coefficientA = '';
    _coefficientB = '';
    _coefficientC = '';
    _coefficientAError = null;
    _coefficientBError = null;
    _coefficientCError = null;
    _setState(AppState1.initial);
  }

  /// Установка выбранного изображения
  Future<void> setSelectedImage(dynamic image) async {
    _selectedImage = image;
    _imageAnalysisResult = null;
    _errorMessage = null;
    if (_state == AppState1.error) {
      _state = _solution != null ? AppState1.solved : AppState1.initial;
    }

    try {
      if (image is XFile) {
        _selectedImageBytes = await image.readAsBytes();
      } else if (image is File) {
        _selectedImageBytes = await image.readAsBytes();
      } else {
        _selectedImageBytes = null;
      }
    } catch (_) {
      _selectedImageBytes = null;
    }

    notifyListeners();
  }

  /// Анализ изображения
  Future<void> analyzeImage({String? equation}) async {
    if (_selectedImage == null) {
      _setError(tr('validation.no_image'));
      return;
    }

    _setState(AppState1.analyzingImage);
    try {
      // Чтение изображения и конвертация в base64
      Uint8List bytes;
      
      if (_selectedImageBytes != null) {
        bytes = _selectedImageBytes!;
      } else if (kIsWeb && _selectedImage is XFile) {
        bytes = await (_selectedImage as XFile).readAsBytes();
      } else if (!kIsWeb && _selectedImage is File) {
        bytes = await (_selectedImage as File).readAsBytes();
      } else {
        throw Exception(tr('validation.unsupported_image'));
      }
      
      final base64Image = base64Encode(bytes);
      final referenceSolution = _solution ?? _buildSolutionPreview();
      final imagePath = _resolveSelectedImagePath();
      
      _imageAnalysisResult = await _imageAnalysisRepository.analyzeImage(
        base64Image,
        equation: equation ?? equationForAnalysis,
        referenceSolution: referenceSolution,
        imagePath: imagePath,
      );
      
      _setState(AppState1.imageAnalyzed);
    } catch (e) {
      _setError('${tr('validation.analyze_error')}: ${e.toString()}');
    }
  }

  /// Сброс анализа изображения
  void resetImageAnalysis() {
    _imageAnalysisResult = null;
    _selectedImage = null;
    _selectedImageBytes = null;
    _errorMessage = null;
    _state = _solution != null ? AppState1.solved : AppState1.initial;
    notifyListeners();
  }

  /// Установка состояния
  void _setState(AppState1 newState) {
    _state = newState;
    notifyListeners();
  }

  /// Установка ошибки
  void _setError(String message) {
    _errorMessage = message;
    _state = AppState1.error;
    notifyListeners();
  }

  /// Проверка, можно ли решать уравнение
  bool get canSolve => 
      _coefficientA.isNotEmpty && 
      _coefficientB.isNotEmpty && 
      _coefficientC.isNotEmpty &&
      _coefficientAError == null &&
      _coefficientBError == null &&
      _coefficientCError == null &&
      _state != AppState1.solving &&
      _state != AppState1.analyzingImage;

  /// Проверка, можно ли анализировать изображение
  bool get canAnalyzeImage => 
      _selectedImage != null && 
      _state != AppState1.analyzingImage &&
      _state != AppState1.solving;

  /// Получение уравнения для анализа
  String? get equationForAnalysis {
    final preview = _buildPreviewCoefficients();
    return preview?.equation;
  }

  SolutionResult? _buildSolutionPreview() {
    final preview = _buildPreviewCoefficients();
    if (preview == null) {
      return null;
    }

    return _solveQuadraticUseCase.execute(preview);
  }

  QuadraticCoefficients? _buildPreviewCoefficients() {
    final aError = MathUtils.validateCoefficient(_coefficientA);
    final bError = MathUtils.validateCoefficient(_coefficientB, allowZero: true);
    final cError = MathUtils.validateCoefficient(_coefficientC, allowZero: true);
    if (aError != null || bError != null || cError != null) {
      return null;
    }

    final a = MathUtils.tryParseCoefficient(_coefficientA);
    final b = MathUtils.tryParseCoefficient(_coefficientB);
    final c = MathUtils.tryParseCoefficient(_coefficientC);
    if (a == null || b == null || c == null) {
      return null;
    }

    return QuadraticCoefficients(a: a, b: b, c: c);
  }

  String? _resolveSelectedImagePath() {
    if (_selectedImage is File) {
      return (_selectedImage as File).path;
    }

    if (_selectedImage is XFile) {
      return (_selectedImage as XFile).path;
    }

    return null;
  }

  void _clearErrorIfNeeded() {
    if (_state == AppState1.solved || _state == AppState1.imageAnalyzed) {
      _state = AppState1.initial;
    }
    if (_state == AppState1.error) {
      _errorMessage = null;
      _state = AppState1.initial;
    }
  }
}
