require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const Creator = require("../models/Creator");
const Campaign = require("../models/Campaign");
const Shortlist = require("../models/Shortlist");
const Application = require("../models/Application");

async function seedDatabase() {
  console.log("🌱 Starting Kampus.VC database seed script...");

  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error("❌ MONGODB_URI is not set in .env");
    process.exit(1);
  }

  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
    console.log("✅ Connected to MongoDB");

    // Clean existing collections
    console.log("Clearing existing collections...");
    await User.deleteMany({});
    await Creator.deleteMany({});
    await Campaign.deleteMany({});
    await Shortlist.deleteMany({});
    await Application.deleteMany({});

    // Hash password
    const hashedPassword = await bcrypt.hash("password123", 10);

    // 1. Create Brands & Creators (Users)
    console.log("Creating Users...");
    const brandUser = await User.create({
      name: "Apex Beverage Co.",
      email: "brand@apexbev.com",
      password: hashedPassword,
      role: "brand",
      companyName: "Apex Beverages Inc."
    });

    const creatorUser1 = await User.create({
      name: "Aria Chen",
      email: "aria@ai-creators.io",
      password: hashedPassword,
      role: "creator"
    });

    const creatorUser2 = await User.create({
      name: "Marcus Vance",
      email: "marcus@cinematic-ai.com",
      password: hashedPassword,
      role: "creator"
    });

    const creatorUser3 = await User.create({
      name: "Elena Rostova",
      email: "elena@anim-lab.studio",
      password: hashedPassword,
      role: "creator"
    });

    const creatorUser4 = await User.create({
      name: "David Kim",
      email: "david@lumina3d.design",
      password: hashedPassword,
      role: "creator"
    });

    const creatorUser5 = await User.create({
      name: "Chloe Bennett",
      email: "chloe@viralcraft.co",
      password: hashedPassword,
      role: "creator"
    });

    // 2. Create Creator Profiles
    console.log("Creating Creator Profiles...");
    const creator1 = await Creator.create({
      userId: creatorUser1._id,
      name: "Aria Chen",
      displayName: "Aria Chen - AI Culinary Visualist",
      email: "aria@ai-creators.io",
      bio: "Pioneering commercial AI food & beverage visuals, hyper-realistic macro shots, condensation physics, and culinary cinematography.",
      specialization: ["AI Food Advertising", "Commercial Product Videos", "Hyper-realistic CGI"],
      skills: ["Prompt Engineering", "Macro Cinematography", "Color Grading", "Visual Effects", "AI Video Generation"],
      aiTools: ["Midjourney v6", "Runway Gen-3", "Magnific AI", "Kling AI", "FLUX.1"],
      contentTypes: ["Reels", "Commercial Video", "Product Teaser", "High-res Still Renders"],
      portfolio: [
        {
          title: "Sub-Zero Citrus Splash Campaign",
          description: "Macro slow-motion condensation droplets bursting over an icy citrus drink can.",
          contentType: "Commercial Video",
          contentStyle: "Hyper-realistic Cinematic",
          toolsUsed: ["Runway Gen-3", "Midjourney v6", "Magnific AI"],
          projectUrl: "https://demo.kampus.vc/portfolio/citrus-splash",
          thumbnailUrl: "https://images.unsplash.com/photo-1551024709-8f23befc6f87"
        }
      ],
      price: 1800,
      pricing: { startingAt: 1800, hourlyRate: 150, currency: "USD" },
      availability: "available",
      languages: ["English", "Mandarin"],
      location: "San Francisco, CA"
    });

    const creator2 = await Creator.create({
      userId: creatorUser2._id,
      name: "Marcus Vance",
      displayName: "Marcus Vance - Sci-Fi & Commercial Filmmaker",
      email: "marcus@cinematic-ai.com",
      bio: "Award-winning independent AI director crafting narrative-driven commercials and cinematic speculative universes.",
      specialization: ["AI Filmmaking", "Cinematic Storytelling", "Sci-Fi & Cyberpunk Aesthetics"],
      skills: ["Directing", "Screenwriting", "AI Video Generation", "Sound Design", "Audio Sync"],
      aiTools: ["Runway Gen-3", "Luma Dream Machine", "ElevenLabs", "Suno", "Midjourney"],
      contentTypes: ["Commercial Video", "Brand Film", "Trailers"],
      portfolio: [
        {
          title: "Chronicles of Neo-Kyoto",
          description: "Full 60-second sci-fi brand trailer generated using generative video pipelines.",
          contentType: "Brand Film",
          contentStyle: "Cinematic Anamorphic",
          toolsUsed: ["Runway Gen-3", "ElevenLabs", "Luma Dream Machine"],
          projectUrl: "https://demo.kampus.vc/portfolio/neo-kyoto",
          thumbnailUrl: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23"
        }
      ],
      price: 3200,
      pricing: { startingAt: 3200, hourlyRate: 200, currency: "USD" },
      availability: "available",
      languages: ["English"],
      location: "London, UK"
    });

    const creator3 = await Creator.create({
      userId: creatorUser3._id,
      name: "Elena Rostova",
      displayName: "Elena Rostova - Hybrid AI Animator",
      email: "elena@anim-lab.studio",
      bio: "Bridging classical frame animation with latent diffusion models to create surreal, viral motion graphics.",
      specialization: ["AI Animation", "Motion Graphics", "Stylized Character Animation"],
      skills: ["Character Design", "Prompt Engineering", "Keyframe Control", "2D/3D Hybrid"],
      aiTools: ["AnimateDiff", "ComfyUI", "Stable Diffusion XL", "Kling AI"],
      contentTypes: ["Animation", "Reels", "TikTok Video", "GIFs"],
      portfolio: [
        {
          title: "Metamorphosis Dreamscape",
          description: "Fluid anime-inspired character morphing animation for a streetwear capsule drop.",
          contentType: "Animation",
          contentStyle: "Vibrant Anime Surrealism",
          toolsUsed: ["AnimateDiff", "ComfyUI"],
          projectUrl: "https://demo.kampus.vc/portfolio/metamorphosis",
          thumbnailUrl: "https://images.unsplash.com/photo-1534447677768-be436bb09401"
        }
      ],
      price: 1500,
      pricing: { startingAt: 1500, hourlyRate: 110, currency: "USD" },
      availability: "available",
      languages: ["English", "German"],
      location: "Berlin, Germany"
    });

    const creator4 = await Creator.create({
      userId: creatorUser4._id,
      name: "David Kim",
      displayName: "David Kim - 3D Product Visualization Specialist",
      email: "david@lumina3d.design",
      bio: "Photorealistic industrial design and luxury cosmetics visualization using hybrid NeRF, Gaussian splatting, and generative AI.",
      specialization: ["Product Visualization", "Industrial Design Renders", "Packaging Animation"],
      skills: ["3D Lighting", "Material Rendering", "Camera Choreography", "AI Upscaling"],
      aiTools: ["FLUX.1", "Midjourney", "Magnific AI", "Blender AI", "Topaz Video AI"],
      contentTypes: ["Product Teaser", "High-res Still Renders", "Commercial Video"],
      portfolio: [
        {
          title: "Luminescence Luxury Serum Bottle",
          description: "Ray-traced glass refraction and liquid physics commercial mock.",
          contentType: "Product Teaser",
          contentStyle: "Luxury Minimalist",
          toolsUsed: ["FLUX.1", "Magnific AI", "Topaz Video AI"],
          projectUrl: "https://demo.kampus.vc/portfolio/luminescence",
          thumbnailUrl: "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9"
        }
      ],
      price: 2400,
      pricing: { startingAt: 2400, hourlyRate: 160, currency: "USD" },
      availability: "busy",
      languages: ["English", "Korean"],
      location: "Seoul, South Korea"
    });

    const creator5 = await Creator.create({
      userId: creatorUser5._id,
      name: "Chloe Bennett",
      displayName: "Chloe Bennett - Viral Short-form AI Creator",
      email: "chloe@viralcraft.co",
      bio: "Gen-Z focused viral hooks, trend-jacking, and snappy social clips for consumer brands on TikTok and IG Reels.",
      specialization: ["Social Media Content", "Viral Hook Generation", "UGC Style AI Avatars"],
      skills: ["Trend Analysis", "Fast Turnaround Editing", "Voice Synthesis", "Engagement Optimization"],
      aiTools: ["Runway Gen-3", "HeyGen", "ElevenLabs", "CapCut AI", "Midjourney"],
      contentTypes: ["TikTok Video", "Reels", "Shorts"],
      portfolio: [
        {
          title: "Smart Snack Flavor Explosion",
          description: "15-second hyper-kinetic viral reel generating over 2.4M organic views.",
          contentType: "TikTok Video",
          contentStyle: "High-Energy Social Fast Cuts",
          toolsUsed: ["Runway Gen-3", "ElevenLabs", "CapCut AI"],
          projectUrl: "https://demo.kampus.vc/portfolio/smart-snack",
          thumbnailUrl: "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e"
        }
      ],
      price: 950,
      pricing: { startingAt: 950, hourlyRate: 85, currency: "USD" },
      availability: "available",
      languages: ["English", "Spanish"],
      location: "Austin, TX"
    });

    // 3. Create Campaigns
    console.log("Creating Campaigns...");
    const campaign1 = await Campaign.create({
      brandId: brandUser._id,
      brandName: brandUser.companyName,
      title: "Apex Glacial Chill - Cinematic Commercial Campaign",
      productName: "Glacial Chill Sparkling Hydration",
      campaignDescription: "Launch campaign for our sub-zero sparkling botanical beverage. We need photorealistic cinematic videos showing macro condensation, ice fractures, and dynamic product pours.",
      contentTypes: ["Commercial Video", "Reels", "Product Teaser"],
      requiredSkills: ["AI Video Generation", "Macro Cinematography", "Color Grading"],
      preferredAITools: ["Runway Gen-3", "Midjourney v6", "Magnific AI"],
      desiredStyle: "Hyper-realistic Cinematic",
      targetPlatforms: ["Instagram", "TikTok", "YouTube Shorts"],
      targetAudience: "Active urban professionals aged 21-38",
      budgetMin: 1500,
      budgetMax: 3500,
      deadline: new Date("2026-11-30T00:00:00Z"),
      deliverables: [
        "1x 30s Master Commercial Spot (16:9 and 9:16)",
        "2x 15s High-energy Reels cuts with sound design",
        "4x 4K Key Art Still Renders"
      ],
      commercialUsageRequirements: "Global perpetual digital and broadcast advertising rights",
      status: "published"
    });

    // 4. Create Shortlist
    console.log("Creating Shortlist...");
    await Shortlist.create({
      campaignId: campaign1._id,
      creatorId: creator1._id,
      brandId: brandUser._id,
      notes: "Top pick for beverage macro photography and condensation effects.",
      matchScore: 95
    });

    // 5. Create Application
    console.log("Creating Application...");
    await Application.create({
      campaignId: campaign1._id,
      creatorId: creator1._id,
      brandId: brandUser._id,
      type: "invitation",
      status: "in_progress",
      pitch: "Direct invitation from Apex Beverage Co. based on portfolio match.",
      proposedRate: 2000,
      deliverableLinks: [
        "https://demo.kampus.vc/deliverables/rough_cut_v1.mp4"
      ],
      revisionComments: [
        {
          comment: "Great color balance. Please intensify the condensation frost on the can logo.",
          requestedBy: brandUser._id,
          createdAt: new Date()
        }
      ]
    });

    console.log("🎉 Database successfully seeded with demo accounts and content!");
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error("❌ Seeding failed:", err.message);
    if (err.message.includes("ENOTFOUND") || err.message.includes("ECONNREFUSED") || err.message.includes("querySrv") || err.message.includes("buffering timed out") || err.name === "MongooseServerSelectionError") {
      console.log("\n⚠️ Note: Database is unreachable due to DNS/network issues.");
      console.log("ℹ️ No problem! The server can run in DEMO_MODE=true with built-in in-memory demo data repository.");
    }
    process.exit(1);
  }
}

seedDatabase();
