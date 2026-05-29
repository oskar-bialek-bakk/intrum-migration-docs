"""MkDocs on_page_markdown hook — inject staging→prod arrows into param-list.

Reads migration/docs-build/mapping.json (produced by extract_mapping.js)
and rewrites <li> blocks in struktura-stagingu/*.md pages.

CI behavior: fail-build on inconsistency between docs and mapping.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

_MAPPING_PATH = Path(__file__).parent / "mapping.json"
_PAGE_PREFIX = "struktura-stagingu/"

_mapping_cache: dict | None = None


def _load_mapping() -> dict:
    global _mapping_cache
    if _mapping_cache is None:
        if not _MAPPING_PATH.exists():
            raise RuntimeError(
                f"mapping.json not found at {_MAPPING_PATH}; "
                "run 'node migration/docs-build/generate_mapping.js' first"
            )
        _mapping_cache = json.loads(_MAPPING_PATH.read_text(encoding="utf-8"))
    return _mapping_cache


def _staging_table_for_page(page_src: str, mapping: dict) -> tuple[str, dict] | None:
    """Find (staging_table, entry) for a given page by scanning mapping for tables
    that appear in the page's filename context. Returns None if page not relevant.

    Note: actual table identification happens per <details> block in inject step.
    This is a fast pre-check to skip pages with no relevant content.
    """
    for iter_key, tables in mapping.items():
        for stg in tables:
            if stg.replace("dbo.", "") in page_src.lower():
                return iter_key, tables
    return None


def on_page_markdown(markdown: str, page, config, files):
    src = getattr(page.file, "src_path", "") or ""
    src = src.replace("\\", "/")
    if not src.startswith(_PAGE_PREFIX):
        return markdown
    mapping = _load_mapping()
    return transform_page(markdown, mapping)


_TECHNICAL_COLS = {"mod_date", "aud_data", "aud_login"}
_PROD_DB_PRETTY = "dbo"
_PROD_DB = "dbo"

# Scratch/pre-materialization temp tables used for JOIN optimization inside a single iter.
# These are NOT migration mapping tables (they don't map staging PKs → prod PKs);
# they pre-join reference data for performance. Badges referencing them are suppressed
# because they do not represent a named, persistent mapping — the actual FK chain is
# via the underlying source (e.g. mapowanie.dodane_sprawy → prod.sprawa.sp_rb_id).
_SCRATCH_TEMP_DICTS = {"#ksd_rb_lookup"}


def _format_prod(prod_table: str, prod_col: str) -> str:
    """Return fully-qualified dbo.table.col string.
    Input prod_table may be 'dbo.tablename' or just 'tablename'."""
    table = prod_table.replace("dbo.", "").replace("__PROD_DB__.", "")
    return f"{_PROD_DB}.{table}.{prod_col}"

# Staging columns that are documented but intentionally not mapped to a prod column
# in the extractor. Each entry: staging_table → set of col names.
# Reasons are documented inline per group.
_INTENTIONALLY_UNMAPPED: dict[str, set[str]] = {
    # dbo.atrybut — at_att_id, at_wartosc, at_id are routed through dbo.usp_migrate_atrybut_wartosc
    # stored proc to dbo.atrybut_wartosc; mappings declared in STORED_PROC_OVERRIDES in extract_mapping.js.
    # No entries needed here anymore — kept empty for the next time another col surfaces.
    # dbo.wlasciwosc — combined <details> in tabele-generyczne.md lists `w_wartosc` as an
    # abstract "property value" col, but no such col exists in the staging schema. Real
    # staging cols (wl_wtpd_id, wl_aktywny_od, wl_aktywny_do) are not shown in docs. Until
    # docs is corrected to match staging schema, ignore the abstract col here.
    "dbo.wlasciwosc": {"w_wartosc"},
    # dbo.ksiegowanie_dekret — staging cols documented but not consumed by iter8 INSERT:
    #   ksd_uwagi removed from staging schema (no longer migrated).
    #   ksd_kwota_wn_wyceny, ksd_kwota_ma_wyceny, ksd_wa_id_wyceny — wycena fields
    #     reserved for valuation flow, not part of current migration.
    #   ksd_ksksub_id — staging FK to ksiegowanie_konto_sub, no corresponding prod col in
    #     current schema (prod uses different sub-account model).
    #   ksd_kwota — split into ksd_kwota_wn/ksd_kwota_ma via CASE WHEN (derived); the original
    #     staging col is not directly mapped — value flows through the derived expressions.
    #   ksd_sp_id — referenced in staging but set to NULL in iter8 INSERT (no longer resolved
    #     from prod sprawa after the #ksd_staging removal refactor).
    "dbo.ksiegowanie_dekret": {
        "ksd_uwagi", "ksd_kwota_wn_wyceny", "ksd_kwota_ma_wyceny", "ksd_wa_id_wyceny",
        "ksd_ksksub_id", "ksd_kwota", "ksd_sp_id"
    },
    # dbo.harmonogram — hr_numer_raty and hr_kwota_raty exist in the staging table but are
    # not referenced in any migration SQL (hr_kwota_raty = hr_kwota_kapitalu + hr_kwota_odsetek,
    # which are migrated individually; hr_numer_raty has no prod equivalent in this migration).
    "dbo.harmonogram": {"hr_numer_raty", "hr_kwota_raty"},
    # dbo.ksiegowanie — ks_id is the staging PK stored in mapowanie.dodane_ksiegowania;
    # prod uses its own IDENTITY PK (never inserted as ks_id — captured via MERGE OUTPUT).
    # ks_korekta is a staging col that has no corresponding mapping in any INSERT statement;
    # it is complementary to ks_pierwotne but not migrated.
    "dbo.ksiegowanie": {"ks_id", "ks_korekta"},
    # dbo.rezultat — re_id is the IDENTITY PK in staging; prod generates its own re_id via
    # IDENTITY — staging re_id is not inserted as prod re_id (no re_ext_id column on prod).
    "dbo.rezultat": {"re_id"},
    # dbo.sprawa — sp_spe_id is a staging FK to sprawa_etap; prod sprawa does not have this
    # column (only sp_spt_id is used). sp_spe_id is not referenced in any iter4 INSERT.
    "dbo.sprawa": {"sp_spe_id"},
    # dbo.sprawa_rola — spr_id is the IDENTITY PK in staging; prod generates its own PK.
    "dbo.sprawa_rola": {"spr_id"},
    # dbo.wierzytelnosc —
    #   wi_id: staging PK; prod generates its own IDENTITY wi_id — staging value stored
    #     in wi_ext_id (VARCHAR) via MERGE ON 1=0 OUTPUT.
    #   wi_sp_id: staging FK to sprawa; used as JOIN key when inserting wierzytelnosc_rola
    #     but not inserted into any prod wierzytelnosc column (prod w-t doesn't carry sp_id).
    #   wi_uko_id: resolved via a 3-hop CROSS APPLY chain
    #     (stg.wi_uko_id → stg_uko → CROSS APPLY uko_resolve → prod_uko.uko_id); the extractor
    #     cannot auto-resolve CROSS APPLY aliases without RDBMS schema introspection.
    "dbo.wierzytelnosc": {"wi_id", "wi_sp_id", "wi_uko_id"},
    # dbo.wierzytelnosc_rola — wir_id is the IDENTITY PK in staging; prod generates its own
    # PK. The iter6 INSERT uses a fixed default wir_wirt_id for the role type.
    "dbo.wierzytelnosc_rola": {"wir_id"},
    # --- iter1 lookup tables (newly parsed by parseMergeValuesBlock) ---
    #
    # Staging PKs included in the USING SELECT only for the OUTPUT clause;
    # prod generates its own IDENTITY PK in these reference-copy tables.
    "dbo.kurs_walut": {"kw_id"},
    "dbo.akcja_typ": {"akt_id"},
    "dbo.atrybut_typ": {"att_id"},
    "dbo.rezultat_typ": {"ret_id"},
    "dbo.telefon_typ": {"tt_id"},
    "dbo.wlasciwosc_dziedzina": {"wdzi_id"},
    "dbo.wlasciwosc_podtyp": {"wpt_id"},
    "dbo.wlasciwosc_typ": {"wt_id"},
    "dbo.wlasciwosc_typ_podtyp_dziedzina": {"wtpd_id"},
    "dbo.wlasciwosc_typ_walidacji": {"wtw_id"},
    # Write-back cols: after MERGE, staging row is updated with the prod PK for FK resolution.
    # These cols exist on the staging table but are not inputs to the prod INSERT.
    "dbo.kontrahent": {"ko_id_migracja"},
    "dbo.umowa_kontrahent": {"uko_ko_id_migracja"},
    # spe_akt_id is a staging FK resolved via a two-hop LEFT JOIN chain
    # (src.spe_akt_id → stg_akt → akt_prod) inside the USING subquery.
    # The result appears in mapping as @spet_akt_id (derived), not by staging col name.
    "dbo.sprawa_etap": {"spe_akt_id"},
    # EXEC #usp_merge_lookup tables: <prefix>_uuid is a merge key col, not user-facing.
    # The extractor skips uuid cols by name pattern so they won't appear in mapping.
    # However docs pages list them as deprecated cols — handle via _TECHNICAL_COLS-like skip.
    # dbo.adres_typ: at_uuid is deprecated in docs; at_ext_id is write-back, not in docs.
    "dbo.adres_typ": {"at_uuid"},
    "dbo.dluznik_typ": {"dt_uuid"},
    "dbo.kraj": {"kraj_uuid"},
    "dbo.ksiegowanie_typ": {"kst_uuid"},
    "dbo.sprawa_rola_typ": {"sprt_uuid"},
    "dbo.sprawa_typ": {"spt_uuid"},
    "dbo.atrybut_dziedzina": {"atd_uuid"},
    "dbo.atrybut_rodzaj": {"atr_uuid"},
    # dbo.operacja — staging table with many context/reference cols that do not map directly
    # to prod columns. The extractor captures oper_data_dekretu and oper_data_ksiegowania
    # (mapped to ks_data_*). The remaining cols are either:
    #   - Staging-only reference cols (oper_id, oper_wi_id, oper_konto, oper_do_id, etc.)
    #   - Amount cols handled via #oper_ksd_rows temp table (oper_kwota_*, oper_kowta_*)
    #   - Derived/computed values used internally (oper_waluta, oper_typ_dekretu, etc.)
    #   - Metadata cols not migrated (oper_opis, oper_opis_*, oper_beneficjent_*, etc.)
    "dbo.operacja": {
        "oper_id",
        "oper_wi_id",
        "oper_waluta",
        "oper_rejestr_kod",
        "oper_typ_dekretu",
        "oper_strona",
        "oper_opis",
        "oper_opis_dekretu",
        "oper_opis_slowny",
        "oper_konto",
        "oper_do_id",
        "oper_kwota",
        "oper_kwota_dekretu",
        "oper_kwota_dekretu_w_pln",
        "oper_kwota_w_pln",
        "oper_kwota_kapitalu",
        "oper_kwota_kapitalu_w_pln",
        "oper_kwota_odsetek",
        "oper_kwota_odsetek_w_pln",
        "oper_kowta_odsetek_karnych",
        "oper_kowta_odsetek_karnych_w_pln",
        "oper_kwota_oplaty",
        "oper_kwota_oplaty_w_pln",
        "oper_kwota_prowizji",
        "oper_kwota_prowizji_w_pln",
        "oper_dokument_typ_prod_id",
        "oper_dokument_typ_prod_opis",
        "oper_dokument_podtyp_prod_id",
        "oper_dokument_podtyp_prod_opis",
        "oper_dokument_prod_id",
        "oper_beneficjent_nazwa",
        "oper_remitter_nazwa",
        "oper_data_danych",
        "oper_data_waluty",
    },
}


def _split_admonition(split_targets: list[str]) -> str:
    pretty = [f"`{_PROD_DB_PRETTY}.{t.replace('dbo.', '')}`" for t in split_targets]
    n = len(split_targets)
    return (
        f'\n\n!!! info "Rozbicie do prod"\n'
        f'    Wiersz tej tabeli stagingowej rozchodzi się do **{n} tabel produkcyjnych**: '
        f'{", ".join(pretty)}. Strzałki przy poszczególnych kolumnach poniżej pokazują '
        f'docelową tabelę produkcyjną.\n\n'
    )


_DETAILS_RE = re.compile(
    r'(<details[^>]*>\s*<summary>.*?<code>(dbo\.[a-z_]+)</code>.*?</summary>)(.*?)(</details>)',
    re.DOTALL | re.IGNORECASE,
)

_LI_RE = re.compile(
    r'(<li>\s*<span class="param-name([^"]*)"[^>]*>([a-z_0-9]+)</span>)(\s*<span class="param-type")',
    re.IGNORECASE,
)


def _render_param_prod(info: dict, default_prod_table: str = "") -> str:
    """Render the param-prod HTML span(s) for a column mapping entry.

    All prod column references are rendered with full dbo.table.col prefix.
    Temp table names (starting with #) are hidden from via-dict badges.
    Multi-target entries render stacked rows.
    """
    kind = info["kind"]
    prod_table = info.get("prod_table") or default_prod_table

    if kind == "1:1":
        full = _format_prod(prod_table, info["prod_col"])
        return f'<span class="param-prod">{full}</span>'

    if kind == "via_dict":
        full = _format_prod(prod_table, info["prod_col"])
        dict_name = info["dict"]
        if dict_name in _SCRATCH_TEMP_DICTS:
            # Scratch/pre-materialization temp — suppress badge; show only the prod col
            return f'<span class="param-prod">{full}</span>'
        return (
            f'<span class="param-prod">{full}</span>'
            f'<span class="prod-badge via-dict">via {dict_name}</span>'
        )

    if kind == "derived":
        full = _format_prod(prod_table, info["prod_col"])
        return (
            f'<span class="param-prod">{full}</span>'
            f'<span class="prod-badge derived">derived</span>'
        )

    if kind == "polymorph":
        targets = " / ".join(info["targets"])
        return (
            f'<span class="param-prod">({targets})</span>'
            f'<span class="prod-badge polymorph">polimorficzne</span>'
        )

    if kind == "split":
        split_prod_table = info.get("prod_table") or default_prod_table
        full = _format_prod(split_prod_table, info["prod_col"])
        return f'<span class="param-prod">{full}</span>'

    if kind == "multi_target":
        parts = []
        for t in info["targets"]:
            t_prod_table = t.get("prod_table") or default_prod_table
            full = _format_prod(t_prod_table, t["prod_col"])
            t_dict = t.get("dict", "")
            if t_dict and t_dict not in _SCRATCH_TEMP_DICTS:
                badge = f'<span class="prod-badge via-dict">via {t_dict}</span>'
                parts.append(f'<span class="multi-target">{full}{badge}</span>')
            else:
                parts.append(f'<span class="multi-target">{full}</span>')
        inner = "\n  ".join(parts)
        return f'<span class="param-prod multi">\n  {inner}\n</span>'

    return ""  # unknown — no span


def _build_col_index(mapping: dict) -> dict:
    """{staging_table: {staging_col_no_prefix: info}} — strips '@'/'?'/'$' prefixes
    used internally for derived/unknown/constant grouping.

    Cross-iter merged entries (under '_cross_iter' key) take priority over
    per-iter entries for polymorph tables like dbo.atrybut.
    """
    index: dict = {}

    def _ingest_tables(tables: dict) -> None:
        for stg, entry in tables.items():
            cols: dict = {}
            for col_key, info in entry["columns"].items():
                if col_key.startswith("@") or col_key.startswith("?") or col_key.startswith("$"):
                    continue
                cols[col_key] = info
            if stg not in index:
                index[stg] = cols
            else:
                index[stg].update(cols)

    # Ingest regular iters first
    for iter_key, tables in mapping.items():
        if iter_key in ("_cross_iter", "_stored_proc"):
            continue
        _ingest_tables(tables)

    # Cross-iter merged entries OVERRIDE per-iter for the affected tables
    cross_iter = mapping.get("_cross_iter", {})
    if cross_iter:
        _ingest_tables(cross_iter)

    # Stored-proc manual entries OVERRIDE / ADD for tables not extractable from SQL
    stored_proc = mapping.get("_stored_proc", {})
    if stored_proc:
        _ingest_tables(stored_proc)

    return index


def transform_page(markdown: str, mapping: dict) -> str:
    """Pure function — no MkDocs deps. Used by both hook and tests."""
    col_index = _build_col_index(mapping)

    _UNMAPPED_ADMONITION = (
        '\n\n!!! warning "Mapowanie niedostępne"\n'
        '    Migracja tej tabeli nie jest jeszcze zaimplementowana w pipeline. '
        'Kolumny pokazane poniżej opisują strukturę stagingową; mapowanie do prod '
        'zostanie uzupełnione po dodaniu odpowiedniego skryptu w `migration/scripts/stage1/`.\n\n'
    )

    _LOOKUP_ONLY_ADMONITION = (
        '\n\n!!! note "Tabela referencyjna (lookup-only)"\n'
        '    Tabela używana wyłącznie do rozwiązywania FK podczas migracji innych tabel. '
        'Sama nie jest przenoszona do prod — odpowiednik produkcyjny istnieje już w '
        'bazowym schemacie DEBT Manager i nie wymaga zasilania ze stagingu.\n\n'
    )

    def transform_details(match: re.Match) -> str:
        opening, staging_table, body, closing = (
            match.group(1), match.group(2), match.group(3), match.group(4)
        )
        entry = None
        default_prod_table = ""
        # Check _cross_iter first for polymorph tables, then _stored_proc for proc-routed tables
        cross_iter = mapping.get("_cross_iter", {})
        stored_proc = mapping.get("_stored_proc", {})
        if staging_table in cross_iter:
            entry = cross_iter[staging_table]
        elif staging_table in stored_proc:
            entry = stored_proc[staging_table]
        else:
            for iter_key, tables in mapping.items():
                if iter_key in ("_cross_iter", "_stored_proc"):
                    continue
                if staging_table in tables:
                    entry = tables[staging_table]
                    break
        if entry is None:
            # Fix 6: table not in mapping at all — inject admonition and return
            new_body = _UNMAPPED_ADMONITION + body
            return opening + new_body + closing

        # Lookup-only tables (staging-only reference, no prod migration) — different message
        if entry.get("_lookup_only"):
            new_body = _LOOKUP_ONLY_ADMONITION + body
            return opening + new_body + closing

        # Set default_prod_table from entry (used by _render_param_prod for 1:1/via_dict/derived)
        if entry.get("prod_table"):
            default_prod_table = entry["prod_table"]

        cols = col_index.get(staging_table, {})

        # Fix 6: if no user-facing mapping cols exist, inject admonition
        has_mapping = bool(cols) and any(
            not k.startswith("@") and not k.startswith("$") and not k.startswith("?")
            for k in cols
        )

        # Consistency check: every name in body must be either in mapping or in ignore lists.
        intentional_unmapped = _INTENTIONALLY_UNMAPPED.get(staging_table, set())
        found_cols = re.findall(r'<span class="param-name[^"]*"[^>]*>([a-z_0-9]+)</span>', body, re.IGNORECASE)
        for c in found_cols:
            if c in cols:
                continue
            if c in _TECHNICAL_COLS:
                continue
            if c in intentional_unmapped:
                continue
            # Also accept: documented col exists in mapping as a constant ($-prefixed)
            # This covers cases where staging col value is overridden by a constant in SQL
            # but the col name still appears in docs (e.g. ks_pierwotne hardcoded to 1).
            if ("$" + c) in entry["columns"]:
                continue
            # Also accept: documented col exists in mapping as a derived (@-prefixed).
            # This covers cases where the staging col and prod col share the same name
            # (e.g. uko_ko_id in staging → uko_ko_id in prod via ISNULL expression).
            if ("@" + c) in entry["columns"]:
                continue
            # Fix 6: if no SQL mapping exists, skip consistency check (admonition will show)
            if not has_mapping:
                break
            raise RuntimeError(
                f'docs/mapping mismatch: {staging_table}.{c} appears in param-list '
                f'but not in mapping.json — extend extractor or add to _INTENTIONALLY_UNMAPPED'
            )
        found_set = set(found_cols)
        for c in cols:
            if c not in found_set:
                # Fix 6: if no mapping exists yet, skip reverse-check too
                if not has_mapping:
                    break
                raise RuntimeError(
                    f'docs/mapping mismatch: {staging_table}.{c} in mapping.json '
                    f'but not in docs param-list — add row to {staging_table} docs page'
                )

        def transform_li(li_match: re.Match) -> str:
            li_open, name_classes, staging_col, type_open = (
                li_match.group(1), li_match.group(2), li_match.group(3), li_match.group(4)
            )
            info = cols.get(staging_col)
            if info is None:
                return li_match.group(0)
            return li_open + _render_param_prod(info, default_prod_table) + type_open

        new_body = _LI_RE.sub(transform_li, body)
        if entry.get("split_targets"):
            new_body = _split_admonition(entry["split_targets"]) + new_body

        # Fix 6: prepend admonition for tables with no SQL migration
        if not has_mapping:
            new_body = _UNMAPPED_ADMONITION + new_body

        return opening + new_body + closing

    return _DETAILS_RE.sub(transform_details, markdown)
