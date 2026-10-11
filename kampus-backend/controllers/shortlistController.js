const Shortlist = require("../models/Shortlist");
const Campaign = require("../models/Campaign");
const Creator = require("../models/Creator");
const demoStore = require("../services/demoDataService");
const { calculateMatchScore } = require("../utils/scoring");
const { isValidObjectId } = require("../utils/validation");

// @desc    Add a creator to a campaign shortlist
// @route   POST /api/shortlists
// @access  Private (brand)
const addToShortlist = async (req, res, next) => {
  try {
    const { campaignId, creatorId, notes, matchScore } = req.body;

    if (!campaignId || !creatorId) {
      return res.status(400).json({
        success: false,
        message: "Please provide both campaignId and creatorId"
      });
    }

    if (!isValidObjectId(campaignId) || !isValidObjectId(creatorId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid ID format for campaignId or creatorId"
      });
    }

    const brandId = req.user ? req.user._id || req.user.id : "demo_brand_1";

    if (process.env.DEMO_MODE === "true") {
      const campaign = demoStore.findCampaignById(campaignId);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }

      const creator = demoStore.findCreatorById(creatorId);
      if (!creator) {
        return res.status(404).json({
          success: false,
          message: "Creator not found"
        });
      }

      // Check ownership
      if (
        req.user &&
        campaign.brandId &&
        campaign.brandId !== req.user._id &&
        campaign.brandId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Forbidden: You do not own this campaign"
        });
      }

      let finalScore = matchScore;
      if (finalScore === undefined || finalScore === null) {
        finalScore = calculateMatchScore(campaign, creator).matchScore;
      }

      try {
        const entry = demoStore.addToShortlist({
          campaignId,
          creatorId,
          brandId,
          notes: notes || "",
          matchScore: finalScore
        });

        res.setHeader("X-Demo-Mode", "true");
        return res.status(201).json({
          success: true,
          message: "Creator shortlisted successfully (Demo Mode)",
          data: {
            ...entry,
            creator
          }
        });
      } catch (err) {
        if (err.statusCode === 409) {
          return res.status(409).json({
            success: false,
            message: err.message
          });
        }
        throw err;
      }
    }

    // Production MongoDB handling
    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: "Campaign not found"
      });
    }

    if (
      req.user &&
      campaign.brandId.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "Forbidden: You do not own this campaign"
      });
    }

    const creator = await Creator.findById(creatorId);
    if (!creator) {
      return res.status(404).json({
        success: false,
        message: "Creator not found"
      });
    }

    // Check for existing duplicate
    const existing = await Shortlist.findOne({ campaignId, creatorId });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "This creator is already on the campaign shortlist"
      });
    }

    let finalScore = matchScore;
    if (finalScore === undefined || finalScore === null) {
      finalScore = calculateMatchScore(campaign, creator).matchScore;
    }

    const shortlistEntry = await Shortlist.create({
      campaignId,
      creatorId,
      brandId: campaign.brandId,
      notes: notes || "",
      matchScore: finalScore
    });

    return res.status(201).json({
      success: true,
      message: "Creator shortlisted successfully",
      data: {
        ...shortlistEntry.toObject(),
        creator
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all shortlisted creators for a campaign
// @route   GET /api/shortlists/:campaignId
// @access  Private / Public
const getShortlistsByCampaign = async (req, res, next) => {
  try {
    const { campaignId } = req.params;

    if (!isValidObjectId(campaignId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const campaign = demoStore.findCampaignById(campaignId);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }

      const list = demoStore.getShortlists(campaignId);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        count: list.length,
        message: "Shortlisted creators retrieved (Demo Mode)",
        data: list
      });
    }

    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: "Campaign not found"
      });
    }

    const list = await Shortlist.find({ campaignId })
      .populate("creatorId")
      .sort({ createdAt: -1 });

    const formatted = list.map((item) => ({
      _id: item._id,
      campaignId: item.campaignId,
      creatorId: item.creatorId ? item.creatorId._id : null,
      notes: item.notes,
      matchScore: item.matchScore,
      createdAt: item.createdAt,
      creator: item.creatorId
    }));

    return res.status(200).json({
      success: true,
      count: formatted.length,
      message: "Shortlisted creators retrieved",
      data: formatted
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Remove creator from campaign shortlist
// @route   DELETE /api/shortlists/:campaignId/:creatorId
// @access  Private (brand)
const removeFromShortlist = async (req, res, next) => {
  try {
    const { campaignId, creatorId } = req.params;

    if (!isValidObjectId(campaignId) || !isValidObjectId(creatorId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const removed = demoStore.removeFromShortlist(campaignId, creatorId);
      if (!removed) {
        return res.status(404).json({
          success: false,
          message: "Creator is not on this campaign's shortlist"
        });
      }
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Creator removed from shortlist successfully (Demo Mode)"
      });
    }

    const entry = await Shortlist.findOne({ campaignId, creatorId });
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: "Creator is not on this campaign's shortlist"
      });
    }

    if (
      req.user &&
      entry.brandId.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "Forbidden: You do not own this campaign shortlist"
      });
    }

    await entry.deleteOne();

    return res.status(200).json({
      success: true,
      message: "Creator removed from shortlist successfully"
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Compare shortlisted creators side-by-side
// @route   GET /api/shortlists/:campaignId/compare
// @access  Public / Private
const compareShortlistedCreators = async (req, res, next) => {
  try {
    const { campaignId } = req.params;

    if (!isValidObjectId(campaignId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    let campaign;
    let shortlisted = [];

    if (process.env.DEMO_MODE === "true") {
      campaign = demoStore.findCampaignById(campaignId);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }
      shortlisted = demoStore.getShortlists(campaignId);
    } else {
      campaign = await Campaign.findById(campaignId);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }
      const rawList = await Shortlist.find({ campaignId }).populate("creatorId");
      shortlisted = rawList.map((item) => ({
        ...item.toObject(),
        creator: item.creatorId
      }));
    }

    const comparisons = shortlisted.map((item) => {
      const creator = item.creator;
      if (!creator) return null;

      const scoreData = calculateMatchScore(campaign, creator);

      return {
        creatorId: creator._id || creator.id,
        name: creator.displayName || creator.name,
        price: creator.price || (creator.pricing ? creator.pricing.startingAt : 0),
        availability: creator.availability,
        matchScore: scoreData.matchScore,
        skills: creator.skills || [],
        aiTools: creator.aiTools || [],
        portfolioCount: (creator.portfolio || []).length,
        notes: item.notes || "",
        budgetCompatibility: scoreData.budgetCompatibility.status,
        missingRequirements: scoreData.missingRequirements
      };
    }).filter(Boolean);

    return res.status(200).json({
      success: true,
      message: "Creator comparison matrix generated successfully",
      count: comparisons.length,
      data: {
        campaignId,
        campaignTitle: campaign.title,
        campaignBudget: { min: campaign.budgetMin, max: campaign.budgetMax },
        comparisons
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  addToShortlist,
  getShortlistsByCampaign,
  removeFromShortlist,
  compareShortlistedCreators
};
