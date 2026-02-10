// DOM Elements
const searchInput = document.getElementById('searchInput');
const statsDiv = document.getElementById('stats');
const resultsContainer = document.getElementById('results');
const noResultsDiv = document.getElementById('noResults');
const yearFromSelect = document.getElementById('yearFrom');
const yearToSelect = document.getElementById('yearTo');
const clearFiltersBtn = document.getElementById('clearFilters');
const filterBtns = document.querySelectorAll('.filter-btn');

// Nav & View Elements
const navBtns = document.querySelectorAll('.nav-btn');
const views = document.querySelectorAll('.view');
const topicsList = document.getElementById('topics-list');
const topicsBreadcrumb = document.getElementById('topics-breadcrumb');
const topicResultsContainer = document.getElementById('topic-results');
const topicResultsHeader = document.getElementById('topic-results-header');
const currentTopicName = document.getElementById('currentTopicName');
const topicStats = document.getElementById('topic-stats');

let allData = [];
let topicsData = {};
let fuse;
let debounceTimer;

// State
let currentState = {
    view: 'search-view',
    topicsPath: [] // [Category, Subcategory, Topic]
};

// Filter State
let filters = {
    yearFrom: null,
    yearTo: null,
    terms: ['Spring', 'Autumn'],
    types: ['Morning', 'Afternoon']
};

// Helper to normalize image paths
function getImagePath(imgPath) {
    if (imgPath.startsWith('../')) {
        return '/' + imgPath.substring(3);
    }
    return imgPath;
}

// Helper to escape special regex characters
function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// Initialize
function init() {
    try {
        if (!window.SEARCH_DATA) {
            throw new Error("SEARCH_DATA not found. Make sure data.js is loaded.");
        }
        allData = window.SEARCH_DATA;
        topicsData = window.TOPICS_DATA || {};

        // Get unique years and populate dropdowns
        const years = [...new Set(allData.map(d => d.year))].filter(y => y).sort((a, b) => a - b);
        populateYearDropdowns(years);

        // Setup Fuse for fuzzy search (fallback)
        const options = {
            keys: ['text', 'tag', 'id'],
            threshold: 0.35,
            includeScore: true,
            ignoreLocation: true,
            minMatchCharLength: 2
        };
        fuse = new Fuse(allData, options);

        // Navigation Listeners
        navBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                switchView(btn.dataset.view);
            });
        });

        // Search Input Listener with Debounce
        searchInput.addEventListener('input', (e) => {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                applyFiltersAndSearch();
            }, 250);
        });

        // Year Filter Listeners
        yearFromSelect.addEventListener('change', (e) => {
            filters.yearFrom = e.target.value ? parseInt(e.target.value) : null;
            applyFiltersAndSearch();
        });

        yearToSelect.addEventListener('change', (e) => {
            filters.yearTo = e.target.value ? parseInt(e.target.value) : null;
            applyFiltersAndSearch();
        });

        // Toggle Button Listeners
        filterBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const filterType = btn.dataset.filter;
                const value = btn.dataset.value;
                btn.classList.toggle('active');
                if (filterType === 'term') {
                    if (btn.classList.contains('active')) {
                        if (!filters.terms.includes(value)) filters.terms.push(value);
                    } else {
                        filters.terms = filters.terms.filter(t => t !== value);
                    }
                } else if (filterType === 'type') {
                    if (btn.classList.contains('active')) {
                        if (!filters.types.includes(value)) filters.types.push(value);
                    } else {
                        filters.types = filters.types.filter(t => t !== value);
                    }
                }
                applyFiltersAndSearch();
            });
        });

        // Clear Filters
        clearFiltersBtn.addEventListener('click', resetFilters);

        // Initial render
        updateStats();
        applyFiltersAndSearch();
        renderTopics();

    } catch (e) {
        if (statsDiv) statsDiv.textContent = "Error loading index. Check console.";
        console.error(e);
    }
}

function switchView(viewId) {
    currentState.view = viewId;
    navBtns.forEach(btn => {
        btn.classList.toggle('active', btn.dataset.view === viewId);
    });
    views.forEach(view => {
        view.classList.toggle('active', view.id === viewId);
    });
}

function populateYearDropdowns(years) {
    years.forEach(year => {
        const optFrom = document.createElement('option');
        optFrom.value = year;
        optFrom.textContent = year;
        yearFromSelect.appendChild(optFrom);

        const optTo = document.createElement('option');
        optTo.value = year;
        optTo.textContent = year;
        yearToSelect.appendChild(optTo);
    });
}

