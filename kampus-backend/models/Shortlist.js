const mongoose = require("mongoose");

const shortlistSchema = new mongoose.Schema(
  {
    campaignId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Campaign",
      required: [true, "Campaign ID is required"],
      index: true
    },
    brandId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Brand ID is required"],
      index: true
    },
    creatorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Creator",
      required: [true, "Creator ID is required"],
      index: true
    },
    notes: {
      type: String,
      trim: true,
      default: ""
    },
    matchScore: {
      type: Number,
      min: 0,
      max: 100,
      default: null
    }
  },
  {
    timestamps: true
  }
);

// Prevent duplicate creator shortlisting for the same campaign
shortlistSchema.index({ campaignId: 1, creatorId: 1 }, { unique: true });

module.exports = mongoose.model("Shortlist", shortlistSchema);
