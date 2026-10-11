const mongoose = require("mongoose");

const dbStatus = {
  isConnected: false,
  host: null,
  name: null,
  error: null,
  attemptedAt: null
};

async function connectDB() {
  const uri = process.env.MONGODB_URI;
  dbStatus.attemptedAt = new Date().toISOString();

  if (!uri) {
    dbStatus.error = "MONGODB_URI is not defined in environment variables";
    dbStatus.isConnected = false;
    console.warn("⚠️ Warning: MONGODB_URI is not set. Database is offline.");
    return false;
  }

  try {
    const connection = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 5000
    });

    dbStatus.isConnected = true;
    dbStatus.host = connection.connection.host;
    dbStatus.name = connection.connection.name;
    dbStatus.error = null;

    console.log(`✅ MongoDB connected: ${connection.connection.host}`);
    return true;
  } catch (error) {
    dbStatus.isConnected = false;
    dbStatus.host = null;
    dbStatus.error = error.message;

    console.error(`❌ MongoDB connection failed: ${error.message}`);
    if (process.env.DEMO_MODE === "true") {
      console.log("ℹ️ DEMO_MODE is enabled: App will serve in-memory demo repository data.");
    } else {
      console.warn("⚠️ Running in offline/degraded mode. Live database operations will report connection errors.");
    }
    return false;
  }
}

function getDbStatus() {
  const readyStates = ["disconnected", "connected", "connecting", "disconnecting"];
  return {
    isConnected: mongoose.connection.readyState === 1,
    state: readyStates[mongoose.connection.readyState] || "unknown",
    host: dbStatus.host,
    name: dbStatus.name,
    error: dbStatus.error,
    attemptedAt: dbStatus.attemptedAt
  };
}

connectDB.connectDB = connectDB;
connectDB.getDbStatus = getDbStatus;

module.exports = connectDB;