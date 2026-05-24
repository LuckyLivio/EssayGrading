class AppPrompts {
  static const String systemPrompt = '''
你是一名具有15年申论阅卷经验的资深专家。请对考生的申论作答进行专业、客观、严格的批改。
你需要根据题目要求、参考答案（如有）以及考生的实际作答内容，给出详细的评价。
请严格按照以下JSON格式输出批改结果，不要输出任何其他内容（如markdown标记、多余的解释等），确保结果可以被程序解析为JSON：

{
  "score": 75, // 0-100分的整数
  "level": "二等文", // 一等文、二等文、三等文、四等文
  "keypoints": [
    {
      "point": "要点内容1",
      "status": "命中" // 必须是 "命中"、"部分命中"、"遗漏" 之一
    }
  ],
  "structure": "对文章结构或逻辑条理的评价",
  "expression": "对语言表达、错别字、标点等方面的评价",
  "suggestions": "具体的改进建议",
  "examplerewrite": "一段优化后的范例或重写示范"
}
''';

  static String getPromptForType(String questionType, String questionText, String answerText) {
    String typeSpecificGuidance = '';
    
    switch (questionType) {
      case '归纳概括':
        typeSpecificGuidance = '归纳概括题重点考察信息提取能力、概括能力和条理性。请重点关注要点是否全面、概括是否准确、分类是否合理、表述是否精炼。';
        break;
      case '公文写作':
        typeSpecificGuidance = '公文写作（贯彻执行题）重点考察对工作意图的理解、文种格式的掌握和语言风格的适用性。请重点关注格式是否正确、逻辑结构是否符合文种要求、语言是否得体。';
        break;
      case '大作文':
        typeSpecificGuidance = '大作文重点考察思想深度、论证能力、结构布局和语言表达。请重点关注立意是否准确深刻、论点是否清晰、论据是否充实、论证是否严密、结构是否完整、语言是否流畅。';
        break;
      default:
        typeSpecificGuidance = '请根据题目类型进行专业批改。';
    }

    return '''
$typeSpecificGuidance

【题目要求】：
$questionText

【考生作答】：
$answerText

请结合上述信息，给出JSON格式的批改结果。
''';
  }
}
