class ExplanationItem {
  final String feature;
  final String value;
  final double impact;
  final String direction;

  ExplanationItem({
    required this.feature,
    required this.value,
    required this.impact,
    required this.direction,
  });

  factory ExplanationItem.fromJson(Map<String, dynamic> json) {
    return ExplanationItem(
      feature: json['feature'] ?? '',
      value: json['value'] ?? '',
      impact: (json['impact'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 'neutral',
    );
  }
}

class RecommendationItem {
  final String category;
  final String title;
  final String suggestion;

  RecommendationItem({
    required this.category,
    required this.title,
    required this.suggestion,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }
}

class PredictionResponse {
  final String prediction;
  final String rawClass;
  final int classId;
  final Map<String, double> probabilities;
  final List<ExplanationItem> explanation;
  final List<RecommendationItem> recommendations;

  PredictionResponse({
    required this.prediction,
    required this.rawClass,
    required this.classId,
    required this.probabilities,
    required this.explanation,
    required this.recommendations,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    var rawProbs = json['probabilities'] as Map<String, dynamic>? ?? {};
    Map<String, double> probs = rawProbs.map((k, v) => MapEntry(k, (v as num).toDouble()));

    var rawExp = json['explanation'] as List? ?? [];
    List<ExplanationItem> expList = rawExp.map((e) => ExplanationItem.fromJson(e)).toList();

    var rawRecs = json['recommendations'] as List? ?? [];
    List<RecommendationItem> recList = rawRecs.map((r) => RecommendationItem.fromJson(r)).toList();

    return PredictionResponse(
      prediction: json['prediction'] ?? 'Unknown',
      rawClass: json['raw_class'] ?? '',
      classId: json['class_id'] ?? 0,
      probabilities: probs,
      explanation: expList,
      recommendations: recList,
    );
  }
}
