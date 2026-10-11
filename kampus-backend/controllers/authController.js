const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const demoStore = require("../services/demoDataService");
const { isValidEmail } = require("../utils/validation");

const getJwtSecret = () => process.env.JWT_SECRET || "kampus_hackathon_jwt_secret_dev_2026";

const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id || user.id,
      email: user.email,
      role: user.role,
      name: user.name
    },
    getJwtSecret(),
    { expiresIn: "7d" }
  );
};

// @desc    Register a new user (brand or creator)
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res, next) => {
  try {
    const { name, email, password, role = "creator", companyName } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide name, email, and password"
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid email address"
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters long"
      });
    }

    if (!["brand", "creator"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: "Role must be either 'brand' or 'creator'"
      });
    }

    // In DEMO_MODE, support demo store
    if (process.env.DEMO_MODE === "true") {
      const existingDemo = demoStore.findUserByEmail(email);
      if (existingDemo) {
        return res.status(409).json({
          success: false,
          message: "A user with this email already exists"
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const newUser = demoStore.createUser({
        name,
        email: email.toLowerCase(),
        password: hashedPassword,
        role,
        companyName: companyName || ""
      });

      const token = generateToken(newUser);
      const safeUser = { ...newUser };
      delete safeUser.password;

      res.setHeader("X-Demo-Mode", "true");
      return res.status(201).json({
        success: true,
        message: "User registered successfully (Demo Mode)",
        data: {
          user: safeUser,
          token
        }
      });
    }

    // Production mode with MongoDB
    const userExists = await User.findOne({ email: email.toLowerCase() });
    if (userExists) {
      return res.status(409).json({
        success: false,
        message: "A user with this email already exists"
      });
    }

    const user = await User.create({
      name,
      email: email.toLowerCase(),
      password,
      role,
      companyName: companyName || ""
    });

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        user: user.toSafeObject(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide email and password"
      });
    }

    // In DEMO_MODE, authenticate against demo store or pre-seeded credentials
    if (process.env.DEMO_MODE === "true") {
      const demoUser = demoStore.findUserByEmail(email);

      // In demo mode, allow default password or checked hash
      if (demoUser) {
        let passwordMatches = true;
        if (demoUser.password) {
          passwordMatches = await bcrypt.compare(password, demoUser.password);
        }

        if (passwordMatches || password === "password123" || password === "demo123") {
          const token = generateToken(demoUser);
          const safeUser = { ...demoUser };
          delete safeUser.password;

          res.setHeader("X-Demo-Mode", "true");
          return res.status(200).json({
            success: true,
            message: "Login successful (Demo Mode)",
            data: {
              user: safeUser,
              token
            }
          });
        }
      }

      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    // Production mode with MongoDB
    const user = await User.findOne({ email: email.toLowerCase() }).select("+password");

    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        user: user.toSafeObject(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  const safeUser = { ...(req.user.toObject ? req.user.toObject() : req.user) };
  delete safeUser.password;

  res.status(200).json({
    success: true,
    message: "Current user profile retrieved",
    data: safeUser
  });
};

// @desc    Get pre-seeded demo accounts for switch-user
// @route   GET /api/auth/demo-accounts
// @access  Public
const getDemoAccounts = async (req, res) => {
  const accounts = [
    {
      id: "demo_brand_1",
      name: "Aura Beverages",
      email: "brand@aurabev.com",
      role: "brand",
      companyName: "Aura Beverages Co.",
      avatarText: "AB",
      description: "Brand Enterprise Organization Account"
    },
    {
      id: "demo_creator_user_1",
      name: "Aria Chen",
      email: "aria@ai-creators.io",
      role: "creator",
      companyName: "AI Culinary Studio",
      avatarText: "AC",
      description: "AI Culinary Visualist & Commercial Specialist"
    },
    {
      id: "demo_creator_user_2",
      name: "Marcus Vance",
      email: "marcus@cinematic-ai.com",
      role: "creator",
      companyName: "Cinematic AI Productions",
      avatarText: "MV",
      description: "Sci-Fi & Commercial Filmmaker"
    },
    {
      id: "demo_creator_user_3",
      name: "Elena Rostova",
      email: "elena@anim-lab.studio",
      role: "creator",
      companyName: "Anim Lab Studio",
      avatarText: "ER",
      description: "Hybrid AI Animator & Motion Graphics"
    },
    {
      id: "demo_creator_user_6",
      name: "Aarav Sharma",
      email: "aarav@generative-motion.ai",
      role: "creator",
      companyName: "Generative Motion VFX",
      avatarText: "AS",
      description: "Macro Liquid VFX & Runway Gen-3 Director"
    }
  ];

  return res.status(200).json({
    success: true,
    count: accounts.length,
    data: accounts
  });
};

module.exports = {
  registerUser,
  loginUser,
  getMe,
  getDemoAccounts,
  generateToken
};

