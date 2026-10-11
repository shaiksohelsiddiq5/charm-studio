const Application = require("../models/Application");
const Campaign = require("../models/Campaign");
const Creator = require("../models/Creator");
const demoStore = require("../services/demoDataService");
const { isValidObjectId, isValidApplicationTransition } = require("../utils/validation");

// @desc    Apply to a campaign (as creator) or invite a creator (as brand)
// @route   POST /api/applications
// @access  Private / Public
const createApplication = async (req, res, next) => {
  try {
    const {
      campaignId,
      creatorId,
      type = "application",
      pitch,
      proposedRate
    } = req.body;

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

    const initialStatus = type === "invitation" ? "invited" : "applied";

    // DEMO_MODE handling
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

      try {
        const app = demoStore.createApplication({
          campaignId,
          creatorId,
          brandId: campaign.brandId,
          type,
          status: initialStatus,
          pitch: pitch || "",
          proposedRate: proposedRate || creator.price || 0
        });

        res.setHeader("X-Demo-Mode", "true");
        return res.status(201).json({
          success: true,
          message: `${type === "invitation" ? "Creator invited" : "Application submitted"} successfully (Demo Mode)`,
          data: app
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

    const creator = await Creator.findById(creatorId);
    if (!creator) {
      return res.status(404).json({
        success: false,
        message: "Creator not found"
      });
    }

    const existing = await Application.findOne({ campaignId, creatorId });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "An application or invitation already exists for this creator and campaign"
      });
    }

    const application = await Application.create({
      campaignId,
      creatorId,
      brandId: campaign.brandId,
      type,
      status: initialStatus,
      pitch: pitch || "",
      proposedRate: proposedRate || creator.price || 0
    });

    return res.status(201).json({
      success: true,
      message: `${type === "invitation" ? "Creator invited" : "Application submitted"} successfully`,
      data: application
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get applications with filters
// @route   GET /api/applications
// @access  Private / Public
const getApplications = async (req, res, next) => {
  try {
    const { campaignId, creatorId, brandId, status } = req.query;

    if (process.env.DEMO_MODE === "true") {
      const apps = demoStore.getApplications({ campaignId, creatorId, brandId, status });
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        count: apps.length,
        message: "Applications retrieved successfully (Demo Mode)",
        data: apps
      });
    }

    const query = {};
    if (campaignId) query.campaignId = campaignId;
    if (creatorId) query.creatorId = creatorId;
    if (brandId) query.brandId = brandId;
    if (status) query.status = status;

    const apps = await Application.find(query)
      .populate("campaignId")
      .populate("creatorId")
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: apps.length,
      message: "Applications retrieved successfully",
      data: apps
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single application by ID
// @route   GET /api/applications/:id
// @access  Private / Public
const getApplicationById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid application ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const app = demoStore.findApplicationById(id);
      if (!app) {
        return res.status(404).json({
          success: false,
          message: "Application not found"
        });
      }
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        data: app
      });
    }

    const app = await Application.findById(id)
      .populate("campaignId")
      .populate("creatorId");

    if (!app) {
      return res.status(404).json({
        success: false,
        message: "Application not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: app
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update application workflow status
// @route   PATCH /api/applications/:id/status
// @access  Private
const updateApplicationStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: "Please provide the target status"
      });
    }

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid application ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const app = demoStore.findApplicationById(id);
      if (!app) {
        return res.status(404).json({
          success: false,
          message: "Application not found"
        });
      }

      // Validate transition
      if (!isValidApplicationTransition(app.status, status)) {
        return res.status(400).json({
          success: false,
          message: `Invalid status transition from '${app.status}' to '${status}'`
        });
      }

      const updated = demoStore.updateApplication(id, { status });
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: `Application status transitioned to '${status}' (Demo Mode)`,
        data: updated
      });
    }

    const app = await Application.findById(id);
    if (!app) {
      return res.status(404).json({
        success: false,
        message: "Application not found"
      });
    }

    // Validate transition
    if (!isValidApplicationTransition(app.status, status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status transition from '${app.status}' to '${status}'`
      });
    }

    app.status = status;
    await app.save();

    return res.status(200).json({
      success: true,
      message: `Application status transitioned to '${status}'`,
      data: app
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Submit content deliverables
// @route   POST /api/applications/:id/deliverables
// @access  Private (creator)
const submitDeliverables = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { deliverableLinks = [] } = req.body;

    if (!Array.isArray(deliverableLinks) || deliverableLinks.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide an array of deliverableLinks"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const app = demoStore.findApplicationById(id);
      if (!app) {
        return res.status(404).json({
          success: false,
          message: "Application not found"
        });
      }

      const updated = demoStore.updateApplication(id, {
        deliverableLinks: [...(app.deliverableLinks || []), ...deliverableLinks],
        status: "submitted"
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Deliverables submitted successfully (Demo Mode)",
        data: updated
      });
    }

    const app = await Application.findById(id);
    if (!app) {
      return res.status(404).json({
        success: false,
        message: "Application not found"
      });
    }

    app.deliverableLinks.push(...deliverableLinks);
    app.status = "submitted";
    await app.save();

    return res.status(200).json({
      success: true,
      message: "Deliverables submitted successfully",
      data: app
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Request revision with feedback comments
// @route   POST /api/applications/:id/revisions
// @access  Private (brand)
const requestRevision = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { comment } = req.body;

    if (!comment || typeof comment !== "string" || comment.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide a revision comment"
      });
    }

    const requestedBy = req.user ? req.user._id || req.user.id : null;

    if (process.env.DEMO_MODE === "true") {
      const app = demoStore.findApplicationById(id);
      if (!app) {
        return res.status(404).json({
          success: false,
          message: "Application not found"
        });
      }

      const newComments = [
        ...(app.revisionComments || []),
        { comment, requestedBy, createdAt: new Date() }
      ];

      const updated = demoStore.updateApplication(id, {
        revisionComments: newComments,
        status: "revision_requested"
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Revision requested successfully (Demo Mode)",
        data: updated
      });
    }

    const app = await Application.findById(id);
    if (!app) {
      return res.status(404).json({
        success: false,
        message: "Application not found"
      });
    }

    app.revisionComments.push({ comment, requestedBy, createdAt: new Date() });
    app.status = "revision_requested";
    await app.save();

    return res.status(200).json({
      success: true,
      message: "Revision requested successfully",
      data: app
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createApplication,
  getApplications,
  getApplicationById,
  updateApplicationStatus,
  submitDeliverables,
  requestRevision
};
