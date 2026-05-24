class GradingResult {
  final int score;
  final String level;
  final List<KeyPoint> keypoints;
  final String structure;
  final String expression;
  final String suggestions;
  final String examplerewrite;

  GradingResult({
    required this.score,
    required this.level,
    required this.keypoints,
    required this.structure,
    required this.expression,
    required this.suggestions,
    required this.examplerewrite,
  });

  factory GradingResult.fromJson(Map<String, dynamic> json) {
    return GradingResult(
      score: json['score'] ?? 0,
      level: json['level'] ?? '四等文',
      keypoints: (json['keypoints'] as List<dynamic>?)
              ?.map((e) => KeyPoint.fromJson(e))
              .toList() ??
          [],
      structure: json['structure'] ?? '',
      expression: json['expression'] ?? '',
      suggestions: json['suggestions'] ?? '',
      examplerewrite: json['examplerewrite'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'keypoints': keypoints.map((e) => e.toJson()).toList(),
      'structure': structure,
      'expression': expression,
      'suggestions': suggestions,
      'examplerewrite': examplerewrite,
    };
  }
}

class KeyPoint {
  final String point;
  final String status;

  KeyPoint({required this.point, required this.status});

  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      point: json['point'] ?? '',
      status: json['status'] ?? '遗漏',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point': point,
      'status': status,
    };
  }
}
