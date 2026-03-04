# 🗺️ Treasure Hunt App — Full Stack

A cross-platform treasure hunt & puzzle solving app built with **Flutter**, **Spring Boot (Kotlin)**, **MongoDB**, and **Angular**.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Client Layer                       │
│  📱 Flutter App (iOS + Android)   🅰️ Angular Admin  │
│     Player + In-App Admin UI         Web Admin UI   │
└───────────────┬────────────────────────┬────────────┘
                │  REST + JWT            │
┌───────────────▼────────────────────────▼────────────┐
│          🍃 Spring Boot Kotlin API (:8080)           │
│  JWT Auth · Role-based (ADMIN / PLAYER) · CORS      │
└───────────────────────────┬─────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────┐
│              🍃 MongoDB (:27017)                     │
│  users · puzzles · clues · game_progress            │
└─────────────────────────────────────────────────────┘
```

## 📦 Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| Admin Web UI | Angular 17 + Angular Material |
| Backend API | Spring Boot 3.2 + Kotlin |
| Database | MongoDB 7.0 |
| Auth | JWT (jjwt) + BCrypt |
| State (Flutter) | Riverpod |
| Navigation (Flutter) | go_router |
| HTTP (Flutter) | Dio |
| DB UI (Dev) | Mongo Express |
| Container | Docker + Docker Compose |

---

## 🚀 Quick Start (Local with Docker)

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (for mobile dev)
- Node.js 20+ (for Angular dev)
- JDK 17+ (for backend dev)

### 1. Start everything with Docker Compose

```bash
git clone <repo>
cd treasure-hunt
docker-compose up --build
```

### 2. Services running at:

| Service | URL |
|---|---|
| 🍃 Spring Boot API | http://localhost:8080 |
| 🅰️ Angular Admin UI | http://localhost:4200 |
| 🍃 Mongo Express (DB UI) | http://localhost:8081 |
| 🍃 MongoDB | mongodb://localhost:27017 |

### 3. Default Admin Login

```
Email:    admin@treasurehunt.com
Password: admin123
```

---

## 🔑 API Reference

### Auth
```
POST /api/auth/register   → Register new user
POST /api/auth/login      → Login, returns JWT
```

### Puzzles (Player)
```
GET  /api/puzzles          → List all active puzzles
GET  /api/puzzles/:id      → Get puzzle details
GET  /api/puzzles/:id/clues → Get clues (answers hidden)
```

### Game (Player)
```
POST /api/game/start?puzzleId=   → Start/resume game
POST /api/game/answer            → Submit answer
GET  /api/game/hint/:progressId  → Get hint for current clue
```

### Admin (ADMIN role required)
```
GET    /api/admin/puzzles              → All puzzles
POST   /api/admin/puzzles              → Create puzzle
PUT    /api/admin/puzzles/:id          → Update puzzle
DELETE /api/admin/puzzles/:id          → Delete puzzle + clues

GET    /api/admin/puzzles/:id/clues   → All clues for puzzle
POST   /api/admin/puzzles/:id/clues   → Add clue
PUT    /api/admin/clues/:id            → Update clue
DELETE /api/admin/clues/:id            → Delete clue
```

---

## 📁 Project Structure

```
treasure-hunt/
├── docker-compose.yml          # Local dev stack
├── mongo-init/
│   └── init.js                 # DB seed (admin user + sample puzzle)
├── diagrams/
│   ├── architecture.mermaid    # System architecture
│   └── sequence.mermaid        # Auth + game flow sequences
│
├── backend/                    # Spring Boot Kotlin API
│   ├── Dockerfile
│   ├── build.gradle.kts
│   └── src/main/kotlin/com/treasurehunt/
│       ├── TreasureHuntApplication.kt
│       ├── model/Models.kt      # User, Puzzle, Clue, GameProgress
│       ├── repository/          # Spring Data MongoDB repos
│       ├── service/Services.kt  # AuthService, PuzzleService, GameService
│       ├── controller/          # REST Controllers
│       ├── security/            # JWT util + filter
│       └── config/              # SecurityConfig (CORS, role rules)
│
├── flutter-app/                 # Flutter iOS + Android app
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart            # App entry + GoRouter setup
│       ├── models/models.dart   # Puzzle, Clue, GameProgress DTOs
│       ├── services/services.dart # ApiService, AuthService, PuzzleService
│       └── screens/
│           ├── screens.dart     # Login, PuzzleList, GameScreen
│           └── admin_screens.dart # AdminDashboard, ClueEditor, PuzzleEditor
│
└── angular-admin/               # Angular admin web UI
    ├── Dockerfile
    ├── nginx.conf
    ├── package.json
    └── src/app/
        ├── models/models.ts     # TypeScript interfaces
        ├── services/services.ts # ApiService, AuthService, PuzzleService
        ├── components/          # Login, Dashboard, ClueEditor
        └── app.routes.ts        # Routes + auth/admin guards
```

---

## 🔐 Role-Based Access

```
PLAYER role:
  ✓ Browse & play puzzles
  ✓ Submit answers, request hints
  ✓ View own game progress
  ✗ Cannot access /api/admin/**

ADMIN role:
  ✓ All PLAYER permissions
  ✓ Create / Edit / Delete puzzles
  ✓ Manage clues (full CRUD)
  ✓ View all game progress
  ✓ Access Admin Dashboard (Angular + Flutter in-app)
```

---

## 🧪 Development (Without Docker)

### Backend
```bash
cd backend
# Start MongoDB locally first (or use cloud Atlas URI)
./gradlew bootRun
```

### Angular Admin
```bash
cd angular-admin
npm install
npm start
# Visit http://localhost:4200
```

### Flutter App
```bash
cd flutter-app
flutter pub get
# Update baseUrl in lib/services/services.dart to your machine IP
flutter run
```

---

## 🗃️ MongoDB Collections

### users
```json
{ "email": "string", "passwordHash": "bcrypt", "role": "ADMIN|PLAYER", "displayName": "string" }
```

### puzzles
```json
{ "title": "string", "description": "string", "difficulty": "EASY|MEDIUM|HARD|EXPERT", "active": true, "tags": [] }
```

### clues
```json
{ "puzzleId": "ref", "orderIndex": 0, "type": "TEXT|IMAGE|GPS|QR_CODE|RIDDLE|AUDIO", "content": "string", "answer": "string", "hint": "optional" }
```

### game_progress
```json
{ "userId": "ref", "puzzleId": "ref", "status": "IN_PROGRESS|COMPLETED", "currentClueIndex": 0, "hintsUsed": 0 }
```

---

## 🔮 Future Enhancements

- [ ] WebSocket for real-time multiplayer
- [ ] Leaderboard & scoring system
- [ ] Push notifications (FCM)
- [ ] GPS-based clue validation (PostGIS or MongoDB geo)
- [ ] QR code scanning in Flutter (mobile_scanner)
- [ ] Image upload for clues (S3/MinIO)
- [ ] OAuth2 / Social login
- [ ] Analytics dashboard in Angular

---

## 📝 Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MONGO_URI` | `mongodb://localhost:27017/treasurehunt` | MongoDB connection string |
| `JWT_SECRET` | dev key | Min 256-bit secret for JWT signing |
| `SPRING_PROFILES_ACTIVE` | default | `docker` for containerized setup |
