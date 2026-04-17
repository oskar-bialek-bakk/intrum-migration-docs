/**
 * fix-code-blocks.js
 *
 * Reads each .json file from fetched/, extracts code blocks from
 * ac:structured-macro ac:name="code" elements, then fills in the empty
 * fenced code blocks in the corresponding .md files.
 */

const fs = require('fs');
const path = require('path');

const FETCHED_DIR = path.resolve(__dirname, 'fetched');
const DOCS_DIR = path.resolve(__dirname, '../docs');

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────

function cleanTitle(t) {
  return t.replace(/^Intrum\s*⬝?\s*/i, '').trim();
}

function extractFrontmatterTitle(content) {
  const m = content.match(/^---\r?\n[\s\S]*?title:\s*"?([^"\r\n]+)"?\r?\n[\s\S]*?---/m);
  return m ? m[1].trim() : null;
}

/**
 * Extract all code blocks from Confluence HTML.
 * Returns array of { language, code }.
 */
function extractCodeBlocks(html) {
  const macroRegex = /<ac:structured-macro[^>]*ac:name="code"[^>]*>([\s\S]*?)<\/ac:structured-macro>/g;
  const blocks = [];
  let match;
  while ((match = macroRegex.exec(html)) !== null) {
    const inner = match[1];
    const langMatch = inner.match(/<ac:parameter[^>]*ac:name="language"[^>]*>([\s\S]*?)<\/ac:parameter>/);
    const cdataMatch = inner.match(/<!\[CDATA\[([\s\S]*?)\]\]>/);
    if (cdataMatch) {
      blocks.push({
        language: langMatch ? langMatch[1].trim() : 'json',
        code: cdataMatch[1],
      });
    }
  }
  return blocks;
}

/**
 * Count empty fenced code blocks (``` lang\n\n```) in content.
 * Returns the count.
 */
function countEmptyCodeBlocks(content) {
  const regex = /```(\w*)\r?\n\r?\n```/g;
  let count = 0;
  while (regex.exec(content) !== null) count++;
  return count;
}

/**
 * Replace empty fenced code blocks one-by-one with provided code blocks.
 * If counts don't match, replaces as many as possible then reports.
 */
function fillCodeBlocks(content, codeBlocks) {
  let blockIdx = 0;
  let replaced = 0;
  // Match empty code blocks (handles both \n and \r\n)
  const result = content.replace(/```(\w*)\r?\n\r?\n```/g, (fullMatch, lang) => {
    if (blockIdx >= codeBlocks.length) return fullMatch; // no more replacements
    const block = codeBlocks[blockIdx++];
    replaced++;
    const useLang = block.language || lang || 'json';
    return '```' + useLang + '\n' + block.code + '\n```';
  });
  return { result, replaced };
}

// ──────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────

function findAllMdFiles(dir) {
  const result = [];
  const items = fs.readdirSync(dir, { withFileTypes: true });
  for (const item of items) {
    const full = path.join(dir, item.name);
    if (item.isDirectory()) result.push(...findAllMdFiles(full));
    else if (item.name.endsWith('.md')) result.push(full);
  }
  return result;
}

// 1. Build map: cleanTitle -> fetched JSON data (only files with code blocks)
const titleToJson = new Map();
const fetchedFiles = fs.readdirSync(FETCHED_DIR).filter(f => f.endsWith('.json'));
for (const f of fetchedFiles) {
  const data = JSON.parse(fs.readFileSync(path.join(FETCHED_DIR, f), 'utf8'));
  if (!data.html || !data.html.includes('ac:name="code"')) continue;
  const blocks = extractCodeBlocks(data.html);
  if (blocks.length === 0) continue;
  const title = cleanTitle(data.title);
  titleToJson.set(title, { file: f, title: data.title, blocks });
}

console.log(`Found ${titleToJson.size} JSON files with code blocks.`);

// 2. Process each .md file
const mdFiles = findAllMdFiles(DOCS_DIR);
let updatedCount = 0;
let skippedCount = 0;
const unmatched = [];
const mismatched = [];

for (const mdFile of mdFiles) {
  const content = fs.readFileSync(mdFile, 'utf8');

  // Check if it has any empty code blocks
  const emptyCount = countEmptyCodeBlocks(content);
  if (emptyCount === 0) {
    skippedCount++;
    continue; // nothing to do
  }

  // Get frontmatter title
  const mdTitle = extractFrontmatterTitle(content);
  if (!mdTitle) {
    unmatched.push({ file: mdFile, reason: 'no frontmatter title' });
    continue;
  }

  // Find matching JSON
  const jsonData = titleToJson.get(mdTitle);
  if (!jsonData) {
    unmatched.push({ file: mdFile, reason: `no JSON match for title "${mdTitle}"` });
    continue;
  }

  const { blocks } = jsonData;

  if (blocks.length !== emptyCount) {
    mismatched.push({
      file: mdFile,
      mdTitle,
      emptyCount,
      blockCount: blocks.length,
    });
    // Still attempt to fill as many as possible
  }

  const { result, replaced } = fillCodeBlocks(content, blocks);

  if (replaced === 0) {
    skippedCount++;
    continue;
  }

  fs.writeFileSync(mdFile, result, 'utf8');
  updatedCount++;
  const rel = path.relative(DOCS_DIR, mdFile).replace(/\\/g, '/');
  console.log(`  UPDATED (${replaced} block(s)): ${rel}`);
}

// ──────────────────────────────────────────────
// Report
// ──────────────────────────────────────────────

console.log('\n=== Summary ===');
console.log(`Files updated:  ${updatedCount}`);
console.log(`Files skipped (no empty blocks or already filled): ${skippedCount}`);

if (mismatched.length > 0) {
  console.log('\n--- Block count mismatches (partial fill attempted) ---');
  for (const m of mismatched) {
    const rel = path.relative(DOCS_DIR, m.file).replace(/\\/g, '/');
    console.log(`  ${rel}: md has ${m.emptyCount} empty blocks, JSON has ${m.blockCount} blocks`);
  }
}

if (unmatched.length > 0) {
  console.log('\n--- Unmatched .md files (had empty blocks but no JSON match) ---');
  for (const u of unmatched) {
    const rel = path.relative(DOCS_DIR, u.file).replace(/\\/g, '/');
    console.log(`  ${rel}: ${u.reason}`);
  }
}
