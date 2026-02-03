const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, 'class.db');
const db = new Database(dbPath, { verbose: console.log });

// Initialize tables
db.exec(`
  CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    ip_address TEXT
  );

  CREATE TABLE IF NOT EXISTS submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    filename TEXT,
    code_content TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    feedback_code TEXT,
    feedback_comments TEXT,
    FOREIGN KEY(student_id) REFERENCES students(id)
  );
`);

module.exports = db;
