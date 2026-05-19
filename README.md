# Employee Task Management System

A full-stack **Employee Task Management** application built for the Flutter Full Stack Developer assessment.

| Layer | Technology |
|-------|------------|
| Mobile | Flutter (Provider, Dio, GoRouter) |
| Backend | FastAPI |
| Database | MySQL 8.0 |
| Auth | JWT (Bearer token) |

---

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [How to Run](#how-to-run)
- [Test Credentials](#test-credentials)
- [API Configuration](#api-configuration)
- [API Endpoints](#api-endpoints)
- [Build Release APK](#build-release-apk)
- [Deploy Backend (Render)](#deploy-backend-render)
- [Troubleshooting](#troubleshooting)

---

## Features

### Flutter mobile app
- Login & register with validation
- Dashboard: list tasks, search, filter by status, pull-to-refresh
- Create / edit / view / delete tasks
- Task fields: title, description, priority, due date, status
- Secure JWT storage (`flutter_secure_storage`)

### FastAPI backend
- User registration & login
- JWT-protected task CRUD (per user)
- Admin routes (list users/tasks, update status, delete)
- Auto-seeded demo data on startup

---

## Project Structure

```
untitled2/
├── backend/                          # Python FastAPI API
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example                  # Environment variable template
│   └── app/
│       ├── main.py                   # App entry, CORS, routers, DB seed
│       ├── config.py                 # Settings (DATABASE_URL, JWT secret)
│       ├── database.py               # SQLAlchemy engine & session
│       ├── models.py                 # User & Task ORM models
│       ├── schemas.py                # Pydantic request/response models
│       ├── auth.py                   # Password hashing & JWT helpers
│       ├── dependencies.py           # get_current_user, get_admin_user
│       └── routers/
│           ├── auth.py               # /auth/register, /login, /me
│           ├── tasks.py              # /tasks CRUD
│           └── admin.py              # /admin/* (bonus)
│
├── lib/                              # Flutter source (clean architecture)
│   ├── main.dart                     # App entry point
│   ├── app.dart                      # Providers, theme, GoRouter routes
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart       # Base URL (debug vs production)
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Colors, Material theme
│   │   └── utils/
│   │       ├── validators.dart       # Form validation helpers
│   │       └── api_exception.dart    # API error type
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   └── task_model.dart
│   │   ├── services/
│   │   │   └── api_client.dart       # Dio HTTP client + token interceptor
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       └── task_repository.dart
│   └── presentation/
│       ├── providers/
│       │   ├── auth_provider.dart    # Auth state (Provider)
│       │   └── task_provider.dart    # Task list & CRUD state
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   ├── home_screen.dart      # Dashboard
│       │   ├── task_form_screen.dart # Add / edit task
│       │   └── task_detail_screen.dart
│       └── widgets/
│           ├── custom_text_field.dart
│           ├── task_card.dart
│           ├── status_filter_chips.dart
│           └── loading_overlay.dart
│
├── android/                          # Android Gradle (Kotlin DSL)
├── ios/
├── docker-compose.yml                # MySQL + API for local dev
├── render.yaml                       # Render deployment blueprint
└── pubspec.yaml
```

---

## Architecture

```
┌─────────────────┐     HTTP (JSON)      ┌─────────────────┐     SQL      ┌────────┐
│  Flutter App    │ ◄──────────────────► │  FastAPI        │ ◄──────────► │ MySQL  │
│  (Provider)     │   JWT Bearer token   │  (SQLAlchemy)   │              │        │
└─────────────────┘                      └─────────────────┘              └────────┘
       │                                           │
       │  Screens → Providers → Repositories       │  Routers → Models → DB
       │           → ApiClient (Dio)               │
       └───────────────────────────────────────────┘
```

**Flutter layers**
- **Presentation** — UI, `ChangeNotifier` providers, navigation
- **Data** — API calls, JSON models, repositories
- **Core** — theme, config, shared utilities

**Backend layers**
- **Routers** — HTTP endpoints & validation
- **Dependencies** — JWT auth injection
- **Models / Schemas** — database & API shapes

---

## Prerequisites

| Tool | Version |
|------|---------|
| [Flutter](https://flutter.dev) | 3.6+ (3.41+ recommended) |
| [Docker](https://www.docker.com/) & Docker Compose | Latest |
| Android Studio / emulator **or** physical device | — |

Optional (run API without Docker):
- Python 3.12+
- Local or remote MySQL instance

---

## How to Run

### Step 1 — Start backend & database

From the project root:

```bash
docker compose up --build
```

Wait until both containers are healthy. Verify:

```bash
curl http://127.0.0.1:8000/health
# Expected: {"status":"ok"}
```

| Service | URL |
|---------|-----|
| API | http://127.0.0.1:8000 |
| Swagger docs | http://127.0.0.1:8000/docs |
| MySQL (host) | `localhost:3306` (user: `taskuser`, pass: `taskpass`, db: `taskdb`) |

Stop services:

```bash
docker compose down
```

### Step 2 — Run the Flutter app

```bash
flutter pub get
flutter run
```

In **debug mode**, the app picks the API URL automatically:

| Target | Default API URL |
|--------|-----------------|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator / desktop | `http://127.0.0.1:8000` |

**Physical Android device** — use your PC’s LAN IP:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Find your IP: `hostname -I` or `ip addr`.

### Step 3 — Log in

Use the [test credentials](#test-credentials) below, or register a new account from the app.

---

## Test Credentials

Seeded automatically when `SEED_TEST_USER=true` (default in Docker).

| Role | Email | Password |
|------|-------|----------|
| Employee | `employee@test.com` | `password123` |
| Admin | `admin@test.com` | `admin123` |

---

## API Configuration

Base URL is defined in `lib/core/config/api_config.dart`.

**Priority:**
1. `--dart-define=API_BASE_URL=...` (highest)
2. Debug defaults (`10.0.2.2` on Android, `127.0.0.1` elsewhere)
3. Production default: `https://employee-task-api.onrender.com`

Examples:

```bash
# Android emulator (explicit)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Physical phone on same Wi‑Fi
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000

# Release APK pointing to deployed API
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.onrender.com
```

> **Note:** `http://0.0.0.0:8000` works in a browser on your PC only. The mobile app must use `10.0.2.2`, `127.0.0.1`, or your LAN IP — never `0.0.0.0`.

---

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | No | Health check |
| POST | `/auth/register` | No | Register user |
| POST | `/auth/login` | No | Login, returns JWT |
| GET | `/auth/me` | Yes | Current user profile |
| GET | `/tasks` | Yes | List tasks (`?search=&status=`) |
| POST | `/tasks` | Yes | Create task |
| GET | `/tasks/{id}` | Yes | Get task |
| PUT | `/tasks/{id}` | Yes | Update task |
| DELETE | `/tasks/{id}` | Yes | Delete task |
| GET | `/admin/users` | Admin | List all users |
| GET | `/admin/tasks` | Admin | List all tasks |
| PATCH | `/admin/tasks/{id}/status` | Admin | Update task status |
| DELETE | `/admin/users/{id}` | Admin | Delete user |
| DELETE | `/admin/tasks/{id}` | Admin | Delete task |

**Task enums**
- Priority: `Low`, `Medium`, `High`
- Status: `Pending`, `In Progress`, `Completed`

---

## Build Release APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-DEPLOYED-API.onrender.com
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

Debug APK:

```bash
flutter build apk --debug
```

---

## Deploy Backend (Render)

1. Push the repository to GitHub.
2. Provision a **MySQL** database (PlanetScale, Aiven, Railway, etc.).
3. On [Render](https://render.com): **New → Blueprint** and select `render.yaml`, or create a **Web Service** using `backend/Dockerfile`.
4. Set environment variables:

   | Variable | Example |
   |----------|---------|
   | `DATABASE_URL` | `mysql+pymysql://user:pass@host:3306/taskdb` |
   | `SECRET_KEY` | long random string |
   | `SEED_TEST_USER` | `true` |

5. After deploy, build the APK with your live URL (see [Build Release APK](#build-release-apk)).

Copy `backend/.env.example` for all supported variables when running locally without Docker.

---

## Run Backend Without Docker (optional)

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

export DATABASE_URL="mysql+pymysql://taskuser:taskpass@localhost:3306/taskdb"
export SECRET_KEY="dev-secret-key"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

MySQL must be running and the database created before starting the API.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Login shows “Something went wrong” | App is hitting the wrong API URL. Use `flutter run` in debug (auto URL) or pass `--dart-define=API_BASE_URL=http://10.0.2.2:8000` on emulator. |
| Cannot connect from phone | Use PC LAN IP, same Wi‑Fi, and `docker compose` port `8000` exposed. |
| `curl localhost:8000/health` fails | Run `docker compose up --build` and check `docker compose logs api`. |
| API container restarts | Rebuild after dependency changes: `docker compose up --build`. Ensure `email-validator` is in `requirements.txt`. |
| Android v1 embedding error | Ensure `android/settings.gradle.kts`, `android/build.gradle.kts`, and `android/app/build.gradle.kts` exist. |
| Gradle / AGP version warnings | Project uses Gradle 8.14 and AGP 8.11.1 — run `flutter clean` then `flutter run`. |

---

## Tech Stack Summary

- **Flutter:** Provider, Dio, GoRouter, flutter_secure_storage, intl
- **Backend:** FastAPI, Uvicorn, SQLAlchemy, PyMySQL, Pydantic, python-jose, passlib
- **Infra:** Docker Compose, Render (optional)

---

## License

Assessment / educational project.
