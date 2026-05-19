from contextlib import asynccontextmanager
from datetime import date, timedelta

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.auth import get_password_hash
from app.config import settings
from app.database import Base, SessionLocal, engine
from app.models import Task, TaskPriority, TaskStatus, User
from app.routers import admin, auth, tasks


def seed_database():
    db = SessionLocal()
    try:
        if db.query(User).filter(User.email == "employee@test.com").first():
            return

        user = User(
            name="Test Employee",
            email="employee@test.com",
            hashed_password=get_password_hash("password123"),
        )
        admin_user = User(
            name="Admin User",
            email="admin@test.com",
            hashed_password=get_password_hash("admin123"),
            is_admin=True,
        )
        db.add_all([user, admin_user])
        db.commit()
        db.refresh(user)

        sample_tasks = [
            Task(
                user_id=user.id,
                title="Complete project documentation",
                description="Write API docs and README for the assessment project.",
                priority=TaskPriority.HIGH,
                due_date=date.today() + timedelta(days=2),
                status=TaskStatus.IN_PROGRESS,
            ),
            Task(
                user_id=user.id,
                title="Team standup meeting",
                description="Daily sync with the development team.",
                priority=TaskPriority.MEDIUM,
                due_date=date.today() + timedelta(days=1),
                status=TaskStatus.PENDING,
            ),
            Task(
                user_id=user.id,
                title="Review pull requests",
                description="Review and merge pending PRs.",
                priority=TaskPriority.LOW,
                due_date=date.today() - timedelta(days=1),
                status=TaskStatus.COMPLETED,
            ),
        ]
        db.add_all(sample_tasks)
        db.commit()
    finally:
        db.close()


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(bind=engine)
    if settings.seed_test_user:
        seed_database()
    yield


app = FastAPI(
    title="Employee Task Management API",
    description="JWT-authenticated task management for employees",
    version="1.0.0",
    lifespan=lifespan,
)

origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins if origins != ["*"] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(tasks.router)
app.include_router(admin.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
