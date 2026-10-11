// Configurable weights for creator matching
const DEFAULT_WEIGHTS = {
  skillsSpecialization: 0.30,
  portfolioRelevance: 0.25,
  contentTypeStyle: 0.15,
  aiTools: 0.10,
  budgetCompatibility: 0.10,
  availabilityDeadline: 0.10
};

/**
 * Normalizes string for case-insensitive matching
 */
const normalize = (str) => (str ? str.toString().toLowerCase().trim() : "");

/**
 * Calculates array intersection
 */
const getIntersection = (arr1 = [], arr2 = []) => {
  const set2 = new Set(arr2.map(normalize));
  return arr1.filter((item) => set2.has(normalize(item)));
};

/**
 * Calculate deterministic match score and breakdown between a campaign and creator
 */
const calculateMatchScore = (campaign, creator, customWeights = {}) => {
  const weights = { ...DEFAULT_WEIGHTS, ...customWeights };

  // Normalize weights to sum to 1
  const weightSum = Object.values(weights).reduce((a, b) => a + b, 0);
  Object.keys(weights).forEach((k) => {
    weights[k] = weights[k] / weightSum;
  });

  const campaignSkills = campaign.requiredSkills || [];
  const creatorSkills = creator.skills || [];
  const creatorSpecializations = creator.specialization || [];
  const allCreatorCompetencies = [...creatorSkills, ...creatorSpecializations];

  // 1. Skills & Specialization match (0 - 100)
  const matchedSkills = getIntersection(campaignSkills, allCreatorCompetencies);
  const missingSkills = campaignSkills.filter(
    (s) => !allCreatorCompetencies.map(normalize).includes(normalize(s))
  );

  let skillsScore = 70; // baseline if no specific skills required
  if (campaignSkills.length > 0) {
    skillsScore = Math.round((matchedSkills.length / campaignSkills.length) * 100);
  } else if (allCreatorCompetencies.length > 0) {
    skillsScore = 80;
  }

  // 2. Portfolio Relevance (0 - 100)
  const portfolio = creator.portfolio || [];
  let portfolioScore = 50; // baseline if empty
  let relevantPortfolioItems = [];

  if (portfolio.length > 0) {
    let relevantCount = 0;
    const campaignTypes = (campaign.contentTypes || []).map(normalize);
    const campaignStyle = normalize(campaign.desiredStyle);

    portfolio.forEach((item) => {
      let isRelevant = false;
      const itemType = normalize(item.contentType);
      const itemStyle = normalize(item.contentStyle);
      const itemDesc = normalize(item.description);

      if (campaignTypes.includes(itemType)) isRelevant = true;
      if (campaignStyle && (itemStyle.includes(campaignStyle) || itemDesc.includes(campaignStyle))) {
        isRelevant = true;
      }
      if (item.toolsUsed && campaign.preferredAITools) {
        const toolMatch = getIntersection(item.toolsUsed, campaign.preferredAITools);
        if (toolMatch.length > 0) isRelevant = true;
      }

      if (isRelevant) {
        relevantCount++;
        relevantPortfolioItems.push({
          title: item.title,
          contentType: item.contentType,
          url: item.projectUrl || item.url
        });
      }
    });

    portfolioScore = Math.min(100, Math.round((relevantCount / Math.max(1, portfolio.length)) * 100 + (relevantCount > 0 ? 25 : 0)));
  }

  // 3. Content Style & Type Match (0 - 100)
  const campaignTypes = campaign.contentTypes || [];
  const creatorTypes = creator.contentTypes || [];
  const matchedTypes = getIntersection(campaignTypes, creatorTypes);

  let styleScore = 60;
  if (campaignTypes.length > 0) {
    const typeMatchRatio = matchedTypes.length / campaignTypes.length;
    styleScore = Math.round(typeMatchRatio * 80);
    if (campaign.desiredStyle) {
      const bioStyleMatch = normalize(creator.bio).includes(normalize(campaign.desiredStyle));
      if (bioStyleMatch) styleScore = Math.min(100, styleScore + 20);
    }
  } else {
    styleScore = 75;
  }

  // 4. AI Tool Compatibility (0 - 100)
  const preferredTools = campaign.preferredAITools || [];
  const creatorTools = creator.aiTools || [];
  const matchedTools = getIntersection(preferredTools, creatorTools);
  const missingTools = preferredTools.filter(
    (t) => !creatorTools.map(normalize).includes(normalize(t))
  );

  let aiToolsScore = 70;
  if (preferredTools.length > 0) {
    aiToolsScore = Math.round((matchedTools.length / preferredTools.length) * 100);
  } else if (creatorTools.length > 0) {
    aiToolsScore = 90;
  }

  // 5. Budget Compatibility (0 - 100)
  const creatorPrice = creator.price || (creator.pricing ? creator.pricing.startingAt : 0) || 0;
  const budgetMax = campaign.budgetMax || 0;
  let budgetScore = 80;
  let budgetStatus = "Compatible";

  if (budgetMax > 0 && creatorPrice > 0) {
    if (creatorPrice <= budgetMax) {
      budgetScore = 100;
      budgetStatus = "Within brand budget limit";
    } else if (creatorPrice <= budgetMax * 1.2) {
      budgetScore = 75;
      budgetStatus = "Slightly exceeds maximum budget (within 20%)";
    } else if (creatorPrice <= budgetMax * 1.5) {
      budgetScore = 50;
      budgetStatus = "Exceeds budget by up to 50%";
    } else {
      budgetScore = 25;
      budgetStatus = "Significantly exceeds budget";
    }
  } else if (budgetMax > 0 && creatorPrice === 0) {
    budgetScore = 85;
    budgetStatus = "Pricing negotiable / Starting rate not listed";
  } else {
    budgetStatus = "Budget unconstrained by campaign";
  }

  // 6. Availability and Deadline Compatibility (0 - 100)
  let availabilityScore = 60;
  let availabilityStatus = creator.availability || "available";

  if (creator.availability === "available") {
    availabilityScore = 100;
  } else if (creator.availability === "busy") {
    availabilityScore = 50;
  } else if (creator.availability === "unavailable") {
    availabilityScore = 10;
  }

  // Calculate final weighted score
  const totalRaw =
    skillsScore * weights.skillsSpecialization +
    portfolioScore * weights.portfolioRelevance +
    styleScore * weights.contentTypeStyle +
    aiToolsScore * weights.aiTools +
    budgetScore * weights.budgetCompatibility +
    availabilityScore * weights.availabilityDeadline;

  const totalScore = Math.max(0, Math.min(100, Math.round(totalRaw)));

  // Aggregate missing requirements
  const missingRequirements = [];
  if (missingSkills.length > 0) {
    missingRequirements.push(`Missing skills: ${missingSkills.join(", ")}`);
  }
  if (missingTools.length > 0) {
    missingRequirements.push(`Unmatched preferred AI tools: ${missingTools.join(", ")}`);
  }
  if (creator.availability === "unavailable") {
    missingRequirements.push("Creator marked as unavailable");
  }
  if (budgetMax > 0 && creatorPrice > budgetMax) {
    missingRequirements.push(`Rate ($${creatorPrice}) exceeds campaign budget limit ($${budgetMax})`);
  }

  return {
    matchScore: totalScore,
    weights,
    breakdown: {
      skillsSpecialization: {
        score: skillsScore,
        weight: weights.skillsSpecialization,
        contribution: Math.round(skillsScore * weights.skillsSpecialization * 10) / 10,
        matched: matchedSkills,
        missing: missingSkills
      },
      portfolioRelevance: {
        score: portfolioScore,
        weight: weights.portfolioRelevance,
        contribution: Math.round(portfolioScore * weights.portfolioRelevance * 10) / 10,
        relevantItemCount: relevantPortfolioItems.length,
        relevantItems: relevantPortfolioItems
      },
      contentTypeStyle: {
        score: styleScore,
        weight: weights.contentTypeStyle,
        contribution: Math.round(styleScore * weights.contentTypeStyle * 10) / 10,
        matchedTypes
      },
      aiTools: {
        score: aiToolsScore,
        weight: weights.aiTools,
        contribution: Math.round(aiToolsScore * weights.aiTools * 10) / 10,
        matchedTools,
        missingTools
      },
      budgetCompatibility: {
        score: budgetScore,
        weight: weights.budgetCompatibility,
        contribution: Math.round(budgetScore * weights.budgetCompatibility * 10) / 10,
        status: budgetStatus,
        creatorPrice,
        campaignBudgetMax: budgetMax
      },
      availabilityDeadline: {
        score: availabilityScore,
        weight: weights.availabilityDeadline,
        contribution: Math.round(availabilityScore * weights.availabilityDeadline * 10) / 10,
        status: availabilityStatus
      }
    },
    missingRequirements,
    budgetCompatibility: {
      status: budgetStatus,
      creatorPrice,
      campaignBudgetMax: budgetMax,
      compatible: budgetScore >= 70
    },
    availabilityCompatibility: {
      status: availabilityStatus,
      compatible: availabilityScore >= 50
    }
  };
};

module.exports = {
  DEFAULT_WEIGHTS,
  calculateMatchScore
};
