import 'package:uuid/uuid.dart';

class Question {
  final String id;
  final String title;
  final String content;
  final String type;
  final String year;
  final String province;
  final bool isUserAdded;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.year,
    required this.province,
    this.isUserAdded = false,
  });

  Question copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    String? year,
    String? province,
    bool? isUserAdded,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      year: year ?? this.year,
      province: province ?? this.province,
      isUserAdded: isUserAdded ?? this.isUserAdded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type,
    'year': year,
    'province': province,
    'isUserAdded': isUserAdded,
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    type: json['type'] as String,
    year: json['year'] as String,
    province: json['province'] as String,
    isUserAdded: json['isUserAdded'] as bool? ?? false,
  );

  factory Question.create({
    required String title,
    required String content,
    required String type,
    required String year,
    required String province,
  }) => Question(
    id: const Uuid().v4(),
    title: title,
    content: content,
    type: type,
    year: year,
    province: province,
    isUserAdded: true,
  );
}

const List<String> questionTypes = ['归纳概括', '公文写作', '大作文'];
const List<String> questionYears = ['2024', '2023', '2022', '2021', '2020'];
const List<String> questionProvinces = [
  '国考', '北京', '上海', '广东', '浙江', '江苏',
  '山东', '四川', '河南', '河北', '湖南', '湖北',
  '安徽', '福建', '江西', '陕西', '山西', '辽宁',
  '吉林', '黑龙江', '内蒙古', '新疆', '甘肃', '宁夏',
  '青海', '云南', '贵州', '广西', '海南', '天津', '重庆',
];

