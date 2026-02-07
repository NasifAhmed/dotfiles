// DOM Elements
const searchInput = document.getElementById('searchInput');
const statsDiv = document.getElementById('stats');
const resultsContainer = document.getElementById('results');

let allData = [];
let fuse;
let debounceTimer;

// Initialize
function init() {
    try {
        if (!window.SEARCH_DATA) {
            throw new Error("SEARCH_DATA not found. Make sure data.js is loaded.");
        }
        allData = window.SEARCH_DATA;

        // Setup Fuse
        const options = {
            keys: ['text', 'tag', 'year', 'qid'],
            threshold: 0.3,
            includeScore: true,
            ignoreLocation: true
        };
        fuse = new Fuse(allData, options);

        statsDiv.textContent = `Indexed ${allData.length} questions. Ready to search.`;

        // Show initial batch
        renderResults(allData.slice(0, 50));

        // Listeners with Debounce
        searchInput.addEventListener('input', (e) => {
            clearTimeout(debounceTimer);
            const query = e.target.value.trim();
            statsDiv.textContent = "Searching...";

            debounceTimer = setTimeout(() => {
                handleSearch(query);
            }, 300); // 300ms delay
        });

    } catch (e) {
        statsDiv.textContent = "Error loading index. Check console.";
        console.error(e);
    }
}

function handleSearch(query) {
    if (query.length === 0) {
        renderResults(allData.slice(0, 100));
        statsDiv.textContent = `Indexed ${allData.length} questions.`;
        return;
    }

    // Tiered Search Logic
    // 1. Exact Phrase Match (most strict)
    const exactMatches = allData.filter(item =>
        (item.text && item.text.toLowerCase().includes(query.toLowerCase())) ||
        (item.tag && item.tag.toLowerCase().includes(query.toLowerCase()))
    );

    // 2. Fuzzy/Word Match (using Fuse)
    const fuseResults = fuse.search(query).map(r => r.item);

    // Merge: Exact matches first, then fuzzy results (deduplicated)
    const seenIds = new Set(exactMatches.map(i => i.id));
    const combined = [...exactMatches];

    fuseResults.forEach(item => {
        if (!seenIds.has(item.id)) {
            combined.push(item);
            seenIds.add(item.id);
        }
    });

    statsDiv.textContent = `Found ${combined.length} matches.`;
    renderResults(combined);
}

function renderResults(items) {
    resultsContainer.innerHTML = '';

    // Limit DOM nodes for performance
    const displayItems = items.slice(0, 100);

    displayItems.forEach(item => {
        const card = document.createElement('div');
        card.className = 'card';
        // Open image in new tab directly
        card.onclick = () => window.open(item.img_path, '_blank');

        // Badges
        const badgesHtml = `
            <div class="badges">
                <span class="badge badge-year">${item.year}</span>
                <span class="badge badge-term">${item.term}</span>
                <span class="badge badge-type">${item.type}</span>
                ${item.tag && item.tag !== 'Uncategorized' ? `<span class="badge badge-tag">${item.tag}</span>` : ''}
            </div>
        `;

        card.innerHTML = `
            <div class="card-img-container">
                <img src="${item.img_path}" alt="Q${item.q_num}" loading="lazy">
            </div>
            <div class="card-body">
                ${badgesHtml}
                <div class="question-title">Question ${item.q_num}</div>
            </div>
        `;

        resultsContainer.appendChild(card);
    });
}
// Removed Modal Logic entirely as requested

init();
