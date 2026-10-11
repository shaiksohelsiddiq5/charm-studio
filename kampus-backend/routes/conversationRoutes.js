const express = require("express");
const router = express.Router();
const {
  getConversations,
  getConversationById,
  getMessages,
  sendMessage,
  simulateReply,
  suggestReply
} = require("../controllers/conversationController");
const { optionalAuth, protect } = require("../middleware/authMiddleware");

// Route configurations
router.route("/")
  .get(optionalAuth, getConversations);

router.route("/:id")
  .get(optionalAuth, getConversationById);

router.route("/:id/messages")
  .get(optionalAuth, getMessages)
  .post(optionalAuth, sendMessage);

router.route("/:id/simulate-reply")
  .post(optionalAuth, simulateReply);

router.route("/:id/suggest-reply")
  .post(optionalAuth, suggestReply);

module.exports = router;
