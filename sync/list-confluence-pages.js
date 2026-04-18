#!/usr/bin/env node
/**
 * List all descendant pages under CONF_PARENT, with labels and child counts.
 *
 * Usage:
 *   node list-confluence-pages.js
 *
 * Output: tree of pages under CONF_PARENT with `[labels]` and `(N child)`
 *         markers. Pairs with sync-to-confluence.js for pre-cleanup audit.
 */

const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, 'utf-8').split('\n')) {
    const m = line.match(/^\s*([^#=]+?)\s*=\s*(.*?)\s*$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2];
  }
}

const BASE_URL     = process.env.CONF_URL?.replace(/\/$/, '');
const USER         = process.env.CONF_USER;
const PASS         = process.env.CONF_PASS;
const SPACE        = process.env.CONF_SPACE || 'INTRUM';
const PARENT_TITLE = process.env.CONF_PARENT || 'Migracja danych';

if (!BASE_URL || !USER || !PASS) {
  console.error('ERR  Set CONF_URL, CONF_USER, CONF_PASS in sync/.env');
  process.exit(1);
}

const AUTH = 'Basic ' + Buffer.from(`${USER}:${PASS}`).toString('base64');
const API  = `${BASE_URL}/rest/api`;

async function req(urlPath) {
  const res = await fetch(`${API}${urlPath}`, {
    headers: { 'Authorization': AUTH, 'Accept': 'application/json' },
  });
  if (!res.ok) throw new Error(`GET ${urlPath} -> ${res.status}`);
  return res.json();
}

async function findPage(title) {
  const data = await req(
    `/content?spaceKey=${SPACE}&title=${encodeURIComponent(title)}&type=page`
  );
  return data.results?.[0] || null;
}

async function getChildren(pageId) {
  const out = [];
  let start = 0;
  while (true) {
    const data = await req(
      `/content/${pageId}/child/page?limit=50&start=${start}&expand=metadata.labels`
    );
    out.push(...data.results);
    if (data.results.length < 50) break;
    start += 50;
  }
  return out;
}

async function walk(pageId, depth) {
  const kids = await getChildren(pageId);
  for (const p of kids) {
    const labels = (p.metadata?.labels?.results || []).map(l => l.name);
    const labelStr = labels.length ? `  [${labels.join(', ')}]` : '';
    const indent = '  '.repeat(depth);
    console.log(`${indent}• ${p.title}${labelStr}  (id: ${p.id})`);
    await walk(p.id, depth + 1);
  }
}

async function main() {
  const parent = await findPage(PARENT_TITLE);
  if (!parent) {
    console.error(`ERR  parent page "${PARENT_TITLE}" not found in ${SPACE}`);
    process.exit(1);
  }
  console.log(
    `Space: ${SPACE}\nParent: "${PARENT_TITLE}" (id: ${parent.id})\n`
  );
  await walk(parent.id, 0);
  console.log('\nDone.');
}

main().catch(e => { console.error('\nERR', e.message); process.exit(1); });
