// DOM Elements
const searchInput = document.getElementById('searchInput');
const statsDiv = document.getElementById('stats');
const resultsContainer = document.getElementById('results');
const noResultsDiv = document.getElementById('noResults');
const yearFromSelect = document.getElementById('yearFrom');
const yearToSelect = document.getElementById('yearTo');
const clearFiltersBtn = document.getElementById('clearFilters');
const filterBtns = document.querySelectorAll('.filter-btn');

let allData = [];
let fuse;
let debounceTimer;

// Helper to normalize image paths (works for both Docker and local file access)
function getImagePath(imgPath) {
    // Convert ../cropped_questions/... to /cropped_questions/...
    if (imgPath.startsWith('../')) {
        return '/' + imgPath.substring(3);
    }
    return imgPath;
}

// Helper to escape special regex characters
function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// Filter State
let filters = {
    yearFrom: null,
    yearTo: null,
    terms: ['Spring', 'Autumn'],
    types: ['Morning', 'Afternoon']
};

// Initialize
function init() {
    try {
        if (!window.SEARCH_DATA) {
            throw new Error("SEARCH_DATA not found. Make sure data.js is loaded.");
        }
        allData = window.SEARCH_DATA;

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

        updateStats();

        // Show initial batch
        applyFiltersAndSearch();

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

    } catch (e) {
        statsDiv.textContent = "Error loading index. Check console.";
        console.error(e);
    }
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
    // Reset state
    filters = {
        yearFrom: null,
        yearTo: null,
        terms: ['Spring', 'Autumn'],
        types: ['Morning', 'Afternoon']
    };

    // Reset UI
    searchInput.value = '';
    yearFromSelect.value = '';
    yearToSelect.value = '';
    filterBtns.forEach(btn => btn.classList.add('active'));

    applyFiltersAndSearch();
}

function applyFiltersAndSearch() {
    const query = searchInput.value.trim();

    // Step 1: Apply filters
    let filtered = allData.filter(item => {
        // Year filter
        if (filters.yearFrom && item.year < filters.yearFrom) return false;
        if (filters.yearTo && item.year > filters.yearTo) return false;

        // Term filter
        if (filters.terms.length > 0 && !filters.terms.includes(item.term)) return false;

        // Type filter
        if (filters.types.length > 0 && !filters.types.includes(item.type)) return false;

        return true;
    });

    // Step 2: Apply search using Unified Parser
    let results;
    if (query.length === 0) {
        // No search, just show filtered results sorted by year (newest first)
        results = filtered.sort((a, b) => {
            if (b.year !== a.year) return b.year - a.year;
            return a.q_num - b.q_num;
        });
    } else {
        results = advancedSearch(filtered, query);
    }

    updateStats(results.length, query);
    renderResults(results);
}

/**
 * Advanced Search Implementation
 * 
 * Supports mixing and matching:
 * - Exact phrase: "linked list"
 * - Wildcards: *term*, term*, *term, +term, term+
 * - Boolean: term1 & term2 (AND), term1 | term2 (OR)
 * - Combinations: "exact phrase" & *term* | +prefix
 */
function advancedSearch(items, query) {
    if (!query) return items;

    // Split by | first (OR groups)
    const orGroups = splitByOperator(query, '|');

    const results = new Set();

    for (const group of orGroups) {
        if (!group.trim()) continue;

        // Parse AND tokens within this OR group
        // We split by & or implicit space (unless quoted)
        const tokens = parseTokens(group);

        if (tokens.length === 0) continue;

        // Strict AND: Item must match ALL tokens in this group
        const groupMatches = items.filter(item => {
            return tokens.every(token => matchToken(item, token));
        });

        // Add all matches from this OR group
        groupMatches.forEach(m => results.add(m));
    }

    return Array.from(results);
}

/**
 * Helper to split by an operator but respect quotes
 */
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

/**
 * Parses a string into tokens, respecting quotes
 * Treats '&' as delimiter, and spaces as delimiters (implicit AND)
 */
