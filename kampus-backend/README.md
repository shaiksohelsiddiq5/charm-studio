# Kampus.VC — AI Content Creator Marketplace Backend

Welcome to the backend service for **Kampus.VC**, an AI-powered marketplace platform connecting commercial brands with elite AI content creators (specializing in AI filmmaking, synthetic food commercials, 3D product visualizations, anime/motion graphics, and viral social media).

Built for hackathons and production scale using **Node.js**, **Express.js**, **MongoDB Atlas**, **Mongoose**, and **Google Gemini 2.5 Flash**.

---

## 🌟 Architecture & Highlights

- **Modular MVC Architecture**: Clean separation of Models, Views/Routes, Controllers, Services, and Middleware.
- **Dual-Mode Engine (Production + Offline DEMO_MODE)**:
  - **Live Mode**: Interacts directly with MongoDB Atlas via Mongoose models.
  - **DEMO_MODE (`DEMO_MODE=true`)**: Activates an in-memory repository with pre-seeded creator personas, campaigns, shortlists, and applications. Ensures full hackathon presentations without blocking on WiFi or MongoDB DNS hiccups!
- **AI Campaign Brief Builder**: Powered by Google Gemini 2.5 Flash (with intelligent heuristic fallback) to transform vague brand ideas into production-ready creative briefs.
- **Explainable AI Creator Matching Engine**:
  - Transparent, deterministic multi-factor scoring (0–100%)
  - Evidence-based explanations and gap detection
  - Configurable weights across skills (30%), portfolio (25%), style (15%), AI tools (10%), budget (10%), and availability (10%).
- **Campaign & Creator Workflow**: Tracks applications, invitations, deliverable submissions, and revisions.
- **Zero Plaintext Passwords**: Bcrypt password hashing and JWT role-based access control (`brand` and `creator`).

---

## 📁 Project Structure

```text
kampus-backend/
├── server.js                      # Application entrypoint & HTTP server
├── package.json                   # Dependencies, scripts, and configuration
├── .env                           # Environment variables (git-ignored)
├── .env.example                   # Environment variable template
├── .gitignore                     # Git ignore rules
│
├── config/
│   └── db.js                      # MongoDB Atlas connection & health reporter
│
├── models/
│   ├── User.js                    # User authentication & roles (brand/creator)
│   ├── Creator.js                 # Creator profiles, portfolio, tools, pricing
│   ├── Campaign.js                # Campaign briefs, budgets, deliverables
│   ├── Shortlist.js               # Brand creator shortlists & comparisons
│   └── Application.js             # Project proposals, deliverables & revisions
│
├── routes/
│   ├── authRoutes.js              # /api/auth
│   ├── creatorRoutes.js           # /api/creators
│   ├── campaignRoutes.js          # /api/campaigns
│   ├── matchingRoutes.js          # /api/matching
│   ├── shortlistRoutes.js         # /api/shortlists
│   └── applicationRoutes.js       # /api/applications
│
├── controllers/
│   ├── authController.js          # Registration, login, JWT token issuance
│   ├── creatorController.js       # Creator CRUD, search, and filtering
│   ├── campaignController.js      # Campaign CRUD & AI brief builder
│   ├── matchingController.js      # Explainable AI creator matching
│   ├── shortlistController.js     # Shortlisting & side-by-side creator matrix
│   └── applicationController.js   # Project status transitions & deliverables
│
├── middleware/
│   ├── authMiddleware.js          # JWT verification & role authorization
│   └── errorMiddleware.js         # Centralized error handling & 404s
│
├── services/
│   ├── aiBriefService.js          # Gemini 2.5 Flash brief builder
│   ├── creatorMatchingService.js  # Multi-factor ranking engine
│   ├── explanationService.js      # Natural-language evidence explanations
│   └── demoDataService.js         # Offline in-memory repository for DEMO_MODE
│
├── utils/
│   ├── scoring.js                 # Weighted scoring math & breakdowns
│   └── validation.js              # Email, ObjectId, and transition validation
│
├── scripts/
│   └── seed.js                    # Database seed script for MongoDB Atlas
│
└── tests/
    └── api.test.js                # 31 automated tests with node:test & supertest
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Node.js** (v18 or higher recommended, tested on Node v25)
- **npm** (comes with Node.js)

### 2. Installation
Clone the repository and install dependencies:
```bash
cd kampus-backend
npm install
```

### 3. Environment Variable Setup
Copy the template file to `.env`:
```bash
cp .env.example .env
```

Edit `.env` to customize settings:
```env
PORT=5001
MONGODB_URI=mongodb+srv://<user>:<password>@cluster0.ux2x2pq.mongodb.net/?appName=Cluster0
JWT_SECRET=your_super_secret_jwt_key_here
GEMINI_API_KEY=your_gemini_api_key_here
DEMO_MODE=true
CLIENT_ORIGIN=http://localhost:3000
```

> **Note on `DEMO_MODE`**:
> - If `DEMO_MODE=true`, the backend boots with full in-memory demo data, allowing you to demonstrate the entire platform immediately offline!
> - When your MongoDB connection is online, set `DEMO_MODE=false` to use live MongoDB Atlas.

---

## 🏃 Running the Application

### Start Development Server (with Auto-Reload)
```bash
npm run dev
```

### Start Production Server
```bash
npm start
```

The server will listen on `http://localhost:5001`.