final List<Question> builtInQuestions = [
  // ==================== 2024年真题 ====================
  Question(
    id: 'b2024g01', title: '概括B市推进新型城市化的主要举措',
    content: '请根据给定资料，概括B市在推进新型城市化过程中的主要举措。要求：全面、准确、有条理，不超过200字。',
    type: '归纳概括', year: '2024', province: '国考',
  ),
  Question(
    id: 'b2024g02', title: '写一份数字政府建设的经验材料',
    content: '假设你是某省政府办公厅工作人员，请根据给定资料，围绕"数字政府建设"主题，写一份经验交流材料。要求：结构清晰，重点突出，具有借鉴意义，不超过800字。',
    type: '公文写作', year: '2024', province: '国考',
  ),
  Question(
    id: 'b2024g03', title: '以"流动与新生"为题写文章',
    content: '给定资料中呈现了人口流动与城市发展的关系。请深入思考，自拟题目，写一篇文章。要求：观点鲜明，论证充分，结构完整，1000-1200字。',
    type: '大作文', year: '2024', province: '国考',
  ),

  // ==================== 2023年真题 ====================
  Question(
    id: 'b2023g01', title: '概括小张在乡村振兴中的主要做法',
    content: '给定资料1中提到了大学生村官小张在A村开展乡村振兴工作的情况。请归纳概括小张的主要做法。要求：全面、准确、有条理，不超过200字。',
    type: '归纳概括', year: '2023', province: '国考',
  ),
  Question(
    id: 'b2023g02', title: '关于开展"垃圾分类"的倡议书',
    content: '假设你是某市城管局的工作人员，请结合给定资料，起草一份关于开展"垃圾分类"的倡议书。要求：格式正确，语言得体，具有号召力，不超过500字。',
    type: '公文写作', year: '2023', province: '山东',
  ),
  Question(
    id: 'b2023z01', title: '以"韧性"为主题写一篇文章',
    content: '给定资料中提到"城市需要韧性，人也需要韧性"。请结合你对这句话的思考，自选角度，自拟题目，写一篇文章。要求：观点明确，论述深刻，结构完整，语言流畅，1000-1200字。',
    type: '大作文', year: '2023', province: '浙江',
  ),
  Question(
    id: 'b2023g03', title: '概括Z市打造一流营商环境的主要经验',
    content: '给定资料介绍了Z市在优化营商环境方面的探索与实践。请归纳概括其主要经验。要求：全面、准确、有条理，不超过250字。',
    type: '归纳概括', year: '2023', province: '国考',
  ),

  // ==================== 2022年真题 ====================
  Question(
    id: 'b2022g01', title: '概括"村超"火爆出圈的主要因素',
    content: '给定资料介绍了贵州"村超"现象。请分析其火爆出圈的主要因素。要求：分析全面，条理清晰，不超过200字。',
    type: '归纳概括', year: '2022', province: '国考',
  ),
  Question(
    id: 'b2022g02', title: '写一份关于青年就业创业的指导意见',
    content: '假设你是某省人社部门工作人员，请根据给定资料，起草一份关于支持青年就业创业的指导意见。要求：措施具体，有针对性，格式规范，不超过600字。',
    type: '公文写作', year: '2022', province: '国考',
  ),
  Question(
    id: 'b2022z01', title: '以"平衡"为话题写文章',
    content: '给定资料围绕发展与保护的平衡展开论述。请结合给定资料，自拟题目，写一篇文章。要求：观点鲜明，论据充实，论证严密，1000-1200字。',
    type: '大作文', year: '2022', province: '浙江',
  ),
  Question(
    id: 'b2022s01', title: '概括A市社会治理创新的主要做法',
    content: '给定资料描述了A市在社会治理方面的创新实践。请归纳概括其主要做法。要求：准确、全面、有条理，不超过200字。',
    type: '归纳概括', year: '2022', province: '四川',
  ),
  Question(
    id: 'b2022sd01', title: '写一份抗旱保收工作的紧急通知',
    content: '某县遭遇严重旱情，领导让你起草一份关于切实抓好抗旱保收工作的紧急通知。要求：格式规范，语气果断，措施有力，不超过500字。',
    type: '公文写作', year: '2022', province: '山东',
  ),

  // ==================== 2021年真题 ====================
  Question(
    id: 'b2021g01', title: '概括L村电商发展的成功路径',
    content: '给定资料介绍了L村通过发展农村电商实现脱贫致富的情况。请归纳概括其成功路径的主要特点。要求：简明扼要，条理清晰，不超过200字。',
    type: '归纳概括', year: '2021', province: '国考',
  ),
  Question(
    id: 'b2021g02', title: '关于加强未成年人保护的实施方案',
    content: '假设你是某市民政部门工作人员，请根据给定资料，起草一份关于加强未成年人保护工作的实施方案。要求：目标明确，措施具体，可操作性强，不超过600字。',
    type: '公文写作', year: '2021', province: '国考',
  ),
  Question(
    id: 'b2021g03', title: '以"敬畏"为主题写文章',
    content: '给定资料从多个角度探讨了"敬畏"的意义。请根据对给定资料的理解，自拟题目，写一篇文章。要求：立意深刻，论证有力，结构严谨，1000-1200字。',
    type: '大作文', year: '2021', province: '国考',
  ),
  Question(
    id: 'b2021h01', title: '概括W市历史文化街区保护的主要做法',
    content: '给定资料介绍了W市在历史文化街区保护与活化方面的经验。请归纳概括其主要做法。要求：全面、准确，不超过200字。',
    type: '归纳概括', year: '2021', province: '湖北',
  ),

  // ==================== 2020年真题 ====================
  Question(
    id: 'b2020g01', title: '概括某地产业扶贫的主要模式',
    content: '给定资料介绍了多个地区产业扶贫的做法。请归纳概括其主要模式。要求：分类准确，表述清晰，不超过200字。',
    type: '归纳概括', year: '2020', province: '国考',
  ),
  Question(
    id: 'b2020g02', title: '写一份推进复工复产的倡议书',
    content: '假设你是某市工信部门工作人员，在疫情防控常态化背景下，请起草一份关于有序推进复工复产的倡议书。要求：语言得体，措施务实，不超过500字。',
    type: '公文写作', year: '2020', province: '国考',
  ),
  Question(
    id: 'b2020g03', title: '以"诚信"为主题写文章',
    content: '给定资料探讨了社会诚信建设的重要性。请结合给定资料和生活实际，自拟题目，写一篇文章。要求：观点鲜明，论据充分，论证严密，1000-1200字。',
    type: '大作文', year: '2020', province: '国考',
  ),
];
