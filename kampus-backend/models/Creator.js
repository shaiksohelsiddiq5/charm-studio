const mongoose = require("mongoose");

const portfolioItemSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true
    },
    description: {
      type: String,
      trim: true,
      default: ""
    },
    contentType: {
      type: String,
      trim: true,
      default: "video"
    },
    contentStyle: {
      type: String,
      trim: true,
      default: ""
    },
    toolsUsed: {
      type: [String],
      default: []
    },
    projectUrl: {
      type: String,
      trim: true
    },
    url: {
      type: String,
      trim: true
    },
    thumbnailUrl: {
      type: String,
      trim: true,
      default: ""
    }
  },
  { _id: true }
);

const creatorSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      index: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    displayName: {
      type: String,
      trim: true
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },
    bio: {
      type: String,
      trim: true,
      default: ""
    },
    specialization: {
      type: [String],
      default: []
    },
    skills: {
      type: [String],
      default: []
    },
    aiTools: {
      type: [String],
      default: []
    },
    contentTypes: {
      type: [String],
      default: []
    },
    portfolio: [portfolioItemSchema],
    price: {
      type: Number,
      min: 0,
      default: 0
    },
    pricing: {
      startingAt: { type: Number, min: 0, default: 0 },
      hourlyRate: { type: Number, min: 0, default: 0 },
      currency: { type: String, default: "USD" }
    },
    availability: {
      type: String,
      enum: ["available", "busy", "unavailable"],
      default: "available"
    },
    languages: {
      type: [String],
      default: ["English"]
    },
    location: {
      type: String,
      trim: true,
      default: ""
    }
  },
  {
    timestamps: true
  }
);

// Pre-save hook to ensure displayName and pricing synchronization
creatorSchema.pre("save", function () {
  if (!this.displayName && this.name) {
    this.displayName = this.name;
  }
  if (this.price && (!this.pricing || !this.pricing.startingAt)) {
    this.pricing = this.pricing || {};
    this.pricing.startingAt = this.price;
  } else if (this.pricing && this.pricing.startingAt && !this.price) {
    this.price = this.pricing.startingAt;
  }
});

// Text indexing for fast search
creatorSchema.index({
  name: "text",
  displayName: "text",
  bio: "text",
  skills: "text",
  specialization: "text"
});

module.exports = mongoose.model("Creator", creatorSchema);