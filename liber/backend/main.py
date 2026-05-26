from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr
from typing import Optional, List
import sqlite3
import hashlib
import secrets
import os

app = FastAPI(title="BookShelf API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer(auto_error=False)
DB_PATH = "bookshelf.db"

# ── Database ──────────────────────────────────────────────────────────────────

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            token TEXT
        );
        CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT NOT NULL,
            cover_url TEXT DEFAULT '',
            content TEXT DEFAULT '',
            genre TEXT DEFAULT 'General'
        );
        CREATE TABLE IF NOT EXISTS user_books (
            user_id INTEGER,
            book_id INTEGER,
            is_favorite INTEGER DEFAULT 0,
            progress REAL DEFAULT 0.0,
            PRIMARY KEY (user_id, book_id)
        );
    """)
    # Seed books if empty
    c.execute("SELECT COUNT(*) FROM books")
    if c.fetchone()[0] == 0:
        books = [
            ("The Silent Forest", "Elena Marsh", "", PROLOGUE_TEXT, "Fantasy"),
            ("Neon Horizons", "J. Carvalho", "", PROLOGUE_TEXT, "Sci-Fi"),
            ("Cartas ao Vento", "Ana Lima", "", PROLOGUE_TEXT, "Romance"),
            ("O Último Mapa", "Pedro Santos", "", PROLOGUE_TEXT, "Adventure"),
            ("A Sombra do Farol", "Carlos Melo", "", PROLOGUE_TEXT, "Mystery"),
            ("Espelhos Partidos", "Luana Costa", "", PROLOGUE_TEXT, "Drama"),
        ]
        c.executemany(
            "INSERT INTO books (title, author, cover_url, content, genre) VALUES (?,?,?,?,?)",
            books
        )
    conn.commit()
    conn.close()

PROLOGUE_TEXT = """PROLOGUE

When my parents made me to leave the town I used to live in, I always trusted finally on it. I didn't expect the actually arriving in the village, the stretching trees like a giant brush strokes on our walls. Color was there. But had the flung riding up after a few minutes, finding all the distance and shone between the far trees. But me? None would pass before I was able to end myself back together. Different.

Back I was.

The only one who had disappeared to some of the parking grove, old times hopes there from a trusted condition; nevertheless, yet acting, it was so security and easy until where we settled. The only one entering the door was there or nothing to pass before me to stand with some other tray of homogenous. Head would find the place for me.

When they picked up the pieces, the areas that the continual speakers quartet had for years known me, who had myself forward me, the years there after many times, they would go for this matter a take, eventually started to all resemble.

The village was unlike anything I had imagined. Stone walls covered in moss, narrow paths that wound between ancient trees, the smell of earth and rain permanent in the air. This was home now, whether I accepted it or not.

I unpacked slowly, letting each object settle into its new place as if asking it permission. The wooden shelf. The brass lamp. The three books I could not leave behind. They looked out of place here, too bright, too modern, but they were mine, and that was enough.

