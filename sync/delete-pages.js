#!/usr/bin/env node
/**
 * Delete Confluence pages by ID.
 *
 * Usage:
 *   node delete-pages.js <id> [id...]
 *
 * Pairs with list-confluence-pages.js — copy IDs from that tool's output
 * into the argv. Each ID is DELETEd via REST; children (if any) are
 * orphaned by Confluence to the parent's parent.
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

const BASE_URL = process.env.CONF_URL?.replace(/\/$/, '');
const USER     = process.env.CONF_USER;
const PASS     = process.env.CONF_PASS;

if (!BASE_URL || !USER || !PASS) {
  console.error('ERR  Set CONF_URL, CONF_USER, CONF_PASS in sync/.env');
  process.exit(1);
}

const AUTH = 'Basic ' + Buffer.from(`${USER}:${PASS}`).toString('base64');
const API  = `${BASE_URL}/rest/api`;

async function req(method, urlPath) {
  const res = await fetch(`${API}${urlPath}`, {
    method,
    headers: { 'Authorization': AUTH, 'Accept': 'application/json' },
  });
  if (res.status === 204) return null;
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`${method} ${urlPath} -> ${res.status}\n${txt}`);
  }
  return res.json();
}

async function main() {
  const ids = process.argv.slice(2).filter(Boolean);
  if (ids.length === 0) {
    console.error('Usage: node delete-pages.js <id> [id...]');
    process.exit(1);
  }

  console.log(`Deleting ${ids.length} page(s) from ${BASE_URL}\n`);

  let ok = 0, fail = 0;
  for (const id of ids) {
    try {
      const page = await req('GET', `/content/${id}`);
      const title = page?.title || '(unknown)';
      await req('DELETE', `/content/${id}`);
      console.log(`  DELETE  "${title}" (id: ${id})`);
      ok++;
    } catch (e) {
      console.error(`  FAIL    id ${id}: ${e.message.split('\n')[0]}`);
      fail++;
    }
  }

  console.log(`\nDone. ${ok} deleted, ${fail} failed.`);
  if (fail > 0) process.exit(1);
}

main().catch(e => { console.error('\nERR', e.message); process.exit(1); });
