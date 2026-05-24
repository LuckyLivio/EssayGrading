import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> recognizeText(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    final inputImage = InputImage.fromFilePath(imagePath);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('文字识别失败: $e');
    } finally {
      textRecognizer.close();
    }
  }
}
