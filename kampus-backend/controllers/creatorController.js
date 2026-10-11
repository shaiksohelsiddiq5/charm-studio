const Creator = require("../models/Creator");
const demoStore = require("../services/demoDataService");
const { isValidObjectId, isValidEmail } = require("../utils/validation");

// @desc    Register / create a creator profile
// @route   POST /api/creators
// @access  Public / Private (creator)
const createCreator = async (req, res, next) => {
  try {
    const {
      name,
      displayName,
      email,
      bio,
      specialization,
      skills,
      aiTools,
      contentTypes,
      portfolio,
      price,
      pricing,
      availability,
      languages,
      location
    } = req.body;

    if (!name || !email) {
      return res.status(400).json({
        success: false,
        message: "Please provide both name and email for the creator profile"
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid email address"
      });
    }

    const userId = req.user ? req.user._id || req.user.id : null;
    const finalDisplayName = displayName || name;
    const finalPrice = price !== undefined ? Number(price) : (pricing && pricing.startingAt ? Number(pricing.startingAt) : 0);

    // DEMO_MODE handling
    if (process.env.DEMO_MODE === "true") {
      const existing = demoStore.creators.find(
        (c) => c.email.toLowerCase() === email.toLowerCase()
      );
      if (existing) {
        return res.status(409).json({
          success: false,
          message: "A creator with this email already exists"
        });
      }

      const newCreator = demoStore.createCreator({
        userId,
        name,
        displayName: finalDisplayName,
        email: email.toLowerCase(),
        bio: bio || "",
        specialization: Array.isArray(specialization) ? specialization : [],
        skills: Array.isArray(skills) ? skills : [],
        aiTools: Array.isArray(aiTools) ? aiTools : [],
        contentTypes: Array.isArray(contentTypes) ? contentTypes : [],
        portfolio: Array.isArray(portfolio) ? portfolio : [],
        price: finalPrice,
        pricing: pricing || { startingAt: finalPrice, hourlyRate: 0, currency: "USD" },
        availability: availability || "available",
        languages: Array.isArray(languages) ? languages : ["English"],
        location: location || ""
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(201).json({
        success: true,
        message: "Creator registered successfully (Demo Mode)",
        data: newCreator
      });
    }

    // Production MongoDB handling
    const existingCreator = await Creator.findOne({ email: email.toLowerCase() });
    if (existingCreator) {
      return res.status(409).json({
        success: false,
        message: "A creator with this email already exists"
      });
    }

    const creator = await Creator.create({
      userId,
      name,
      displayName: finalDisplayName,
      email: email.toLowerCase(),
      bio: bio || "",
      specialization: Array.isArray(specialization) ? specialization : [],
      skills: Array.isArray(skills) ? skills : [],
      aiTools: Array.isArray(aiTools) ? aiTools : [],
      contentTypes: Array.isArray(contentTypes) ? contentTypes : [],
      portfolio: Array.isArray(portfolio) ? portfolio : [],
      price: finalPrice,
      pricing: pricing || { startingAt: finalPrice, hourlyRate: 0, currency: "USD" },
      availability: availability || "available",
      languages: Array.isArray(languages) ? languages : ["English"],
      location: location || ""
    });

    return res.status(201).json({
      success: true,
      message: "Creator registered successfully",
      data: creator
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all creators with rich search, filters, and pagination
// @route   GET /api/creators
// @access  Public
const getCreators = async (req, res, next) => {
  try {
    const {
      search,
      name,
      skills,
      specialization,
      aiTools,
      contentTypes,
      budgetMax,
      availability,
      language,
      sort,
      page = 1,
      limit = 20
    } = req.query;

    // DEMO_MODE handling
    if (process.env.DEMO_MODE === "true") {
      const result = demoStore.getCreators({
        search: search || name,
        skills,
        specialization,
        aiTools,
        contentTypes,
        budgetMax,
        availability,
        language,
        sort,
        page,
        limit
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Creators retrieved successfully (Demo Mode)",
        count: result.creators.length,
        total: result.total,
        page: result.page,
        pages: result.pages,
        data: result.creators,
        creators: result.creators
      });
    }

    // Production MongoDB handling
    const query = {};

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } },
        { displayName: { $regex: search, $options: "i" } },
        { bio: { $regex: search, $options: "i" } },
        { skills: { $in: [new RegExp(search, "i")] } },
        { specialization: { $in: [new RegExp(search, "i")] } }
      ];
    } else if (name) {
      query.$or = [
        { name: { $regex: name, $options: "i" } },
        { displayName: { $regex: name, $options: "i" } }
      ];
    }

    if (skills) {
      const skillList = Array.isArray(skills)
        ? skills
        : skills.split(",").map((s) => s.trim());
      query.skills = { $in: skillList.map((s) => new RegExp(`^${s}$`, "i")) };
    }

    if (specialization) {
      query.specialization = { $regex: specialization, $options: "i" };
    }

    if (aiTools) {
      const toolsList = Array.isArray(aiTools)
        ? aiTools
        : aiTools.split(",").map((t) => t.trim());
      query.aiTools = { $in: toolsList.map((t) => new RegExp(`^${t}$`, "i")) };
    }

    if (contentTypes) {
      const typeList = Array.isArray(contentTypes)
        ? contentTypes
        : contentTypes.split(",").map((t) => t.trim());
      query.contentTypes = { $in: typeList.map((t) => new RegExp(`^${t}$`, "i")) };
    }

    if (budgetMax) {
      query.price = { $lte: Number(budgetMax) };
    }

    if (availability) {
      query.availability = availability;
    }

    if (language) {
      query.languages = { $regex: language, $options: "i" };
    }

    let sortQuery = { createdAt: -1 };
    if (sort === "price_asc") sortQuery = { price: 1 };
    else if (sort === "price_desc") sortQuery = { price: -1 };

    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.max(1, parseInt(limit, 10));
    const skip = (pageNum - 1) * limitNum;

    const [total, creators] = await Promise.all([
      Creator.countDocuments(query),
      Creator.find(query).sort(sortQuery).skip(skip).limit(limitNum)
    ]);

    return res.status(200).json({
      success: true,
      message: "Creators retrieved successfully",
      count: creators.length,
      total,
      page: pageNum,
      pages: Math.ceil(total / limitNum),
      data: creators,
      creators: creators
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single creator by ID
// @route   GET /api/creators/:id
// @access  Public
const getCreatorById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid creator ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const creator = demoStore.findCreatorById(id);
      if (!creator) {
        return res.status(404).json({
          success: false,
          message: "Creator not found"
        });
      }
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Creator retrieved successfully (Demo Mode)",
        data: creator
      });
    }

    const creator = await Creator.findById(id);
    if (!creator) {
      return res.status(404).json({
        success: false,
        message: "Creator not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: creator
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update creator profile
// @route   PUT /api/creators/:id
// @access  Private (owning creator or admin)
const updateCreator = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid creator ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const creator = demoStore.findCreatorById(id);
      if (!creator) {
        return res.status(404).json({
          success: false,
          message: "Creator not found"
        });
      }

      // Check ownership if user is authenticated and creator has userId
      if (
        req.user &&
        creator.userId &&
        creator.userId !== req.user._id &&
        creator.userId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Forbidden: You are not authorized to update this creator profile"
        });
      }

      const updated = demoStore.updateCreator(id, req.body);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Creator profile updated successfully (Demo Mode)",
        data: updated
      });
    }

    const creator = await Creator.findById(id);
    if (!creator) {
      return res.status(404).json({
        success: false,
        message: "Creator not found"
      });
    }

    // Check ownership
    if (
      req.user &&
      creator.userId &&
      creator.userId.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "Forbidden: You are not authorized to update this creator profile"
      });
    }

    Object.assign(creator, req.body);
    await creator.save();

    return res.status(200).json({
      success: true,
      message: "Creator profile updated successfully",
      data: creator
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete creator profile
// @route   DELETE /api/creators/:id
// @access  Private (owning creator or admin)
const deleteCreator = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid creator ID format"
      });
    }

    if (process.env.DEMO_MODE === "true") {
      const creator = demoStore.findCreatorById(id);
      if (!creator) {
        return res.status(404).json({
          success: false,
          message: "Creator not found"
        });
      }

      if (
        req.user &&
        creator.userId &&
        creator.userId !== req.user._id &&
        creator.userId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Forbidden: You are not authorized to delete this creator profile"
        });
      }

      demoStore.deleteCreator(id);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        message: "Creator profile deleted successfully (Demo Mode)"
      });
    }

    const creator = await Creator.findById(id);
    if (!creator) {
      return res.status(404).json({
        success: false,
        message: "Creator not found"
      });
    }

    if (
      req.user &&
      creator.userId &&
      creator.userId.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "Forbidden: You are not authorized to delete this creator profile"
      });
    }

    await creator.deleteOne();

    return res.status(200).json({
      success: true,
      message: "Creator profile deleted successfully"
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createCreator,
  getCreators,
  getCreatorById,
  updateCreator,
  deleteCreator
};