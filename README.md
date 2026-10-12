# ✨ Charm Studio — CREATOR STUDIO

### AI-Powered Creator Marketplace

Discover creators. Build campaigns. Create together.

<p align="center">
  <strong>Connecting brands with AI creators through intelligent discovery, recommendations, and collaboration.</strong>
</p>

---

## 🌐 Quick Links

- 🚀 **Live Website:** [Open Charm Studio](https://charmstudio11.netlify.app)
- ⚙️ **Backend API:** [Backend Server](https://charm-studio-backend.onrender.com)
- 💻 **GitHub Repository:** [Charm Studio Source Code](https://github.com/shaiksohelsiddiq5/charm-studio)

---

## 📌 About the Project

**Charm Studio** is an AI-powered creator marketplace that connects brands and creative agencies with AI content creators.

The platform helps brands discover suitable creators, generate advertising campaign briefs, evaluate creative portfolios, compare creator profiles, and manage campaign workflows.

Creators can showcase their skills, AI tools, portfolios, content styles, pricing, and availability to help brands find suitable collaboration opportunities.

By combining artificial intelligence with an intuitive interface, Charm Studio aims to simplify creator discovery and brand collaboration.

---

## 🚀 Key Features

### 🏢 For Brands

- Create and manage advertising campaigns.
- Generate campaign briefs using Google Gemini AI.
- Discover AI content creators.
- Search creators by skills, tools, style, and name.
- Receive AI-assisted creator recommendations.
- Compare creator profiles and portfolios.
- Evaluate creator skills, pricing, and availability.
- Shortlist suitable creators.
- Manage campaign applications and progress.

### 🎨 For Creators

- Create and update creator profiles.
- Showcase creative portfolios.
- Add skills and specializations.
- List AI tools and content types.
- Share portfolio links.
- Specify pricing and availability.
- Discover campaign opportunities.

### 🤖 AI-Powered Capabilities

- AI campaign brief generation.
- Intelligent creator matching.
- Explainable creator recommendations.
- AI-assisted messaging and reply suggestions.
- Campaign requirement analysis.
- Fallback responses when AI services are unavailable.

*The availability of individual features depends on their implementation and configuration.*

---

## 🛠️ Technology Stack

| Component | Technology |
|---|---|
| Frontend | Flutter |
| Programming Language | Dart |
| State Management | Provider |
| API Communication | HTTP |
| Backend | Node.js |
| Backend Framework | Express.js |
| Database | MongoDB |
| Database ODM | Mongoose |
| Artificial Intelligence | Google Gemini API |
| API Architecture | REST APIs |
| Version Control | Git |
| Code Hosting | GitHub |
| Frontend Deployment | Netlify |
| Backend Deployment | Render |

---

## 🏗️ System Architecture

```text
                    CHARM STUDIO
                    CREATOR STUDIO
                          |
                 +-------------------+
                 | Flutter Frontend  |
                 |   Web Interface   |
                 +-------------------+
                          |
                       REST API
                          |
                 +-------------------+
                 |   Node.js Server  |
                 |    Express.js     |
                 +-------------------+
                          |
                +---------+---------+
                |                   |
       +----------------+   +----------------+
       |    MongoDB     |   | Google Gemini  |
       |    Database    |   |   AI Services  |
       +----------------+   +----------------+
```

---

## 📁 Project Structure

```text
charm-studio/
|
├── frontend_flutter/
|   ├── lib/
|   ├── web/
|   ├── test/
|   └── pubspec.yaml
|
├── kampus-backend/
|   ├── models/
|   ├── routes/
|   ├── controllers/
|   ├── services/
|   ├── scripts/
|   ├── tests/
|   ├── utils/
|   ├── server.js
|   └── package.json
|
├── .gitignore
└── README.md
```

---

## 🧠 AI Creator Matching Engine

Charm Studio uses a weighted scoring approach to recommend creators based on campaign requirements.

### Matching Criteria

| Matching Factor | Weight |
|---|---:|
| Skills Match | 30% |
| Portfolio Relevance | 25% |
| Content Type and Style | 15% |
| AI Tool Compatibility | 10% |
| Budget Compatibility | 10% |
| Availability Compatibility | 10% |
| **Total** | **100%** |

### How Creator Matching Works

1. A brand creates a campaign brief.
2. The campaign requirements are identified.
3. Creator profiles are evaluated against those requirements.
4. The matching service calculates compatibility scores.
5. Creators are ranked according to their matching scores.
6. Brands can review the recommendations and shortlist suitable creators.

The matching score supports the discovery process and does not guarantee campaign success.

---

## ⚙️ Getting Started

Follow these instructions to run Charm Studio locally.

### Prerequisites

Install the following:

- Flutter SDK
- Dart SDK
- Node.js
- npm
- MongoDB database
- Git
- Google Gemini API key for Gemini-powered features

### Step 1: Clone the Repository

```bash
git clone https://github.com/shaiksohelsiddiq5/charm-studio.git
```

Navigate into the project:

```bash
cd charm-studio
```

### Step 2: Configure the Backend

Navigate to the backend directory:

```bash
cd kampus-backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file inside the `kampus-backend` directory.

Example configuration:

```env
PORT=5001
MONGODB_URI=your_mongodb_connection_string
GEMINI_API_KEY=your_gemini_api_key
JWT_SECRET=your_jwt_secret
```

**Important:** These are example variable names. Check the backend source code and use the exact environment variable names required by your application.

Never publish your actual API keys, database credentials, or `.env` file.

### Step 3: Start the Backend

Run the command configured in your backend's `package.json`.

If the project defines an `npm start` script, use:

```bash
npm start
```

The backend should start on the configured port.

### Step 4: Configure the Frontend

Open another terminal and navigate to the frontend:

```bash
cd frontend_flutter
```

Install Flutter dependencies:

```bash
flutter pub get
```

Ensure the frontend API base URL points to your running backend.

### Step 5: Run the Frontend

Run the Flutter application in Chrome:

```bash
flutter run -d chrome
```

Charm Studio should open in your browser.

---

## 🌍 Deployment

Charm Studio can be deployed using separate frontend and backend services.

### Frontend Deployment — Netlify

Build the Flutter Web application:

```bash
cd frontend_flutter
flutter pub get
flutter build web --release
```

The generated website files will be available at:

```text
frontend_flutter/build/web/
```

Deploy the generated files using Netlify.

**Live Website:** Replace `YOUR_NETLIFY_DEPLOYED_URL` at the top of this README with your actual Netlify deployment URL.

### Backend Deployment — Render

Deploy the Node.js backend as a web service.

Typical configuration:

- **Root Directory:** `kampus-backend`
- **Build Command:** `npm install`
- **Start Command:** Use the appropriate start script from `package.json`.
- **Environment Variables:** Configure the database connection, authentication secrets, and Gemini API key.

Update the Flutter API base URL to the deployed backend address before rebuilding and redeploying the frontend.

**Backend API:** Replace `YOUR_RENDER_DEPLOYED_URL` at the top of this README with your actual Render service URL.

---

## 🔐 Security

Charm Studio should follow these security practices:

- Store sensitive credentials in environment variables.
- Exclude `.env` files from Git.
- Never expose API keys or database connection strings.
- Configure CORS appropriately for deployed environments.
- Protect restricted endpoints with authentication and authorization.
- Avoid exposing sensitive information in application logs.
- Review AI-generated content before using it in important workflows.

---

## 🎯 Project Objectives

The primary objectives of Charm Studio are to:

- Simplify AI creator discovery.
- Help brands find creators suitable for their campaigns.
- Improve creator recommendations through intelligent matching.
- Support campaign brief creation with AI.
- Make creator portfolios easier to evaluate.
- Streamline communication between brands and creators.
- Provide a unified platform for creator collaboration.

---

## 🔮 Future Enhancements

Potential future improvements include:

- Advanced creator analytics.
- Campaign performance dashboards.
- Enhanced portfolio previews.
- Real-time messaging and notifications.
- Improved recommendation models.
- Campaign collaboration tools.
- Detailed reporting and engagement analytics.

---

## 👨‍💻 Project Information

| Detail | Description |
|---|---|
| Project Name | Charm Studio |
| Tagline | CREATOR STUDIO |
| Category | AI-Powered Creator Marketplace |
| Frontend | Flutter |
| Backend | Node.js and Express.js |
| Database | MongoDB |
| AI Integration | Google Gemini API |
| Repository | GitHub |

---

## 🔗 Important Links

- **GitHub Repository:** https://github.com/shaiksohelsiddiq5/charm-studio
- **Live Website:** Add your deployed Netlify URL.
- **Backend API:** Add your deployed Render URL.

---

<p align="center">
  <strong>✨ Charm Studio — CREATOR STUDIO ✨</strong>
  <br><br>
  Discover creators. Build campaigns. Create together.
</p>
