const Campaign = require("../models/Campaign");
const Creator = require("../models/Creator");
const demoStore = require("../services/demoDataService");
const { matchCreatorsForCampaign } = require("../services/creatorMatchingService");
const { isValidObjectId } = require("../utils/validation");

// @desc    Match creators to a campaign with explainable breakdown
// @route   POST /api/matching/:campaignId or GET /api/matching/:campaignId
// @access  Public / Private (brand)
const getMatchingCreators = async (req, res, next) => {
  try {
    const { campaignId } = req.params;
    const limit = req.query.limit || req.body.limit || 10;
    const customWeights = req.body.customWeights || {};
    const generateAiExplanations = req.body.aiExplanations === true || req.query.aiExplanations === "true";

    if (!isValidObjectId(campaignId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    let campaign;
    let eligibleCreators = [];

    // DEMO_MODE handling
    if (process.env.DEMO_MODE === "true") {
      campaign = demoStore.findCampaignById(campaignId);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }

      eligibleCreators = demoStore.creators;

      const matchResults = await matchCreatorsForCampaign(
        campaign,
        eligibleCreators,
        {
          limit,
          customWeights,
          generateAiExplanations
        }
      );

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: `Ranked creators matched to campaign "${campaign.title}" (Demo Mode)`,
        data: matchResults
      });
    }

    // Production MongoDB handling
    campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: "Campaign not found"
      });
    }

    // Load creators from MongoDB
    eligibleCreators = await Creator.find();

    const matchResults = await matchCreatorsForCampaign(
      campaign,
      eligibleCreators,
      {
        limit,
        customWeights,
        generateAiExplanations
      }
    );

    return res.status(200).json({
      success: true,
      message: `Ranked creators matched to campaign "${campaign.title}"`,
      data: matchResults
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getMatchingCreators
};
