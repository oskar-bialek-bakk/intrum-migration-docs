# Migracja danych stagingowych — DEBT Manager

Dokumentacja techniczna procesu migracji danych stagingowych do bazy produkcyjnej w systemie DEBT Manager.

## Linki

- **Dokumentacja online:** https://oskar-bialek-bakk.github.io/intrum-migration-docs/ (po publikacji)
- **Confluence:** [Migracja danych](http://192.168.199.190:8090/display/INTRUM/Migracja+danych)
- **Repozytorium źródłowe:** `migration/` w monorepo `murtni`
- **Publiczne repo dokumentacji:** [intrum-migration-docs](https://github.com/oskar-bialek-bakk/intrum-migration-docs)

## Stack

- MkDocs Material ≥9.5 (z wtyczką `mkdocs-drawio`)
- Node (sync do Confluence — `marked`, `turndown`, `glob`)
- GitHub Actions: `sync-docs.yml` (murtni → public repo), `deploy-pages.yml` (public repo → GitHub Pages)

## Uruchomienie lokalne

```bash
pip install -r requirements.txt
mkdocs serve
```

Strona dostępna na `http://127.0.0.1:8000`.

## Sync do Confluence

Po każdym `git push` do `main` zmieniającym pliki w `migration/docs/`, uruchom lokalnie:

```bash
cd migration
node sync/sync-to-confluence.js
```

Wymaga pliku `sync/.env` ze skonfigurowanymi zmiennymi (`CONF_URL`, `CONF_USER`, `CONF_PASS`, `CONF_SPACE`, `CONF_PARENT`). Szablon: `sync/.env.example`.

## Struktura repo

```
migration/
├── docs/                # źródło MkDocs (synced to public repo)
├── sync/                # skrypty sync do Confluence
├── scripts/             # SQL (staging, indeksy)
├── internal/            # robocze dokumenty (NIE synced)
├── mkdocs.yml
├── requirements.txt
└── README.md
```

## Publikacja

Proces dwustopniowy:

1. Push do `murtni/main` → workflow `sync-docs.yml` kopiuje zmiany do `intrum-migration-docs`.
2. Push do `intrum-migration-docs/main` → workflow `deploy-pages.yml` buduje MkDocs i publikuje na GitHub Pages.

Confluence to sync manualny — uruchamiany po push (patrz wyżej).
