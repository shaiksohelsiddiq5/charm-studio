const express = require("express");
const {
  createCreator,
  getCreators,
  getCreatorById,
  updateCreator,
  deleteCreator
} = require("../controllers/creatorController");
const { protect, optionalAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.route("/")
  .get(getCreators)
  .post(optionalAuth, createCreator);

router.route("/:id")
  .get(getCreatorById)
  .put(protect, updateCreator)
  .delete(protect, deleteCreator);

module.exports = router;