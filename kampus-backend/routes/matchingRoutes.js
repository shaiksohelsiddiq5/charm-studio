const express = require("express");
const { getMatchingCreators } = require("../controllers/matchingController");
const { optionalAuth } = require("../middleware/authMiddleware");

const router = express.Router();

// Allow both POST and GET for matching as specified in Section 8
router.route("/:campaignId")
  .post(optionalAuth, getMatchingCreators)
  .get(optionalAuth, getMatchingCreators);

module.exports = router;
