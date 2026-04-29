#!/usr/bin/env node
/**
 * Markdown-to-PDF Generator
 * 
 * Converts a Markdown file (with LaTeX math, code blocks, tables, emojis)
 * into a beautifully formatted PDF using:
 *   - marked: Markdown → HTML
 *   - highlight.js: Code syntax highlighting
 *   - KaTeX: LaTeX math rendering
 *   - Puppeteer: HTML → PDF (via headless Chrome)
 *
 * Usage: node generate_pdf.mjs [input.md] [output.pdf]
 */

import fs from 'fs';
import path from 'path';
import { Marked } from 'marked';
import { markedHighlight } from 'marked-highlight';
import hljs from 'highlight.js';
import katex from 'katex';
import puppeteer from 'puppeteer-core';

// ─── Config ───────────────────────────────────────────────────────
const INPUT  = process.argv[2] || 'pseudocode_exam_collection.md';
const OUTPUT = process.argv[3] || INPUT.replace(/\.md$/i, '.pdf');

// ─── Read Markdown ────────────────────────────────────────────────
let md = fs.readFileSync(INPUT, 'utf-8');

// ─── Pre-process: Render LaTeX math with KaTeX ────────────────────
// Display math: $$ ... $$ (can span multiple lines)
md = md.replace(/\$\$([\s\S]*?)\$\$/g, (_, tex) => {
  try {
    return katex.renderToString(tex.trim(), { displayMode: true, throwOnError: false });
  } catch { return `<pre class="katex-error">${tex}</pre>`; }
});

// Inline math: $ ... $ (single line, not greedy)
md = md.replace(/(?<!\$)\$(?!\$)([^\n$]+?)\$(?!\$)/g, (_, tex) => {
  try {
    return katex.renderToString(tex.trim(), { displayMode: false, throwOnError: false });
  } catch { return `<code class="katex-error">${tex}</code>`; }
});

// ─── Configure Marked with Highlight.js ───────────────────────────
const marked = new Marked(
  markedHighlight({
    langPrefix: 'hljs language-',
    highlight(code, lang) {
      if (lang && hljs.getLanguage(lang)) {
        return hljs.highlight(code, { language: lang }).value;
      }
      // Fallback: treat 'vb' pseudocode blocks nicely
      return hljs.highlightAuto(code).value;
    },
  })
);

marked.setOptions({
  gfm: true,
  breaks: false,
});

// ─── Convert Markdown → HTML ──────────────────────────────────────
const bodyHtml = marked.parse(md);

// ─── Full HTML Document with Premium Styling ──────────────────────
const fullHtml = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FE Evening Exam — Pseudocode Collection</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
<style>
/* ── Page & Typography ─────────────────────────────────────── */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap');

:root {
  --bg: #ffffff;
  --fg: #1a1a2e;
  --fg-secondary: #4a4a6a;
  --accent: #6366f1;
  --accent-soft: #818cf8;
  --accent-bg: #eef2ff;
  --green: #10b981;
  --green-bg: #ecfdf5;
  --orange: #f59e0b;
  --orange-bg: #fffbeb;
  --red: #ef4444;
  --red-bg: #fef2f2;
  --border: #e2e8f0;
  --code-bg: #1e1e2e;
  --code-fg: #cdd6f4;
  --blockquote-border: #6366f1;
  --blockquote-bg: #f8faff;
  --table-header-bg: #6366f1;
  --table-header-fg: #ffffff;
  --table-stripe: #f8fafc;
  --shadow: 0 1px 3px rgba(0,0,0,0.06);
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 10.5pt;
  line-height: 1.7;
  color: var(--fg);
  background: var(--bg);
  padding: 0;
  -webkit-font-smoothing: antialiased;
}

/* ── Headings ──────────────────────────────────────────────── */
h1 {
  font-size: 24pt;
  font-weight: 800;
  color: var(--accent);
  margin: 0 0 6pt 0;
  padding-bottom: 8pt;
  border-bottom: 3px solid var(--accent);
  letter-spacing: -0.5px;
  line-height: 1.2;
  page-break-after: avoid;
}

h1:first-child {
  text-align: center;
  border-bottom: none;
  margin-bottom: 2pt;
}

h2 {
  font-size: 15pt;
  font-weight: 700;
  color: var(--fg);
  margin: 20pt 0 8pt 0;
  padding: 6pt 12pt;
  background: linear-gradient(135deg, var(--accent-bg), #f0f4ff);
  border-left: 4px solid var(--accent);
  border-radius: 0 8px 8px 0;
  page-break-after: avoid;
}

h3 {
  font-size: 13pt;
  font-weight: 700;
  color: var(--accent);
  margin: 18pt 0 6pt 0;
  padding-bottom: 4pt;
  border-bottom: 2px solid var(--border);
  page-break-after: avoid;
}

/* ── Paragraphs & Text ─────────────────────────────────────── */
p {
  margin: 6pt 0;
  text-align: justify;
  hyphens: auto;
}

strong {
  font-weight: 600;
  color: var(--fg);
}

em { color: var(--fg-secondary); }

a {
  color: var(--accent);
  text-decoration: none;
  border-bottom: 1px dotted var(--accent-soft);
}

/* ── Blockquotes ───────────────────────────────────────────── */
blockquote {
  margin: 10pt 0;
  padding: 10pt 16pt;
  border-left: 4px solid var(--blockquote-border);
  background: var(--blockquote-bg);
  border-radius: 0 8px 8px 0;
  font-style: italic;
  color: var(--fg-secondary);
}

blockquote p { margin: 2pt 0; }

/* ── Lists ─────────────────────────────────────────────────── */
ul, ol {
  margin: 6pt 0 6pt 20pt;
  padding: 0;
}

li {
  margin: 3pt 0;
  padding-left: 4pt;
}

li::marker {
  color: var(--accent);
  font-weight: 600;
}

/* ── Code Blocks ───────────────────────────────────────────── */
pre {
  margin: 8pt 0;
  padding: 14pt 16pt;
  background: var(--code-bg);
  color: var(--code-fg);
  border-radius: 10px;
  font-family: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;
  font-size: 9pt;
  line-height: 1.6;
  overflow-x: auto;
  page-break-inside: avoid;
  box-shadow: var(--shadow), inset 0 1px 0 rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.05);
}

