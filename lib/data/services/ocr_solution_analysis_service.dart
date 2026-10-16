import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
import '../models/image_analysis_result.dart';
import '../models/solution_result.dart';

/// Разбор OCR-текста и сравнение с правильным решением
class OcrSolutionAnalysisService {
  ImageAnalysisResult analyzeRecognizedText({
    required String recognizedText,
    required ImageAnalysisRequest request,
    required String correctSolution,
  }) {
    final normalizedLines = recognizedText
        .split('\n')
        .map(_normalizeLine)
        .where((line) => line.isNotEmpty)
        .toList();

    final expectedEquation = request.equation != null
        ? _extractEquationFromText(request.equation!)
        : null;
    final detectedEquation = _extractEquationFromText(recognizedText);
    final detectedDiscriminant = _extractDiscriminant(normalizedLines);
    final detectedRoots = _extractRoots(normalizedLines);
    final reference = request.referenceSolution;

    final errors = <String>[];
    final notes = <String>[];

    if (expectedEquation != null) {
      if (detectedEquation == null) {
        notes.add(tr('image_analysis.ocr_equation_not_found'));
      } else if (!_sameEquation(expectedEquation, detectedEquation)) {
        errors.add(tr('image_analysis.ocr_equation_mismatch'));
      }
    }

    if (reference != null) {
      if (detectedDiscriminant == null) {
        notes.add(tr('image_analysis.ocr_discriminant_not_found'));
      } else if (!_approximatelyEqual(
        detectedDiscriminant,
        reference.discriminant,
      )) {
        errors.add(tr('image_analysis.ocr_discriminant_mismatch'));
      }

      if (reference.roots.isEmpty) {
        if (detectedRoots.isNotEmpty) {
          errors.add(tr('image_analysis.ocr_roots_mismatch'));
        }
      } else if (detectedRoots.isEmpty) {
        notes.add(tr('image_analysis.ocr_roots_not_found'));
      } else if (!_sameRootSet(detectedRoots, reference.roots)) {
        errors.add(tr('image_analysis.ocr_roots_mismatch'));
      }
    }

    if (errors.isNotEmpty) {
      return ImageAnalysisResult.withErrors(
        errors: errors,
        correctSolution: correctSolution,
        explanation: notes.isEmpty
            ? tr('image_analysis.ocr_errors_explanation')
            : notes.join(' '),
        confidence: 0.82,
        recognizedText: recognizedText,
      );
    }

    final hasAnyRecognizedMath =
        detectedEquation != null ||
        detectedDiscriminant != null ||
        detectedRoots.isNotEmpty;

    if (hasAnyRecognizedMath &&
        _isCompleteAnalysis(
          expectedEquation: expectedEquation,
          detectedEquation: detectedEquation,
          reference: reference,
          detectedDiscriminant: detectedDiscriminant,
          detectedRoots: detectedRoots,
        )) {
      return ImageAnalysisResult(
        errors: const [],
        correctSolution: correctSolution,
        explanation: tr('image_analysis.ocr_match_explanation'),
        status: ImageAnalysisStatus.correct,
        confidence: 0.93,
        recognizedText: recognizedText,
      );
    }

    return ImageAnalysisResult.needsReview(
      correctSolution: correctSolution,
      explanation: hasAnyRecognizedMath
          ? tr('image_analysis.ocr_partial_review')
          : tr('image_analysis.ocr_no_text_found'),
      errors: notes.isEmpty
          ? [tr('image_analysis.ocr_partial_issue')]
          : notes,
      confidence: hasAnyRecognizedMath ? 0.58 : 0.28,
      recognizedText: recognizedText,
    );
  }

  bool _isCompleteAnalysis({
    required _ParsedQuadratic? expectedEquation,
    required _ParsedQuadratic? detectedEquation,
    required SolutionResult? reference,
    required double? detectedDiscriminant,
    required List<double> detectedRoots,
  }) {
    final equationOk = expectedEquation == null || detectedEquation != null;
    final discriminantOk = reference == null || detectedDiscriminant != null;

    final rootsOk =
        reference == null ||
        reference.roots.isEmpty ||
        detectedRoots.length >= reference.roots.length;

    return equationOk && discriminantOk && rootsOk;
  }

