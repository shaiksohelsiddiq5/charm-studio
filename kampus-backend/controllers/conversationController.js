const Conversation = require("../models/Conversation");
const Message = require("../models/Message");
const Campaign = require("../models/Campaign");
const demoStore = require("../services/demoDataService");
const { generateSuggestedReply } = require("../services/geminiChatService");

// @desc    Get all conversations for the user
// @route   GET /api/conversations
// @access  Public or Protected
const getConversations = async (req, res, next) => {
  try {
    const userId = req.user ? (req.user._id || req.user.id) : null;

    if (process.env.DEMO_MODE === "true") {
      const list = demoStore.getConversations(userId);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        count: list.length,
        data: list
      });
    }

    const query = userId ? { "participants.userId": userId } : {};
    const conversations = await Conversation.find(query).sort({ updatedAt: -1 });

    return res.status(200).json({
      success: true,
      count: conversations.length,
      data: conversations
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single conversation by ID
// @route   GET /api/conversations/:id
// @access  Public or Protected
const getConversationById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (process.env.DEMO_MODE === "true") {
      const conv = demoStore.findConversationById(id);
      if (!conv) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        data: conv
      });
    }

    const conv = await Conversation.findById(id);
    if (!conv) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: conv
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get message history for a conversation
// @route   GET /api/conversations/:id/messages
// @access  Public or Protected
const getMessages = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (process.env.DEMO_MODE === "true") {
      const conv = demoStore.findConversationById(id);
      if (!conv) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      const messages = demoStore.getMessages(id);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        count: messages.length,
        data: messages
      });
    }

    const conv = await Conversation.findById(id);
    if (!conv) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    const messages = await Message.find({ conversationId: id }).sort({ createdAt: 1 });

    return res.status(200).json({
      success: true,
      count: messages.length,
      data: messages
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Send a message in a conversation
// @route   POST /api/conversations/:id/messages
// @access  Protected
const sendMessage = async (req, res, next) => {
  try {
    const { id: conversationId } = req.params;
    const { text, recipientId } = req.body;

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "Message text cannot be empty"
      });
    }

    // Authenticated sender identity
    const senderId = req.user ? (req.user._id || req.user.id) : "demo_brand_1";
    const senderName = req.user ? req.user.name : "Aura Beverages";
    const senderRole = req.user ? req.user.role : "brand";

    if (process.env.DEMO_MODE === "true") {
      const conv = demoStore.findConversationById(conversationId);
      if (!conv) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      // Determine recipient if not provided
      let targetRecipient = recipientId;
      if (!targetRecipient && conv.participants && conv.participants.length > 0) {
        const other = conv.participants.find((p) => (p.userId || p.id) !== senderId);
        targetRecipient = other ? (other.userId || other.id) : "";
      }

      const newMsg = demoStore.createMessage({
        conversationId,
        senderId,
        senderName,
        senderRole,
        recipientId: targetRecipient,
        text: text.trim(),
        isSimulatedReply: false
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(201).json({
        success: true,
        message: "Message sent successfully (Demo Mode)",
        data: newMsg
      });
    }

    // Production mode with MongoDB
    const conv = await Conversation.findById(conversationId);
    if (!conv) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    let targetRecipient = recipientId;
    if (!targetRecipient && conv.participants && conv.participants.length > 0) {
      const other = conv.participants.find((p) => p.userId !== senderId.toString());
      targetRecipient = other ? other.userId : "";
    }

    const newMsg = await Message.create({
      conversationId,
      senderId: senderId.toString(),
      senderName,
      senderRole,
      recipientId: targetRecipient,
      text: text.trim(),
      isSimulatedReply: false
    });

    conv.lastMessage = {
      text: newMsg.text,
      senderId: newMsg.senderId,
      senderName: newMsg.senderName,
      createdAt: newMsg.createdAt
    };
    conv.updatedAt = new Date();
    await conv.save();

    return res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: newMsg
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Trigger simulated creator reply for demo testing
// @route   POST /api/conversations/:id/simulate-reply
// @access  Public or Protected
const simulateReply = async (req, res, next) => {
  try {
    const { id: conversationId } = req.params;
    const { customText } = req.body || {};

    if (process.env.DEMO_MODE === "true") {
      const conv = demoStore.findConversationById(conversationId);
      if (!conv) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      const replyMsg = demoStore.simulateReply(conversationId, customText);
      res.setHeader("X-Demo-Mode", "true");
      return res.status(201).json({
        success: true,
        message: "Simulated creator reply generated successfully (Demo Mode)",
        data: replyMsg
      });
    }

    // In production MongoDB mode
    const conv = await Conversation.findById(conversationId);
    if (!conv) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    const creator = conv.participants.find((p) => p.role === "creator") || conv.participants[0];
    const brand = conv.participants.find((p) => p.role === "brand") || conv.participants[1];

    const replyMsg = await Message.create({
      conversationId,
      senderId: creator ? creator.userId : "demo_creator_user_6",
      senderName: creator ? creator.name : "Aarav Sharma",
      senderRole: "creator",
      recipientId: brand ? brand.userId : "",
      text: customText || "Thanks for the feedback! I've loaded the camera moves into Runway Gen-3 and will deliver the initial render milestone by tomorrow.",
      isSimulatedReply: true
    });

    conv.lastMessage = {
      text: replyMsg.text,
      senderId: replyMsg.senderId,
      senderName: replyMsg.senderName,
      createdAt: replyMsg.createdAt
    };
    await conv.save();

    return res.status(201).json({
      success: true,
      message: "Simulated creator reply generated successfully",
      data: replyMsg
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Generate AI context-aware suggested reply using Gemini
// @route   POST /api/conversations/:id/suggest-reply
// @access  Public or Protected
const suggestReply = async (req, res, next) => {
  try {
    const { id: conversationId } = req.params;
    const { prompt } = req.body || {};

    const userId = req.user ? (req.user._id || req.user.id).toString() : null;
    const userRole = req.user ? req.user.role : "brand";
    const userName = req.user ? req.user.name : "Aura Beverages";

    if (process.env.DEMO_MODE === "true") {
      const conv = demoStore.findConversationById(conversationId);
      if (!conv) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      // Check ownership if user is authenticated
      if (userId && conv.participants && conv.participants.length > 0) {
        const isParticipant = conv.participants.some(
          (p) => (p.userId || p.id || "").toString() === userId
        );
        if (!isParticipant) {
          return res.status(403).json({
            success: false,
            message: "Unauthorized: You are not a participant in this conversation"
          });
        }
      }

      const messages = demoStore.getMessages(conversationId);
      const campaign = conv.campaignId ? demoStore.findCampaignById(conv.campaignId) : null;

      // Identify active participant in conversation
      const currentParticipant = (conv.participants || []).find(
        (p) => (p.userId || p.id || "").toString() === userId
      ) || (conv.participants ? conv.participants[0] : null);

      const activeUser = {
        id: userId || (currentParticipant ? (currentParticipant.userId || currentParticipant.id) : "demo_brand_1"),
        name: currentParticipant ? currentParticipant.name : userName,
        role: currentParticipant ? currentParticipant.role : userRole
      };

      const result = await generateSuggestedReply({
        conversation: conv,
        messages,
        campaign,
        currentUser: activeUser,
        userPrompt: prompt
      });

      res.setHeader("X-Demo-Mode", "true");
      return res.status(200).json({
        success: true,
        data: result
      });
    }

    // Production MongoDB Mode
    const conv = await Conversation.findById(conversationId);
    if (!conv) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found"
      });
    }

    if (userId && conv.participants && conv.participants.length > 0) {
      const isParticipant = conv.participants.some(
        (p) => (p.userId || "").toString() === userId
      );
      if (!isParticipant) {
        return res.status(403).json({
          success: false,
          message: "Unauthorized: You are not a participant in this conversation"
        });
      }
    }

    const messages = await Message.find({ conversationId }).sort({ createdAt: 1 });
    let campaign = null;
    if (conv.campaignId) {
      campaign = await Campaign.findById(conv.campaignId).catch(() => null);
    }

    const currentParticipant = (conv.participants || []).find(
      (p) => (p.userId || "").toString() === userId
    ) || (conv.participants ? conv.participants[0] : null);

    const activeUser = {
      id: userId || (currentParticipant ? currentParticipant.userId : "demo_brand_1"),
      name: currentParticipant ? currentParticipant.name : userName,
      role: currentParticipant ? currentParticipant.role : userRole
    };

    const result = await generateSuggestedReply({
      conversation: conv,
      messages,
      campaign,
      currentUser: activeUser,
      userPrompt: prompt
    });

    return res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getConversations,
  getConversationById,
  getMessages,
  sendMessage,
  simulateReply,
  suggestReply
};