pre code {
  background: none;
  padding: 0;
  border: none;
  font-size: inherit;
  color: inherit;
  border-radius: 0;
}

code {
  font-family: 'JetBrains Mono', monospace;
  font-size: 9pt;
  background: #f1f5f9;
  color: #e11d48;
  padding: 1pt 5pt;
  border-radius: 4px;
  border: 1px solid var(--border);
}

/* ── Highlight.js - Catppuccin Mocha Theme ─────────────────── */
.hljs { background: var(--code-bg); color: var(--code-fg); }
.hljs-keyword, .hljs-built_in { color: #cba6f7; font-weight: 500; }
.hljs-type { color: #f9e2af; }
.hljs-literal, .hljs-number { color: #fab387; }
.hljs-string { color: #a6e3a1; }
.hljs-comment { color: #6c7086; font-style: italic; }
.hljs-function, .hljs-title { color: #89b4fa; }
.hljs-variable { color: #f38ba8; }
.hljs-operator { color: #89dceb; }
.hljs-symbol { color: #f5c2e7; }
.hljs-attr { color: #89b4fa; }
.hljs-meta { color: #f5e0dc; }

/* ── Tables ────────────────────────────────────────────────── */
table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  margin: 10pt 0;
  font-size: 9.5pt;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: var(--shadow);
  page-break-inside: avoid;
}

thead th {
  background: var(--table-header-bg);
  color: var(--table-header-fg);
  padding: 8pt 12pt;
  text-align: left;
  font-weight: 600;
  font-size: 9pt;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

tbody td {
  padding: 7pt 12pt;
  border-bottom: 1px solid var(--border);
}

tbody tr:nth-child(even) { background: var(--table-stripe); }
tbody tr:last-child td { border-bottom: none; }

/* ── Horizontal Rules ──────────────────────────────────────── */
hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, transparent, var(--border), transparent);
  margin: 16pt 0;
}

/* ── KaTeX fixes ───────────────────────────────────────────── */
.katex-display {
  margin: 8pt 0;
  overflow-x: auto;
}

.katex { font-size: 1.05em; }

/* ── Custom Badges (Year & Exam labels) ────────────────────── */

/* ── Page Break Helpers ────────────────────────────────────── */
h1 { page-break-before: always; }
h1:first-child { page-break-before: avoid; }

/* Prevent orphan headings */
h2, h3 { page-break-after: avoid; }
pre, table, blockquote { page-break-inside: avoid; }

/* ── Print-specific ────────────────────────────────────────── */
@media print {
  body { padding: 0; }
}

/* ── Title Page Styling ────────────────────────────────────── */
.title-block {
  text-align: center;
  padding: 40pt 20pt 30pt;
}

.title-block h1 {
  font-size: 28pt;
  border-bottom: none;
  margin-bottom: 8pt;
}

.title-block blockquote {
  border-left: none;
  background: none;
  font-style: normal;
  text-align: center;
  max-width: 85%;
  margin: 0 auto;
  padding: 8pt 0;
  color: var(--fg-secondary);
  font-size: 10pt;
}

/* First child special handling */
body > h1:first-child + blockquote {
  border-left: none;
  background: none;
  text-align: center;
  max-width: 85%;
  margin: 0 auto 20pt;
  font-style: normal;
  font-size: 10pt;
}

/* ── Emoji styling ─────────────────────────────────────────── */
</style>
</head>
<body>
${bodyHtml}
</body>
</html>`;

// ─── Write intermediate HTML (useful for debugging) ───────────────
const htmlPath = OUTPUT.replace(/\.pdf$/i, '.html');
fs.writeFileSync(htmlPath, fullHtml, 'utf-8');
console.log(`✅ HTML written to: ${htmlPath}`);

// ─── Launch Puppeteer & Generate PDF ──────────────────────────────
console.log('🖨️  Generating PDF...');

const browser = await puppeteer.launch({
  executablePath: '/usr/bin/google-chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

const page = await browser.newPage();

// Load the HTML from file so relative resources work
await page.goto(`file://${path.resolve(htmlPath)}`, { waitUntil: 'networkidle0', timeout: 60000 });

// Wait for KaTeX fonts to load
await page.waitForFunction(() => document.fonts.ready, { timeout: 15000 }).catch(() => {});

await page.pdf({
  path: OUTPUT,
  format: 'A4',
  printBackground: true,
  margin: {
    top: '20mm',
    bottom: '20mm',
    left: '18mm',
    right: '18mm',
  },
  displayHeaderFooter: true,
  headerTemplate: `
    <div style="font-size:7pt; color:#94a3b8; width:100%; text-align:center; font-family:Inter,sans-serif; padding:0 18mm;">
      FE Evening Exam — Pseudocode Collection
    </div>`,
  footerTemplate: `
    <div style="font-size:7pt; color:#94a3b8; width:100%; text-align:center; font-family:Inter,sans-serif; padding:0 18mm;">
      Page <span class="pageNumber"></span> of <span class="totalPages"></span>
    </div>`,
});

await browser.close();

console.log(`✅ PDF generated: ${path.resolve(OUTPUT)}`);
console.log(`📄 ${fs.statSync(OUTPUT).size / 1024 | 0} KB`);
