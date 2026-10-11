const mongoose = require("mongoose");

// Validate email format
const isValidEmail = (email) => {
  if (!email || typeof email !== "string") return false;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email.trim());
};

// Validate MongoDB ObjectId
const isValidObjectId = (id) => {
  if (!id) return false;
  // If in demo mode, allow demo string IDs or valid 24-hex string
  if (typeof id === "string" && (id.startsWith("demo_") || id.startsWith("creator_") || id.startsWith("campaign_"))) {
    return true;
  }
  return mongoose.Types.ObjectId.isValid(id);
};

// Validate URL format
const isValidUrl = (url) => {
  if (!url || typeof url !== "string") return false;
  try {
    new URL(url);
    return true;
  } catch (err) {
    return false;
  }
};

// Application workflow valid transitions
const VALID_APPLICATION_TRANSITIONS = {
  invited: ["accepted", "rejected"],
  applied: ["accepted", "rejected"],
  accepted: ["in_progress", "rejected"],
  in_progress: ["submitted", "rejected"],
  submitted: ["revision_requested", "approved"],
  revision_requested: ["submitted"],
  approved: ["completed"],
  rejected: [],
  completed: []
};

const isValidApplicationTransition = (currentStatus, newStatus) => {
  if (!VALID_APPLICATION_TRANSITIONS[currentStatus]) return false;
  return VALID_APPLICATION_TRANSITIONS[currentStatus].includes(newStatus);
};

// Campaign valid statuses
const VALID_CAMPAIGN_STATUSES = [
  "draft",
  "published",
  "in_progress",
  "review",
  "completed",
  "cancelled"
];

module.exports = {
  isValidEmail,
  isValidObjectId,
  isValidUrl,
  isValidApplicationTransition,
  VALID_APPLICATION_TRANSITIONS,
  VALID_CAMPAIGN_STATUSES
};
