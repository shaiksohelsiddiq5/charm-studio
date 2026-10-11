const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: String,
      required: [true, "conversationId is required"],
      index: true
    },
    senderId: {
      type: String,
      required: [true, "senderId is required"]
    },
    senderName: {
      type: String,
      required: [true, "senderName is required"]
    },
    senderRole: {
      type: String,
      enum: ["brand", "creator"],
      default: "brand"
    },
    recipientId: {
      type: String,
      default: ""
    },
    text: {
      type: String,
      required: [true, "Message text cannot be empty"],
      trim: true,
      maxlength: [2000, "Message cannot exceed 2000 characters"]
    },
    isSimulatedReply: {
      type: Boolean,
      default: false
    },
    read: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("Message", messageSchema);
