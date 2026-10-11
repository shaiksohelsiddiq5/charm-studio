const { GoogleGenAI } = require("@google/genai");

/**
 * Validates the structured output for the campaign brief
 */
const validateBriefOutput = (brief) => {
  if (!brief || typeof brief !== "object") return false;

  const requiredFields = [
    "campaignTitle",
    "productDescription",
    "contentRequirements",
    "suggestedVisualStyles",
    "suggestedDeliverables",
    "requiredSkills",
    "preferredAITools",
    "suggestedTimeline",
    "questionsAboutMissingInformation"
  ];

  for (const field of requiredFields) {
    if (!brief[field]) return false;
  }

  // Ensure arrays are arrays
  if (
    !Array.isArray(brief.contentRequirements) ||
    !Array.isArray(brief.suggestedVisualStyles) ||
    !Array.isArray(brief.suggestedDeliverables) ||
    !Array.isArray(brief.requiredSkills) ||
    !Array.isArray(brief.preferredAITools) ||
    !Array.isArray(brief.questionsAboutMissingInformation)
  ) {
    return false;
  }

  return true;
};

/**
 * Deterministic fallback generator for when Gemini API key is missing or offline
 */
const generateFallbackBrief = (promptText) => {
  const text = (promptText || "").toLowerCase();

  let productName = "Featured Product / Service";
  let productDesc = promptText;
  let visualStyles = ["Photorealistic", "Cinematic Lighting", "Modern Minimalist"];
  let deliverables = [
    "1x 15-30s High-impact Hero Video (9:16 vertical)",
    "2x 10s Social Cuts for Stories/Reels",
    "3x High-resolution Static Visuals"
  ];
  let skills = ["Prompt Engineering", "AI Video Generation", "Color Grading", "Sound Design"];
  let tools = ["Midjourney", "Runway Gen-3", "Luma Dream Machine", "Topaz Video AI"];

  if (text.includes("drink") || text.includes("beverage") || text.includes("food")) {
    productName = "Beverage / Food Launch";
    visualStyles = ["Macro Product Shots", "Slow-motion Condensation Droplets", "Vibrant Commercial Grade"];
    tools = ["Midjourney v6", "Runway Gen-3", "Magnific AI", "Premiere Pro"];
  } else if (text.includes("fashion") || text.includes("clothing") || text.includes("apparel")) {
    productName = "Fashion & Apparel";
    visualStyles = ["Editorial High-Fashion", "Dynamic Movement & Fabric Flow", "Runway Aesthetics"];
    tools = ["Midjourney", "Kling AI", "FLUX.1", "Photoshop AI"];
  } else if (text.includes("tech") || text.includes("software") || text.includes("app")) {
    productName = "Tech / Digital Product";
    visualStyles = ["Futuristic 3D Renders", "Holographic UI Accents", "Sleek Dark Mode"];
    tools = ["Blender AI", "FLUX.1", "Runway Gen-3", "ElevenLabs"];
  }

  return {
    campaignTitle: `AI Campaign: ${promptText.slice(0, 40).trim()}...`,
    productDescription: productDesc,
    contentRequirements: [
      "High resolution vertical video (1080x1920) optimized for mobile feeds",
      "Seamless motion transitions without uncanny morphing artifacts",
      "Original royalty-free sound design and audio sync"
    ],
    suggestedVisualStyles: visualStyles,
    suggestedDeliverables: deliverables,
    requiredSkills: skills,
    preferredAITools: tools,
    suggestedTimeline: "1 to 2 weeks for first cuts and revisions",
    questionsAboutMissingInformation: [
      "What is your exact target budget range for creator payouts?",
      "Who is your specific target demographic (e.g. Gen-Z, working professionals, regional focus)?",
      "What is your firm campaign launch deadline?",
      "Are there specific brand guidelines, color palettes, or vector logos that must be incorporated?"
    ],
    metadata: {
      source: "template_fallback",
      note: "Generated via structured heuristic engine (Gemini API key not configured or offline)."
    }
  };
};

/**
 * Transforms a raw brand idea into a structured campaign brief using Gemini
 */
const generateCampaignBrief = async (ideaPrompt) => {
  if (!ideaPrompt || typeof ideaPrompt !== "string" || ideaPrompt.trim().length === 0) {
    throw new Error("Brand campaign idea prompt is required");
  }

  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey || apiKey.trim() === "") {
    return generateFallbackBrief(ideaPrompt);
  }

  try {
    const ai = new GoogleGenAI({ apiKey });

    const systemInstruction = `You are an expert AI Campaign Strategist for Kampus.VC, a marketplace connecting commercial brands with elite AI content creators.
Your task is to transform a rough brand idea into a structured, highly actionable campaign brief.
RULES:
1. Return valid JSON only.
2. Clearly distinguish AI suggestions from confirmed brand requirements.
3. Do NOT invent or assume the brand's actual budget, demographic audience statistics, or campaign deadline. Instead, include relevant inquiries about them in "questionsAboutMissingInformation".
4. Ensure the JSON strictly has these keys:
- "campaignTitle": string
- "productDescription": string
- "contentRequirements": array of strings
- "suggestedVisualStyles": array of strings
- "suggestedDeliverables": array of strings
- "requiredSkills": array of strings
- "preferredAITools": array of strings (e.g. Midjourney, Runway Gen-3, Kling, FLUX, ElevenLabs)
- "suggestedTimeline": string
- "questionsAboutMissingInformation": array of strings`;

    const userPrompt = `Brand Idea: "${ideaPrompt}"\n\nGenerate the complete structured JSON brief.`;

    const generatePromise = ai.models.generateContent({
      model: "gemini-3.8-flash",
      contents: [
        { role: "user", parts: [{ text: `${systemInstruction}\n\n${userPrompt}` }] }
      ],
      config: {
        responseMimeType: "application/json"
      }
    });

    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error("Gemini API call timed out after 4000ms")), 4000)
    );

    const response = await Promise.race([generatePromise, timeoutPromise]);

    const responseText = response.text ? response.text.trim() : "";
    let parsed;

    try {
      parsed = JSON.parse(responseText);
    } catch (parseErr) {
      // If wrapped in markdown code fence, clean it
      const cleaned = responseText.replace(/```json\s*/gi, "").replace(/```\s*$/gi, "").trim();
      parsed = JSON.parse(cleaned);
    }

    if (validateBriefOutput(parsed)) {
      parsed.metadata = {
        source: "gemini",
        model: "gemini-3.8-flash"
      };
      return parsed;
    } else {
      console.warn("Gemini output failed validation schema, using fallback brief.");
      return generateFallbackBrief(ideaPrompt);
    }
  } catch (error) {
    console.error("Gemini API Brief generation failed:", error.message);
    // Provide graceful fallback
    const fallback = generateFallbackBrief(ideaPrompt);
    fallback.metadata.note = `AI service unavailable (${error.message}). Providing heuristic structured brief.`;
    return fallback;
  }
};

module.exports = {
  generateCampaignBrief,
  validateBriefOutput,
  generateFallbackBrief
};
