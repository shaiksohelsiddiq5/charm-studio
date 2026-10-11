const { GoogleGenAI } = require("@google/genai");

/**
 * Deterministic heuristic reply generator for offline/fallback mode
 */
const generateFallbackReply = ({ role, otherName, lastMessageText, campaignTitle }) => {
  const isBrand = role === "brand";
  const lastLower = (lastMessageText || "").toLowerCase();

  if (isBrand) {
    if (lastLower.includes("rate") || lastLower.includes("price") || lastLower.includes("cost") || lastLower.includes("quote")) {
      return {
        suggestion: `Hi ${otherName}, thanks for providing the quote! The pricing aligns with our campaign budget. Could you confirm if this includes 2 rounds of minor revisions on the final cuts?`,
        metadata: {
          source: "template_fallback",
          model: "heuristic-rules",
          note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
        }
      };
    }

    if (lastLower.includes("timeline") || lastLower.includes("tomorrow") || lastLower.includes("deadline") || lastLower.includes("delivery")) {
      return {
        suggestion: `Sounds great, ${otherName}! That timeline works well for our launch schedule. Looking forward to reviewing the first styleframes.`,
        metadata: {
          source: "template_fallback",
          model: "heuristic-rules",
          note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
        }
      };
    }

    if (lastLower.includes("moodboard") || lastLower.includes("styleframe") || lastLower.includes("render") || lastLower.includes("asset")) {
      return {
        suggestion: `Hi ${otherName}, thank you for sharing! The visual direction looks promising. Let's make sure the brand logo placement and lighting closely match our brief.`,
        metadata: {
          source: "template_fallback",
          model: "heuristic-rules",
          note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
        }
      };
    }

    return {
      suggestion: `Hi ${otherName}, thank you for the update on ${campaignTitle || "our campaign"}. Please proceed with the next milestone and keep us posted on progress!`,
      metadata: {
        source: "template_fallback",
        model: "heuristic-rules",
        note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
      }
    };
  } else {
    // Creator replying to brand
    if (lastLower.includes("timeline") || lastLower.includes("deadline") || lastLower.includes("when")) {
      return {
        suggestion: `Hi ${otherName}, I can deliver the initial draft cuts within 3 business days, with final 4K renders ready by your deadline. Does that timing work for your review team?`,
        metadata: {
          source: "template_fallback",
          model: "heuristic-rules",
          note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
        }
      };
    }

    if (lastLower.includes("revision") || lastLower.includes("change") || lastLower.includes("feedback")) {
      return {
        suggestion: `Got it! I will incorporate that feedback into the next generation pass in Runway Gen-3 and upload the updated preview for your review shortly.`,
        metadata: {
          source: "template_fallback",
          model: "heuristic-rules",
          note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
        }
      };
    }

    return {
      suggestion: `Hi ${otherName}, thank you for reaching out! I've reviewed the requirements for ${campaignTitle || "the project"} and would love to collaborate. I have prepped my AI workflows for this visual style.`,
      metadata: {
        source: "template_fallback",
        model: "heuristic-rules",
        note: "Generated via context-aware heuristic template (Gemini API key offline or quota limit)."
      }
    };
  }
};

/**
 * Generate a context-aware suggested reply using Google Gemini
 *
 * @param {Object} options
 * @param {Object} options.conversation - The conversation object
 * @param {Array} options.messages - Recent message history
 * @param {Object} [options.campaign] - Associated campaign (if any)
 * @param {Object} options.currentUser - Current active user ({ id, name, role })
 * @param {string} [options.userPrompt] - Optional user guidance/intent for the reply
 * @returns {Promise<{ suggestion: string, metadata: Object }>}
 */
