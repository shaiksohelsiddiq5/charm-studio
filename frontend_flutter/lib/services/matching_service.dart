import '../models/creator_model.dart';
import '../models/campaign_model.dart';
import '../models/match_result_model.dart';

class MatchingService {
  static List<String> _tokenize(String text) {
    if (text.isEmpty) return [];
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toList();
  }

  static MatchResult calculateMatch(Creator creator, Campaign campaign) {
    final List<String> explanations = [];

    // 1. Portfolio Relevance (30%)
    final campaignKeywords = [
      ..._tokenize(campaign.title),
      ..._tokenize(campaign.category),
      ..._tokenize(campaign.productType),
      ..._tokenize(campaign.description),
    ];

    int portfolioMatches = 0;
    final List<String> matchedItems = [];

    for (final item in creator.portfolio) {
      final itemKeywords = [
        ..._tokenize(item.title),
        ..._tokenize(item.description),
        ..._tokenize(item.clientType),
        ...item.tags.map((t) => t.toLowerCase()),
      ];

      final matchCount = campaignKeywords.where((k) => itemKeywords.contains(k)).length;
      if (matchCount > 0) {
        portfolioMatches += matchCount;
        matchedItems.add(item.title);
      }
    }

    double portfolioScore = 0.2;
    if (matchedItems.isNotEmpty) {
      portfolioScore = (0.5 + (matchedItems.length * 0.2) + (portfolioMatches * 0.05)).clamp(0.0, 1.0);
      if (campaign.category.toLowerCase().contains("beverage") || campaign.title.toLowerCase().contains("cold-drink")) {
        explanations.add("Portfolio includes ${matchedItems.length} verified commercial beverage & drink project(s).");
      } else {
        explanations.add("Portfolio includes ${matchedItems.length} directly related project(s) matching your campaign domain.");
      }
    } else {
      explanations.add("Diverse commercial creative portfolio adaptable to your brief.");
    }

    // 2. Skills and Specialization (25%)
    final reqContentType = campaign.contentType.toLowerCase();
    final reqCategory = campaign.category.toLowerCase();
    final creatorSpecs = creator.specializations.map((s) => s.toLowerCase()).toList();

    int specMatches = 0;
    for (final spec in creatorSpecs) {
      if (reqContentType.contains(spec) || spec.contains(reqContentType)) specMatches++;
      if (reqCategory.contains(spec) || spec.contains(reqCategory)) specMatches++;
      if (reqContentType.contains("video") && spec.contains("video")) specMatches++;
      if (reqContentType.contains("photo") && (spec.contains("photo") || spec.contains("stills"))) specMatches++;
      if (reqCategory.contains("food") && spec.contains("food")) specMatches++;
      if (reqCategory.contains("luxury") && spec.contains("luxury")) specMatches++;
      if (reqCategory.contains("fashion") && spec.contains("fashion")) specMatches++;
    }

    final double skillsScore = (0.3 + (specMatches * 0.35)).clamp(0.0, 1.0);
    if (specMatches > 0 && creator.specializations.isNotEmpty) {
      explanations.add("Primary specialization in ${creator.specializations.first} directly aligns with campaign deliverables.");
    }

    // 3. Visual Style Compatibility (20%)
    final reqStyle = campaign.visualStyle.toLowerCase();
    final creatorStyles = creator.visualStyles.map((s) => s.toLowerCase()).toList();

    double styleScore = 0.3;
    if (creatorStyles.any((s) => s.contains(reqStyle) || reqStyle.contains(s))) {
      styleScore = 1.0;
      explanations.add("Strong aesthetic match for ${campaign.visualStyle.toLowerCase()} visual direction.");
    } else if (creatorStyles.isNotEmpty) {
      styleScore = 0.6;
    }

    // 4. AI Tools & Workflow (10%)
    final reqTools = campaign.requiredTools;
    final creatorTools = creator.aiTools.map((t) => t.toLowerCase()).toList();

    int toolMatches = 0;
    for (final tool in reqTools) {
      if (creatorTools.any((ct) => ct.contains(tool.toLowerCase()) || tool.toLowerCase().contains(ct))) {
        toolMatches++;
      }
    }

    final double toolsScore = reqTools.isNotEmpty
        ? (0.4 + (toolMatches / reqTools.length) * 0.6).clamp(0.0, 1.0)
        : 0.8;

    if (toolMatches > 0 && creator.aiTools.isNotEmpty) {
      final sampleTools = creator.aiTools.take(2).join(", ");
      explanations.add("Proficient with required generative tool stack ($sampleTools).");
    }

    // 5. Budget Compatibility (10%)
    final creatorPrice = creator.startingPrice;
    final campaignBudget = campaign.budget;
    double budgetScore = 1.0;

    if (creatorPrice <= campaignBudget) {
      budgetScore = 1.0;
      explanations.add("Fits within campaign budget (Starting ₹$creatorPrice vs ₹$campaignBudget budget).");
    } else {
      final overageRatio = (creatorPrice - campaignBudget) / campaignBudget;
      budgetScore = (1.0 - overageRatio).clamp(0.2, 1.0);
      explanations.add("Starting price (₹$creatorPrice) slightly exceeds campaign budget (₹$campaignBudget).");
    }

    // 6. Content Format & Delivery (5%)
    final reqAspect = campaign.aspectRatio.toLowerCase();
    final creatorFormats = creator.supportedFormats.map((f) => f.toLowerCase()).toList();

    double formatScore = 0.5;
    final bool supportsFormat = creatorFormats.any((f) =>
        (reqAspect.contains("9:16") && f.contains("9:16")) ||
        (reqAspect.contains("16:9") && f.contains("16:9")) ||
        (reqAspect.contains("1:1") && f.contains("1:1")) ||
        (f.contains("reels") && reqContentType.contains("reels")));

    if (supportsFormat) {
      formatScore = 1.0;
      explanations.add("Supports required deliverable format (${campaign.aspectRatio.isNotEmpty ? campaign.aspectRatio : 'Reels 9:16'}).");
    } else {
      formatScore = 0.7;
    }

    // Total Weighted Calculation
    final rawScore = (portfolioScore * 30) +
        (skillsScore * 25) +
        (styleScore * 20) +
        (toolsScore * 10) +
        (budgetScore * 10) +
        (formatScore * 5);

    final finalScore = rawScore.round().clamp(40, 99);

    final breakdown = MatchBreakdown(
      portfolioRelevance: (portfolioScore * 100).round(),
      skillsSpecialization: (skillsScore * 100).round(),
      visualStyle: (styleScore * 100).round(),
      aiTools: (toolsScore * 100).round(),
      budgetCompatibility: (budgetScore * 100).round(),
      formatAndDelivery: (formatScore * 100).round(),
    );

    return MatchResult(
      score: finalScore,
      isStrongMatch: finalScore >= 85,
      breakdown: breakdown,
      explanations: explanations.take(4).toList(),
    );
  }
}
