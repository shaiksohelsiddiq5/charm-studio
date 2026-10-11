const express = require("express");
const {
  createApplication,
  getApplications,
  getApplicationById,
  updateApplicationStatus,
  submitDeliverables,
  requestRevision
} = require("../controllers/applicationController");
const { protect, optionalAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.route("/")
  .get(optionalAuth, getApplications)
  .post(optionalAuth, createApplication);

router.route("/:id")
  .get(optionalAuth, getApplicationById);

router.patch("/:id/status", optionalAuth, updateApplicationStatus);
router.put("/:id/status", optionalAuth, updateApplicationStatus);

router.post("/:id/deliverables", optionalAuth, submitDeliverables);
router.post("/:id/revisions", optionalAuth, requestRevision);

module.exports = router;