const generateSuggestedReply = async ({
  conversation,
  messages = [],
  campaign = null,
  currentUser = { role: "brand", name: "User" },
  userPrompt = ""
}) => {
  const currentRole = currentUser.role || "brand";
  const participants = conversation?.participants || [];
  const otherParticipant = participants.find(
    (p) => (p.userId || p.id || "") !== (currentUser.id || currentUser._id || "")
  ) || { name: "Collaborator", role: currentRole === "brand" ? "creator" : "brand" };

  const otherName = otherParticipant.name || "Collaborator";
  const campaignTitle = campaign?.title || conversation?.campaignTitle || "AI Content Campaign";

  // Last message from the other participant
  const otherMessages = messages.filter(
    (m) => (m.senderId || "") !== (currentUser.id || currentUser._id || "")
  );
  const lastOtherMessage = otherMessages.length > 0 ? otherMessages[otherMessages.length - 1] : null;
  const lastMessageText = lastOtherMessage ? lastOtherMessage.text : (messages.length > 0 ? messages[messages.length - 1].text : "");

  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey || apiKey.trim() === "") {
    return generateFallbackReply({
      role: currentRole,
      otherName,
      lastMessageText,
      campaignTitle
    });
  }

  try {
    const ai = new GoogleGenAI({ apiKey });

    // Format recent chat history (up to last 6 messages)
    const recentHistory = messages.slice(-6).map((m) => {
      const isSender = (m.senderId || "") === (currentUser.id || currentUser._id || "");
      const speakerName = isSender ? `${currentUser.name} (${currentRole})` : `${m.senderName || otherName} (${m.senderRole || otherParticipant.role})`;
      return `${speakerName}: "${m.text}"`;
    }).join("\n");

    const systemInstruction = `You are an AI Communications Assistant for Kampus.VC, a marketplace connecting commercial brands with elite AI content creators (using Runway Gen-3, Midjourney v6, Kling, FLUX, etc.).
Your job is to draft a single professional, concise, and courteous suggested message reply for ${currentUser.name} (acting as ${currentRole}) to send to ${otherName} (${otherParticipant.role}).

Context:
- Campaign: "${campaignTitle}"
- Current User: ${currentUser.name} (Role: ${currentRole})
- Recipient: ${otherName} (Role: ${otherParticipant.role})
${userPrompt ? `- User's Intent / Instruction: "${userPrompt}"` : ""}

Rules:
1. Provide ONLY the suggested reply text. Do NOT wrap in quotes, do NOT include explanations, greetings like "Here is a suggestion:", or markdown fences.
2. Keep the reply focused, respectful, and brief (1 to 3 sentences).
3. If the user is a brand, maintain a decisive, professional client tone (milestones, deliverables, visual feedback, timeline).
4. If the user is a creator, maintain an enthusiastic, capable professional tone (technical workflows, turnarounds, deliverable formats).
5. Never agree to free work or disclose proprietary API keys.`;

    const userMessage = `Recent Conversation History:\n${recentHistory || `No prior messages. Starting new conversation about "${campaignTitle}".`}\n\nLatest Message from ${otherName}:\n"${lastMessageText || "Let's connect on this project."}"\n\nGenerate the suggested reply:`;

    const generatePromise = ai.models.generateContent({
      model: "gemini-3.8-flash",
      contents: [
        { role: "user", parts: [{ text: `${systemInstruction}\n\n${userMessage}` }] }
      ]
    });

    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error("Gemini API call timed out after 4000ms")), 4000)
    );

    const response = await Promise.race([generatePromise, timeoutPromise]);

    const replyText = response.text ? response.text.trim() : "";

    if (replyText && replyText.length > 5) {
      // Clean any accidental surrounding quotation marks
      const cleaned = replyText.replace(/^["']|["']$/g, "").trim();
      return {
        suggestion: cleaned,
        metadata: {
          source: "gemini",
          model: "gemini-3.8-flash"
        }
      };
    } else {
      return generateFallbackReply({
        role: currentRole,
        otherName,
        lastMessageText,
        campaignTitle
      });
    }
  } catch (error) {
    console.warn("Gemini suggested reply generation failed, using fallback:", error.message);
    const fallback = generateFallbackReply({
      role: currentRole,
      otherName,
      lastMessageText,
      campaignTitle
    });
    fallback.metadata.note = `AI service unavailable (${error.message}). Providing heuristic reply.`;
    return fallback;
  }
};

module.exports = {
  generateSuggestedReply,
  generateFallbackReply
};
