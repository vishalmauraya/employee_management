from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_admin_user
from app.models import Task, User
from app.schemas import AdminTaskStatusUpdate, MessageResponse, TaskResponse, UserResponse

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/users", response_model=list[UserResponse])
def list_users(db: Session = Depends(get_db), _: User = Depends(get_admin_user)):
    return db.query(User).order_by(User.id.asc()).all()


@router.get("/tasks", response_model=list[TaskResponse])
def list_all_tasks(db: Session = Depends(get_db), _: User = Depends(get_admin_user)):
    return db.query(Task).order_by(Task.id.desc()).all()


@router.patch("/tasks/{task_id}/status", response_model=TaskResponse)
def update_task_status(
    task_id: int,
    payload: AdminTaskStatusUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(get_admin_user),
):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    task.status = payload.status
    db.commit()
    db.refresh(task)
    return task


@router.delete("/users/{user_id}", response_model=MessageResponse)
def delete_user(user_id: int, db: Session = Depends(get_db), admin: User = Depends(get_admin_user)):
    if user_id == admin.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot delete your own account")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    db.delete(user)
    db.commit()
    return MessageResponse(message="User deleted successfully")


@router.delete("/tasks/{task_id}", response_model=MessageResponse)
def delete_task(task_id: int, db: Session = Depends(get_db), _: User = Depends(get_admin_user)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    db.delete(task)
    db.commit()
    return MessageResponse(message="Task deleted successfully")
