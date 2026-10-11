const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    campaignId: {
      type: String,
      default: ""
    },
    campaignTitle: {
      type: String,
      default: ""
    },
    participants: [
      {
        userId: {
          type: String,
          required: true
        },
        name: {
          type: String,
          required: true
        },
        role: {
          type: String,
          enum: ["brand", "creator"],
          default: "creator"
        },
        avatar: {
          type: String,
          default: ""
        }
      }
    ],
    lastMessage: {
      text: { type: String, default: "" },
      senderId: { type: String, default: "" },
      senderName: { type: String, default: "" },
      createdAt: { type: Date, default: Date.now }
    },
    unreadCount: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("Conversation", conversationSchema);
