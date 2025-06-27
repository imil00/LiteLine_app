-- assets/database/init_db.sql

-- Tabel Pengguna (Users)
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    phone_number TEXT UNIQUE,
    profile_picture_url TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Obrolan (Chats) - untuk menyimpan informasi grup atau obrolan pribadi
CREATE TABLE IF NOT EXISTS chats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT, -- Nama untuk grup chat, null untuk chat pribadi
    type TEXT NOT NULL DEFAULT 'private', -- 'private' atau 'group'
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Partisipan Obrolan (ChatParticipants) - menghubungkan pengguna dengan obrolan
CREATE TABLE IF NOT EXISTS chat_participants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chat_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    joined_at TEXT DEFAULT CURRENT_TIMESTAMP,
    role TEXT DEFAULT 'member', -- 'member', 'admin'
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (chat_id, user_id) -- Memastikan setiap pengguna hanya satu kali dalam satu obrolan
);

-- Tabel Pesan (Messages)
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chat_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT NOT NULL DEFAULT 'text', -- 'text', 'image', 'video', 'audio'
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    is_read INTEGER DEFAULT 0, -- 0 for false, 1 for true
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Kontak (Contacts) - untuk menyimpan daftar kontak pengguna
CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL, -- Pengguna yang memiliki kontak ini
    contact_user_id INTEGER NOT NULL, -- Pengguna yang menjadi kontak
    alias TEXT, -- Nama alias untuk kontak
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (user_id, contact_user_id) -- Memastikan kontak unik untuk setiap pengguna
);

-- Tabel Notifikasi (Notifications)
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    type TEXT NOT NULL, -- 'new_message', 'friend_request', etc.
    content TEXT NOT NULL,
    is_read INTEGER DEFAULT 0, -- 0 for false, 1 for true
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indeks untuk mempercepat query
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages (chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages (sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_chat_id ON chat_participants (chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON chat_participants (user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_user_id ON contacts (user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_contact_user_id ON contacts (contact_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);