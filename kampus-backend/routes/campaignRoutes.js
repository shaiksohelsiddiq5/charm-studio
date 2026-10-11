const express = require("express");
const {
  createCampaign,
  getCampaigns,
  getCampaignById,
  updateCampaign,
  deleteCampaign,
  generateAiBrief
} = require("../controllers/campaignController");
const { protect, authorize, optionalAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/ai-brief", generateAiBrief);
router.post("/brief-builder", generateAiBrief);

router.route("/")
  .get(getCampaigns)
  .post(optionalAuth, createCampaign);

router.route("/:id")
  .get(getCampaignById)
  .put(protect, authorize("brand"), updateCampaign)
  .delete(protect, authorize("brand"), deleteCampaign);

module.exports = router;
