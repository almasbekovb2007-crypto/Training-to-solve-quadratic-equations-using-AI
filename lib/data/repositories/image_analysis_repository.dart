import 'package:easy_localization/easy_localization.dart';
import '../models/image_analysis_result.dart';
import '../models/solution_result.dart';
import '../datasources/image_analysis_remote_datasource.dart';

/// Репозиторий для анализа изображений
class ImageAnalysisRepository {
  final ImageAnalysisRemoteDataSource _remoteDataSource;

  ImageAnalysisRepository(this._remoteDataSource);

  /// Анализ изображения решения
  Future<ImageAnalysisResult> analyzeImage(
    String base64Image, {
    String? equation,
    SolutionResult? referenceSolution,
    String? imagePath,
  }) async {
    try {
      final request = ImageAnalysisRequest(
        base64Image: base64Image,
        equation: equation,
        referenceSolution: referenceSolution,
        imagePath: imagePath,
      );
      
      return await _remoteDataSource.analyzeImage(request);
    } catch (e) {
      // В случае ошибки возвращаем результат с сообщением об ошибке
      return ImageAnalysisResult.withErrors(
        errors: [tr('validation.analyze_error')],
        correctSolution: '',
        explanation: tr('image_analysis.analysis_retry'),
        confidence: 0.0,
        recognizedText: '',
      );
    }
  }
}
