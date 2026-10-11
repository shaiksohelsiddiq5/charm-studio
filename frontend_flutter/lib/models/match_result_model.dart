class MatchBreakdown {
  final int portfolioRelevance;
  final int skillsSpecialization;
  final int visualStyle;
  final int aiTools;
  final int budgetCompatibility;
  final int formatAndDelivery;

  MatchBreakdown({
    required this.portfolioRelevance,
    required this.skillsSpecialization,
    required this.visualStyle,
    required this.aiTools,
    required this.budgetCompatibility,
    required this.formatAndDelivery,
  });

  factory MatchBreakdown.fromJson(Map<String, dynamic> json) {
    return MatchBreakdown(
      portfolioRelevance: json['portfolioRelevance'] ?? 80,
      skillsSpecialization: json['skillsSpecialization'] ?? 80,
      visualStyle: json['visualStyle'] ?? 80,
      aiTools: json['aiTools'] ?? 80,
      budgetCompatibility: json['budgetCompatibility'] ?? 80,
      formatAndDelivery: json['formatAndDelivery'] ?? 80,
    );
  }
}

class MatchResult {
  final int score;
  final bool isStrongMatch;
  final MatchBreakdown breakdown;
  final List<String> explanations;

  MatchResult({
    required this.score,
    required this.isStrongMatch,
    required this.breakdown,
    required this.explanations,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      score: json['score'] ?? 75,
      isStrongMatch: json['isStrongMatch'] ?? false,
      breakdown: MatchBreakdown.fromJson(json['breakdown'] ?? {}),
      explanations: List<String>.from(json['explanations'] ?? []),
    );
  }
}