Check the health status:
```bash
curl http://localhost:5001/health
```

---

## 🧪 Running Automated Tests

Run the built-in test suite (executes 31 automated unit and integration tests):
```bash
npm test
```

### Test Coverage Highlights
- API Health & Status Reporting
- Brand & Creator Registration and Login
- JWT Authorization & Ownership Checks
- Creator Search, Filtering, and Pagination
- Campaign CRUD Operations
- AI Campaign Brief Generation
- Weighted Creator Matching & Score Breakdown
- Shortlist Addition, Duplication Prevention, and Matrix Comparison
- Application Workflow Transitions (`applied` ➔ `accepted` ➔ `in_progress` ➔ `submitted`)
- Centralized 404 & Error Responses

---

## 📖 API Documentation & Sample Requests

All API responses follow a consistent JSON format:
```json
{
  "success": true,
  "message": "Descriptive status message",
  "data": {}
}
```

### 1. System Health
- **`GET /health`**
  ```bash
  curl http://localhost:5001/health
  ```
  Returns:
  ```json
  {
    "success": true,
    "status": "UP",
    "uptime": 12.34,
    "database": {
      "connected": false,
      "state": "disconnected",
      "error": "..."
    },
    "demoMode": true,
    "aiServiceConfigured": false
  }
  ```

---

### 2. Authentication & Authorization
- **`POST /api/auth/register`**
  ```bash
  curl -X POST http://localhost:5001/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Acme Brand",
      "email": "brand@acme.com",
      "password": "securePassword123",
      "role": "brand",
      "companyName": "Acme Foods"
    }'
  ```

- **`POST /api/auth/login`**
  ```bash
  curl -X POST http://localhost:5001/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "email": "brand@acme.com",
      "password": "securePassword123"
    }'
  ```

- **`GET /api/auth/me`**
  ```bash
  curl http://localhost:5001/api/auth/me \
    -H "Authorization: Bearer <TOKEN>"
  ```

---

### 3. Creator Management
- **`GET /api/creators`**
  Query parameters:
  - `search`: Fuzzy text search (name, bio, skills)
  - `skills`: Filter by skill (e.g. `Macro Cinematography`)
  - `specialization`: Filter by specialization (e.g. `AI Food Advertising`)
  - `aiTools`: Filter by tool (e.g. `Runway Gen-3`)
  - `budgetMax`: Filter creators within budget (e.g. `2000`)
  - `availability`: `available`, `busy`, or `unavailable`
  - `sort`: `price_asc` or `price_desc`
  - `page`: Page number (default: 1)
  - `limit`: Page size (default: 20)

  ```bash
  curl "http://localhost:5001/api/creators?skills=Color%20Grading&budgetMax=2000"
  ```

- **`GET /api/creators/:id`**
  ```bash
  curl http://localhost:5001/api/creators/demo_creator_1
  ```

