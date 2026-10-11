const mongoose = require("mongoose");

const applicationSchema = new mongoose.Schema(
  {
    campaignId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Campaign",
      required: [true, "Campaign ID is required"],
      index: true
    },
    creatorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Creator",
      required: [true, "Creator ID is required"],
      index: true
    },
    brandId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Brand ID is required"],
      index: true
    },
    type: {
      type: String,
      enum: ["application", "invitation"],
      default: "application"
    },
    status: {
      type: String,
      enum: {
        values: [
          "invited",
          "applied",
          "accepted",
          "rejected",
          "in_progress",
          "submitted",
          "revision_requested",
          "approved",
          "completed"
        ],
        message: "Invalid application status"
      },
      default: "applied"
    },
    pitch: {
      type: String,
      trim: true,
      default: ""
    },
    proposedRate: {
      type: Number,
      min: 0
    },
    deliverableLinks: {
      type: [String],
      default: []
    },
    revisionComments: [
      {
        comment: { type: String, required: true },
        requestedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        createdAt: { type: Date, default: Date.now }
      }
    ]
  },
  {
    timestamps: true
  }
);

applicationSchema.index({ campaignId: 1, creatorId: 1 }, { unique: true });

module.exports = mongoose.model("Application", applicationSchema);
