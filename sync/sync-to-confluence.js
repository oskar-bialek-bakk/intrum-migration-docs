#!/usr/bin/env node
/**
 * Sync Markdown docs → Confluence.
 *
 * Usage:
 *   node sync-to-confluence.js                          # sync all docs
 *   node sync-to-confluence.js docs/komunikaty/case.md  # sync one file
 *
 * Features:
 *   - Folder structure → Confluence page hierarchy (auto)
 *   - Change detection — skip update if content + labels unchanged
 *   - Admonitions → Confluence info/warning/note macros
 *   - Relative Markdown links → Confluence page links
 *   - Snippets (--8<--) → expanded before upload
 *   - BRQ labels from frontmatter → Confluence labels (additive only)
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');
const { marked } = require('marked');

// ---- load .env --------------------------------------------------------------

const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, 'utf-8').split('\n')) {
    const m = line.match(/^\s*([^#=]+?)\s*=\s*(.*?)\s*$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2];
  }
}

const BASE_URL    = process.env.CONF_URL?.replace(/\/$/, '');
const USER        = process.env.CONF_USER;
const PASS        = process.env.CONF_PASS;
const SPACE       = process.env.CONF_SPACE || 'INTRUM';
const DRAFT_TITLE = process.env.CONF_PARENT || 'Migracja danych';

if (!BASE_URL || !USER || !PASS) {
  console.error('ERR  Set CONF_URL, CONF_USER, CONF_PASS');
  process.exit(1);
}

const AUTH    = 'Basic ' + Buffer.from(`${USER}:${PASS}`).toString('base64');
const API     = `${BASE_URL}/rest/api`;
const DOCS    = path.join(__dirname, '..', 'docs');

// ---- frontmatter parser -----------------------------------------------------

function parseFrontmatter(content) {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: content };

  const meta = {};
  let currentKey = null;
  for (const line of match[1].split('\n')) {
    const kv = line.match(/^(\w+):\s*(.*)$/);
    if (kv) {
      currentKey = kv[1];
      const val = kv[2].trim().replace(/^["']|["']$/g, '');
      meta[currentKey] = val || null;
      continue;
    }
    const arr = line.match(/^\s+-\s+(.+)$/);
    if (arr && currentKey) {
      if (!Array.isArray(meta[currentKey])) meta[currentKey] = [];
      meta[currentKey].push(arr[1].trim());
    }
  }
  return { meta, body: match[2] };
}

// ---- snippet expansion ------------------------------------------------------

function expandSnippets(md, baseDir) {
  return md.replace(/^--8<--\s+"(.+)"\s*$/gm, (_, snippetPath) => {
    const fullPath = path.join(baseDir, snippetPath);
    if (fs.existsSync(fullPath)) {
      return fs.readFileSync(fullPath, 'utf-8').trim();
    }
    console.log(`  WARN  snippet not found: ${snippetPath}`);
    return `<!-- snippet not found: ${snippetPath} -->`;
  });
}

// ---- admonition pre-processing ---------------------------------------------

/**
 * Extract admonitions, replace with placeholders, return map of placeholders→XML.
 * This prevents marked from wrapping Confluence XML in <p> tags.
 */
