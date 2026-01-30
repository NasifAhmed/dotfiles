const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const db = require('./db');

const app = express();
const PORT = 3000;
const upload = multer({ storage: multer.memoryStorage() }); // Store files in memory to read text

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../public')));

// === API ROUTES ===

// 1. Student Signup/Login
app.post('/api/login', (req, res) => {
    const { name, student_id } = req.body;
    if (!name || !student_id) return res.status(400).json({ error: 'Missing fields' });

    try {
        const insert = db.prepare('INSERT INTO students (name, student_id, ip_address) VALUES (?, ?, ?) ON CONFLICT(student_id) DO UPDATE SET ip_address = ?');
        insert.run(name, student_id, req.ip, req.ip);

        const student = db.prepare('SELECT * FROM students WHERE student_id = ?').get(student_id);
        res.json({ success: true, student });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// 2. Submit Code (Text or File)
app.post('/api/submit', upload.single('codeFile'), (req, res) => {
    const { student_id_db, codeText } = req.body;
    let codeContent = codeText;
    let filename = 'submission.txt';

    if (req.file) {
        codeContent = req.file.buffer.toString('utf-8');
        filename = req.file.originalname;
    }

    if (!codeContent) return res.status(400).json({ error: 'No code provided' });

    try {
        const stmt = db.prepare('INSERT INTO submissions (student_id, filename, code_content) VALUES (?, ?, ?)');
        stmt.run(student_id_db, filename, codeContent);
        res.json({ success: true, message: 'Code submitted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Submission failed' });
    }
});

// 3. Get Student Submissions (For student to check status/feedback)
app.get('/api/student/submissions/:id', (req, res) => {
    try {
        const stmt = db.prepare('SELECT * FROM submissions WHERE student_id = ? ORDER BY timestamp DESC');
        const submissions = stmt.all(req.params.id);
        res.json(submissions);
    } catch (err) {
        res.status(500).json({ error: 'Error fetching submissions' });
    }
});

// 4. Teacher: List All Submissions
app.get('/api/teacher/submissions', (req, res) => {
    try {
        const stmt = db.prepare(`
            SELECT s.*, st.name, st.student_id as student_identifier 
            FROM submissions s 
            JOIN students st ON s.student_id = st.id 
            ORDER BY s.timestamp DESC
        `);
        const submissions = stmt.all();
        res.json(submissions);
    } catch (err) {
        res.status(500).json({ error: 'Error fetching submissions' });
    }
});

// 5. Teacher: Get Single Submission
app.get('/api/submission/:id', (req, res) => {
    try {
        const stmt = db.prepare('SELECT s.*, st.name FROM submissions s JOIN students st ON s.student_id = st.id WHERE s.id = ?');
        const submission = stmt.get(req.params.id);
        res.json(submission);
    } catch (err) {
        res.status(500).json({ error: 'Error fetching submission' });
    }
});

// 6. Teacher: Submit Feedback
app.post('/api/feedback', (req, res) => {
    const { submission_id, feedback_code, feedback_comments } = req.body;
    try {
        const stmt = db.prepare('UPDATE submissions SET feedback_code = ?, feedback_comments = ? WHERE id = ?');
        stmt.run(feedback_code, feedback_comments, submission_id);
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Error saving feedback' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
