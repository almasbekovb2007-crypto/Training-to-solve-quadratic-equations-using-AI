import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:image/image.dart' as img;
import '../../data/models/image_analysis_result.dart';
import '../services/ai_vision_service.dart';

/// Удаленный источник данных для анализа изображений
class ImageAnalysisRemoteDataSource {
  final AiVisionService _aiVisionService;

  ImageAnalysisRemoteDataSource({
    required AiVisionService aiVisionService,
  })  : _aiVisionService = aiVisionService;

  /// Анализ изображения через AI-провайдера (например, DeepSeek)
  Future<ImageAnalysisResult> analyzeImage(ImageAnalysisRequest request) async {
    try {
      print('[STEP 1] Decoding base64...');
      final decodedBytes = base64Decode(request.base64Image);

      print('[STEP 2] Decoding image...');
      final image = img.decodeImage(decodedBytes);

      if (image == null) {
        return ImageAnalysisResult.withErrors(
          errors: [tr('image_analysis.decode_failed')],
          correctSolution: '',
          explanation: tr('image_analysis.analysis_retry'),
          confidence: 0.0,
          recognizedText: '',
        );
      }

      print('[STEP 3] Analyzing quality...');
      final qualityIssues = _analyzeImageQuality(image);

      print('[AI] Sending image to Gemini Vision');
      final aiResponse = await _aiVisionService.analyzeImageBase64(
        base64Image: request.base64Image,
      );

      final result = ImageAnalysisResult(
        errors: aiResponse.errors,
        correctSolution: aiResponse.roots,
        explanation: aiResponse.analysis,
        status: aiResponse.isCorrect
            ? ImageAnalysisStatus.correct
            : ImageAnalysisStatus.needsReview,
        confidence: aiResponse.confidence,
        recognizedText: '',
      );

      return _mergeQualityIssues(result, qualityIssues);
    } catch (e) {
      print('[Analysis] Failed: $e');
      return ImageAnalysisResult.withErrors(
        errors: ['${tr('validation.analyze_error')}: ${e.toString()}'],
        correctSolution: '',
        explanation: tr('image_analysis.analysis_retry'),
        confidence: 0.0,
        recognizedText: '',
      );
    }
  }


  ImageAnalysisResult _mergeQualityIssues(
    ImageAnalysisResult result,
    List<String> qualityIssues,
  ) {
    if (qualityIssues.isEmpty) {
      return result;
    }

    final mergedErrors = List<String>.from(result.errors);
    mergedErrors.addAll(qualityIssues);

    final mergedExplanation = result.explanation.isNotEmpty
        ? '${result.explanation}\n${qualityIssues.join('. ')}'
        : qualityIssues.join('. ');

    return ImageAnalysisResult(
      errors: mergedErrors,
      correctSolution: result.correctSolution,
      explanation: mergedExplanation,
      status: result.status,
      confidence: result.confidence,
      recognizedText: result.recognizedText,
    );
  }

  List<String> _analyzeImageQuality(img.Image image) {
    final issues = <String>[];
    final width = image.width;
    final height = image.height;

    if (width < 300 || height < 300) {
      issues.add(tr('image_analysis.low_resolution'));
    }

    final stats = _calculateLuminanceStats(image);

    if (stats.average < 30) {
      issues.add(tr('image_analysis.too_dark'));
    } else if (stats.average > 230) {
      issues.add(tr('image_analysis.too_bright'));
    }

    if (stats.contrast < 10) {
      issues.add(tr('image_analysis.low_contrast'));
    }

    if (stats.darkPixelRatio < 0.002) {
      issues.add(tr('image_analysis.not_enough_text'));
    }

    return issues;
  }

  _LuminanceStats _calculateLuminanceStats(img.Image image) {
    var sum = 0.0;
    var sumSquares = 0.0;
    var darkPixels = 0;
    final total = image.width * image.height;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = (0.2126 * pixel.r) + (0.7152 * pixel.g) + (0.0722 * pixel.b);
        sum += luminance;
        sumSquares += luminance * luminance;
        if (luminance < 110) {
          darkPixels++;
        }
      }
    }

    final average = sum / total;
    final variance = (sumSquares / total) - (average * average);
    final contrast = variance <= 0 ? 0.0 : sqrt(variance);

    return _LuminanceStats(
      average: average,
      contrast: contrast,
      darkPixelRatio: darkPixels / total,
    );
  }
}

class _LuminanceStats {
  final double average;
  final double contrast;
  final double darkPixelRatio;

  const _LuminanceStats({
    required this.average,
    required this.contrast,
    required this.darkPixelRatio,
  });
}
