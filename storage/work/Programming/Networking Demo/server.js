// ==========================================
//  1. SETUP THE SERVER
// ==========================================
const express = require('express');
const http = require('http');
const { WebSocketServer } = require('ws');
const uaParser = require('ua-parser-js');

const port = 3000;
const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

// ==========================================
//  2. IN-MEMORY "DATABASE"
// ==========================================
const visitors = new Map();
let likedIPs = new Set();
let comments = [];
let hostSocket = null; 

// ==========================================
//  3. HELPER FUNCTION
// ==========================================
function broadcastState() {
  const visitorList = Array.from(visitors.values());
  const state = JSON.stringify({
    type: 'state-update',
    payload: {
      visitors: visitorList,
      likes: likedIPs.size,
      likedBy: Array.from(likedIPs),
      comments: comments,
    },
  });

  wss.clients.forEach((client) => {
    if (client !== hostSocket) { 
      client.send(state);
    }
  });
}

function broadcastFrame(frame) {
    const message = JSON.stringify({ type: 'video-frame', payload: frame });
    wss.clients.forEach((client) => {
        if (client !== hostSocket && client.readyState === client.OPEN) {
            client.send(message);
        }
    });
}

function broadcastStreamStatus(status) { 
    const message = JSON.stringify({ type: 'stream-status', payload: status });
    wss.clients.forEach((client) => {
        if (client !== hostSocket && client.readyState === client.OPEN) {
            client.send(message);
        }
    });
}

// ==========================================
//  4. REAL-TIME LOGIC (WebSockets)
// ==========================================

wss.on('connection', (ws, req) => {
  // 1. Get info.
  const userAgentString = req.headers['user-agent'];
  let ip = req.socket.remoteAddress; 
  const ua = uaParser(userAgentString);

  if (ip.includes('::ffff:')) ip = ip.split(':').pop();
  if (ip === '::1') ip = '127.0.0.1 (Localhost)';

  // --- MODIFIED: Capture more header data ---
  const visitorData = {
    id: Date.now(), ip: ip,
    browser: `${ua.browser.name || 'N/A'} (v: ${ua.browser.version || 'N/A'})`,
    os: `${ua.os.name || 'N/A'} (v: ${ua.os.version || 'N/A'})`,
    deviceType: ua.device.type || 'desktop',
    deviceInfo: `${ua.device.vendor || ''} ${ua.device.model || ''}`,
    fullUserAgent: userAgentString,
    // --- NEW: Add more networking headers from the request ---
    headers: {
        host: req.headers.host || 'N/A',
        language: req.headers['accept-language'] ? req.headers['accept-language'].split(',')[0] : 'N/A',
    },
    // --- NEW: Placeholder for client-side network info ---
    clientInfo: {
        online: true,
        downlink: 'N/A',
        effectiveType: 'N/A'
    }
  };

  // 2. Send 'welcome' message
  ws.send(JSON.stringify({ type: 'welcome', payload: { ip: visitorData.ip } }));

  // 3. Add to visitor list (but not the host)
  visitors.set(ws, visitorData);

  // 4. Handle messages
  ws.on('message', (message) => {
    try {
      // Use Buffer.from for binary/string flexibility
      const data = JSON.parse(message.toString());
      
      if (data.type === 'host-connect') {
          console.log('Host connected!');
          hostSocket = ws;
          visitors.delete(ws); // Remove host from public visitor list
          broadcastStreamStatus('offline');
      } else if (ws === hostSocket) {
          if (data.type === 'video-frame') {
              broadcastFrame(data.payload);
          } else if (data.type === 'stream-start') {
              broadcastStreamStatus('live');
          } else if (data.type === 'stream-stop') {
              broadcastStreamStatus('offline');
          }
      } 
      
      // --- NEW: Handle ping ---
      else if (data.type === 'ping') {
        // Immediately send a 'pong' back to this specific client
        ws.send(JSON.stringify({ type: 'pong' }));
      }
      
      // --- NEW: Handle client-side network info ---
      else if (data.type === 'client-info') {
        visitorData.clientInfo = data.payload;
        broadcastState(); // Update everyone with this new info
      }
      // --- END NEW ---
      
      else if (data.type === 'like') {
        likedIPs.add(visitorData.ip); 
        broadcastState();
      } else if (data.type === 'new-comment') {
        const commentText = data.payload.trim();
        if (commentText) {
          comments.push({ user: visitorData.ip, text: commentText }); 
          if (comments.length > 10) comments.shift();
        }
        broadcastState();
      }
    } catch (e) {
      if (message.length < 1000) {
        console.error('Failed to parse message:', e);
      }
    }
  });

  // 5. Handle disconnect
  ws.on('close', () => {
    if (ws === hostSocket) {
        console.log('Host disconnected.');
        hostSocket = null;
        broadcastStreamStatus('offline');
    } else {
        visitors.delete(ws);
    }
    broadcastState();
  });

  ws.on('error', console.error);

  // 6. Send initial state
  broadcastState();
  if (hostSocket) broadcastStreamStatus('live');
});

