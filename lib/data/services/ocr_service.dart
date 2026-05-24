import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> recognizeText(String imagePath) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFilePath(imagePath);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String result = recognizedText.text.trim();
      
      if (result.isEmpty) {
        throw Exception('未能识别到任何文字，请确保图片清晰且包含文字。');
      }
      
      return result;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('文字识别过程发生异常: $e');
    } finally {
      textRecognizer.close();
    }
  }
}
