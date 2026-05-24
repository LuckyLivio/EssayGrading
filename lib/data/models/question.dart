class Question {
  final String id;
  final String title;
  final String content;
  final String type; // 归纳概括, 公文写作, 大作文
  final String year;
  final String province;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.year,
    required this.province,
  });
}

// Mock data
final List<Question> mockQuestions = [
  Question(
    id: '1',
    title: '概括小张在乡村振兴中的主要做法',
    content: '给定资料1中提到了大学生村官小张在A村开展乡村振兴工作的情况。请归纳概括小张的主要做法。要求：全面、准确、有条理，不超过200字。',
    type: '归纳概括',
    year: '2023',
    province: '国考',
  ),
  Question(
    id: '2',
    title: '关于开展“垃圾分类”的倡议书',
    content: '假设你是某市城管局的工作人员，请结合给定资料，起草一份关于开展“垃圾分类”的倡议书。要求：格式正确，语言得体，具有号召力，不超过500字。',
    type: '公文写作',
    year: '2022',
    province: '山东',
  ),
  Question(
    id: '3',
    title: '以“韧性”为主题写一篇文章',
    content: '给定资料中提到“城市需要韧性，人也需要韧性”。请结合你对这句话的思考，自选角度，自拟题目，写一篇文章。要求：观点明确，论述深刻，结构完整，语言流畅，1000-1200字。',
    type: '大作文',
    year: '2023',
    province: '浙江',
  ),
];
