// In-memory demo data repository for DEMO_MODE=true offline operation
// Clearly labelled demo data to support hackathon demos during database DNS/offline conditions

const DEMO_USERS = [
  {
    _id: "demo_brand_1",
    id: "demo_brand_1",
    name: "Aura Beverages",
    email: "brand@aurabev.com",
    role: "brand",
    companyName: "Aura Beverages Co.",
    isDemoData: true,
    createdAt: new Date("2026-01-10T10:00:00Z")
  },
  {
    _id: "demo_brand_2",
    id: "demo_brand_2",
    name: "Apex Beverage Co.",
    email: "brand@apexbev.com",
    role: "brand",
    companyName: "Apex Beverages Inc.",
    isDemoData: true,
    createdAt: new Date("2026-01-10T10:00:00Z")
  },
  {
    _id: "demo_creator_user_1",
    id: "demo_creator_user_1",
    name: "Aria Chen",
    email: "aria@ai-creators.io",
    role: "creator",
    companyName: "",
    isDemoData: true,
    createdAt: new Date("2026-01-11T11:00:00Z")
  },
  {
    _id: "demo_creator_user_2",
    id: "demo_creator_user_2",
    name: "Marcus Vance",
    email: "marcus@cinematic-ai.com",
    role: "creator",
    companyName: "",
    isDemoData: true,
    createdAt: new Date("2026-01-12T12:00:00Z")
  },
  {
    _id: "demo_creator_user_3",
    id: "demo_creator_user_3",
    name: "Elena Rostova",
    email: "elena@anim-lab.studio",
    role: "creator",
    companyName: "Anim Lab Studio",
    isDemoData: true,
    createdAt: new Date("2026-01-13T13:00:00Z")
  },
  {
    _id: "demo_creator_user_6",
    id: "demo_creator_user_6",
    name: "Aarav Sharma",
    email: "aarav@generative-motion.ai",
    role: "creator",
    companyName: "Generative Motion VFX",
    isDemoData: true,
    createdAt: new Date("2026-01-14T14:00:00Z")
  }
];

const DEMO_CREATORS = [
  {
    _id: "demo_creator_1",
    id: "demo_creator_1",
    userId: "demo_creator_user_1",
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
        _id: "port_1",
        title: "Sub-Zero Citrus Splash Campaign",
        description: "Macro slow-motion condensation droplets bursting over an icy citrus drink can.",
        contentType: "Commercial Video",
        contentStyle: "Hyper-realistic Cinematic",
        toolsUsed: ["Runway Gen-3", "Midjourney v6", "Magnific AI"],
        projectUrl: "https://demo.kampus.vc/portfolio/citrus-splash",
        thumbnailUrl: "https://images.unsplash.com/photo-1551024709-8f23befc6f87"
      },
      {
        _id: "port_2",
        title: "Artisan Coffee Steam & Pour",
        description: "Photorealistic AI motion render of artisan pour-over coffee with ambient steam.",
        contentType: "Reels",
        contentStyle: "Warm Atmospheric",
        toolsUsed: ["Kling AI", "FLUX.1"],
        projectUrl: "https://demo.kampus.vc/portfolio/artisan-coffee",
        thumbnailUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93"
      }
    ],
    price: 1800,
    pricing: { startingAt: 1800, hourlyRate: 150, currency: "USD" },
    availability: "available",
    languages: ["English", "Mandarin"],
    location: "San Francisco, CA",
    isDemoData: true,
    createdAt: new Date("2026-01-15T09:00:00Z")
  },
  {
    _id: "demo_creator_2",
    id: "demo_creator_2",
    userId: "demo_creator_user_2",
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
        _id: "port_3",
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
    location: "London, UK",
    isDemoData: true,
    createdAt: new Date("2026-01-16T10:00:00Z")
  },
  {
    _id: "demo_creator_3",
    id: "demo_creator_3",
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
        _id: "port_4",
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
    location: "Berlin, Germany",
    isDemoData: true,
    createdAt: new Date("2026-01-17T11:00:00Z")
  },
  {
    _id: "demo_creator_4",
    id: "demo_creator_4",
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
        _id: "port_5",
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
    location: "Seoul, South Korea",
    isDemoData: true,
    createdAt: new Date("2026-01-18T14:00:00Z")
  },
  {
    _id: "demo_creator_5",
    id: "demo_creator_5",
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
        _id: "port_6",
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
    location: "Austin, TX",
    isDemoData: true,
    createdAt: new Date("2026-01-19T16:00:00Z")
  }
];