function extractAdmonitions(md) {
  const placeholders = {};
  let idx = 0;

  // Process line-by-line to handle multi-paragraph admonitions with blank lines
  const lines = md.split('\n');
  const result = [];
  let i = 0;

  while (i < lines.length) {
    const admonMatch = lines[i].match(/^!!! (\w+)(?: "([^"]*)")?[ \t]*$/);
    if (admonMatch) {
      const type = admonMatch[1];
      const title = admonMatch[2] || null;
      const confType = { warning: 'warning', danger: 'warning', note: 'note', tip: 'tip', info: 'info', example: 'info' }[type] || 'info';

      // Collect body: indented lines + blank lines (until a non-blank non-indented line)
      i++;
      const bodyLines = [];
      while (i < lines.length) {
        const line = lines[i];
        if (line.match(/^[ \t]/) || line.trim() === '') {
          bodyLines.push(line.replace(/^[ \t]{4}/, ''));
          i++;
        } else {
          break;
        }
      }

      const content = bodyLines.join('\n').trim();
      const titleParam = title ? `<ac:parameter ac:name="title">${title}</ac:parameter>` : '';
      const xml = `<ac:structured-macro ac:name="${confType}">${titleParam}<ac:rich-text-body><p>${content}</p></ac:rich-text-body></ac:structured-macro>`;
      const key = `ADMONITION_PLACEHOLDER_${idx++}`;
      placeholders[key] = xml;
      result.push('');
      result.push(key);
      result.push('');
    } else {
      result.push(lines[i]);
      i++;
    }
  }

  return { processed: result.join('\n'), placeholders };
}

function restoreAdmonitions(html, placeholders) {
  let result = html;
  for (const [key, xml] of Object.entries(placeholders)) {
    // Replace <p>KEY</p> or KEY (in case marked wraps it)
    result = result.replace(new RegExp(`<p>${key}</p>`, 'g'), xml);
    result = result.replace(new RegExp(key, 'g'), xml);
  }
  return result;
}

// ---- markdown link rewriting ------------------------------------------------

