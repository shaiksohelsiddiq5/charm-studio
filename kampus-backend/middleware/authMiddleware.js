const jwt = require("jsonwebtoken");
const User = require("../models/User");
const demoStore = require("../services/demoDataService");

const getJwtSecret = () => process.env.JWT_SECRET || "kampus_hackathon_jwt_secret_dev_2026";

// Protect routes: verify JWT token
const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer ")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Authentication required. No authorization token provided."
    });
  }

  try {
    const decoded = jwt.verify(token, getJwtSecret());

    // In DEMO_MODE, find in demo store if DB is not connected or in demo mode
    if (process.env.DEMO_MODE === "true") {
      const demoUser = demoStore.findUserById(decoded.id);
      if (demoUser) {
        req.user = demoUser;
        return next();
      }
    }

    // Try finding user in MongoDB
    try {
      const user = await User.findById(decoded.id).select("-password");
      if (user) {
        req.user = user;
        return next();
      }
    } catch (dbErr) {
      // If DB fails, fallback to decoded token payload if in demo mode or fallback
      if (process.env.DEMO_MODE === "true") {
        req.user = {
          _id: decoded.id,
          id: decoded.id,
          name: decoded.name || "Demo User",
          email: decoded.email,
          role: decoded.role || "creator"
        };
        return next();
      }
      throw dbErr;
    }

    return res.status(401).json({
      success: false,
      message: "The user associated with this token no longer exists"
    });
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token"
    });
  }
};

// Grant access to specific roles
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Forbidden: Role '${req.user ? req.user.role : "unauthenticated"}' is not authorized to access this route. Required roles: ${roles.join(", ")}`
      });
    }
    next();
  };
};

// Optional auth: sets req.user if valid token exists, proceeds regardless
const optionalAuth = async (req, res, next) => {
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer ")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return next();
  }

  try {
    const decoded = jwt.verify(token, getJwtSecret());
    if (process.env.DEMO_MODE === "true") {
      req.user = demoStore.findUserById(decoded.id) || decoded;
    } else {
      const user = await User.findById(decoded.id).select("-password");
      if (user) req.user = user;
    }
  } catch (err) {
    // Ignore invalid token in optionalAuth
  }
  next();
};

module.exports = {
  protect,
  authorize,
  optionalAuth
};
