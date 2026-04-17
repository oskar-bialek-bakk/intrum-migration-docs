#!/usr/bin/env node
/**
 * Convert fetched Confluence HTML → Markdown files with frontmatter.
 *
 * Usage: node convert-to-markdown.js
 * Input:  ./fetched/*.json
 * Output: ../docs/ (nested folders)
 */

const fs = require('fs');
const path = require('path');
const TurndownService = require('turndown');
const { gfm } = require('turndown-plugin-gfm');

const FETCHED = path.join(__dirname, 'fetched');
const DOCS    = path.join(__dirname, '..', 'docs');

// ---- title → folder/filename mapping ----------------------------------------

const STRUCTURE = {
  // Root page → index.md
  '142002476': { dir: '', file: 'index.md' },

  // Section index pages — map Confluence title to folder
  'Intrum⬝ Założenia':                       { dir: 'zalozenia',           file: 'index.md' },
  'Intrum⬝ Architektura fizyczna':            { dir: 'architektura',        file: 'index.md' },
  'Intrum ⬝ Funkcje API':                     { dir: 'funkcje-api',         file: 'index.md' },
  'Intrum ⬝ Funkcje API ⬝ Importy':          { dir: 'funkcje-api/importy', file: 'index.md' },
  'Intrum⬝ Komunikaty':                       { dir: 'komunikaty',          file: 'index.md' },
  'Intrum ⬝ Kolejki':                         { dir: 'kolejki',             file: 'index.md' },
  'Intrum ⬝ Przypadki użycia API':            { dir: 'przypadki-uzycia',    file: 'index.md' },
};

function slugify(title) {
  return title
    .replace(/^Intrum\s*⬝?\s*/i, '')  // strip "Intrum⬝ " prefix
    .toLowerCase()
    .replace(/[ąàáâ]/g, 'a').replace(/[ćč]/g, 'c').replace(/[ęèéê]/g, 'e')
    .replace(/[ł]/g, 'l').replace(/[ńñ]/g, 'n').replace(/[óòôö]/g, 'o')
    .replace(/[śš]/g, 's').replace(/[źżž]/g, 'z').replace(/[üù]/g, 'u')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

function resolveLocation(record) {
  // Check by page ID first (root page)
  if (STRUCTURE[record.id]) return STRUCTURE[record.id];
  // Check by title
  if (STRUCTURE[record.title]) return STRUCTURE[record.title];

  // Derive from parent
  const parentDir = resolveParentDir(record.parentTitle);
  return { dir: parentDir, file: slugify(record.title) + '.md' };
}

function resolveParentDir(parentTitle) {
  if (!parentTitle) return '';
  for (const [key, val] of Object.entries(STRUCTURE)) {
    if (key === parentTitle) return val.dir;
  }
  // Fallback: slugify the parent title
  return slugify(parentTitle);
}

// ---- turndown setup ---------------------------------------------------------

const td = new TurndownService({
  headingStyle: 'atx',
  codeBlockStyle: 'fenced',
  bulletListMarker: '-',
});
td.use(gfm);

// Handle Confluence structured macros — code blocks
td.addRule('confluenceCode', {
  filter: (node) => {
    return node.nodeName === 'AC:STRUCTURED-MACRO' ||
           (node.getAttribute && node.getAttribute('ac:name') === 'code');
  },
  replacement: (content, node) => {
    const bodyEl = node.querySelector('ac\\:plain-text-body, ac\\3a plain-text-body');
    const langEl = node.querySelector('ac\\:parameter[ac\\:name="language"], ac\\3a parameter');
    const code = bodyEl ? bodyEl.textContent : content;
    const lang = langEl ? langEl.textContent : '';
    return `\n\`\`\`${lang}\n${code.trim()}\n\`\`\`\n`;
  },
});

// Handle Confluence info/warning/note macros → admonitions
td.addRule('confluenceAdmonition', {
  filter: (node) => {
    if (node.nodeName !== 'AC:STRUCTURED-MACRO') return false;
    const name = node.getAttribute('ac:name');
    return ['info', 'warning', 'note', 'tip'].includes(name);
  },
  replacement: (content, node) => {
    const type = node.getAttribute('ac:name') || 'info';
    const titleEl = node.querySelector('ac\\:parameter[ac\\:name="title"]');
    const title = titleEl ? titleEl.textContent : '';
    const body = content.trim();
    const header = title ? `!!! ${type} "${title}"` : `!!! ${type}`;
    const indented = body.split('\n').map(l => '    ' + l).join('\n');
    return `\n${header}\n${indented}\n`;
  },
});

// ---- convert ----------------------------------------------------------------

function buildFrontmatter(record, cleanedTitle) {
  const lines = ['---'];
  lines.push(`title: "${cleanedTitle}"`);
  if (record.labels.length > 0) {
    lines.push('tags:');
    for (const l of record.labels) lines.push(`  - ${l}`);
  }
  lines.push('---');
  return lines.join('\n');
}

function cleanTitle(title) {
  return title.replace(/^Intrum\s*⬝?\s*/i, '').trim();
}

function main() {
  const files = fs.readdirSync(FETCHED).filter(f => f.endsWith('.json'));
  console.log(`Converting ${files.length} pages...\n`);

  // Load all records first to build parent mapping
  const records = files.map(f => JSON.parse(fs.readFileSync(path.join(FETCHED, f), 'utf-8')));

  for (const rec of records) {
    const loc = resolveLocation(rec);
    const outDir = path.join(DOCS, loc.dir);
    const outFile = path.join(outDir, loc.file);

    if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

    const title = cleanTitle(rec.title);
    const frontmatter = buildFrontmatter(rec, title);
    const markdown = rec.html ? td.turndown(rec.html) : '';
    const content = frontmatter + '\n\n' + markdown.trim() + '\n';

    fs.writeFileSync(outFile, content);
    console.log(`  ${loc.dir ? loc.dir + '/' : ''}${loc.file}`);
  }

  console.log(`\nDone. Output in ${DOCS}/`);
}

main();