function rewriteLinks(md, allFiles) {
  // Replace relative .md links with Confluence page title references
  return md.replace(
    /\[([^\]]+)\]\(([^)]+\.md(?:#[^)]*)?)\)/g,
    (match, text, href) => {
      const [filePart] = href.split('#');
      const targetFile = allFiles.find(f => f.relativePath === filePart || f.relativePath.endsWith(filePart.replace(/^\.\.\//, '')));
      if (targetFile) {
        return `<a href="${BASE_URL}/display/${SPACE}/${encodeURIComponent(targetFile.title)}">${text}</a>`;
      }
      return match; // leave unchanged if target not found
    }
  );
}

// ---- markdown → confluence HTML ---------------------------------------------

function markdownToConfluenceHtml(md, filePath, allFiles) {
  let processed = expandSnippets(md, DOCS);
  processed = rewriteLinks(processed, allFiles);
  const { processed: withPlaceholders, placeholders } = extractAdmonitions(processed);
  let html = marked.parse(withPlaceholders, { xhtml: true });
  // Confluence XHTML parser rejects HTML5 boolean attributes (e.g. `<div markdown>`).
  // `markdown` is a pymdownx/md_in_html directive — strip it.
  html = html.replace(/\s+markdown(?=[\s>])/g, '');
  // `open` on <details> — convert to XHTML form `open="open"`.
  html = html.replace(/(<details\b[^>]*?)\s+open(?=[\s>])/g, '$1 open="open"');
  // Confluence XHTML requires self-closing void elements (img, br, hr).
  // marked's `xhtml` option doesn't handle img properly — force self-closing.
  html = html.replace(/<img\b([^>]*?)(?<!\/)>/g, '<img$1 />');
  html = html.replace(/<br>/g, '<br />');
  html = html.replace(/<hr>/g, '<hr />');
  return restoreAdmonitions(html, placeholders);
}

// ---- HTML entity normalization for change detection -------------------------

/**
 * Decode named/numeric HTML entities so that Confluence-stored content
 * (which uses &oacute; etc.) compares equal to our UTF-8 generated HTML.
 */
// HTML named entity table — covers Latin, arrows, math, punctuation
const HTML_ENTITIES = {
  // Basic
  amp:'&',lt:'<',gt:'>',quot:'"',apos:"'",nbsp:'\u00a0',
  // Latin Extended
  Agrave:'À',Aacute:'Á',Acirc:'Â',Atilde:'Ã',Auml:'Ä',Aring:'Å',AElig:'Æ',Ccedil:'Ç',
  Egrave:'È',Eacute:'É',Ecirc:'Ê',Euml:'Ë',Igrave:'Ì',Iacute:'Í',Icirc:'Î',Iuml:'Ï',
  ETH:'Ð',Ntilde:'Ñ',Ograve:'Ò',Oacute:'Ó',Ocirc:'Ô',Otilde:'Õ',Ouml:'Ö',Oslash:'Ø',
  Ugrave:'Ù',Uacute:'Ú',Ucirc:'Û',Uuml:'Ü',Yacute:'Ý',THORN:'Þ',szlig:'ß',
  agrave:'à',aacute:'á',acirc:'â',atilde:'ã',auml:'ä',aring:'å',aelig:'æ',ccedil:'ç',
  egrave:'è',eacute:'é',ecirc:'ê',euml:'ë',igrave:'ì',iacute:'í',icirc:'î',iuml:'ï',
  eth:'ð',ntilde:'ñ',ograve:'ò',oacute:'ó',ocirc:'ô',otilde:'õ',ouml:'ö',oslash:'ø',
  ugrave:'ù',uacute:'ú',ucirc:'û',uuml:'ü',yacute:'ý',thorn:'þ',yuml:'ÿ',
  // Currency & symbols
  euro:'€',pound:'£',yen:'¥',cent:'¢',copy:'©',reg:'®',trade:'™',
  laquo:'«',raquo:'»',middot:'·',para:'¶',sect:'§',deg:'°',plusmn:'±',
  frac12:'½',frac14:'¼',frac34:'¾',sup1:'¹',sup2:'²',sup3:'³',
  // Punctuation & typographic
  mdash:'—',ndash:'–',hellip:'…',bull:'•',lsquo:'\u2018',rsquo:'\u2019',
  ldquo:'\u201c',rdquo:'\u201d',sbquo:'\u201a',bdquo:'\u201e',
  dagger:'†',Dagger:'‡',permil:'‰',
  // Arrows
  larr:'←',rarr:'→',uarr:'↑',darr:'↓',harr:'↔',
  lArr:'⇐',rArr:'⇒',uArr:'⇑',dArr:'⇓',hArr:'⇔',
  // Math
  times:'×',divide:'÷',minus:'−',prime:'′',Prime:'″',
  sum:'∑',prod:'∏',infin:'∞',part:'∂',nabla:'∇',
  forall:'∀',exist:'∃',empty:'∅',isin:'∈',notin:'∉',
  ni:'∋',land:'∧',lor:'∨',cap:'∩',cup:'∪',int:'∫',
  there4:'∴',sim:'∼',cong:'≅',asymp:'≈',ne:'≠',
  equiv:'≡',le:'≤',ge:'≥',sub:'⊂',sup:'⊃',sube:'⊆',supe:'⊇',
  oplus:'⊕',otimes:'⊗',perp:'⊥',sdot:'⋅',
  // Greek
  Alpha:'Α',Beta:'Β',Gamma:'Γ',Delta:'Δ',Epsilon:'Ε',Zeta:'Ζ',Eta:'Η',Theta:'Θ',
  Iota:'Ι',Kappa:'Κ',Lambda:'Λ',Mu:'Μ',Nu:'Ν',Xi:'Ξ',Omicron:'Ο',Pi:'Π',
  Rho:'Ρ',Sigma:'Σ',Tau:'Τ',Upsilon:'Υ',Phi:'Φ',Chi:'Χ',Psi:'Ψ',Omega:'Ω',
  alpha:'α',beta:'β',gamma:'γ',delta:'δ',epsilon:'ε',zeta:'ζ',eta:'η',theta:'θ',
  iota:'ι',kappa:'κ',lambda:'λ',mu:'μ',nu:'ν',xi:'ξ',omicron:'ο',pi:'π',
  rho:'ρ',sigmaf:'ς',sigma:'σ',tau:'τ',upsilon:'υ',phi:'φ',chi:'χ',psi:'ψ',omega:'ω',
  // Misc
  spades:'♠',clubs:'♣',hearts:'♥',diams:'♦',
};

function decodeHtmlEntities(str) {
  return str
    .replace(/&#(\d+);/g, (_, dec) => String.fromCodePoint(Number(dec)))
    .replace(/&#x([0-9a-fA-F]+);/g, (_, hex) => String.fromCodePoint(parseInt(hex, 16)))
    .replace(/&([a-zA-Z][a-zA-Z0-9]{1,8});/g, (match, name) => HTML_ENTITIES[name] || match);
}

// ---- confluence API ---------------------------------------------------------

async function req(method, urlPath, body) {
  const res = await fetch(`${API}${urlPath}`, {
    method,
    headers: {
      'Authorization': AUTH,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`${method} ${urlPath} -> ${res.status}\n${txt}`);
  }
  return res.json();
}

async function findPage(title) {
  const data = await req('GET',
    `/content?spaceKey=${SPACE}&title=${encodeURIComponent(title)}&type=page&expand=version,body.storage,metadata.labels`
  );
  return data.results?.[0] || null;
}

async function createPage(parentId, title, htmlBody) {
  return req('POST', '/content', {
    type: 'page',
    title,
    space: { key: SPACE },
    ancestors: [{ id: parentId }],
    body: { storage: { value: htmlBody, representation: 'storage' } },
  });
}

async function updatePage(pageId, title, htmlBody, currentVersion) {
  return req('PUT', `/content/${pageId}`, {
    type: 'page',
    title,
    version: { number: currentVersion + 1 },
    body: { storage: { value: htmlBody, representation: 'storage' } },
  });
}

async function getLabels(pageId) {
  const data = await req('GET', `/content/${pageId}/label`);
  return data.results.map(l => l.name);
}

async function addLabels(pageId, labels) {
  if (!labels.length) return;
  return req('POST', `/content/${pageId}/label`, labels.map(name => ({ prefix: 'global', name })));
}

// ---- file discovery ---------------------------------------------------------

function discoverFiles(inputFiles) {
  let mdFiles;
  if (inputFiles.length > 0) {
    mdFiles = inputFiles.map(f => path.resolve(f));
  } else {
    mdFiles = glob.sync('**/*.md', { cwd: DOCS, absolute: true });
  }

  return mdFiles.map(absPath => {
    const relativePath = path.relative(DOCS, absPath).replace(/\\/g, '/');
    const raw = fs.readFileSync(absPath, 'utf-8');
    const { meta, body } = parseFrontmatter(raw);
    const title = meta.title || path.basename(absPath, '.md');
    const tags = Array.isArray(meta.tags) ? meta.tags : [];
    const parentOverride = typeof meta.parent === 'string' ? meta.parent : null;

    return { absPath, relativePath, raw, body, title, tags, parentOverride };
  });
}

// ---- hierarchy resolution ---------------------------------------------------

function resolveParentTitle(file, allFiles) {
  if (file.parentOverride) return file.parentOverride;

  const parts = file.relativePath.split('/');

  if (parts.length === 1) {
    // Top-level file (e.g., index.md) → DRAFT parent
    return DRAFT_TITLE;
  }

  if (parts[parts.length - 1] === 'index.md') {
    // This is a directory index — parent is the index one level up
    const parentDirParts = parts.slice(0, -2); // drop filename + current dir
    if (parentDirParts.length === 0) {
      // e.g., zalozenia/index.md → parent is root index.md
      const rootIndex = allFiles.find(f => f.relativePath === 'index.md');
      return rootIndex ? rootIndex.title : DRAFT_TITLE;
    }
    // e.g., funkcje-api/importy/index.md → parent is funkcje-api/index.md
    const parentIndexPath = parentDirParts.join('/') + '/index.md';
    const parentIndex = allFiles.find(f => f.relativePath === parentIndexPath);
    return parentIndex ? parentIndex.title : DRAFT_TITLE;
  }

  // Regular file — parent is the index.md in the same directory
  const parentDir = parts.slice(0, -1).join('/');
  const parentIndex = allFiles.find(f => f.relativePath === parentDir + '/index.md');
  return parentIndex ? parentIndex.title : DRAFT_TITLE;
}

// ---- sync logic -------------------------------------------------------------

async function syncFile(file, allFiles, parentCache) {
  const parentTitle = resolveParentTitle(file, allFiles);

  // Resolve parent page ID (with cache)
  if (!parentCache[parentTitle]) {
    const parentPage = await findPage(parentTitle);
    if (parentPage) {
      parentCache[parentTitle] = parentPage.id;
    } else {
      console.log(`  WARN  parent "${parentTitle}" not found, skipping ${file.relativePath}`);
      return;
    }
  }
  const parentId = parentCache[parentTitle];

  // Generate HTML
  const html = markdownToConfluenceHtml(file.body, file.absPath, allFiles);

  // Check if page exists
  const existing = await findPage(file.title);

  if (existing) {
    // Change detection — compare HTML content after normalization
    // Confluence may: encode entities, use self-closing empty tags, drop start=N from <ol>
    const normalizeForCompare = s => decodeHtmlEntities(s)
      .replace(/\u00a0/g, ' ')                    // non-breaking space → regular space
      .replace(/<(\w+)\s*\/>/g, '<$1></$1>')       // self-closing → open+close: <th /> → <th></th>
      .replace(/<ol(\s+start="\d+")?>/g, '<ol>')   // strip start attribute from <ol> for comparison
      .trim();
    const existingHtml = normalizeForCompare(existing.body?.storage?.value || '');
    const generatedHtml = normalizeForCompare(html);
    const existingLabels = existing.metadata?.labels?.results?.map(l => l.name) || [];
    const newLabels = file.tags.filter(l => !existingLabels.includes(l));

    if (existingHtml === generatedHtml && newLabels.length === 0) {
      console.log(`  SKIP  "${file.title}" (no changes)`);
      return;
    }

    const ver = existing.version.number;
    await updatePage(existing.id, file.title, html, ver);
    console.log(`  UPDATE  "${file.title}" v${ver} -> v${ver + 1}`);

    if (newLabels.length > 0) {
      await addLabels(existing.id, newLabels);
      console.log(`  TAG+  ${newLabels.join(', ')}`);
    }
  } else {
    const created = await createPage(parentId, file.title, html);
    console.log(`  CREATE  "${file.title}" (id: ${created.id})`);

    if (file.tags.length > 0) {
      await addLabels(created.id, file.tags);
      console.log(`  TAG+  ${file.tags.join(', ')}`);
    }
  }
}

// ---- main -------------------------------------------------------------------

async function main() {
  console.log(`Confluence: ${BASE_URL} | Space: ${SPACE} | Parent: ${DRAFT_TITLE}\n`);

  try {
    await req('GET', `/space/${SPACE}`);
    console.log('Connection OK\n');
  } catch (e) {
    console.error('ERR Connection failed:', e.message);
    process.exit(1);
  }

  const inputFiles = process.argv.slice(2);
  // Always discover all files for parent resolution, even in single-file mode
  const allFiles = discoverFiles([]);
  const filesToSync = inputFiles.length > 0
    ? discoverFiles(inputFiles)
    : allFiles;
  console.log(`Found ${filesToSync.length} files to sync (${allFiles.length} total for hierarchy)\n`);

  // Sort: index.md files first (parents before children)
  filesToSync.sort((a, b) => {
    const aIdx = a.relativePath.endsWith('index.md') ? 0 : 1;
    const bIdx = b.relativePath.endsWith('index.md') ? 0 : 1;
    if (aIdx !== bIdx) return aIdx - bIdx;
    return a.relativePath.localeCompare(b.relativePath);
  });

  const parentCache = {};
  for (const file of filesToSync) {
    await syncFile(file, allFiles, parentCache);
  }

  console.log('\nDone.');
}

main().catch(e => { console.error('\nERR', e.message); process.exit(1); });