function parseTokens(str) {
    const tokens = [];
    let current = '';
    let inQuote = false;

    for (let i = 0; i < str.length; i++) {
        const char = str[i];

        if (char === '"') {
            inQuote = !inQuote;
            if (!inQuote && current) {
                // End of quote -> Add as phrase token
                tokens.push({ type: 'phrase', value: current });
                current = '';
            }
        } else if ((char === '&' || char === ' ') && !inQuote) {
            if (current.trim()) tokens.push(createToken(current));
            current = '';
        } else {
            current += char;
        }
    }

    if (current.trim()) tokens.push(createToken(current));

    return tokens;
}

function createToken(str) {
    str = str.trim();
    // Default to pattern token
    return { type: 'pattern', value: str };
}

/**
 * Checks if an item matches a single token pattern
 */
function matchToken(item, token) {
    const text = (item.text || '').toLowerCase();
    const tag = (item.tag || '').toLowerCase();

    // 1. Exact Phrase (Quoted) or Simple Term (No Wildcards)
    // Both should use smart boundary logic:
    // - If it starts/ends with alphanumeric, require \b boundary.
    // - If it starts/ends with symbol, do strictly substring at that edge.
    // This allows "AI" to match strict, but "C++" to work.

    let pattern = escapeRegex(token.value);

    // Check if it has wildcards (escaped by escapeRegex as \* and \+)
    // Only if token.type is 'pattern' (not quoted phrase)
    let hasWildcards = false;
    if (token.type === 'pattern') {
        hasWildcards = pattern.includes('\\*') || pattern.includes('\\+');
    }

    if (hasWildcards) {
        // Replace escaped wildcards with Regex equivalents
        // \* -> .* (Match any sequence)
        // \+ -> .+ (Match at least one char)
        pattern = pattern
            .replace(/\\\*/g, '.*')
            .replace(/\\\+/g, '.+');

        // Boundary Logic:
        // If query starts with wildcard, NO leading boundary.
        // If query does NOT start with wildcard, use word boundary \b
        if (!token.value.startsWith('*') && !token.value.startsWith('+')) {
            pattern = '\\b' + pattern;
        }

        // Same for end
        if (!token.value.endsWith('*') && !token.value.endsWith('+')) {
            pattern = pattern + '\\b';
        }
    } else {
        // No wildcards OR Quoted Phrase.
        // TREAT AS STRICT WORD if alphanumeric boundaries exist.

        // Reset pattern (just in case)
        pattern = escapeRegex(token.value);

        // Smart Boundaries
        // If it starts with a word char [a-zA-Z0-9_], require leading \b
        if (/^\w/.test(token.value)) {
            pattern = '\\b' + pattern;
        }
        // If it ends with a word char, require trailing \b
        if (/\w$/.test(token.value)) {
            pattern = pattern + '\\b';
        }
    }

    try {
        const regex = new RegExp(pattern, 'i');
        return regex.test(text) || regex.test(tag);
    } catch (e) {
        // Fallback to simple includes if regex fails (unlikely)
        return text.includes(token.value.toLowerCase()) || tag.includes(token.value.toLowerCase());
    }
}

function updateStats(count = null, query = '') {
    const total = allData.length;
    const activeFilters = getActiveFilterCount();

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

function renderResults(items) {
    resultsContainer.innerHTML = '';

    if (items.length === 0) {
        resultsContainer.style.display = 'none';
        noResultsDiv.style.display = 'flex';
        return;
    }

    resultsContainer.style.display = 'grid';
    noResultsDiv.style.display = 'none';

    // Limit DOM nodes for performance
    const displayItems = items.slice(0, 100);

    displayItems.forEach(item => {
        const card = document.createElement('div');
        card.className = 'card';
        const imgPath = getImagePath(item.img_path);
        card.onclick = () => window.open(imgPath, '_blank');

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
                <img src="${imgPath}" alt="Q${item.q_num}" loading="lazy">
            </div>
            <div class="card-body">
                ${badgesHtml}
                <div class="question-title">Question ${item.q_num}</div>
            </div>
        `;

        resultsContainer.appendChild(card);
    });

    // Show count if limited
    if (items.length > 100) {
        const moreDiv = document.createElement('div');
        moreDiv.className = 'more-results';
        moreDiv.textContent = `+${items.length - 100} more results. Refine your search to see all.`;
        resultsContainer.appendChild(moreDiv);
    }
}

init();
