const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/db");
const { getDbStatus } = require("./config/db");
const { notFound, errorHandler } = require("./middleware/errorMiddleware");

// Route imports
const authRoutes = require("./routes/authRoutes");
const creatorRoutes = require("./routes/creatorRoutes");
const campaignRoutes = require("./routes/campaignRoutes");
const matchingRoutes = require("./routes/matchingRoutes");
const shortlistRoutes = require("./routes/shortlistRoutes");
const applicationRoutes = require("./routes/applicationRoutes");
const conversationRoutes = require("./routes/conversationRoutes");

const app = express();

// Middleware
app.use(cors({
  origin: process.env.CLIENT_ORIGIN || "*",
  credentials: true
}));
app.use(express.json());

// Root endpoint: API discovery & welcome
app.get("/", (req, res) => {
  const isDemo = process.env.DEMO_MODE === "true";
  const dbStatus = getDbStatus();

  res.status(200).json({
    success: true,
    name: "Kampus.VC Backend API",
    tagline: "AI Content Creator Marketplace",
    version: "1.0.0",
    status: "online",
    environment: {
      demoMode: isDemo,
      databaseState: dbStatus.state,
      port: process.env.PORT || 5001
    },
    endpoints: {
      health: "/health",
      auth: "/api/auth (register, login, me)",
      creators: "/api/creators (CRUD, search, filtering)",
      campaigns: "/api/campaigns (CRUD, ai-brief)",
      matching: "/api/matching/:campaignId (explainable scoring & ranking)",
      shortlists: "/api/shortlists/:campaignId (curation & comparison)",
      applications: "/api/applications (workflows, status transitions, deliverables)",
      conversations: "/api/conversations (direct messaging, threads, replies)"
    }
  });
});

// Health check endpoint with accurate database connectivity reporting
app.get("/health", (req, res) => {
  const dbStatus = getDbStatus();
  const isDemo = process.env.DEMO_MODE === "true";
  const geminiConfigured = Boolean(process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY.trim().length > 0);

  // Return 200 if server is UP (either live database or demo mode active)
  res.status(200).json({
    success: true,
    status: "UP",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: {
      connected: dbStatus.isConnected,
      state: dbStatus.state,
      host: dbStatus.host,
      name: dbStatus.name,
      error: dbStatus.error
    },
    demoMode: isDemo,
    aiServiceConfigured: geminiConfigured,
    message: dbStatus.isConnected
      ? "All systems operational with active MongoDB Atlas connection."
      : isDemo
      ? "Server operational in DEMO_MODE. In-memory demo data repository active."
      : "Server operational in degraded mode. MongoDB is offline and DEMO_MODE is disabled."
  });
});

// Legacy test endpoint
app.get("/api/test", (req, res) => {
  res.status(200).json({
    success: true,
    message: "API is working successfully!"
  });
});

// Mount modular API routes
app.use("/api/auth", authRoutes);
app.use("/api/creators", creatorRoutes);
app.use("/api/campaigns", campaignRoutes);
app.use("/api/matching", matchingRoutes);
app.use("/api/shortlists", shortlistRoutes);
app.use("/api/applications", applicationRoutes);
app.use("/api/conversations", conversationRoutes);

// Centralized error handling
app.use(notFound);
app.use(errorHandler);

let serverInstance;

async function startServer() {
  const PORT = process.env.PORT || 5001;

  // Attempt database connection without crashing the server if offline
  await connectDB();

  serverInstance = app.listen(PORT, () => {
    console.log(`🚀 Kampus.VC server running on http://localhost:${PORT}`);
    console.log(`📡 Health Check: http://localhost:${PORT}/health`);
    console.log(`🎯 Mode: ${process.env.DEMO_MODE === "true" ? "DEMO_MODE (Offline-ready mock repository)" : "PRODUCTION (MongoDB Atlas)"}`);
  });

  return serverInstance;
}

// Graceful shutdown handling
const handleShutdown = (signal) => {
  console.log(`\n🛑 Received ${signal}. Initiating graceful shutdown...`);
  if (serverInstance) {
    serverInstance.close(() => {
      console.log("💤 HTTP server closed.");
      process.exit(0);
    });
  } else {
    process.exit(0);
  }
};

process.on("SIGTERM", () => handleShutdown("SIGTERM"));
process.on("SIGINT", () => handleShutdown("SIGINT"));

// Auto-start server when run directly
if (require.main === module) {
  startServer();
}

module.exports = { app, startServer };