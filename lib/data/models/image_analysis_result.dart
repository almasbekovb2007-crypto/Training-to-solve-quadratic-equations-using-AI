import 'package:easy_localization/easy_localization.dart';
import 'solution_result.dart';

enum ImageAnalysisStatus {
  correct,
  errorsFound,
  needsReview,
}

/// Результат анализа изображения решения
class ImageAnalysisResult {
  final List<String> errors;
  final String correctSolution;
  final String explanation;
  final ImageAnalysisStatus status;
  final double confidence;
  final String recognizedText;

  const ImageAnalysisResult({
    required this.errors,
    required this.correctSolution,
    required this.explanation,
    required this.status,
    required this.confidence,
    this.recognizedText = '',
  });

  /// Создание из JSON
  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String?;
    final isCorrect = json['is_correct'] as bool?;

    return ImageAnalysisResult(
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      correctSolution: json['correct_solution'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      status: _parseStatus(statusName, isCorrect),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recognizedText: json['recognized_text'] as String? ?? '',
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'errors': errors,
      'correct_solution': correctSolution,
      'explanation': explanation,
      'status': status.name,
      'is_correct': isCorrect,
      'confidence': confidence,
      'recognized_text': recognizedText,
    };
  }

  /// Создание успешного результата (без ошибок)
  factory ImageAnalysisResult.success() {
    return ImageAnalysisResult(
      errors: [],
      correctSolution: '',
      explanation: tr('image_analysis.correct_explanation'),
      status: ImageAnalysisStatus.correct,
      confidence: 1.0,
      recognizedText: '',
    );
  }

  /// Создание результата с ошибками
  factory ImageAnalysisResult.withErrors({
    required List<String> errors,
    required String correctSolution,
    required String explanation,
    double confidence = 0.8,
    String recognizedText = '',
  }) {
    return ImageAnalysisResult(
      errors: errors,
      correctSolution: correctSolution,
      explanation: explanation,
      status: ImageAnalysisStatus.errorsFound,
      confidence: confidence,
      recognizedText: recognizedText,
    );
  }

  /// Создание результата, требующего ручной проверки
  factory ImageAnalysisResult.needsReview({
    required String explanation,
    required String correctSolution,
    List<String> errors = const [],
    double confidence = 0.4,
    String recognizedText = '',
  }) {
    return ImageAnalysisResult(
      errors: errors,
      correctSolution: correctSolution,
      explanation: explanation,
      status: ImageAnalysisStatus.needsReview,
      confidence: confidence,
      recognizedText: recognizedText,
    );
  }

  bool get isCorrect => status == ImageAnalysisStatus.correct;

  /// Получение статуса анализа
  String get statusText {
    switch (status) {
      case ImageAnalysisStatus.correct:
        return tr('image_analysis.correct');
      case ImageAnalysisStatus.errorsFound:
        return tr('image_analysis.errors_found');
      case ImageAnalysisStatus.needsReview:
        return tr('image_analysis.needs_review');
    }
  }

  /// Получение цвета статуса
  String get statusColor {
    switch (status) {
      case ImageAnalysisStatus.correct:
        return 'green';
      case ImageAnalysisStatus.errorsFound:
        return 'red';
      case ImageAnalysisStatus.needsReview:
        return 'blue';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageAnalysisResult &&
          runtimeType == other.runtimeType &&
          _listEquals(errors, other.errors) &&
          correctSolution == other.correctSolution &&
          explanation == other.explanation &&
          status == other.status &&
          confidence == other.confidence &&
          recognizedText == other.recognizedText;

  @override
  int get hashCode => 
      errors.hashCode ^ 
      correctSolution.hashCode ^ 
      explanation.hashCode ^ 
      status.hashCode ^ 
      confidence.hashCode ^
      recognizedText.hashCode;

  /// Сравнение списков
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'ImageAnalysisResult(status: $status, errors: ${errors.length}, confidence: $confidence, recognizedTextLength: ${recognizedText.length})';

  static ImageAnalysisStatus _parseStatus(String? statusName, bool? isCorrect) {
    if (statusName != null) {
      return ImageAnalysisStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => isCorrect == true
            ? ImageAnalysisStatus.correct
            : ImageAnalysisStatus.errorsFound,
      );
    }

    if (isCorrect == true) {
      return ImageAnalysisStatus.correct;
    }

    return ImageAnalysisStatus.errorsFound;
  }
}

/// Запрос для анализа изображения
class ImageAnalysisRequest {
  final String base64Image;
  final String? equation;
  final SolutionResult? referenceSolution;
  final String? imagePath;

  const ImageAnalysisRequest({
    required this.base64Image,
    this.equation,
    this.referenceSolution,
    this.imagePath,
  });

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'image': base64Image,
      if (equation != null) 'equation': equation,
      if (imagePath != null) 'image_path': imagePath,
    };
  }

  @override
  String toString() => 'ImageAnalysisRequest(imageLength: ${base64Image.length}, equation: $equation)';
}