const DEMO_CAMPAIGNS = [
  {
    _id: "demo_campaign_1",
    id: "demo_campaign_1",
    brandId: "demo_brand_1",
    brandName: "Apex Beverage Co.",
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
    status: "published",
    isDemoData: true,
    createdAt: new Date("2026-01-20T10:00:00Z")
  },
  {
    _id: "demo_campaign_2",
    id: "demo_campaign_2",
    brandId: "demo_brand_1",
    brandName: "Apex Beverage Co.",
    title: "Zero-Gravity Hydration Futuristic Brand Film",
    productName: "Apex Orbital Energy Drink",
    campaignDescription: "A sci-fi cinematic narrative trailer showcasing astronauts drinking floating globules of energy nectar in deep space.",
    contentTypes: ["Brand Film", "Trailers"],
    requiredSkills: ["AI Filmmaking", "Sci-Fi & Cyberpunk Aesthetics", "Sound Design"],
    preferredAITools: ["Runway Gen-3", "Luma Dream Machine", "ElevenLabs"],
    desiredStyle: "Cinematic Anamorphic",
    targetPlatforms: ["YouTube", "Twitter/X"],
    targetAudience: "Gamers and sci-fi tech enthusiasts",
    budgetMin: 2500,
    budgetMax: 5000,
    deadline: new Date("2026-12-15T00:00:00Z"),
    deliverables: ["1x 60s Cinematic Brand Trailer"],
    commercialUsageRequirements: "Full digital distribution rights",
    status: "published",
    isDemoData: true,
    createdAt: new Date("2026-01-22T14:00:00Z")
  }
];

let demoShortlists = [
  {
    _id: "demo_shortlist_1",
    id: "demo_shortlist_1",
    campaignId: "demo_campaign_1",
    brandId: "demo_brand_1",
    creatorId: "demo_creator_1",
    notes: "Top pick for beverage macro photography and condensation effects.",
    matchScore: 95,
    isDemoData: true,
    createdAt: new Date("2026-01-25T11:00:00Z")
  }
];

let demoApplications = [
  {
    _id: "demo_app_1",
    id: "demo_app_1",
    campaignId: "demo_campaign_1",
    creatorId: "demo_creator_1",
    brandId: "demo_brand_1",
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
        requestedBy: "demo_brand_1",
        createdAt: new Date("2026-01-26T15:00:00Z")
      }
    ],
    isDemoData: true,
    createdAt: new Date("2026-01-25T12:00:00Z")
  }
];

