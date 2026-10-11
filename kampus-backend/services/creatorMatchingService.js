const { calculateMatchScore, DEFAULT_WEIGHTS } = require("../utils/scoring");
const { generateExplanation } = require("./explanationService");

/**
 * Matches a list of creators to a campaign, ranks them, and generates explanations
 */
const matchCreatorsForCampaign = async (campaign, creators = [], options = {}) => {
  const { limit = 10, customWeights = {}, generateAiExplanations = false } = options;

  if (!campaign) {
    throw new Error("Campaign data is required for matching");
  }

  // Calculate scores for all eligible creators
  const scoredCreators = [];

  for (const creator of creators) {
    const scoreData = calculateMatchScore(campaign, creator, customWeights);

    // Build evidence explanation
    let explanation;
    if (generateAiExplanations) {
      explanation = await generateExplanation(campaign, creator, scoreData);
    } else {
      // Use fast deterministic explanation by default for speed, can be enhanced
      const { buildDeterministicExplanation } = require("./explanationService");
      explanation = buildDeterministicExplanation(campaign, creator, scoreData);
    }

    scoredCreators.push({
      creator: {
        _id: creator._id || creator.id,
        id: creator._id || creator.id,
        name: creator.name,
        displayName: creator.displayName || creator.name,
        email: creator.email,
        bio: creator.bio,
        skills: creator.skills,
        specialization: creator.specialization,
        aiTools: creator.aiTools,
        contentTypes: creator.contentTypes,
        portfolio: creator.portfolio,
        price: creator.price || (creator.pricing ? creator.pricing.startingAt : 0),
        pricing: creator.pricing,
        availability: creator.availability,
        languages: creator.languages,
        location: creator.location
      },
      matchScore: scoreData.matchScore,
      scoreBreakdown: scoreData.breakdown,
      explanation,
      missingRequirements: scoreData.missingRequirements,
      budgetCompatibility: scoreData.budgetCompatibility,
      availabilityCompatibility: scoreData.availabilityCompatibility
    });
  }

  // Sort by matchScore in descending order
  scoredCreators.sort((a, b) => b.matchScore - a.matchScore);

  // Apply result limit
  const topMatches = scoredCreators.slice(0, Number(limit) || 10);

  return {
    campaignId: campaign._id || campaign.id,
    campaignTitle: campaign.title,
    weightsUsed: { ...DEFAULT_WEIGHTS, ...customWeights },
    totalEvaluated: creators.length,
    matchesReturned: topMatches.length,
    matches: topMatches
  };
};

module.exports = {
  matchCreatorsForCampaign
};
