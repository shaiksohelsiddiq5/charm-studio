const express = require("express");
const {
  addToShortlist,
  getShortlistsByCampaign,
  removeFromShortlist,
  compareShortlistedCreators
} = require("../controllers/shortlistController");
const { protect, optionalAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", optionalAuth, addToShortlist);

router.get("/:campaignId/compare", optionalAuth, compareShortlistedCreators);

router.get("/:campaignId", optionalAuth, getShortlistsByCampaign);

router.delete("/:campaignId/:creatorId", optionalAuth, removeFromShortlist);

module.exports = router;