function resetFilters() {
    filters = {
        yearFrom: null,
        yearTo: null,
        terms: ['Spring', 'Autumn'],
        types: ['Morning', 'Afternoon']
    };
    searchInput.value = '';
    yearFromSelect.value = '';
    yearToSelect.value = '';
    filterBtns.forEach(btn => btn.classList.add('active'));
    applyFiltersAndSearch();
}

function applyFiltersAndSearch() {
    const query = searchInput.value.trim();
    let filtered = allData.filter(item => {
        if (filters.yearFrom && item.year < filters.yearFrom) return false;
        if (filters.yearTo && item.year > filters.yearTo) return false;
        if (filters.terms.length > 0 && !filters.terms.includes(item.term)) return false;
        if (filters.types.length > 0 && !filters.types.includes(item.type)) return false;
        return true;
    });

    let results;
    if (query.length === 0) {
        results = filtered.sort((a, b) => {
            if (b.year !== a.year) return b.year - a.year;
            return a.q_num - b.q_num;
        });
    } else {
        results = advancedSearch(filtered, query);
    }

    updateStats(results.length, query);
    renderResults(results, resultsContainer);
}

// Hierarchical Topics Logic
function renderTopics() {
    const path = currentState.topicsPath;
    topicsList.innerHTML = '';
    topicResultsContainer.innerHTML = '';
    topicResultsHeader.style.display = 'none';
    
    updateBreadcrumbs();

    let currentLevel = topicsData;
    for (const segment of path) {
        currentLevel = currentLevel[segment];
    }

    if (Array.isArray(currentLevel)) {
        // We reached the questions (Topic level)
        renderTopicQuestions(path[path.length - 1], currentLevel);
    } else {
        // Still in hierarchy (Category or Subcategory level)
        const keys = Object.keys(currentLevel).sort();
        
        if (keys.length === 0) {
            topicsList.innerHTML = '<div class="no-results">No topics found in this category.</div>';
            return;
        }

        keys.forEach(key => {
            const item = document.createElement('div');
            item.className = 'topic-item';
            
            // Count helper
            const count = countQuestionsUnder(currentLevel[key]);
            
            item.innerHTML = `
                <div class="topic-item-title">${key}</div>
                <div class="topic-item-count">${count} question${count !== 1 ? 's' : ''}</div>
            `;
            
            item.onclick = () => {
                currentState.topicsPath.push(key);
                renderTopics();
            };
            
            topicsList.appendChild(item);
        });
    }
}

function countQuestionsUnder(node) {
    if (Array.isArray(node)) return node.length;
    let count = 0;
    for (const key in node) {
        count += countQuestionsUnder(node[key]);
    }
    return count;
}

function updateBreadcrumbs() {
    topicsBreadcrumb.innerHTML = '';
    
    // Home item
    const home = document.createElement('span');
    home.className = 'breadcrumb-item';
    home.textContent = 'All Categories';
    home.onclick = () => {
        currentState.topicsPath = [];
        renderTopics();
    };
    topicsBreadcrumb.appendChild(home);

    currentState.topicsPath.forEach((segment, index) => {
        const item = document.createElement('span');
        item.className = 'breadcrumb-item';
        item.textContent = segment;
        item.onclick = () => {
            currentState.topicsPath = currentState.topicsPath.slice(0, index + 1);
            renderTopics();
        };
        topicsBreadcrumb.appendChild(item);
    });
}

function renderTopicQuestions(topicName, questionIds) {
    topicResultsHeader.style.display = 'block';
    document.getElementById('current-topic-name').textContent = topicName;
    topicStats.textContent = `${questionIds.length} question${questionIds.length !== 1 ? 's' : ''} found`;

    // Map IDs back to full data objects
    const dataMap = new Map(allData.map(d => [d.id, d]));
    const items = questionIds.map(id => dataMap.get(id)).filter(item => !!item);
    
    renderResults(items, topicResultsContainer, true);
}

