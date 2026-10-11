const Campaign = require("../models/Campaign");
const demoStore = require("../services/demoDataService");
const { generateCampaignBrief } = require("../services/aiBriefService");
const { isValidObjectId, VALID_CAMPAIGN_STATUSES } = require("../utils/validation");

// @desc    Create a new campaign
// @route   POST /api/campaigns
// @access  Private (brand)
const createCampaign = async (req, res, next) => {
  try {
    const {
      title,
      productName,
      campaignDescription,
      contentTypes,
      requiredSkills,
      preferredAITools,
      desiredStyle,
      targetPlatforms,
      targetAudience,
      budgetMin,
      budgetMax,
      deadline,
      deliverables,
      commercialUsageRequirements,
      status
    } = req.body;

    if (!title || !campaignDescription) {
      return res.status(400).json({
        success: false,
        message: "Please provide both campaign title and campaign description"
      });
    }

    if (budgetMin && budgetMax && Number(budgetMin) > Number(budgetMax)) {
      return res.status(400).json({
        success: false,
        message: "Minimum budget cannot be greater than maximum budget"
      });
    }

    const brandId = req.user ? req.user._id || req.user.id : "demo_brand_1";
    const brandName = req.user
      ? req.user.companyName || req.user.name || "Brand Partner"
      : "Demo Brand";

    if (process.env.DEMO_MODE === "true") {
      const newCampaign = demoStore.createCampaign({
        brandId,
        brandName,
        title,
        productName: productName || "",
        campaignDescription,
        contentTypes: Array.isArray(contentTypes) ? contentTypes : [],
        requiredSkills: Array.isArray(requiredSkills) ? requiredSkills : [],
        preferredAITools: Array.isArray(preferredAITools) ? preferredAITools : [],
        desiredStyle: desiredStyle || "",
        targetPlatforms: Array.isArray(targetPlatforms) ? targetPlatforms : ["Instagram", "TikTok"],
        targetAudience: targetAudience || "",
        budgetMin: Number(budgetMin) || 0,
        budgetMax: Number(budgetMax) || 0,
        deadline: deadline ? new Date(deadline) : null,
        deliverables: Array.isArray(deliverables) ? deliverables : [],
        commercialUsageRequirements: commercialUsageRequirements || "Full digital distribution rights",
        status: status && VALID_CAMPAIGN_STATUSES.includes(status) ? status : "published"
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(201).json({
        success: true,
        message: "Campaign created successfully (Demo Mode)",
        data: newCampaign
      });
    }

    const campaign = await Campaign.create({
      brandId,
      brandName,
      title,
      productName: productName || "",
      campaignDescription,
      contentTypes: Array.isArray(contentTypes) ? contentTypes : [],
      requiredSkills: Array.isArray(requiredSkills) ? requiredSkills : [],
      preferredAITools: Array.isArray(preferredAITools) ? preferredAITools : [],
      desiredStyle: desiredStyle || "",
      targetPlatforms: Array.isArray(targetPlatforms) ? targetPlatforms : ["Instagram", "TikTok"],
      targetAudience: targetAudience || "",
      budgetMin: Number(budgetMin) || 0,
      budgetMax: Number(budgetMax) || 0,
      deadline: deadline ? new Date(deadline) : null,
      deliverables: Array.isArray(deliverables) ? deliverables : [],
      commercialUsageRequirements: commercialUsageRequirements || "Full digital distribution rights",
      status: status && VALID_CAMPAIGN_STATUSES.includes(status) ? status : "published"
    });

    return res.status(201).json({
      success: true,
      message: "Campaign created successfully",
      data: campaign
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all campaigns with filters and pagination
// @route   GET /api/campaigns
// @access  Public
const getCampaigns = async (req, res, next) => {
  try {
    const {
      status,
      brandId,
      search,
      page = 1,
      limit = 20
    } = req.query;

    if (process.env.DEMO_MODE === "true") {
      const result = demoStore.getCampaigns({
        status,
        brandId,
        search,
        page,
        limit
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Campaigns retrieved successfully (Demo Mode)",
        count: result.campaigns.length,
        total: result.total,
        page: result.page,
        pages: result.pages,
        data: result.campaigns,
        campaigns: result.campaigns
      });
    }

    const query = {};
    if (status) query.status = status;
    if (brandId) query.brandId = brandId;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: "i" } },
        { campaignDescription: { $regex: search, $options: "i" } },
        { productName: { $regex: search, $options: "i" } }
      ];
    }

    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.max(1, parseInt(limit, 10));
    const skip = (pageNum - 1) * limitNum;

    const [total, campaigns] = await Promise.all([
      Campaign.countDocuments(query),
      Campaign.find(query).sort({ createdAt: -1 }).skip(skip).limit(limitNum)
    ]);

    return res.status(200).json({
      success: true,
      message: "Campaigns retrieved successfully",
      count: campaigns.length,
      total,
      page: pageNum,
      pages: Math.ceil(total / limitNum),
      data: campaigns,
      campaigns: campaigns
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single campaign by ID
// @route   GET /api/campaigns/:id
// @access  Public
const getCampaignById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const campaign = demoStore.findCampaignById(id);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        data: campaign
      });
    }

    const campaign = await Campaign.findById(id);
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: "Campaign not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: campaign
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update campaign
// @route   PUT /api/campaigns/:id
// @access  Private (owning brand)
const updateCampaign = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const campaign = demoStore.findCampaignById(id);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }

      if (
        req.user &&
        campaign.brandId &&
        campaign.brandId !== req.user._id &&
        campaign.brandId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Forbidden: You are not authorized to update this campaign"
        });
      }

      const updated = demoStore.updateCampaign(id, req.body);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Campaign updated successfully (Demo Mode)",
        data: updated
      });
    }

    const campaign = await Campaign.findById(id);
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
        message: "Forbidden: You are not authorized to update this campaign"
      });
    }

    Object.assign(campaign, req.body);
    await campaign.save();

    return res.status(200).json({
      success: true,
      message: "Campaign updated successfully",
      data: campaign
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete campaign
// @route   DELETE /api/campaigns/:id
// @access  Private (owning brand)
const deleteCampaign = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid campaign ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const campaign = demoStore.findCampaignById(id);
      if (!campaign) {
        return res.status(404).json({
          success: false,
          message: "Campaign not found"
        });
      }

      if (
        req.user &&
        campaign.brandId &&
        campaign.brandId !== req.user._id &&
        campaign.brandId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Forbidden: You are not authorized to delete this campaign"
        });
      }

      demoStore.deleteCampaign(id);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Campaign deleted successfully (Demo Mode)"
      });
    }

    const campaign = await Campaign.findById(id);
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
        message: "Forbidden: You are not authorized to delete this campaign"
      });
    }

    await campaign.deleteOne();

    return res.status(200).json({
      success: true,
      message: "Campaign deleted successfully"
    });
  } catch (error) {
    next(error);
  }
};

// @desc    AI Campaign Brief Builder
// @route   POST /api/campaigns/ai-brief
// @access  Public / Private
const generateAiBrief = async (req, res, next) => {
  try {
    const { prompt, idea } = req.body;
    const rawIdea = prompt || idea;

    if (!rawIdea || typeof rawIdea !== "string" || rawIdea.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide a brand idea prompt to generate a campaign brief"
      });
    }

    const structuredBrief = await generateCampaignBrief(rawIdea);

    return res.status(200).json({
      success: true,
      message: "AI Campaign brief generated successfully",
      data: structuredBrief
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createCampaign,
  getCampaigns,
  getCampaignById,
  updateCampaign,
  deleteCampaign,
  generateAiBrief
};
