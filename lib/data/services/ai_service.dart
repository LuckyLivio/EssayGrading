import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/prompts.dart';
import '../models/grading_result.dart';

class AiService {
  final Dio _dio = Dio();

  Future<GradingResult> gradeEssay({
    required String apiUrl,
    required String apiKey,
    required String model,
    required String questionType,
    required String questionText,
    required String answerText,
    required int strictness, // 0: 宽松, 1: 适中, 2: 严格
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('请先在设置中配置API Key');
    }

    String prompt = AppPrompts.getPromptForType(questionType, questionText, answerText);
    
    String strictnessPrompt = '';
    if (strictness == 0) {
      strictnessPrompt = '请采用较为宽松的批改标准，多给予鼓励。';
    } else if (strictness == 2) {
      strictnessPrompt = '请采用极其严格的批改标准，不放过任何瑕疵。';
    }
    
    prompt = '$prompt\n$strictnessPrompt';

    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'system', 'content': AppPrompts.systemPrompt},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        },
      );

      final String content = response.data['choices'][0]['message']['content'];
      final Map<String, dynamic> jsonMap = jsonDecode(content);
      return GradingResult.fromJson(jsonMap);
    } catch (e) {
      throw Exception('AI批改失败: $e');
    }
  }
}