Outside the window, the forest breathed. I could hear it, a low constant sound, like something very old deciding whether to pay attention."""

# ── Auth helpers ──────────────────────────────────────────────────────────────

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: sqlite3.Connection = Depends(get_db)
):
    if not credentials:
        raise HTTPException(status_code=401, detail="Not authenticated")
    user = db.execute(
        "SELECT * FROM users WHERE token = ?", (credentials.credentials,)
    ).fetchone()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return dict(user)

# ── Schemas ───────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    confirm_password: str

class ProgressUpdate(BaseModel):
    progress: float

# ── Auth routes ───────────────────────────────────────────────────────────────

@app.post("/auth/login")
def login(req: LoginRequest, db: sqlite3.Connection = Depends(get_db)):
    user = db.execute(
        "SELECT * FROM users WHERE email = ? AND password_hash = ?",
        (req.email, hash_password(req.password))
    ).fetchone()
    if not user:
        raise HTTPException(status_code=401, detail="Email ou senha incorretos")
    token = secrets.token_hex(32)
    db.execute("UPDATE users SET token = ? WHERE id = ?", (token, user["id"]))
    db.commit()
    return {
        "token": token,
        "user": {"id": user["id"], "name": user["name"], "email": user["email"]}
    }

@app.post("/auth/register", status_code=201)
def register(req: RegisterRequest, db: sqlite3.Connection = Depends(get_db)):
    if req.password != req.confirm_password:
        raise HTTPException(status_code=400, detail="Senhas não conferem")
    existing = db.execute("SELECT id FROM users WHERE email = ?", (req.email,)).fetchone()
    if existing:
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    token = secrets.token_hex(32)
    db.execute(
        "INSERT INTO users (name, email, password_hash, token) VALUES (?,?,?,?)",
        (req.name, req.email, hash_password(req.password), token)
    )
    db.commit()
    user = db.execute("SELECT * FROM users WHERE email = ?", (req.email,)).fetchone()
    return {
        "token": token,
        "user": {"id": user["id"], "name": user["name"], "email": user["email"]}
    }

@app.post("/auth/logout")
def logout(current_user=Depends(get_current_user), db: sqlite3.Connection = Depends(get_db)):
    db.execute("UPDATE users SET token = NULL WHERE id = ?", (current_user["id"],))
    db.commit()
    return {"message": "Logout realizado"}

# ── Books routes ──────────────────────────────────────────────────────────────

@app.get("/books")
def get_books(
    search: Optional[str] = None,
    current_user=Depends(get_current_user),
    db: sqlite3.Connection = Depends(get_db)
):
    if search:
        books = db.execute(
            "SELECT * FROM books WHERE title LIKE ? OR author LIKE ? OR genre LIKE ?",
            (f"%{search}%", f"%{search}%", f"%{search}%")
        ).fetchall()
    else:
        books = db.execute("SELECT * FROM books").fetchall()

    result = []
    for book in books:
        ub = db.execute(
            "SELECT * FROM user_books WHERE user_id = ? AND book_id = ?",
            (current_user["id"], book["id"])
        ).fetchone()
        result.append({
            **dict(book),
            "is_favorite": bool(ub["is_favorite"]) if ub else False,
            "progress": ub["progress"] if ub else 0.0,
        })
    return result

@app.get("/books/favorites")
def get_favorites(
    current_user=Depends(get_current_user),
    db: sqlite3.Connection = Depends(get_db)
):
    books = db.execute("""
        SELECT b.*, ub.is_favorite, ub.progress
        FROM books b
        JOIN user_books ub ON b.id = ub.book_id
        WHERE ub.user_id = ? AND ub.is_favorite = 1
    """, (current_user["id"],)).fetchall()
    return [dict(b) for b in books]

@app.post("/books/{book_id}/favorite")
def toggle_favorite(
    book_id: int,
    current_user=Depends(get_current_user),
    db: sqlite3.Connection = Depends(get_db)
):
    ub = db.execute(
        "SELECT * FROM user_books WHERE user_id = ? AND book_id = ?",
        (current_user["id"], book_id)
    ).fetchone()
    if ub:
        new_val = 0 if ub["is_favorite"] else 1
        db.execute(
            "UPDATE user_books SET is_favorite = ? WHERE user_id = ? AND book_id = ?",
            (new_val, current_user["id"], book_id)
        )
    else:
        db.execute(
            "INSERT INTO user_books (user_id, book_id, is_favorite) VALUES (?,?,1)",
            (current_user["id"], book_id)
        )
    db.commit()
    return {"message": "Favorito atualizado"}

@app.put("/books/{book_id}/progress")
def update_progress(
    book_id: int,
    req: ProgressUpdate,
    current_user=Depends(get_current_user),
    db: sqlite3.Connection = Depends(get_db)
):
    ub = db.execute(
        "SELECT * FROM user_books WHERE user_id = ? AND book_id = ?",
        (current_user["id"], book_id)
    ).fetchone()
    if ub:
        db.execute(
            "UPDATE user_books SET progress = ? WHERE user_id = ? AND book_id = ?",
            (req.progress, current_user["id"], book_id)
        )
    else:
        db.execute(
            "INSERT INTO user_books (user_id, book_id, progress) VALUES (?,?,?)",
            (current_user["id"], book_id, req.progress)
        )
    db.commit()
    return {"message": "Progresso salvo"}

@app.get("/health")
def health():
    return {"status": "ok"}

# ── Startup ───────────────────────────────────────────────────────────────────
init_db()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)