// ==========================================
//  5. WEB SERVER LOGIC (Express)
// ==========================================

app.get('/', (req, res) => {
  res.send(HTML_CONTENT);
});

app.get('/download', (req, res) => {
  const fileContent = 'hello world';
  res.setHeader('Content-Disposition', 'attachment; filename=hello.txt');
  res.setHeader('Content-Type', 'text/plain');
  res.send(fileContent);
});

app.get('/host', (req, res) => {
    res.send(HOST_HTML_CONTENT);
});

// ==========================================
//  6. START THE SERVER
// ==========================================
server.listen(port, () => {
  console.log(`Server is listening on http://localhost:${port}`);
  console.log('--- HOST/ADMIN PAGE is http://localhost:3000/host ---');
  console.log('WARNING: This server shows RAW IP ADDRESSES and user data.');
});

// ==========================================
//  7. STUDENT/VISITOR PAGE (HTML_CONTENT)
// ==========================================

const HTML_CONTENT = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Server Demo (Classroom)</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: #121212;
            color: #e0e0e0;
            margin: 0;
            padding: 0;
        }
        .container { display: flex; width: 100%; height: 100vh; }
        .main-content { flex-grow: 1; padding: 40px; overflow-y: auto; }
        .sidebar {
            width: 450px; 
            min-width: 400px;
            background-color: #1e1e1e;
            border-left: 1px solid #333;
            padding: 20px;
            box-shadow: -5px 0 15px rgba(0,0,0,0.3);
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }
        h1 { color: #4CAF50; }
        h2 { color: #03A9F4; border-bottom: 1px solid #444; padding-bottom: 5px; }
        p { font-size: 1.1em; line-height: 1.6; }
        .element-box {
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        button, input[type="text"], a.button {
            padding: 10px 15px; border-radius: 5px; border: none;
            font-size: 1em; cursor: pointer; text-decoration: none; display: inline-block;
        }
        button { background-color: #03A9F4; color: white; }
        button:hover { background-color: #0288D1; }
        button:disabled { background-color: #555; color: #999; cursor: not-allowed; }
        a.button { background-color: #4CAF50; color: white; }
        a.button:hover { background-color: #43A047; }
        #like-count { font-size: 1.2em; font-weight: bold; color: #FFC107; margin-left: 10px; }
        #like-list { list-style: none; padding: 0; margin-top: 15px; display: flex; flex-wrap: wrap; gap: 5px; }
        #like-list li {
            font-size: 0.9em; color: #ddd; background: #3a3a3a;
            padding: 5px 10px; border-radius: 4px;
        }
        #comment-form { display: flex; margin-bottom: 15px; }
        #comment-input {
            flex-grow: 1; background: #333; color: #eee;
            border: 1px solid #555; margin-right: 10px;
        }
        #comment-list { list-style: none; padding: 0; }
        #comment-list li {
            background: #333; padding: 10px; border-radius: 5px;
            margin-bottom: 5px; border-left: 3px solid #03A9F4;
        }
        #comment-list li .comment-user {
            font-size: 0.8em; color: #ef5350; font-weight: bold; display: block;
        }
        #visitor-list { list-style: none; padding: 0; margin: 0; }
        #visitor-list li {
            background-color: #2a2a2a; border: 1px solid #444; border-radius: 8px;
            padding: 15px; margin-bottom: 10px; display: flex; flex-direction: column;
            gap: 5px; animation: fadeIn 0.5s ease; transition: background-color 0.3s ease, border-color 0.3s ease;
        }
        #visitor-list li strong { color: #ef5350; font-size: 1.1em; word-break: break-all; }
        #visitor-list li span { font-size: 0.9em; color: #c0c0c0; }
        /* --- NEW: Style for sub-data (networking info) --- */
        #visitor-list li .net-info {
            font-size: 0.85em; color: #aaa;
            border-top: 1px dashed #444;
            margin-top: 5px; padding-top: 5px;
        }
        #visitor-list li small {
            font-size: 0.8em; color: #777; font-style: italic; word-break: break-all;
            margin-top: 5px; border-top: 1px dashed #444; padding-top: 5px;
        }
        #visitor-list li.is-me {
            background-color: #0277bd; border-color: #03A9F4;
        }
        #visitor-list li.is-me strong { color: #ffffff; }
        #visitor-list li.is-me span, #visitor-list li.is-me small, #visitor-list li.is-me .net-info { color: #e0e0e0; }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        #stream-wrapper {
            background: #000; border: 1px solid #444; position: relative;
            min-height: 240px; border-radius: 8px; overflow: hidden;
        }
        #video-stream { width: 100%; height: auto; display: block; }
        #stream-offline {
            position: absolute; top: 50%; left: 50%;
            transform: translate(-50%, -50%); color: #888; font-size: 1.2em; display: none;
        }
        /* --- NEW: Ping result style --- */
        #ping-result {
            font-size: 1.1em;
            font-weight: bold;
            color: #FFC107;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="main-content">
            <h1>hello Metro IT.</h1>
            <p>This is a webpage/server hosted by <strong>Nasif Ahmed</strong> on his laptop.</p>
            
            <div class="element-box">
                <h3>Live Stream from Host</h3>
                <div id="stream-wrapper">
                    <img id="video-stream" src="" alt="Live Stream" />
                    <div id="stream-offline">Stream is Offline</div>
                </div>
            </div>

            <div class="element-box">
                <h3>Network Info (Ping Test)</h3>
                <p>Click this to measure your Ping or Round-Trip Time (RTT) to the server.</p>
                <button id="ping-btn">Ping Server</button>
                <span id="ping-result"></span>
            </div>

            <div class="element-box">
                <h3>Download Button (HTTP GET)</h3>
                <a href="/download" class="button">Download hello.txt</a>
            </div>
            <div class="element-box">
                <h3>Live Like Button (WebSocket)</h3>
                <button id="like-btn">❤️ Like</button>
                <span id="like-count">0</span>
                <p style="margin-top: 20px; font-size: 0.9em; color: #ccc; margin-bottom: 5px;">Liked by:</p>
                <ul id="like-list"></ul>
            </div>
            <div class="element-box">
                <h3>Live Comment Section</h3>
                <form id="comment-form">
                    <input type="text" id="comment-input" placeholder="Type a comment..." autocomplete="off">
                    <button type="submit">Send</button>
                </form>
                <ul id="comment-list"></ul>
            </div>
        </div>
        <aside class="sidebar">
            <h2>Live Visitors (<span id="visitor-count">0</span>)</h2>
            <ul id="visitor-list"></ul>
        </aside>
    </div>

    <script>
        const visitorList = document.getElementById('visitor-list');
        const visitorCount = document.getElementById('visitor-count');
        const likeBtn = document.getElementById('like-btn');
        const likeCountEl = document.getElementById('like-count');
        const commentForm = document.getElementById('comment-form');
        const commentInput = document.getElementById('comment-input');
        const commentList = document.getElementById('comment-list');
        const likeListEl = document.getElementById('like-list');
        const videoStreamEl = document.getElementById('video-stream');
        const streamOfflineEl = document.getElementById('stream-offline');
        // --- NEW: Ping elements ---
        const pingBtn = document.getElementById('ping-btn');
        const pingResult = document.getElementById('ping-result');
        let pingStartTime;

        let myIP = null;
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const ws = new WebSocket(\`\${wsProtocol}//\${window.location.host}\`);

        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            
            if (data.type === 'welcome') {
                myIP = data.payload.ip;
            } 
            else if (data.type === 'video-frame') {
                videoStreamEl.src = data.payload;
            } 
            else if (data.type === 'stream-status') {
                if (data.payload === 'live') {
                    streamOfflineEl.style.display = 'none';
                    videoStreamEl.style.display = 'block';
                } else {
                    streamOfflineEl.style.display = 'block';
                    videoStreamEl.style.display = 'none';
                }
            } 
            // --- NEW: Handle pong ---
            else if (data.type === 'pong') {
                const latency = Date.now() - pingStartTime;
                pingResult.textContent = \`RTT: \${latency} ms\`;
            }
            // --- END NEW ---
            else if (data.type === 'state-update') {
                const state = data.payload;
                visitorCount.textContent = state.visitors.length;
                visitorList.innerHTML = '';
                
                // --- MODIFIED: Display all new networking data ---
                state.visitors.forEach(visitor => {
                    const li = document.createElement('li');
                    
                    let selfText = '';
                    if (myIP && visitor.ip === myIP) {
                        li.classList.add('is-me');
                        selfText = ' (This is You)';
                    }
                    
                    li.innerHTML = \`
                        <strong>IP: \${visitor.ip}\${selfText}</strong>
                        <span>Browser: \${visitor.browser}</span>
                        <span>OS: \${visitor.os}</span>
                        
                        <div class="net-info">
                            <strong>Host Header:</strong> \${visitor.headers.host}<br>
                            <strong>Language:</strong> \${visitor.headers.language}<br>
                            <strong>Conn. Type:</strong> \${visitor.clientInfo?.effectiveType || 'N/A'}<br>
                            <strong>Downlink:</strong> \${visitor.clientInfo?.downlink || 'N/A'} Mbps
                        </div>
                        
                        <small>\${visitor.fullUserAgent}</small>
                    \`;
                    visitorList.appendChild(li);
                });
                // --- END MODIFICATION ---

                likeCountEl.textContent = state.likes;
                likeListEl.innerHTML = '';
                state.likedBy.forEach(ip => {
                    const li = document.createElement('li');
                    li.textContent = ip;
                    likeListEl.appendChild(li);
                });
                if (myIP && state.likedBy.includes(myIP)) {
                    likeBtn.disabled = true;
                    likeBtn.textContent = '❤️ Liked';
                } else {
                    likeBtn.disabled = false;
                    likeBtn.textContent = '❤️ Like';
                }
                commentList.innerHTML = '';
                state.comments.forEach(comment => {
                    const li = document.createElement('li');
                    li.innerHTML = \`<span class="comment-user">From: \${comment.user}</span> \${comment.text}\`;
                    commentList.appendChild(li);
                });
            }
        };

        likeBtn.onclick = () => ws.send(JSON.stringify({ type: 'like' }));
        
        // --- NEW: Ping button click ---
        pingBtn.onclick = () => {
            pingStartTime = Date.now();
            ws.send(JSON.stringify({ type: 'ping' }));
            pingResult.textContent = 'Pinging...';
        };

        commentForm.onsubmit = (e) => {
            e.preventDefault();
            const commentText = commentInput.value;
            if (commentText) {
                ws.send(JSON.stringify({ type: 'new-comment', payload: commentText }));
                commentInput.value = '';
            }
        };

        ws.onopen = () => {
            console.log('Connected to WebSocket server!');
            
            // --- NEW: Send client-side network info to server ---
            const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection || {};
            const clientInfo = {
                online: navigator.onLine,
                downlink: connection.downlink || 'N/A',
                effectiveType: connection.effectiveType || 'N/A'
            };
            ws.send(JSON.stringify({ type: 'client-info', payload: clientInfo }));
        };
        
        ws.onclose = () => console.log('Disconnected from WebSocket server.');
    </script>
</body>
</html>
`;


// ==========================================
//  8. HOST/ADMIN PAGE (HOST_HTML_CONTENT)
// ==========================================

const HOST_HTML_CONTENT = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Host Control Panel</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #222; color: #eee;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        h1 { color: #4CAF50; }
        #webcam-preview {
            border: 2px solid #555;
            background: #000;
            border-radius: 8px;
            width: 100%;
            max-width: 640px;
        }
        .controls { margin-top: 20px; }
        button {
            padding: 12px 20px;
            font-size: 1.2em;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        #start-btn { background-color: #4CAF50; color: white; }
        #stop-btn { background-color: #ef5350; color: white; }
    </style>
</head>
<body>
    <h1>Host Control Panel</h1>
    <p>Your webcam feed is shown below. Click "Start Stream" to broadcast to visitors.</p>
    
    <video id="webcam-preview" autoplay muted playsinline></video>
    <canvas id="canvas" style="display: none;"></canvas>

    <div class="controls">
        <button id="start-btn">Start Stream</button>
        <button id="stop-btn" disabled>Stop Stream</button>
    </div>

    <script>
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const ws = new WebSocket(\`\${wsProtocol}//\${window.location.host}\`);
        
        ws.onopen = () => {
            console.log('Host connected to WebSocket.');
            ws.send(JSON.stringify({ type: 'host-connect' }));
        };

        const video = document.getElementById('webcam-preview');
        const canvas = document.getElementById('canvas');
        const startBtn = document.getElementById('start-btn');
        const stopBtn = document.getElementById('stop-btn');
        const context = canvas.getContext('2d');

        let streamInterval = null;
        const FPS = 10; 
        const FRAME_QUALITY = 0.4; 

        async function setupWebcam() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ 
                    video: { width: 640, height: 480 } 
                });
                video.srcObject = stream;
                video.onloadedmetadata = () => {
                    canvas.width = video.videoWidth;
                    canvas.height = video.videoHeight;
                };
            } catch (err) {
                console.error("Error accessing webcam:", err);
                alert("Could not access webcam. Please check permissions.");
            }
        }
        
        function sendFrame() {
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            const dataUrl = canvas.toDataURL('image/jpeg', FRAME_QUALITY);
            if (ws.readyState === ws.OPEN) {
                ws.send(JSON.stringify({ type: 'video-frame', payload: dataUrl }));
            }
        }

        startBtn.onclick = () => {
            if (!streamInterval) {
                streamInterval = setInterval(sendFrame, 1000 / FPS);
                ws.send(JSON.stringify({ type: 'stream-start' }));
                startBtn.disabled = true;
                stopBtn.disabled = false;
                console.log('Stream started.');
            }
        };

        stopBtn.onclick = () => {
            if (streamInterval) {
                clearInterval(streamInterval);
                streamInterval = null;
                ws.send(JSON.stringify({ type: 'stream-stop' }));
                startBtn.disabled = false;
                stopBtn.disabled = true;
                console.log('Stream stopped.');
            }
        };
        
        setupWebcam();
    </script>
</body>
</html>
`;