  _ParsedQuadratic? _extractEquationFromText(String text) {
    final candidateLines = text
        .split('\n')
        .map(_normalizeLine)
        .where(_looksLikeEquationLine)
        .toList();

    for (final line in candidateLines) {
      final parsed = _parseEquationLine(line);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  bool _looksLikeEquationLine(String line) {
    return line.contains('=0') &&
        line.contains('x') &&
        (line.contains('x^2') || line.contains('x2'));
  }

  _ParsedQuadratic? _parseEquationLine(String line) {
    final leftPart = line.split('=').first;
    final rawTerms = RegExp(r'[+\-]?[^+\-]+')
        .allMatches(leftPart)
        .map((match) => match.group(0)!)
        .where((term) => term.isNotEmpty)
        .toList();

    var a = 0.0;
    var b = 0.0;
    var c = 0.0;
    var hasQuadraticTerm = false;

    for (final term in rawTerms) {
      if (term.contains('x^2') || term.contains('x2')) {
        final coefficient = term
            .replaceAll('x^2', '')
            .replaceAll('x2', '');
        a = _parseCoefficientToken(coefficient);
        hasQuadraticTerm = true;
      } else if (term.contains('x')) {
        final coefficient = term.replaceAll('x', '');
        b = _parseCoefficientToken(coefficient);
      } else {
        final value = double.tryParse(term);
        if (value != null) {
          c = value;
        }
      }
    }

    if (!hasQuadraticTerm) {
      return null;
    }

    return _ParsedQuadratic(a: a, b: b, c: c);
  }

  double _parseCoefficientToken(String token) {
    if (token.isEmpty || token == '+') {
      return 1.0;
    }
    if (token == '-') {
      return -1.0;
    }

    return double.tryParse(token) ?? 0.0;
  }

  double? _extractDiscriminant(List<String> lines) {
    for (final line in lines.reversed) {
      if (!line.contains('d') || !line.contains('=')) {
        continue;
      }

      final value = _extractLastNumber(line);
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  List<double> _extractRoots(List<String> lines) {
    double? x1;
    double? x2;
    double? singleRoot;

    for (final line in lines) {
      if (!line.contains('x') || !line.contains('=')) {
        continue;
      }

      final value = _extractLastNumber(line);
      if (value == null) {
        continue;
      }

      if (line.contains('x1=')) {
        x1 = value;
      } else if (line.contains('x2=')) {
        x2 = value;
      } else if (line.startsWith('x=')) {
        singleRoot = value;
      }
    }

    if (x1 != null && x2 != null) {
      return [x1, x2];
    }

    if (singleRoot != null) {
      return [singleRoot];
    }

    if (x1 != null) {
      return [x1];
    }

    return const [];
  }

  double? _extractLastNumber(String line) {
    final matches = RegExp(r'-?\d+(?:\.\d+)?').allMatches(line).toList();
    if (matches.isEmpty) {
      return null;
    }

    return double.tryParse(matches.last.group(0)!);
  }

  String _normalizeLine(String line) {
    return line
        .toLowerCase()
        .replaceAll('х', 'x')
        .replaceAll('Х', 'x')
        .replaceAll('₁', '1')
        .replaceAll('₂', '2')
        .replaceAll('²', '^2')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(',', '.')
        .replaceAll(' ', '')
        .replaceAll('\t', '');
  }

  bool _sameEquation(_ParsedQuadratic first, _ParsedQuadratic second) {
    return _approximatelyEqual(first.a, second.a) &&
        _approximatelyEqual(first.b, second.b) &&
        _approximatelyEqual(first.c, second.c);
  }

  bool _sameRootSet(List<double> detected, List<double> expected) {
    if (detected.length != expected.length) {
      return false;
    }

    final left = [...detected]..sort();
    final right = [...expected]..sort();

    for (var i = 0; i < left.length; i++) {
      if (!_approximatelyEqual(left[i], right[i])) {
        return false;
      }
    }

    return true;
  }

  bool _approximatelyEqual(double first, double second) {
    final difference = (first - second).abs();
    final tolerance = max(AppConstants.epsilon * 10, 0.02);
    return difference <= tolerance;
  }
}

class _ParsedQuadratic {
  final double a;
  final double b;
  final double c;

  const _ParsedQuadratic({
    required this.a,
    required this.b,
    required this.c,
  });
}