let demoConversations = [
  {
    _id: "conv_1",
    id: "conv_1",
    campaignId: "demo_campaign_1",
    campaignTitle: "Summer Cold-Drink Campaign",
    participants: [
      { userId: "demo_brand_1", name: "Aura Beverages", role: "brand", avatar: "" },
      { userId: "demo_creator_user_6", name: "Aarav Sharma", role: "creator", avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80" }
    ],
    lastMessage: {
      text: "Absolutely. Turnaround takes 3 days. I can send the first styleframe moodboard by tomorrow afternoon.",
      senderId: "demo_creator_user_6",
      senderName: "Aarav Sharma",
      createdAt: new Date("2026-01-26T10:50:00Z")
    },
    unreadCount: 1,
    isDemoData: true,
    createdAt: new Date("2026-01-26T10:45:00Z"),
    updatedAt: new Date("2026-01-26T10:50:00Z")
  },
  {
    _id: "conv_2",
    id: "conv_2",
    campaignId: "demo_campaign_2",
    campaignTitle: "Aura Noir Luxury Fragrance Reveal",
    participants: [
      { userId: "demo_brand_1", name: "Aura Beverages", role: "brand", avatar: "" },
      { userId: "demo_creator_user_3", name: "Elena Rostova", role: "creator", avatar: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80" }
    ],
    lastMessage: {
      text: "Sent obsidian fragrance lighting moodboard and motion tests for review.",
      senderId: "demo_creator_user_3",
      senderName: "Elena Rostova",
      createdAt: new Date("2026-01-25T14:30:00Z")
    },
    unreadCount: 0,
    isDemoData: true,
    createdAt: new Date("2026-01-25T14:00:00Z"),
    updatedAt: new Date("2026-01-25T14:30:00Z")
  },
  {
    _id: "conv_3",
    id: "conv_3",
    campaignId: "demo_campaign_1",
    campaignTitle: "Apex Glacial Chill - Cinematic Commercial Campaign",
    participants: [
      { userId: "demo_brand_1", name: "Aura Beverages", role: "brand", avatar: "" },
      { userId: "demo_creator_user_1", name: "Aria Chen", role: "creator", avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80" }
    ],
    lastMessage: {
      text: "Hello! I have prepped the FLUX.1 + Runway Gen-3 assets for the citrus splash tests.",
      senderId: "demo_creator_user_1",
      senderName: "Aria Chen",
      createdAt: new Date("2026-01-24T09:15:00Z")
    },
    unreadCount: 0,
    isDemoData: true,
    createdAt: new Date("2026-01-24T09:00:00Z"),
    updatedAt: new Date("2026-01-24T09:15:00Z")
  }
];

let demoMessages = [
  {
    _id: "msg_1_1",
    id: "msg_1_1",
    conversationId: "conv_1",
    senderId: "demo_creator_user_6",
    senderName: "Aarav Sharma",
    senderRole: "creator",
    recipientId: "demo_brand_1",
    text: "Hi Aura Beverages team! I reviewed your brief for the Summer Cold-Drink Campaign. I specialize in macro fluid condensation and have fine-tuned Runway Gen-3 workflows for zero-gravity citrus splashes.",
    isSimulatedReply: false,
    read: true,
    createdAt: new Date("2026-01-26T10:45:00Z")
  },
  {
    _id: "msg_1_2",
    id: "msg_1_2",
    conversationId: "conv_1",
    senderId: "demo_brand_1",
    senderName: "Aura Beverages",
    senderRole: "brand",
    recipientId: "demo_creator_user_6",
    text: "Fantastic Aarav! We need a 15-second cutdown in 9:16 vertical for Instagram Reels, with ultra-crisp condensation water droplets on the glass curve. Can you meet the Oct 28 deadline?",
    isSimulatedReply: false,
    read: true,
    createdAt: new Date("2026-01-26T10:48:00Z")
  },
  {
    _id: "msg_1_3",
    id: "msg_1_3",
    conversationId: "conv_1",
    senderId: "demo_creator_user_6",
    senderName: "Aarav Sharma",
    senderRole: "creator",
    recipientId: "demo_brand_1",
    text: "Absolutely. Turnaround takes 3 days. I can send the first styleframe moodboard by tomorrow afternoon.",
    isSimulatedReply: false,
    read: false,
    createdAt: new Date("2026-01-26T10:50:00Z")
  },
  {
    _id: "msg_2_1",
    id: "msg_2_1",
    conversationId: "conv_2",
    senderId: "demo_creator_user_3",
    senderName: "Elena Rostova",
    senderRole: "creator",
    recipientId: "demo_brand_1",
    text: "Sent obsidian fragrance lighting moodboard and motion tests for review.",
    isSimulatedReply: false,
    read: true,
    createdAt: new Date("2026-01-25T14:30:00Z")
  },
  {
    _id: "msg_3_1",
    id: "msg_3_1",
    conversationId: "conv_3",
    senderId: "demo_creator_user_1",
    senderName: "Aria Chen",
    senderRole: "creator",
    recipientId: "demo_brand_1",
    text: "Hello! I have prepped the FLUX.1 + Runway Gen-3 assets for the citrus splash tests.",
    isSimulatedReply: false,
    read: true,
    createdAt: new Date("2026-01-24T09:15:00Z")
  }
];

// Helper methods for the Demo Store
class DemoDataService {
  constructor() {
    this.users = [...DEMO_USERS];
    this.creators = [...DEMO_CREATORS];
    this.campaigns = [...DEMO_CAMPAIGNS];
    this.shortlists = [...demoShortlists];
    this.applications = [...demoApplications];
    this.conversations = [...demoConversations];
    this.messages = [...demoMessages];
  }

  // Users
  findUserById(id) {
    return this.users.find((u) => u._id === id || u.id === id);
  }

  findUserByEmail(email) {
    return this.users.find((u) => u.email.toLowerCase() === (email || "").toLowerCase());
  }

  createUser(userData) {
    const newUser = {
      _id: `demo_user_${Date.now()}`,
      id: `demo_user_${Date.now()}`,
      ...userData,
      isDemoData: true,
      createdAt: new Date()
    };
    this.users.push(newUser);
    return newUser;
  }

  // Creators
  getCreators(filters = {}) {
    let list = [...this.creators];

    if (filters.search) {
      const q = filters.search.toLowerCase();
      list = list.filter(
        (c) =>
          c.name.toLowerCase().includes(q) ||
          (c.bio && c.bio.toLowerCase().includes(q)) ||
          (c.displayName && c.displayName.toLowerCase().includes(q))
      );
    }
    if (filters.skills) {
      const skillArr = Array.isArray(filters.skills)
        ? filters.skills
        : filters.skills.split(",").map((s) => s.trim().toLowerCase());
      list = list.filter((c) =>
        c.skills.some((s) => skillArr.includes(s.toLowerCase()))
      );
    }
    if (filters.specialization) {
      const spec = filters.specialization.toLowerCase();
      list = list.filter((c) =>
        c.specialization.some((s) => s.toLowerCase().includes(spec))
      );
    }
    if (filters.aiTools) {
      const toolArr = Array.isArray(filters.aiTools)
        ? filters.aiTools
        : filters.aiTools.split(",").map((t) => t.trim().toLowerCase());
      list = list.filter((c) =>
        c.aiTools.some((t) => toolArr.includes(t.toLowerCase()))
      );
    }
    if (filters.contentTypes) {
      const typeArr = Array.isArray(filters.contentTypes)
        ? filters.contentTypes
        : filters.contentTypes.split(",").map((t) => t.trim().toLowerCase());
      list = list.filter((c) =>
        c.contentTypes.some((t) => typeArr.includes(t.toLowerCase()))
      );
    }
    if (filters.budgetMax) {
      const max = Number(filters.budgetMax);
      list = list.filter((c) => c.price <= max);
    }
    if (filters.availability) {
      list = list.filter((c) => c.availability === filters.availability);
    }
    if (filters.language) {
      const lang = filters.language.toLowerCase();
      list = list.filter((c) =>
        c.languages.some((l) => l.toLowerCase() === lang)
      );
    }

    // Sorting
    if (filters.sort === "price_asc") {
      list.sort((a, b) => a.price - b.price);
    } else if (filters.sort === "price_desc") {
      list.sort((a, b) => b.price - a.price);
    } else {
      list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    }

    const total = list.length;
    const page = Number(filters.page) || 1;
    const limit = Number(filters.limit) || 20;
    const startIndex = (page - 1) * limit;
    const paginated = list.slice(startIndex, startIndex + limit);

    return {
      creators: paginated,
      total,
      page,
      pages: Math.ceil(total / limit)
    };
  }

  findCreatorById(id) {
    return this.creators.find((c) => c._id === id || c.id === id);
  }

  createCreator(creatorData) {
    const newCreator = {
      _id: `demo_creator_${Date.now()}`,
      id: `demo_creator_${Date.now()}`,
      ...creatorData,
      isDemoData: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    this.creators.unshift(newCreator);
    return newCreator;
  }

  updateCreator(id, updateData) {
    const index = this.creators.findIndex((c) => c._id === id || c.id === id);
    if (index === -1) return null;
    this.creators[index] = {
      ...this.creators[index],
      ...updateData,
      updatedAt: new Date()
    };
    return this.creators[index];
  }

  deleteCreator(id) {
    const index = this.creators.findIndex((c) => c._id === id || c.id === id);
    if (index === -1) return false;
    this.creators.splice(index, 1);
    return true;
  }

  // Campaigns
  getCampaigns(filters = {}) {
    let list = [...this.campaigns];
    if (filters.brandId) {
      list = list.filter((c) => c.brandId === filters.brandId);
    }
    if (filters.status) {
      list = list.filter((c) => c.status === filters.status);
    }
    if (filters.search) {
      const q = filters.search.toLowerCase();
      list = list.filter(
        (c) =>
          c.title.toLowerCase().includes(q) ||
          c.campaignDescription.toLowerCase().includes(q)
      );
    }
    list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    const total = list.length;
    const page = Number(filters.page) || 1;
    const limit = Number(filters.limit) || 20;
    const startIndex = (page - 1) * limit;
    const paginated = list.slice(startIndex, startIndex + limit);

    return {
      campaigns: paginated,
      total,
      page,
      pages: Math.ceil(total / limit)
    };
  }

  findCampaignById(id) {
    return this.campaigns.find((c) => c._id === id || c.id === id);
  }

  createCampaign(campaignData) {
    const newCampaign = {
      _id: `demo_campaign_${Date.now()}`,
      id: `demo_campaign_${Date.now()}`,
      ...campaignData,
      isDemoData: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    this.campaigns.unshift(newCampaign);
    return newCampaign;
  }

  updateCampaign(id, updateData) {
    const index = this.campaigns.findIndex((c) => c._id === id || c.id === id);
    if (index === -1) return null;
    this.campaigns[index] = {
      ...this.campaigns[index],
      ...updateData,
      updatedAt: new Date()
    };
    return this.campaigns[index];
  }

  deleteCampaign(id) {
    const index = this.campaigns.findIndex((c) => c._id === id || c.id === id);
    if (index === -1) return false;
    this.campaigns.splice(index, 1);
    return true;
  }

  // Shortlists
  getShortlists(campaignId) {
    const items = this.shortlists.filter((s) => s.campaignId === campaignId);
    return items.map((item) => {
      const creator = this.findCreatorById(item.creatorId);
      return {
        ...item,
        creator: creator || null
      };
    });
  }

  addToShortlist(data) {
    const existing = this.shortlists.find(
      (s) => s.campaignId === data.campaignId && s.creatorId === data.creatorId
    );
    if (existing) {
      const err = new Error("This creator is already on the campaign shortlist");
      err.statusCode = 409;
      throw err;
    }
    const item = {
      _id: `demo_shortlist_${Date.now()}`,
      id: `demo_shortlist_${Date.now()}`,
      ...data,
      isDemoData: true,
      createdAt: new Date()
    };
    this.shortlists.push(item);
    return item;
  }

  removeFromShortlist(campaignId, creatorId) {
    const index = this.shortlists.findIndex(
      (s) => s.campaignId === campaignId && s.creatorId === creatorId
    );
    if (index === -1) return false;
    this.shortlists.splice(index, 1);
    return true;
  }

  // Applications
  getApplications(filters = {}) {
    let list = [...this.applications];
    if (filters.campaignId) {
      list = list.filter((a) => a.campaignId === filters.campaignId);
    }
    if (filters.creatorId) {
      list = list.filter((a) => a.creatorId === filters.creatorId);
    }
    if (filters.brandId) {
      list = list.filter((a) => a.brandId === filters.brandId);
    }
    if (filters.status) {
      list = list.filter((a) => a.status === filters.status);
    }
    return list.map((a) => ({
      ...a,
      campaign: this.findCampaignById(a.campaignId) || null,
      creator: this.findCreatorById(a.creatorId) || null
    }));
  }

  findApplicationById(id) {
    const app = this.applications.find((a) => a._id === id || a.id === id);
    if (!app) return null;
    return {
      ...app,
      campaign: this.findCampaignById(app.campaignId) || null,
      creator: this.findCreatorById(app.creatorId) || null
    };
  }

  createApplication(data) {
    const existing = this.applications.find(
      (a) => a.campaignId === data.campaignId && a.creatorId === data.creatorId
    );
    if (existing) {
      const err = new Error("An application or invitation already exists for this creator and campaign");
      err.statusCode = 409;
      throw err;
    }
    const newApp = {
      _id: `demo_app_${Date.now()}`,
      id: `demo_app_${Date.now()}`,
      deliverableLinks: [],
      revisionComments: [],
      ...data,
      isDemoData: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    this.applications.push(newApp);
    return newApp;
  }

  updateApplication(id, updateData) {
    const index = this.applications.findIndex((a) => a._id === id || a.id === id);
    if (index === -1) return null;
    this.applications[index] = {
      ...this.applications[index],
      ...updateData,
      updatedAt: new Date()
    };
    return this.findApplicationById(id);
  }

  // Conversations
  getConversations(userId = null) {
    if (!userId) return [...this.conversations];
    const userConvs = this.conversations.filter((c) =>
      c.participants.some((p) => p.userId === userId || p.id === userId)
    );
    return userConvs.length > 0 ? userConvs : [...this.conversations];
  }

  findConversationById(id) {
    return this.conversations.find((c) => c._id === id || c.id === id) || null;
  }

  createConversation(data) {
    const newConv = {
      _id: `conv_${Date.now()}`,
      id: `conv_${Date.now()}`,
      campaignId: data.campaignId || "",
      campaignTitle: data.campaignTitle || "",
      participants: data.participants || [],
      lastMessage: {
        text: "",
        senderId: "",
        senderName: "",
        createdAt: new Date()
      },
      unreadCount: 0,
      isDemoData: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    this.conversations.unshift(newConv);
    return newConv;
  }

  // Messages
  getMessages(conversationId) {
    return this.messages.filter((m) => m.conversationId === conversationId);
  }

  createMessage(data) {
    const newMsg = {
      _id: `msg_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      id: `msg_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      conversationId: data.conversationId,
      senderId: data.senderId,
      senderName: data.senderName,
      senderRole: data.senderRole || "brand",
      recipientId: data.recipientId || "",
      text: data.text,
      isSimulatedReply: Boolean(data.isSimulatedReply),
      read: false,
      createdAt: new Date()
    };
    this.messages.push(newMsg);

    // Update conversation lastMessage & updatedAt
    const conv = this.findConversationById(data.conversationId);
    if (conv) {
      conv.lastMessage = {
        text: data.text,
        senderId: data.senderId,
        senderName: data.senderName,
        createdAt: newMsg.createdAt
      };
      conv.updatedAt = new Date();
    }

    return newMsg;
  }

  simulateReply(conversationId, customText = null) {
    const conv = this.findConversationById(conversationId);
    if (!conv) return null;

    const creatorParticipant = conv.participants.find((p) => p.role === "creator") || conv.participants[1] || conv.participants[0];
    const brandParticipant = conv.participants.find((p) => p.role === "brand") || conv.participants[0];

    const replySamples = [
      "Thanks for the prompt directives! I've loaded the camera moves into Runway Gen-3 and will deliver the initial render milestone by tomorrow.",
      "Understood! The condensation droplets and lighting curves are being adjusted to match the 9:16 layout specs.",
      "Great note. I've updated the storyboard frame to emphasize the cold beverage frost texture.",
      "Received! I am finalizing the 4K render and will submit the asset links to the delivery escrow tab."
    ];
    const text = customText || replySamples[Math.floor(Math.random() * replySamples.length)];

    return this.createMessage({
      conversationId,
      senderId: creatorParticipant.userId || creatorParticipant.id,
      senderName: creatorParticipant.name,
      senderRole: "creator",
      recipientId: brandParticipant.userId || brandParticipant.id,
      text,
      isSimulatedReply: true
    });
  }
}

module.exports = new DemoDataService();
