import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Сервис реального OCR через Google ML Kit
class MlKitTextRecognitionService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> recognizeText({
    String? imagePath,
  }) async {
    if (imagePath == null || imagePath.isEmpty) {
      print('[OCR] imagePath is null');
      return null;
    }

    if (!kIsWeb && !File(imagePath).existsSync()) {
      print('[OCR] File not found');
      return null;
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      print('[OCR RAW] ${recognizedText.text}');
      for (final block in recognizedText.blocks) {
        print('[OCR BLOCK] ${block.text}');
      }

      final text = recognizedText.text.trim();
      return text;
    } catch (e) {
      print('[OCR ERROR] $e');
      return null;
    }
  }

  Future<String?> recognizeTextFromBytes({
    required Uint8List imageBytes,
  }) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(0, 0),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 0,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);
      print('[OCR RAW] ${recognizedText.text}');
      for (final block in recognizedText.blocks) {
        print('[OCR BLOCK] ${block.text}');
      }

      final text = recognizedText.text.trim();
      return text.isEmpty ? null : text;
    } catch (e) {
      print('[OCR ERROR] $e');
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
