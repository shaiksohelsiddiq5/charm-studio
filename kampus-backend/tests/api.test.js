const test = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");

// Ensure DEMO_MODE is true for offline unit & integration testing
process.env.DEMO_MODE = "true";
process.env.JWT_SECRET = "test_jwt_secret_kampus_2026";

const { app } = require("../server");

test("Kampus.VC Backend Test Suite", async (t) => {
  let authTokenBrand = "";
  let authTokenCreator = "";
  let testCampaignId = "demo_campaign_1";
  let testCreatorId = "demo_creator_1";

  // ==========================================
  // 1. Health and Discovery Endpoints
  // ==========================================
  await t.test("GET / - Should return API metadata and endpoints map", async () => {
    const res = await request(app).get("/");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.name, "Kampus.VC Backend API");
    assert.ok(res.body.endpoints);
  });

  await t.test("GET /health - Should report server status and database connectivity accurately", async () => {
    const res = await request(app).get("/health");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.status, "UP");
    assert.ok(res.body.database !== undefined);
    assert.equal(res.body.demoMode, true);
  });

  // ==========================================
  // 2. Authentication & Authorization
  // ==========================================
  await t.test("POST /api/auth/register - Should register a new brand user", async () => {
    const uniqueEmail = `brand_${Date.now()}@test.com`;
    const res = await request(app)
      .post("/api/auth/register")
      .send({
        name: "Test Brand User",
        email: uniqueEmail,
        password: "securePassword123",
        role: "brand",
        companyName: "Test Beverage Labs"
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.token);
    assert.equal(res.body.data.user.role, "brand");
    authTokenBrand = res.body.data.token;
  });

  await t.test("POST /api/auth/register - Should fail if password is too short", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({
        name: "Short Pwd",
        email: `short_${Date.now()}@test.com`,
        password: "123",
        role: "creator"
      });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
  });

  await t.test("POST /api/auth/register - Should reject duplicate email", async () => {
    const email = `dup_${Date.now()}@test.com`;
    await request(app)
      .post("/api/auth/register")
      .send({
        name: "First User",
        email,
        password: "password123",
        role: "creator"
      });

    const resDup = await request(app)
      .post("/api/auth/register")
      .send({
        name: "Second User",
        email,
        password: "password123",
        role: "creator"
      });

    assert.equal(resDup.status, 409);
    assert.equal(resDup.body.success, false);
  });

  await t.test("POST /api/auth/login - Should login and return JWT token", async () => {
    const email = `login_${Date.now()}@test.com`;
    await request(app)
      .post("/api/auth/register")
      .send({
        name: "Login User",
        email,
        password: "password123",
        role: "creator"
      });

    const res = await request(app)
      .post("/api/auth/login")
      .send({
        email,
        password: "password123"
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.token);
    authTokenCreator = res.body.data.token;
  });

  await t.test("GET /api/auth/me - Should return current user when authenticated", async () => {
    const res = await request(app)
      .get("/api/auth/me")
      .set("Authorization", `Bearer ${authTokenBrand}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.role, "brand");
  });

  await t.test("GET /api/auth/me - Should reject unauthenticated requests", async () => {
    const res = await request(app).get("/api/auth/me");
    assert.equal(res.status, 401);
    assert.equal(res.body.success, false);
  });

  await t.test("GET /api/auth/demo-accounts - Should return pre-seeded demo accounts for switch-user", async () => {
    const res = await request(app).get("/api/auth/demo-accounts");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
    assert.ok(res.body.data.length >= 4);
    assert.ok(res.body.data.some((a) => a.role === "brand"));
    assert.ok(res.body.data.some((a) => a.role === "creator"));
  });

  // ==========================================
  // 3. Creator Management and Filtering
  // ==========================================
  await t.test("GET /api/creators - Should retrieve list of creators", async () => {
    const res = await request(app).get("/api/creators");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
    assert.ok(res.body.data.length >= 1);
  });

  await t.test("GET /api/creators - Should filter creators by skills and specialization", async () => {
    const res = await request(app)
      .get("/api/creators?skills=Macro Cinematography");

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.some((c) => c.name === "Aria Chen"));
  });

  await t.test("GET /api/creators - Should filter creators by budget max", async () => {
    const res = await request(app).get("/api/creators?budgetMax=1000");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.every((c) => c.price <= 1000));
  });

  await t.test("GET /api/creators/:id - Should return single creator profile", async () => {
    const res = await request(app).get(`/api/creators/${testCreatorId}`);
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.name, "Aria Chen");
    assert.ok(Array.isArray(res.body.data.portfolio));
  });

  await t.test("GET /api/creators/invalid-id - Should handle invalid creator ID", async () => {
    const res = await request(app).get("/api/creators/9999");
    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
  });

  // ==========================================
  // 4. Campaign Management
  // ==========================================
  await t.test("POST /api/campaigns - Should create a campaign with brief requirements", async () => {
    const res = await request(app)
      .post("/api/campaigns")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        title: "Cold Brew Nitro AI Launch",
        campaignDescription: "High-contrast cinematic macro visuals for our organic nitro cold brew can launch.",
        contentTypes: ["Commercial Video", "Reels"],
        requiredSkills: ["AI Video Generation", "Macro Cinematography"],
        preferredAITools: ["Runway Gen-3", "Midjourney v6"],
        desiredStyle: "Hyper-realistic Cinematic",
        budgetMin: 1000,
        budgetMax: 2500,
        deadline: "2026-12-01T00:00:00Z"
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.title, "Cold Brew Nitro AI Launch");
    testCampaignId = res.body.data._id || res.body.data.id;
  });

  await t.test("POST /api/campaigns - Should fail when title or description is missing", async () => {
    const res = await request(app)
      .post("/api/campaigns")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        title: "Incomplete Campaign"
      });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
  });

  await t.test("GET /api/campaigns - Should list campaigns", async () => {
    const res = await request(app).get("/api/campaigns");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
  });

  // ==========================================
  // 5. AI Campaign Brief Builder
  // ==========================================
  await t.test("POST /api/campaigns/ai-brief - Should generate structured campaign brief from raw idea", async () => {
    const res = await request(app)
      .post("/api/campaigns/ai-brief")
      .send({
        prompt: "We are launching an artisanal sparkling iced tea and need cinematic vertical reels."
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.campaignTitle);
    assert.ok(Array.isArray(res.body.data.suggestedVisualStyles));
    assert.ok(Array.isArray(res.body.data.suggestedDeliverables));
    assert.ok(Array.isArray(res.body.data.requiredSkills));
    assert.ok(Array.isArray(res.body.data.preferredAITools));
    assert.ok(Array.isArray(res.body.data.questionsAboutMissingInformation));
  });

  await t.test("POST /api/campaigns/ai-brief - Should reject empty prompt", async () => {
    const res = await request(app)
      .post("/api/campaigns/ai-brief")
      .send({});

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
  });

  // ==========================================
  // 6. AI Creator Matching Engine
  // ==========================================
  await t.test("POST /api/matching/:campaignId - Should calculate transparent scores, breakdown and explanations", async () => {
    const res = await request(app)
      .post(`/api/matching/${testCampaignId}`)
      .send({ limit: 5 });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.matches);
    assert.ok(res.body.data.matches.length > 0);

    const topMatch = res.body.data.matches[0];
    assert.ok(topMatch.matchScore >= 0 && topMatch.matchScore <= 100);
    assert.ok(topMatch.scoreBreakdown.skillsSpecialization);
    assert.ok(topMatch.scoreBreakdown.portfolioRelevance);
    assert.ok(topMatch.scoreBreakdown.contentTypeStyle);
    assert.ok(topMatch.scoreBreakdown.aiTools);
    assert.ok(topMatch.scoreBreakdown.budgetCompatibility);
    assert.ok(topMatch.scoreBreakdown.availabilityDeadline);
    assert.ok(topMatch.explanation.summary);
    assert.ok(Array.isArray(topMatch.explanation.strengths));
  });

  // ==========================================
  // 7. Shortlist Management
  // ==========================================
  await t.test("POST /api/shortlists - Should shortlist a creator for a campaign", async () => {
    const res = await request(app)
      .post("/api/shortlists")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        campaignId: testCampaignId,
        creatorId: "demo_creator_2",
        notes: "Great candidate for cinematic tone."
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
  });

  await t.test("POST /api/shortlists - Should reject duplicate shortlisting", async () => {
    const res = await request(app)
      .post("/api/shortlists")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        campaignId: testCampaignId,
        creatorId: "demo_creator_2"
      });

    assert.equal(res.status, 409);
    assert.equal(res.body.success, false);
  });

  await t.test("GET /api/shortlists/:campaignId - Should get shortlisted creators", async () => {
    const res = await request(app).get(`/api/shortlists/${testCampaignId}`);
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.length >= 1);
  });

  await t.test("GET /api/shortlists/:campaignId/compare - Should return comparison matrix", async () => {
    const res = await request(app).get(`/api/shortlists/${testCampaignId}/compare`);
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data.comparisons));
  });

  await t.test("DELETE /api/shortlists/:campaignId/:creatorId - Should remove shortlisted creator", async () => {
    const res = await request(app)
      .delete(`/api/shortlists/${testCampaignId}/demo_creator_2`)
      .set("Authorization", `Bearer ${authTokenBrand}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
  });

  // ==========================================
  // 8. Applications and Workflow Transitions
  // ==========================================
  let applicationId = "";

  await t.test("POST /api/applications - Should create an application for a creator", async () => {
    const res = await request(app)
      .post("/api/applications")
      .send({
        campaignId: testCampaignId,
        creatorId: "demo_creator_3",
        type: "application",
        pitch: "Excited to bring hybrid diffusion animations to this launch!",
        proposedRate: 1500
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, "applied");
    applicationId = res.body.data._id || res.body.data.id;
  });

  await t.test("PATCH /api/applications/:id/status - Should transition applied -> accepted", async () => {
    const res = await request(app)
      .patch(`/api/applications/${applicationId}/status`)
      .send({ status: "accepted" });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, "accepted");
  });

  await t.test("PATCH /api/applications/:id/status - Should reject invalid transition (accepted -> completed directly)", async () => {
    const res = await request(app)
      .patch(`/api/applications/${applicationId}/status`)
      .send({ status: "completed" });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
  });

  await t.test("POST /api/applications/:id/deliverables - Should submit deliverable links", async () => {
    // Transition to in_progress first
    await request(app)
      .patch(`/api/applications/${applicationId}/status`)
      .send({ status: "in_progress" });

    const res = await request(app)
      .post(`/api/applications/${applicationId}/deliverables`)
      .send({
        deliverableLinks: [
          "https://assets.kampus.vc/deliverables/final_hero_cut.mp4"
        ]
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, "submitted");
  });

  await t.test("POST /api/applications/:id/revisions - Should record revision request and notes", async () => {
    const res = await request(app)
      .post(`/api/applications/${applicationId}/revisions`)
      .send({
        comment: "Please refine the color grading on the condensation particles."
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, "revision_requested");
  });

  // ==========================================
  // 9. Centralized Error Handling
  // ==========================================
  await t.test("GET /api/nonexistent-route - Should return 404 with standard JSON format", async () => {
    const res = await request(app).get("/api/nonexistent-route");
    assert.equal(res.status, 404);
    assert.equal(res.body.success, false);
    assert.ok(res.body.message.includes("not found"));
  });

  // ==========================================
  // 10. Creator Messaging & Conversations
  // ==========================================
  await t.test("GET /api/conversations - Should return list of conversations with participant metadata", async () => {
    const res = await request(app)
      .get("/api/conversations")
      .set("Authorization", `Bearer ${authTokenBrand}`);
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
    assert.ok(res.body.data.length >= 1);
    assert.ok(res.body.data[0].participants.length >= 2);
  });

  await t.test("GET /api/conversations/:id - Should return single conversation by ID", async () => {
    const res = await request(app).get("/api/conversations/conv_1");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.id || res.body.data._id, "conv_1");
  });

  await t.test("GET /api/conversations/:id - Should return 404 for nonexistent conversation", async () => {
    const res = await request(app).get("/api/conversations/nonexistent_conv");
    assert.equal(res.status, 404);
    assert.equal(res.body.success, false);
  });

  await t.test("GET /api/conversations/:id/messages - Should retrieve chronological message history", async () => {
    const res = await request(app).get("/api/conversations/conv_1/messages");
    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
    assert.ok(res.body.data.length >= 2);
    assert.ok(res.body.data[0].text);
  });

  await t.test("POST /api/conversations/:id/messages - Should send a message and associate with authenticated user", async () => {
    const res = await request(app)
      .post("/api/conversations/conv_1/messages")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        text: "Please send the updated 9:16 vertical render for review."
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.text, "Please send the updated 9:16 vertical render for review.");
    assert.ok(res.body.data.senderId);
    assert.ok(res.body.data.createdAt);
  });

  await t.test("POST /api/conversations/:id/messages - Should reject empty message text", async () => {
    const res = await request(app)
      .post("/api/conversations/conv_1/messages")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({
        text: "   "
      });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
    assert.ok(res.body.message.includes("empty"));
  });

  await t.test("POST /api/conversations/:id/simulate-reply - Should generate a simulated creator reply", async () => {
    const res = await request(app)
      .post("/api/conversations/conv_1/simulate-reply")
      .send({
        customText: "Render complete! Checking condensation particle physics in 4K."
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.isSimulatedReply, true);
    assert.equal(res.body.data.text, "Render complete! Checking condensation particle physics in 4K.");
  });

  await t.test("POST /api/conversations/:id/suggest-reply - Should reject unauthorized user not in conversation", async () => {
    const res = await request(app)
      .post("/api/conversations/conv_1/suggest-reply")
      .set("Authorization", `Bearer ${authTokenBrand}`)
      .send({});

    assert.equal(res.status, 403);
    assert.equal(res.body.success, false);
    assert.ok(res.body.message.includes("Unauthorized"));
  });

  await t.test("POST /api/conversations/:id/suggest-reply - Should generate context-aware reply suggestion for participant", async () => {
    // Login as conversation participant (Aura Beverages)
    const loginRes = await request(app)
      .post("/api/auth/login")
      .send({
        email: "brand@aurabev.com",
        password: "password123"
      });
    assert.equal(loginRes.status, 200);
    const participantToken = loginRes.body.data.token;

    const res = await request(app)
      .post("/api/conversations/conv_1/suggest-reply")
      .set("Authorization", `Bearer ${participantToken}`)
      .send({
        prompt: "Acknowledge the styleframe timeline and ask about 9:16 aspect ratio"
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.suggestion);
    assert.ok(typeof res.body.data.suggestion === "string");
    assert.ok(res.body.data.suggestion.length > 5);
    assert.ok(res.body.data.metadata);
    assert.ok(["gemini", "template_fallback"].includes(res.body.data.metadata.source));
  });

  await t.test("POST /api/conversations/:id/suggest-reply - Should return 404 for nonexistent conversation", async () => {
    const res = await request(app)
      .post("/api/conversations/nonexistent_conv/suggest-reply")
      .send({});

    assert.equal(res.status, 404);
    assert.equal(res.body.success, false);
  });
});
