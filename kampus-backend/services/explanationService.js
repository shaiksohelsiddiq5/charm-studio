const { GoogleGenAI } = require("@google/genai");

/**
 * Builds a deterministic, evidence-based explanation using the score breakdown
 */
const buildDeterministicExplanation = (campaign, creator, scoreData) => {
  const { breakdown, matchScore } = scoreData;
  const strengths = [];
  const considerations = [];

  // Skills & Specialization
  if (breakdown.skillsSpecialization.matched.length > 0) {
    strengths.push(
      `Directly matches required competencies: ${breakdown.skillsSpecialization.matched.join(", ")}`
    );
  }
  if (breakdown.skillsSpecialization.missing.length > 0) {
    considerations.push(
      `Profile does not list: ${breakdown.skillsSpecialization.missing.join(", ")}`
    );
  }

  // Portfolio
  if (breakdown.portfolioRelevance.relevantItemCount > 0) {
    strengths.push(
      `Portfolio contains ${breakdown.portfolioRelevance.relevantItemCount} relevant project(s) matching your content styles or formats`
    );
  } else if ((creator.portfolio || []).length === 0) {
    considerations.push("Portfolio links have not yet been uploaded to this profile");
  }

  // AI Tools
  if (breakdown.aiTools.matchedTools.length > 0) {
    strengths.push(
      `Proficient in requested AI tooling: ${breakdown.aiTools.matchedTools.join(", ")}`
    );
  }

  // Budget
  if (breakdown.budgetCompatibility.score === 100) {
    strengths.push(`Stated starting rate ($${breakdown.budgetCompatibility.creatorPrice}) falls within the campaign budget`);
  } else if (breakdown.budgetCompatibility.creatorPrice > (campaign.budgetMax || 0) && campaign.budgetMax > 0) {
    considerations.push(
      `Starting rate ($${breakdown.budgetCompatibility.creatorPrice}) is above stated budget cap ($${campaign.budgetMax})`
    );
  }

  // Availability
  if (creator.availability === "available") {
    strengths.push("Currently active and available for new projects");
  } else if (creator.availability === "busy") {
    considerations.push("Creator currently reports busy availability");
  }

  let fitLabel = "Moderate Match";
  if (matchScore >= 80) fitLabel = "Strong Match";
  else if (matchScore >= 65) fitLabel = "Good Match";
  else if (matchScore < 50) fitLabel = "Partial Match";

  const creatorName = creator.displayName || creator.name || "This creator";
  const campaignTitle = campaign.title || "the campaign";

  const summary = `${creatorName} is a ${fitLabel.toLowerCase()} (${matchScore}% match) for "${campaignTitle}". ${
    strengths.length > 0 ? strengths[0] + "." : ""
  } ${
    considerations.length > 0 ? "Note: " + considerations[0] + "." : ""
  }`.trim();

  return {
    fitRating: fitLabel,
    summary,
    strengths,
    considerations,
    missingRequirements: scoreData.missingRequirements || []
  };
};

/**
 * Generate evidence-based explanation, using Gemini if key is provided or deterministic generator
 */
const generateExplanation = async (campaign, creator, scoreData) => {
  const baseExplanation = buildDeterministicExplanation(campaign, creator, scoreData);

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey.trim() === "") {
    return baseExplanation;
  }

  try {
    const ai = new GoogleGenAI({ apiKey });
    const prompt = `You are an AI creator marketplace analyst.
Generate a concise, 2-sentence objective match summary for why this creator was recommended for the campaign.
RULES:
1. Use only the provided verified facts.
2. Do not fabricate demographics, past metrics, or guarantee success.
3. Be professional and balanced.

Facts:
Campaign: "${campaign.title}"
Required Skills: ${(campaign.requiredSkills || []).join(", ") || "General AI content"}
Preferred Tools: ${(campaign.preferredAITools || []).join(", ") || "Any"}
Budget Max: $${campaign.budgetMax || "Flexible"}

Creator: ${creator.displayName || creator.name}
Skills: ${(creator.skills || []).join(", ")}
AI Tools: ${(creator.aiTools || []).join(", ")}
Price: $${creator.price || 0}
Availability: ${creator.availability}
Calculated Match Score: ${scoreData.matchScore}%

Return only the 2-sentence explanation.`;

    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt
    });

    if (response && response.text) {
      baseExplanation.summary = response.text.trim();
    }
    return baseExplanation;
  } catch (error) {
    // Graceful fallback to deterministic explanation
    return baseExplanation;
  }
};

module.exports = {
  generateExplanation,
  buildDeterministicExplanation
};
