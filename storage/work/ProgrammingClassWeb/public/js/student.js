const API_URL = 'http://' + window.location.hostname + ':3000/api';

// State
let currentUser = null;

// DOM Elements
const loginSection = document.getElementById('loginSection');
const studentDashboard = document.getElementById('studentDashboard');
const userInfo = document.getElementById('userInfo');
const userNameDisplay = document.getElementById('userNameDisplay');
const loginForm = document.getElementById('loginForm');
const submitForm = document.getElementById('submitForm');
const submissionsList = document.getElementById('submissionsList');

// --- Login Flow ---
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('nameInput').value;
    const student_id = document.getElementById('idInput').value;

    try {
        const res = await fetch(`${API_URL}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, student_id })
        });
        const data = await res.json();

        if (data.success) {
            currentUser = data.student;
            showDashboard();
            loadSubmissions();
        } else {
            alert('Login failed');
        }
    } catch (err) {
        console.error(err);
        alert('Error connecting to server');
    }
});

function showDashboard() {
    loginSection.classList.add('hidden');
    studentDashboard.classList.remove('hidden');
    userInfo.classList.remove('hidden');
    userNameDisplay.textContent = `${currentUser.name} (${currentUser.student_id})`;
}

function logout() {
    currentUser = null;
    location.reload();
}

// --- Submission Flow ---
submitForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!currentUser) return;

    const codeText = document.getElementById('codeTextInput').value;
    const fileInput = document.getElementById('fileInput');

    const formData = new FormData();
    formData.append('student_id_db', currentUser.id);

    if (fileInput.files.length > 0) {
        formData.append('codeFile', fileInput.files[0]);
    } else if (codeText.trim()) {
        formData.append('codeText', codeText);
    } else {
        alert('Please enter code or select a file');
        return;
    }

    try {
        const res = await fetch(`${API_URL}/submit`, {
            method: 'POST',
            body: formData
        });
        const data = await res.json();

        if (data.success) {
            alert('Code submitted!');
            document.getElementById('codeTextInput').value = '';
            document.getElementById('fileInput').value = '';
            loadSubmissions();
        } else {
            alert('Submission failed');
        }
    } catch (err) {
        alert('Error submitting code');
    }
});

// --- View Submissions / Feedback ---
async function loadSubmissions() {
    if (!currentUser) return;
    try {
        const res = await fetch(`${API_URL}/student/submissions/${currentUser.id}`);
        const submissions = await res.json();

        submissionsList.innerHTML = '';
        if (submissions.length === 0) {
            submissionsList.innerHTML = '<p style="color: var(--text-secondary)">No submissions yet.</p>';
            return;
        }

        submissions.forEach(sub => {
            const div = document.createElement('div');
            div.className = 'card flex';
            div.style.alignItems = 'center';
            div.style.justifyContent = 'space-between';
            div.style.padding = '10px 15px';
            div.style.marginBottom = '10px';

            const status = sub.feedback_code ?
                '<span class="badge badge-success">Reviewed</span>' :
                '<span class="badge badge-pending">Pending</span>';

            div.innerHTML = `
                <div>
                    <strong>${sub.filename}</strong>
                    <br>
                    <small style="color: var(--text-secondary)">${new Date(sub.timestamp).toLocaleString()}</small>
                </div>
                <div style="text-align: right;">
                    ${status}
                    ${sub.feedback_code ? `<br><a href="#" onclick="viewFeedback(${sub.id})" style="font-size: 0.9rem; color: var(--accent);">View Feedback</a>` : ''}
                </div>
            `;
            submissionsList.appendChild(div);
        });
    } catch (err) {
        console.error(err);
    }
}

// Make globally available for onclick
window.viewFeedback = async (id) => {
    // Ideally fetch single submission or find in list
    // Re-fetching strictly ensures we get fresh data
    try {
        // We can't actually fetch single submission as student from my API design (oops, only teacher can), 
        // but we can filter from the list we just fetched if we store it.
        // Let's adjust the simple way: re-fetch list is fine or store in memory.
        // I'll assume we can just find it in the current DOM or list if I stored it.
        // Okay, let's just cheat and assume the student has the data or I can add a getter for student too. 
        // Actually, let's update the backend or just filter from the previous call.
        // I didn't store the previous call data in a variable. Let's fix that next time.
        // For now, I'll just refetch the list and find it.
        const res = await fetch(`${API_URL}/student/submissions/${currentUser.id}`);
        const submissions = await res.json();
        const sub = submissions.find(s => s.id === id);

        if (sub && sub.feedback_code) {
            const feedbackView = document.getElementById('feedbackView');
            const codeBlock = document.getElementById('feedbackCodeBlock');
            const comments = document.getElementById('feedbackComments');

            feedbackView.classList.remove('hidden');

            // Set content
            codeBlock.textContent = sub.feedback_code;
            comments.textContent = sub.feedback_comments || 'No comments.';

            // Detect language simply by extension or default to c
            const ext = sub.filename.split('.').pop();
            codeBlock.className = `language-${ext}`;

            // Apply highlighting
            hljs.highlightElement(codeBlock);
        }
    } catch (err) { console.error(err); }
};
