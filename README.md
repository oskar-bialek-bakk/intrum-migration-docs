# Migracja danych stagingowych — DEBT Manager

Dokumentacja techniczna procesu migracji danych stagingowych do bazy produkcyjnej w systemie DEBT Manager.

## Linki

- **Dokumentacja online:** https://oskar-bialek-bakk.github.io/intrum-migration-docs/ (po publikacji)
- **Confluence:** [Migracja danych](http://192.168.199.190:8090/display/INTRUM/Migracja+danych)
- **Repozytorium źródłowe (silnik + docs):** [BakkShared/Generic.DataBase.Migration](https://dev.azure.com/bakkspzoo/BakkShared/_git/Generic.DataBase.Migration)
- **Repozytorium klienckie (profil, hooki, sync):** [Dm.Intrum/Dm.Web.Intrum.Migration](https://dev.azure.com/bakkspzoo/Dm.Intrum/_git/Dm.Web.Intrum.Migration)
- **Publiczne repo dokumentacji:** [intrum-migration-docs](https://github.com/oskar-bialek-bakk/intrum-migration-docs)

## Stack

- MkDocs Material ≥9.5 (z wtyczką `mkdocs-drawio`)
- Node (sync do Confluence — `marked`, `turndown`, `glob`)
- Azure Pipelines: `mirror-github.yml` w repo klienckim (AzDO → public repo), `deploy-docs.yml` (AzDO → App Service); `deploy-pages.yml` (public repo → GitHub Pages)

## Uruchomienie lokalne

```bash
pip install -r requirements.txt
mkdocs serve
```

Strona dostępna na `http://127.0.0.1:8000`.

## Sync do Confluence

Skrypty sync żyją w repie klienckim (`Dm.Web.Intrum.Migration/migration/sync/`). Po każdej zmianie w `migration/docs/` uruchom lokalnie z roota repa klienckiego:

```bash
node migration/sync/sync-to-confluence.js
```

Wymaga pliku `migration/sync/.env` ze skonfigurowanymi zmiennymi (`CONF_URL`, `CONF_USER`, `CONF_PASS`, `CONF_SPACE`, `CONF_PARENT`). Szablon: `migration/sync/.env.example`.

## Struktura repo

```
migration/
├── docs/                # źródło MkDocs (mirrorowane do public repo)
├── lib/                 # generator, loadery, konwerter sqlproj (Node)
├── scripts/             # SQL (staging, stage1, indeksy, cross-db)
├── docs-build/          # ekstraktor mapowania kolumn
├── clients/             # profil bazowy _base + fixture testowy
├── mkdocs.yml
├── requirements.txt
└── README.md
```

Część kliencka (profil intrum, hooki, test_data, sync do Confluence, dokumenty robocze) żyje w `Dm.Web.Intrum.Migration`, które montuje to repo jako submodule `core/`.

## Publikacja

1. Merge do `main` tego repo → podbicie submodule `core/` w `Dm.Web.Intrum.Migration` (PR).
2. Push do `main` repa klienckiego → pipeline `mirror-github.yml` kopiuje treść do `intrum-migration-docs`, a `deploy-docs.yml` publikuje na App Service.
3. Push do `intrum-migration-docs/main` → workflow `deploy-pages.yml` buduje MkDocs i publikuje na GitHub Pages.

Confluence to sync manualny — uruchamiany po zmianach w docs (patrz wyżej).
