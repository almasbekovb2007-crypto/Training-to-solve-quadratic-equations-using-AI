import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/image_analysis_result.dart';

/// Виджет для отображения результата анализа изображения
class AnalysisResultWidget extends StatelessWidget {
  final ImageAnalysisResult result;

  const AnalysisResultWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();
    final accentBackground = _getAccentBackgroundColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок результата
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'image_analysis.result_title'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(result.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Статус
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: accentColor.withOpacity(0.25),
                ),
              ),
              child: Text(
                result.statusText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Объяснение
            if (result.explanation.isNotEmpty) ...[
              Text(
                'image_analysis.explanation'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  result.explanation,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (result.recognizedText.isNotEmpty) ...[
              Text(
                'image_analysis.recognized_text'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  result.recognizedText,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Ошибки
            if (result.errors.isNotEmpty) ...[
              Text(
                'image_analysis.errors'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.errors.map((error) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Правильное решение
            if (result.correctSolution.isNotEmpty) ...[
              Text(
                'image_analysis.correct_solution'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  result.correctSolution,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyResult(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text('common.copy'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyResult(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln(result.statusText);
    if (result.explanation.isNotEmpty) {
      buffer.writeln('${tr('image_analysis.explanation')} ${result.explanation}');
    }
    if (result.errors.isNotEmpty) {
      buffer.writeln(tr('image_analysis.errors'));
      for (final error in result.errors) {
        buffer.writeln('- $error');
      }
    }
    if (result.correctSolution.isNotEmpty) {
      buffer.writeln('${tr('image_analysis.correct_solution')} ${result.correctSolution}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('common.copied'.tr())),
    );
  }

  IconData _getStatusIcon() {
    switch (result.status) {
      case ImageAnalysisStatus.correct:
        return Icons.check_circle;
      case ImageAnalysisStatus.errorsFound:
        return Icons.error_outline;
      case ImageAnalysisStatus.needsReview:
        return Icons.fact_check_outlined;
    }
  }

  Color _getAccentColor() {
    switch (result.status) {
      case ImageAnalysisStatus.correct:
        return Colors.green;
      case ImageAnalysisStatus.errorsFound:
        return Colors.orange;
      case ImageAnalysisStatus.needsReview:
        return Colors.blue;
    }
  }

  Color _getAccentBackgroundColor() {
    switch (result.status) {
      case ImageAnalysisStatus.correct:
        return Colors.green[50]!;
      case ImageAnalysisStatus.errorsFound:
        return Colors.orange[50]!;
      case ImageAnalysisStatus.needsReview:
        return Colors.blue[50]!;
    }
  }
}
