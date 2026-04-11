-- EMOTRACE Database Schema (SQLite)
-- Simplified MVP with 5 essential tables

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mood_entries (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  mood_score INTEGER NOT NULL CHECK(mood_score >= 1 AND mood_score <= 10),
  emotion_tags TEXT,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE emotion_tags (
  id TEXT PRIMARY KEY,
  mood_entry_id TEXT NOT NULL,
  tag_name TEXT NOT NULL,
  FOREIGN KEY (mood_entry_id) REFERENCES mood_entries(id)
);

CREATE TABLE settings (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  theme TEXT DEFAULT 'dark',
  daily_reminder_enabled INTEGER DEFAULT 1,
  reminder_time TEXT DEFAULT '20:00',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  jwt_token TEXT NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Indexes for performance
CREATE INDEX idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX idx_mood_entries_created_at ON mood_entries(created_at);
CREATE INDEX idx_emotion_tags_mood_entry_id ON emotion_tags(mood_entry_id);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);

-- Predefined emotion options
INSERT INTO emotion_tags (id, tag_name) VALUES 
('anxious', 'Anxious'),
('calm', 'Calm'),
('stressed', 'Stressed'),
('happy', 'Happy'),
('sad', 'Sad'),
('grateful', 'Grateful'),
('overwhelmed', 'Overwhelmed'),
('focused', 'Focused');
