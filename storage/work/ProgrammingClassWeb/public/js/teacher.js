const API_URL = 'http://' + window.location.hostname + ':3000/api';

let editor;
let currentSubmissionId = null;

// Initialize CodeMirror
window.onload = () => {
    editor = CodeMirror.fromTextArea(document.getElementById('codeEditor'), {
        lineNumbers: true,
        theme: 'dracula', // Premium dark theme
        mode: 'clike', // Default to C-like
        lineWrapping: true,
    });

    loadSubmissions();
};

async function loadSubmissions() {
    const list = document.getElementById('submissionList');
    list.innerHTML = '<p style="padding:10px;">Loading...</p>';

    try {
        const res = await fetch(`${API_URL}/teacher/submissions`);
        const submissions = await res.json();

        list.innerHTML = '';
        if (submissions.length === 0) {
            list.innerHTML = '<p style="padding:10px;">No submissions yet.</p>';
            return;
        }

        submissions.forEach(sub => {
            const div = document.createElement('div');
            div.className = 'card';
            div.style.margin = '10px';
            div.style.padding = '10px';
            div.style.cursor = 'pointer';
            div.style.borderLeft = sub.feedback_code ? '4px solid var(--success)' : '4px solid var(--accent)';

            div.onclick = () => loadEditor(sub.id);

            div.innerHTML = `
                <strong>${sub.name}</strong> <small>(${sub.student_identifier})</small>
                <br>
                <span>${sub.filename}</span>
                <br>
                <small style="color: var(--text-secondary)">${new Date(sub.timestamp).toLocaleTimeString()}</small>
            `;
            list.appendChild(div);
        });
    } catch (err) {
        console.error(err);
        list.innerHTML = '<p style="color:red; padding:10px;">Error loading submissions.</p>';
    }
}

async function loadEditor(id) {
    try {
        const res = await fetch(`${API_URL}/submission/${id}`);
        const sub = await res.json();

        currentSubmissionId = id;

        // Show Editor
        document.getElementById('emptyState').classList.add('hidden');
        document.getElementById('editorSection').classList.remove('hidden');

        document.getElementById('currentStudentName').textContent = `Reviewing: ${sub.name}`;
        document.getElementById('currentSubmissionTime').textContent = `Submitted: ${new Date(sub.timestamp).toLocaleString()}`;

        // Use feedback code if available, else original code
        const codeToShow = sub.feedback_code || sub.code_content;
        editor.setValue(codeToShow);

        document.getElementById('feedbackComments').value = sub.feedback_comments || '';

        // Detect mode
        const ext = sub.filename.split('.').pop();
        let mode = 'clike';
        if (ext === 'js') mode = 'javascript';
        if (ext === 'py') mode = 'python';
        if (ext === 'html') mode = 'xml';
        editor.setOption('mode', mode);

        // Refresh to fix rendering issues
        setTimeout(() => editor.refresh(), 1);

    } catch (err) {
        alert('Error loading submission');
    }
}

async function saveFeedback() {
    if (!currentSubmissionId) return;

    const feedback_code = editor.getValue();
    const feedback_comments = document.getElementById('feedbackComments').value;

    try {
        const res = await fetch(`${API_URL}/feedback`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                submission_id: currentSubmissionId,
                feedback_code,
                feedback_comments
            })
        });

        const data = await res.json();
        if (data.success) {
            alert('Feedback sent to student!');
            loadSubmissions(); // Refresh list to show updated status
        } else {
            alert('Error saving feedback');
        }
    } catch (err) {
        alert('Error saving feedback');
    }
}
