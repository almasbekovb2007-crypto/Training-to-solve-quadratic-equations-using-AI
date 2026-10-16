import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/image_analysis_result.dart';
import '../providers/quadratic_provider.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/analysis_result_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Экран анализа изображений
class ImageAnalysisScreen extends StatelessWidget {
  const ImageAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('image_analysis.title'.tr()),
      ),
      body: Consumer<QuadraticProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoWidget(
                  message: 'image_analysis.info_message'.tr(),
                  icon: Icons.camera_alt,
                ),
                if (provider.equationForAnalysis != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'main.your_equation'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.equationForAnalysis!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (provider.selectedImage == null)
                  ImagePickerWidget(
                    onImageSelected: provider.setSelectedImage,
                  )
                else
                  Column(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImage(provider),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: provider.resetImageAnalysis,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: Text('image_analysis.delete'.tr()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: provider.canAnalyzeImage
                                  ? () => _analyzeImage(context, provider)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('image_analysis.analyze'.tr()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (provider.state == AppState1.error && provider.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  CustomErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: provider.selectedImage != null
                        ? () => _analyzeImage(context, provider)
                        : null,
                  ),
                ],
                if (provider.state == AppState1.analyzingImage) ...[
                  const SizedBox(height: 24),
                  LoadingWidget(message: 'image_analysis.analyzing'.tr()),
                ],
                if (provider.imageAnalysisResult != null) ...[
                  const SizedBox(height: 24),
                  AnalysisResultWidget(
                    result: provider.imageAnalysisResult!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(QuadraticProvider provider) {
    final bytes = provider.selectedImageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
      );
    }

    return Container(
      color: Colors.grey[100],
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        size: 56,
        color: Colors.grey[500],
      ),
    );
  }

  /// Анализ изображения
  void _analyzeImage(BuildContext context, QuadraticProvider provider) async {
    await provider.analyzeImage(
      equation: provider.equationForAnalysis,
    );
    
    if (context.mounted) {
      // Показываем снэкбар с результатом
      final result = provider.imageAnalysisResult;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.statusText),
            backgroundColor: _getSnackBarColor(result.status),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getSnackBarColor(ImageAnalysisStatus status) {
    switch (status) {
      case ImageAnalysisStatus.correct:
        return Colors.green;
      case ImageAnalysisStatus.errorsFound:
        return Colors.orange;
      case ImageAnalysisStatus.needsReview:
        return Colors.blue;
    }
  }
}