- **`POST /api/creators`**
  ```bash
  curl -X POST http://localhost:5001/api/creators \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Sarah Connor",
      "email": "sarah@ai-visuals.io",
      "bio": "Cyberpunk and tech visuals specialist",
      "specialization": ["AI Filmmaking"],
      "skills": ["Prompt Engineering", "VFX"],
      "aiTools": ["Midjourney v6", "Runway Gen-3"],
      "price": 1200
    }'
  ```

---

### 4. AI Campaign Brief Builder
- **`POST /api/campaigns/ai-brief`**
  Turns a raw prompt into a structured campaign brief using Gemini (or intelligent fallback).

  ```bash
  curl -X POST http://localhost:5001/api/campaigns/ai-brief \
    -H "Content-Type: application/json" \
    -d '{
      "prompt": "We are launching a cold drink and need cinematic Instagram videos."
    }'
  ```

  Sample Response:
  ```json
  {
    "success": true,
    "message": "AI Campaign brief generated successfully",
    "data": {
      "campaignTitle": "AI Campaign: We are launching a cold drink...",
      "productDescription": "We are launching a cold drink...",
      "contentRequirements": [
        "High resolution vertical video (1080x1920) optimized for mobile feeds"
      ],
      "suggestedVisualStyles": ["Macro Product Shots", "Slow-motion Condensation Droplets"],
      "suggestedDeliverables": [
        "1x 15-30s High-impact Hero Video (9:16 vertical)"
      ],
      "requiredSkills": ["Prompt Engineering", "Color Grading"],
      "preferredAITools": ["Runway Gen-3", "Midjourney v6"],
      "suggestedTimeline": "1 to 2 weeks for first cuts and revisions",
      "questionsAboutMissingInformation": [
        "What is your exact target budget range for creator payouts?",
        "What is your firm campaign launch deadline?"
      ]
    }
  }
  ```

---

### 5. AI Creator Matching Engine
- **`POST /api/matching/:campaignId`**
  Evaluates all creators against the campaign using transparent multi-factor weighted scoring.

  ```bash
  curl -X POST http://localhost:5001/api/matching/demo_campaign_1 \
    -H "Content-Type: application/json" \
    -d '{ "limit": 3 }'
  ```

  Sample Output:
  ```json
  {
    "success": true,
    "data": {
      "campaignId": "demo_campaign_1",
      "campaignTitle": "Apex Glacial Chill - Cinematic Commercial Campaign",
      "matches": [
        {
          "creator": {
            "name": "Aria Chen",
            "displayName": "Aria Chen - AI Culinary Visualist",
            "price": 1800
          },
          "matchScore": 95,
          "scoreBreakdown": {
            "skillsSpecialization": { "score": 100, "weight": 0.3, "contribution": 30 },
            "portfolioRelevance": { "score": 90, "weight": 0.25, "contribution": 22.5 },
            "contentTypeStyle": { "score": 85, "weight": 0.15, "contribution": 12.8 },
            "aiTools": { "score": 100, "weight": 0.1, "contribution": 10 },
            "budgetCompatibility": { "score": 100, "weight": 0.1, "contribution": 10 },
            "availabilityDeadline": { "score": 100, "weight": 0.1, "contribution": 10 }
          },
          "explanation": {
            "fitRating": "Strong Match",
            "summary": "Aria Chen is a strong match (95% match) for Apex Glacial Chill. Directly matches required competencies: AI Video Generation, Macro Cinematography, Color Grading.",
            "strengths": [
              "Directly matches required competencies",
              "Portfolio contains 1 relevant project(s)"
            ]
          }
        }
      ]
    }
  }
  ```

---

### 6. Shortlist & Comparisons
- **`POST /api/shortlists`**: Shortlist a creator.
  ```bash
  curl -X POST http://localhost:5001/api/shortlists \
    -H "Content-Type: application/json" \
    -d '{
      "campaignId": "demo_campaign_1",
      "creatorId": "demo_creator_2",
      "notes": "Excellent candidate for sci-fi atmosphere"
    }'
  ```

- **`GET /api/shortlists/:campaignId/compare`**: Side-by-side comparison matrix.
  ```bash
  curl http://localhost:5001/api/shortlists/demo_campaign_1/compare
  ```

