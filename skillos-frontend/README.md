# SkillOS — Frontend Client

The web client for **SkillOS**, an AI-driven learning and skill-tracking platform. Built with React 19 and Vite, providing a fast, responsive interface for learning roadmaps, study sessions, spaced-repetition flashcards, and knowledge notes.

---

## 🛠️ Tech Stack

- **Framework:** React 19
- **Build Tool & Dev Server:** Vite 8
- **Routing:** React Router v7
- **HTTP Client:** Axios (with request/response interceptors & token handling)
- **Data Visualization:** Chart.js & react-chartjs-2
- **Styling:** CSS Modules with responsive variables

---

## 📁 Project Architecture

```
skillos-frontend/
├── public/                 # Static assets
├── src/
│   ├── assets/             # Images, SVGs, and graphics
│   ├── components/         # Reusable UI components
│   │   ├── ErrorBoundary   # Graceful UI failure boundary
│   │   ├── Footer          # Global footer
│   │   ├── Navbar          # Landing navigation bar
│   │   ├── Sidebar         # Responsive, collapsible application sidebar
│   │   └── Topbar          # Application top navigation bar
│   ├── context/            # React context providers (AuthContext)
│   ├── hooks/              # Custom hooks (useAuth)
│   ├── layouts/            # Page layouts (DashboardLayout)
│   ├── pages/              # Primary route views
│   │   ├── AuthPage        # Login and registration view
│   │   ├── DashboardPage   # Student command center & goal overview
│   │   ├── KnowledgePage   # Knowledge vault (notes & flashcards study)
│   │   ├── LandingPage     # Public introduction & features
│   │   └── RoadmapListPage # Learning path timelines & verification
│   ├── routes/             # AppRouter & ProtectedRoute guards
│   ├── services/           # Backend API integration layer
│   │   ├── api.js          # Base Axios instance with auth interceptors
│   │   ├── authService.js  # Authentication endpoints
│   │   └── dashboardService.js # Dashboard data aggregation
│   ├── App.jsx             # Root application component
│   ├── index.css           # Global theme variables & typography
│   └── main.jsx            # Application entry point
├── package.json
└── vite.config.js          # Vite configuration & backend proxy rules
```

---

## 🚀 Getting Started

### Prerequisites

- **Node.js**: v18.0.0 or higher
- **npm**: v9.0.0 or higher

### Installation

```bash
cd skillos-frontend
npm install
```

### Available Scripts

| Command | Description |
| :--- | :--- |
| `npm run dev` | Starts the local Vite development server with HMR at `http://localhost:5173/` |
| `npm run build` | Bundles the application for production into `dist/` |
| `npm run preview` | Locally serves the production build |
| `npm run lint` | Runs ESLint across all source files |

---

## 🔌 API Integration

The frontend connects to the Spring Boot REST backend (`http://localhost:8080`). During local development, API requests directed to `/api/v1` and WebSocket connections at `/ws` are proxied via `vite.config.js`.
