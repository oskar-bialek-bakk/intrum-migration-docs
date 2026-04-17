#!/usr/bin/env node
/**
 * Fetch Confluence page tree → local HTML files with metadata.
 *
 * Usage: node fetch-from-confluence.js
 * Output: ./fetched/<page-id>.json (title, labels, html, children)
 */

const fs = require('fs');
const path = require('path');

// ---- load .env --------------------------------------------------------------
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, 'utf-8').split('\n')) {
    const m = line.match(/^\s*([^#=]+?)\s*=\s*(.*?)\s*$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2];
  }
}

const BASE_URL = process.env.CONF_URL?.replace(/\/$/, '');
const USER     = process.env.CONF_USER;
const PASS     = process.env.CONF_PASS;
const SPACE    = process.env.CONF_SPACE || 'INTRUM';
const ROOT_ID  = '142002476'; // "Dokumentacja techniczna DEBT Manager - API Integracyjne"

if (!BASE_URL || !USER || !PASS) {
  console.error('ERR  Set CONF_URL, CONF_USER, CONF_PASS in .env');
  process.exit(1);
}

const AUTH = 'Basic ' + Buffer.from(`${USER}:${PASS}`).toString('base64');
const API  = `${BASE_URL}/rest/api`;
const OUT  = path.join(__dirname, 'fetched');

async function req(method, urlPath) {
  const res = await fetch(`${API}${urlPath}`, {
    method,
    headers: { 'Authorization': AUTH, 'Accept': 'application/json' },
  });
  if (!res.ok) throw new Error(`${method} ${urlPath} -> ${res.status}`);
  return res.json();
}

async function fetchPage(id) {
  return req('GET', `/content/${id}?expand=body.storage,metadata.labels,version`);
}

async function fetchChildren(id) {
  const data = await req('GET', `/content/${id}/child/page?limit=100`);
  return data.results || [];
}

async function crawl(id, parentTitle, depth) {
  const page = await fetchPage(id);
  const labels = page.metadata?.labels?.results?.map(l => l.name) || [];
  const html = page.body?.storage?.value || '';
  const title = page.title;

  const record = {
    id: page.id,
    title,
    parentTitle,
    labels,
    html,
    depth,
  };

  const outFile = path.join(OUT, `${page.id}.json`);
  fs.writeFileSync(outFile, JSON.stringify(record, null, 2));
  console.log('  '.repeat(depth) + `${title} [${page.id}] labels:[${labels.join(',')}] html:${html.length}c`);

  const children = await fetchChildren(id);
  for (const child of children) {
    await crawl(child.id, title, depth + 1);
  }
}

async function main() {
  console.log(`Fetching from ${BASE_URL} space:${SPACE} root:${ROOT_ID}\n`);
  if (!fs.existsSync(OUT)) fs.mkdirSync(OUT, { recursive: true });
  await crawl(ROOT_ID, null, 0);
  console.log(`\nDone. Files in ${OUT}/`);
}

main().catch(e => { console.error('ERR', e.message); process.exit(1); });
