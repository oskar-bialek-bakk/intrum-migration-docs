# Migracja danych stagingowych — DEBT Manager (Intrum)

Dokumentacja techniczna procesu migracji danych stagingowych do bazy produkcyjnej w systemie DEBT Manager dla klienta Intrum.

## Linki

- **Dokumentacja online:** https://oskar-bialek-bakk.github.io/intrum-migration-docs/ (po publikacji)
- **Confluence:** [Migracja danych](http://192.168.199.190:8090/display/INTRUM/Migracja+danych)
- **Repozytorium silnika (CORE):** [BakkShared/Generic.DataBase.Migration](https://dev.azure.com/bakkspzoo/BakkShared/_git/Generic.DataBase.Migration)
- **Repozytorium klienckie (profil, docs, hooki, sync):** [Dm.Intrum/Dm.Web.Intrum.Migration](https://dev.azure.com/bakkspzoo/Dm.Intrum/_git/Dm.Web.Intrum.Migration)
- **Publiczne repo dokumentacji:** [intrum-migration-docs](https://github.com/oskar-bialek-bakk/intrum-migration-docs)

## Stack

- MkDocs Material ≥9.5 (z wtyczką `mkdocs-drawio`)
- Node (sync do Confluence — `marked`, `turndown`, `glob`; ekstraktor mapowania — `docs-build/`)
- Azure Pipelines: `mirror-github.yml` (AzDO → public repo), `deploy-docs.yml` (AzDO → App Service); `deploy-pages.yml` (public repo → GitHub Pages)

## Uruchomienie lokalne

```bash
cd migration
pip install -r requirements.txt
mkdocs serve
```

Strona dostępna na `http://127.0.0.1:8000`.

## Mapowanie kolumn (docs-build)

`docs/struktura-stagingu/*.md` dostaje strzałki staging→prod z `docs-build/mapping.json`,
generowanego ze źródeł SQL silnika (submodule `core/`). Po bumpie submodule `core/`
zregeneruj mapping:

```bash
node migration/docs-build/generate_mapping.js
```

CI pilnuje driftu (`drift check mapping.json`).

## Sync do Confluence

Po każdej zmianie w `migration/docs/` uruchom lokalnie z roota repo:

```bash
node migration/sync/sync-to-confluence.js
```

Wymaga pliku `migration/sync/.env` ze skonfigurowanymi zmiennymi (`CONF_URL`, `CONF_USER`, `CONF_PASS`, `CONF_SPACE`, `CONF_PARENT`). Szablon: `migration/sync/.env.example`.

## Struktura repo

```
core/                    # submodule → BakkShared/Generic.DataBase.Migration (silnik)
migration/
├── docs/                # źródło MkDocs (mirrorowane do public repo)
├── docs-build/          # ekstraktor mapowania kolumn + hook MkDocs
├── clients/intrum/      # profil klienta (profile.yaml, hooki, custom iteracje)
├── test_data/           # dane testowe (bcp + manifest)
├── sync/                # sync do Confluence
├── mkdocs.yml
├── requirements.txt
└── README.md
```

## Publikacja

1. Merge do `main` tego repo → pipeline `mirror-github.yml` kopiuje treść do `intrum-migration-docs`, a `deploy-docs.yml` publikuje na App Service.
2. Push do `intrum-migration-docs/main` → workflow `deploy-pages.yml` buduje MkDocs i publikuje na GitHub Pages.

Zmiana wyłącznie w `migration/docs/` nie wymaga bumpa submodule `core/`. Bump jest potrzebny tylko, gdy zmienia się silnik (SQL/generator), a po nim: regeneracja `mapping.json` (patrz wyżej).

Confluence to sync manualny — uruchamiany po zmianach w docs (patrz wyżej).