// Reusable Render Results
function renderResults(items, container, showAll = false) {
    container.innerHTML = '';

    if (items.length === 0) {
        if (container === resultsContainer) {
            container.style.display = 'none';
            noResultsDiv.style.display = 'flex';
        } else {
            container.innerHTML = '<div class="no-results">No questions found.</div>';
        }
        return;
    }

    if (container === resultsContainer) {
        container.style.display = 'grid';
        noResultsDiv.style.display = 'none';
    }

    const displayItems = showAll ? items : items.slice(0, 100);

    displayItems.forEach(item => {
        const card = document.createElement('div');
        card.className = 'card';
        const imgPath = getImagePath(item.img_path);
        card.onclick = () => window.open(imgPath, '_blank');

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
                <img src="${imgPath}" alt="Q${item.q_num}" loading="lazy">
            </div>
            <div class="card-body">
                ${badgesHtml}
                <div class="question-title">Question ${item.q_num}</div>
            </div>
        `;

        container.appendChild(card);
    });

    if (!showAll && items.length > 100) {
        const moreDiv = document.createElement('div');
        moreDiv.className = 'more-results';
        moreDiv.textContent = `+${items.length - 100} more results. Refine your search to see all.`;
        container.appendChild(moreDiv);
    }
}

/**
 * Advanced Search Implementation
 */
function advancedSearch(items, query) {
    if (!query) return items;
    const orGroups = splitByOperator(query, '|');
    const results = new Set();

    for (const group of orGroups) {
        if (!group.trim()) continue;
        const tokens = parseTokens(group);
        if (tokens.length === 0) continue;
        const groupMatches = items.filter(item => {
            return tokens.every(token => matchToken(item, token));
        });
        groupMatches.forEach(m => results.add(m));
    }
    return Array.from(results);
}

function splitByOperator(str, op) {
    const parts = [];
    let current = '';
    let inQuote = false;
    for (let i = 0; i < str.length; i++) {
        const char = str[i];
        if (char === '"') inQuote = !inQuote;
        if (char === op && !inQuote) {
            parts.push(current);
            current = '';
        } else {
            current += char;
        }
    }
    parts.push(current);
    return parts;
}

function parseTokens(str) {
    const tokens = [];
    let current = '';
    let inQuote = false;
    for (let i = 0; i < str.length; i++) {
        const char = str[i];
        if (char === '"') {
            inQuote = !inQuote;
            if (!inQuote && current) {
                tokens.push({ type: 'phrase', value: current });
                current = '';
            }
        } else if ((char === '&' || char === ' ') && !inQuote) {
            if (current.trim()) tokens.push({ type: 'pattern', value: current.trim() });
            current = '';
        } else {
            current += char;
        }
    }
    if (current.trim()) tokens.push({ type: 'pattern', value: current.trim() });
    return tokens;
}

function matchToken(item, token) {
    const text = (item.text || '').toLowerCase();
    const tag = (item.tag || '').toLowerCase();
    let pattern = escapeRegex(token.value);
    let hasWildcards = false;
    if (token.type === 'pattern') {
        hasWildcards = pattern.includes('\\*') || pattern.includes('\\+');
    }

    if (hasWildcards) {
        pattern = pattern.replace(/\\\*/g, '.*').replace(/\\\+/g, '.+');
        if (!token.value.startsWith('*') && !token.value.startsWith('+')) pattern = '\\b' + pattern;
        if (!token.value.endsWith('*') && !token.value.endsWith('+')) pattern = pattern + '\\b';
    } else {
        pattern = escapeRegex(token.value);
        if (/^\w/.test(token.value)) pattern = '\\b' + pattern;
        if (/\w$/.test(token.value)) pattern = pattern + '\\b';
    }

    try {
        const regex = new RegExp(pattern, 'i');
        return regex.test(text) || regex.test(tag);
    } catch (e) {
        return text.includes(token.value.toLowerCase()) || tag.includes(token.value.toLowerCase());
    }
}

function updateStats(count = null, query = '') {
    const total = allData.length;
    const activeFilters = getActiveFilterCount();
    if (!statsDiv) return;

    if (count === null) {
        statsDiv.textContent = `${total} questions indexed`;
    } else if (query) {
        statsDiv.textContent = `Found ${count} of ${total} questions`;
    } else if (activeFilters > 0) {
        statsDiv.textContent = `Showing ${count} of ${total} questions (${activeFilters} filter${activeFilters > 1 ? 's' : ''} active)`;
    } else {
        statsDiv.textContent = `Showing ${Math.min(count, 100)} of ${total} questions`;
    }
}

function getActiveFilterCount() {
    let count = 0;
    if (filters.yearFrom) count++;
    if (filters.yearTo) count++;
    if (filters.terms.length < 2) count++;
    if (filters.types.length < 2) count++;
    return count;
}

init();