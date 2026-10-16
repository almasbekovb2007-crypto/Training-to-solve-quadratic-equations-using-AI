import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:web/web.dart' as web;
import '../../core/constants/app_constants.dart';
import 'dart:async'; // ✅ для Completer
import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:js' as js; // ✅ для js.context
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
/// Результат анализа ИИ
class AiAnalysisResponse {
  final bool isCorrect;
  final String feedback;
  final List<String> errors;
  final double confidence;
  final String analysis;
  final String roots;

  AiAnalysisResponse({
    required this.isCorrect,
    required this.feedback,
    required this.errors,
    required this.confidence,
    required this.analysis,
    required this.roots,
  });

  factory AiAnalysisResponse.fromText(String text) {
    final roots = _extractRoots(text);
    final hasRoots = roots.isNotEmpty;
    return AiAnalysisResponse(
      isCorrect: hasRoots,
      feedback: hasRoots
          ? tr('image_analysis.ai_solution_found')
          : tr('image_analysis.ai_no_roots'),
      errors: hasRoots ? [] : [tr('image_analysis.ai_no_roots')],
      confidence: hasRoots ? 0.9 : 0.0,
      analysis: text,
      roots: roots,
    );
  }

  static String _extractRoots(String text) {
    final normalized = text.replaceAll(',', '.');
    final rootRegex = RegExp(
      r'(?:x(?:₁|1)?\s*[:=]\s*([+-]?\d+(?:\.\d+)?))|(?:x(?:₂|2)?\s*[:=]\s*([+-]?\d+(?:\.\d+)?))',
      caseSensitive: false,
    );
    final matches = rootRegex.allMatches(normalized).toList();
    if (matches.isEmpty) {
      final singleRoot = RegExp(
        r'\bx\s*[:=]\s*([+-]?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ).firstMatch(normalized);
      if (singleRoot != null) return 'x = ${singleRoot.group(1)}';
      return '';
    }
    final extracted = matches
        .map((m) => m.group(1) ?? m.group(2) ?? '')
        .where((v) => v.isNotEmpty)
        .toList();
    if (extracted.isEmpty) return '';
    if (extracted.length == 1) return 'x = ${extracted.first}';
    return extracted.asMap().entries
        .map((e) => 'x${e.key + 1} = ${e.value}')
        .join(', ');
  }
}

/// Сервис анализа: Tesseract.js OCR + DeepSeek
class AiVisionService {
  final http.Client _httpClient;
  final String _apiKey;

  AiVisionService({
    required http.Client httpClient,
    required String apiKey,
  })  : _httpClient = httpClient,
        _apiKey = apiKey;

  /// Главный метод — OCR через Tesseract.js, затем DeepSeek
  Future<AiAnalysisResponse> analyzeImageBase64({
    required String base64Image,
  }) async {
    print('[OCR] Starting Tesseract.js OCR...');

    try {
      // Шаг 1: OCR через Tesseract.js в браузере
      final ocrText = await _runTesseractOcr(base64Image);
      print('[OCR] Result: $ocrText');

      if (ocrText.trim().isEmpty) {
        throw Exception(tr('image_analysis.ocr_no_text_found'));
      }

      // Шаг 2: Отправить текст в DeepSeek
      return await _analyzeWithDeepSeek(ocrText);

    } on http.ClientException catch (e) {
      throw Exception('${tr('validation.network_error')}: ${e.message}');
    } catch (e) {
      throw Exception('${tr('validation.analyze_error')}: $e');
    }
  }

  /// OCR через Tesseract.js (работает в браузере без ML Kit)
  Future<String> _runTesseractOcr(String base64Image) async {
    // Вызываем глобальную JS функцию которую добавим в index.html
    final jsResult = await _callTesseract(base64Image);
    return jsResult;
  }

  Future<String> _callTesseract(String base64Image) {
    final completer = Completer<String>();

    // Используем dart:js_interop для вызова Tesseract
    final imageData = 'data:image/jpeg;base64,$base64Image';

    js.context.callMethod('runTesseractOcr', [
      imageData,
      js.allowInterop((String result) {
        completer.complete(result);
      }),
      js.allowInterop((String error) {
        completer.completeError(error);
      }),
    ]);

    return completer.future;
  }

  /// Анализ текста через DeepSeek
  Future<AiAnalysisResponse> _analyzeWithDeepSeek(String ocrText) async {
    print('[DeepSeek] Sending OCR text: $ocrText');

    final prompt = '''
Вот текст решения квадратного уравнения студентом (распознан через OCR):

$ocrText

Задача:
1. Определи коэффициенты a, b, c квадратного уравнения
2. Проверь каждый шаг решения (дискриминант, формулы корней)
3. Найди ошибки если есть

Верни ответ строго в таком формате:
КОРНИ: x1=... x2=...
ОШИБКИ: (перечисли конкретные ошибки или напиши "нет")
АНАЛИЗ: (подробный разбор каждого шага)
''';

    final response = await _httpClient.post(
      Uri.parse(AppConstants.aiProviderUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    print('[DeepSeek] Status: ${response.statusCode}');
    print('[DeepSeek] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('${tr('validation.analyze_error')}: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final content = body['choices'][0]['message']['content'] as String;

    if (content.trim().isEmpty) {
      throw Exception(tr('validation.empty_ai_response'));
    }

    return AiAnalysisResponse.fromText(content);
  }
}