- **`DELETE /api/shortlists/:campaignId/:creatorId`**: Remove creator from shortlist.
  ```bash
  curl -X DELETE http://localhost:5001/api/shortlists/demo_campaign_1/demo_creator_2
  ```

---

### 7. Applications & Campaign Workflow
- **`POST /api/applications`**: Apply or invite
  ```bash
  curl -X POST http://localhost:5001/api/applications \
    -H "Content-Type: application/json" \
    -d '{
      "campaignId": "demo_campaign_1",
      "creatorId": "demo_creator_3",
      "type": "application",
      "pitch": "Excited to bring high-energy animations to this product drop."
    }'
  ```

- **`PATCH /api/applications/:id/status`**: Transition status
  Allowed transitions:
  - `applied` / `invited` ➔ `accepted`, `rejected`
  - `accepted` ➔ `in_progress`
  - `in_progress` ➔ `submitted`
  - `submitted` ➔ `revision_requested`, `approved`
  - `revision_requested` ➔ `submitted`
  - `approved` ➔ `completed`

  ```bash
  curl -X PATCH http://localhost:5001/api/applications/demo_app_1/status \
    -H "Content-Type: application/json" \
    -d '{ "status": "submitted" }'
  ```

- **`POST /api/applications/:id/deliverables`**: Submit work links
  ```bash
  curl -X POST http://localhost:5001/api/applications/demo_app_1/deliverables \
    -H "Content-Type: application/json" \
    -d '{
      "deliverableLinks": ["https://assets.kampus.vc/deliverables/cut_v1.mp4"]
    }'
  ```

- **`POST /api/applications/:id/revisions`**: Request revision with feedback
  ```bash
  curl -X POST http://localhost:5001/api/applications/demo_app_1/revisions \
    -H "Content-Type: application/json" \
    -d '{
      "comment": "Please boost lighting on the beverage can label."
    }'
  ```

---

## 🛠️ Database Setup & Seeding

When your MongoDB Atlas cluster is online:
1. Ensure `MONGODB_URI` is correctly populated in `.env`.
2. Run the seed script:
   ```bash
   npm run seed
   ```
This will populate demo creators across the 5 target specializations:
- **AI Food Advertising Creators** (e.g., Aria Chen)
- **AI Filmmakers** (e.g., Marcus Vance)
- **AI Animators** (e.g., Elena Rostova)
- **Product Visualization Specialists** (e.g., David Kim)
- **Social Media Content Creators** (e.g., Chloe Bennett)

---

## 💡 Troubleshooting & Known Limitations

1. **MongoDB Atlas DNS Failure (`querySrv ECONNREFUSED`)**:
   - **Cause**: Some local ISP DNS servers fail to resolve `_mongodb._tcp` SRV records for Atlas clusters.
   - **Solution**: Keep `DEMO_MODE=true` in `.env`. The backend runs completely offline with the built-in in-memory demo data repository. Alternatively, change your local DNS to `8.8.8.8` (Google) or `1.1.1.1` (Cloudflare).
2. **Gemini API Key**:
   - If `GEMINI_API_KEY` is not provided in `.env`, the brief builder and matching explanations automatically fallback to the built-in deterministic heuristic engine. No crashes will occur.
3. **Port Conflict**:
   - If port `5001` is already in use by AirPlay on macOS, set `PORT=5002` in `.env`.

---

## 🎓 Second-Year CSE Concept Summary

- **JWT (JSON Web Tokens)**: Stateless token sent in the `Authorization: Bearer <token>` header. Contains encoded user ID and role, verified with `JWT_SECRET`.
- **Bcrypt**: Adaptive salted cryptographic hashing function that protects passwords from rainbow table attacks.
- **Explainable AI (XAI)**: Rather than treating AI as a "black box" that outputs arbitrary numbers, Kampus.VC uses mathematical multi-factor scoring with itemized contribution percentages so brands know *why* each creator was chosen.
- **RESTful State Machine**: The Application lifecycle enforces valid state transitions to prevent illogical jumps (e.g., you cannot jump from `applied` to `completed` without review).
