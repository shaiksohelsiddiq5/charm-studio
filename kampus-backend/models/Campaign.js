const mongoose = require("mongoose");

const campaignSchema = new mongoose.Schema(
  {
    brandId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Brand ID is required"],
      index: true
    },
    brandName: {
      type: String,
      required: [true, "Brand name is required"],
      trim: true
    },
    title: {
      type: String,
      required: [true, "Campaign title is required"],
      trim: true
    },
    productName: {
      type: String,
      trim: true,
      default: ""
    },
    campaignDescription: {
      type: String,
      required: [true, "Campaign description is required"],
      trim: true
    },
    contentTypes: {
      type: [String],
      default: []
    },
    requiredSkills: {
      type: [String],
      default: []
    },
    preferredAITools: {
      type: [String],
      default: []
    },
    desiredStyle: {
      type: String,
      trim: true,
      default: ""
    },
    targetPlatforms: {
      type: [String],
      default: ["Instagram", "TikTok"]
    },
    targetAudience: {
      type: String,
      trim: true,
      default: ""
    },
    budgetMin: {
      type: Number,
      min: 0,
      default: 0
    },
    budgetMax: {
      type: Number,
      min: 0,
      default: 0
    },
    deadline: {
      type: Date
    },
    deliverables: {
      type: [String],
      default: []
    },
    commercialUsageRequirements: {
      type: String,
      trim: true,
      default: "Full commercial rights for digital distribution"
    },
    status: {
      type: String,
      enum: {
        values: [
          "draft",
          "published",
          "in_progress",
          "review",
          "completed",
          "cancelled"
        ],
        message: "Status must be draft, published, in_progress, review, completed, or cancelled"
      },
      default: "published"
    }
  },
  {
    timestamps: true
  }
);

campaignSchema.index({ title: "text", campaignDescription: "text", productName: "text" });

module.exports = mongoose.model("Campaign", campaignSchema);
