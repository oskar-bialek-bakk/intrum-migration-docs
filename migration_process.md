# Intrum — Migration Process Plan

**Scope:** End-to-end migration process from external system data extraction through post-migration quality assurance.
**Related:** `plan.md` covers table-level column mapping. This document covers tooling, process, logging, validations, and reporting.

---

## Topics backlog

| # | Topic | Status |
|---|---|---|
| 1 | E2E Architecture & flow | ✅ Complete |
| 2 | Logging infrastructure (`log` schema) | ✅ Complete |
| 3 | Pre-migration validations | ✅ Complete — scripts in production use |
| 4 | Pre-migration report | ✅ Complete — `00_pre_check.sql` generates `log.validation_result` |
| 5 | Validation spec for external IT team | ✅ Complete — `dokumentacja_dla_zespolu_zewnetrznego.md` |
| 6 | Migration execution scripts | ✅ Complete — `scripts/stage1/01–09` running, pipeline verified |
| 7 | Post-migration quality checks / KPIs | ✅ Complete — 30 KPIs in `99_post_report.sql` |
| 8 | Staging column descriptions (Polish) | ✅ Complete — `staging_column_descriptions.sql` |
| 9 | External team guide (population order + validations + reports) | ✅ Complete — `dokumentacja_dla_zespolu_zewnetrznego.md` |

---

## 1. E2E Architecture & flow

```
[External system]
      │
      │  1. Extract data from source system
      │     (scope, filters, and schedule TBD with external team)
      ▼
[External system ETL]
      │
      │  2. Transform and load into dm_staging
      │     - Populates all staging dbo.* tables
      │     - Populates reference tables: waluta, kurs_walut,
      │       kontrahent, umowa_kontrahent, GE_USER (from prod)
      │     - Does NOT touch dm_data_web
      ▼
[dm_staging]
      │
      │  3. Pre-migration validation run (our scripts)
      │     - Referential integrity checks
      │     - Technical / nullable checks
      │     - Business rule checks
      │     - Writes results to log.validation_result
      ▼
[Pre-migration report]
      │
      │  4. Report reviewed — decision gate
      │     - Blocking errors: must be fixed before migration
      │     - Warnings: document and accept, or fix
      │     - External IT team receives their validation spec
      ▼
[Migration execution]  (topic 6 — scripts TBD)
      │
      │  5. Migration scripts run per table in dependency order
      │     - Each insert wrapped in TRY/CATCH
      │     - Failures: skip record/entity, write to log.migration_error
      │     - Successes: write to log.migration_summary per table
      ▼
[dm_data_web]
      │
      │  6. Post-migration quality checks (our scripts)
      │     - Record count reconciliation (staging vs prod)
      │     - Financial amount reconciliation
      │     - Data quality KPIs
      │     - Writes results to log.postmigration_check
      ▼
[Post-migration report]
      │
      │  7. Report reviewed — sign-off or remediation
```

**Key decisions:**
- Error handling: skip failed record/entity, log it, continue migration — no full rollback
- Logging lives in `dm_staging.log` schema (can be moved to separate DB later)
- Each migration stage (1–5) runs independently; logs distinguish stage number

---

## 2. Logging infrastructure

### Schema: `dm_staging.log`

#### `log.migration_run` — one row per migration execution

| Column | Type | Note |
|---|---|---|
| `run_id` | INT IDENTITY PK | |
| `run_date` | DATETIME NOT NULL | GETDATE() at start |
| `run_type` | VARCHAR(20) NOT NULL | `'PRE_CHECK'` / `'MIGRATION'` / `'POST_CHECK'` |
| `migration_stage` | INT NOT NULL | 1–5 |
| `run_by` | VARCHAR(100) NULL | Windows login or job name |
| `status` | VARCHAR(20) NOT NULL | `'RUNNING'` / `'COMPLETED'` / `'FAILED'` |
| `records_total` | INT NULL | populated at end |
| `records_success` | INT NULL | |
| `records_skipped` | INT NULL | |
| `records_failed` | INT NULL | |
| `duration_seconds` | INT NULL | |
| `notes` | NVARCHAR(MAX) NULL | free text |

#### `log.migration_table_summary` — one row per table per run

| Column | Type | Note |
|---|---|---|
| `summary_id` | INT IDENTITY PK | |
| `run_id` | INT NOT NULL FK → migration_run | |
| `table_name` | VARCHAR(100) NOT NULL | e.g. `'dluznik'` |
| `records_attempted` | INT NOT NULL | |
| `records_inserted` | INT NOT NULL | |
| `records_skipped` | INT NOT NULL | |
| `records_failed` | INT NOT NULL | |

#### `log.migration_error` — one row per failed record

| Column | Type | Note |
|---|---|---|
| `error_id` | BIGINT IDENTITY PK | |
| `run_id` | INT NOT NULL FK → migration_run | |
| `table_name` | VARCHAR(100) NOT NULL | staging table where failure occurred |
| `staging_pk` | VARCHAR(100) NOT NULL | stringified staging PK value |
| `error_type` | VARCHAR(30) NOT NULL | see error type taxonomy below |
| `error_code` | VARCHAR(50) NOT NULL | short machine-readable code |
| `error_message` | NVARCHAR(MAX) NOT NULL | human-readable reason |
| `error_data` | NVARCHAR(MAX) NULL | JSON snapshot of the staging row |
| `logged_at` | DATETIME NOT NULL | GETDATE() |

**Error type taxonomy:**

| error_type | Meaning |
|---|---|
| `REFERENTIAL` | FK target does not exist |
| `TECHNICAL` | NULL in staging maps to NOT NULL with no default in prod |
| `BUSINESS_RULE` | Record violates a defined business rule |
| `FORMAT` | Value fails format validation (optional scope) |
| `SYSTEM` | Unexpected SQL error (e.g. deadlock, timeout) |

#### `log.validation_result` — pre-migration check results

| Column | Type | Note |
|---|---|---|
| `result_id` | INT IDENTITY PK | |
| `run_id` | INT NULL FK → migration_run | NULL allowed for ad-hoc runs not linked to a migration_run record. |
| `check_name` | VARCHAR(100) NOT NULL | e.g. `'REF_01_sprawa_rola_dluznik'` |
| `check_type` | VARCHAR(30) NOT NULL | `'REFERENTIAL'` / `'TECHNICAL'` / `'BUSINESS_RULE'` / `'FORMAT'` |
| `severity` | VARCHAR(10) NOT NULL | `'BLOCKING'` / `'WARNING'` / `'INFO'` |
| `affected_count` | INT NOT NULL | number of records failing this check |
| `sample_ids` | NVARCHAR(MAX) NULL | comma-separated staging PKs (up to 10) |
| `detail` | NVARCHAR(MAX) NULL | extra context |

#### `log.postmigration_check` — post-migration KPI results

| Column | Type | Note |
|---|---|---|
| `check_id` | INT IDENTITY PK | |
| `run_id` | INT NOT NULL FK → migration_run | |
| `kpi_name` | VARCHAR(100) NOT NULL | |
| `kpi_type` | VARCHAR(30) NOT NULL | `'COUNT'` / `'SUM'` / `'RATIO'` / `'ANOMALY'` |
| `expected_value` | NVARCHAR(200) NULL | staging baseline |
| `actual_value` | NVARCHAR(200) NULL | prod result |
| `delta` | NVARCHAR(200) NULL | difference |
| `pass` | BIT NOT NULL | 1 = OK, 0 = failed |
| `note` | NVARCHAR(MAX) NULL | |

### 2.5 Configuration schema: `dm_staging.configuration`

A separate schema for tunable parameters — primarily anomaly thresholds. This avoids hardcoded magic numbers in validation scripts and allows easy adjustment between staging runs without code changes.

#### `configuration.threshold_config`

| Column | Type | Note |
|---|---|---|
| `cfg_key` | VARCHAR(100) NOT NULL PK | machine-readable key |
| `cfg_value` | VARCHAR(200) NOT NULL | value as string (cast at use) |
| `cfg_description` | NVARCHAR(500) NULL | human-readable explanation |
| `cfg_updated_at` | DATETIME NOT NULL | last modified |

**Initial default values:**

| cfg_key | Default value | Used by |
|---|---|---|
| `max_phones_per_dluznik` | `10` | BIZ_09 |
| `max_adresy_per_dluznik` | `10` | BIZ_10 |
| `max_akcje_per_sprawa` | `200` | BIZ_11 |
| `max_dokumenty_per_wierzytelnosc` | `20` | BIZ_12 |
| `phone_min_digits` | `9` | FMT_06 |

> Thresholds should be tuned after first analysis of real staging data to avoid false positives and false negatives.

---

## 3. Pre-migration validations

Validations are grouped into four tiers. Each check has a code used in `log.validation_result.check_name`.

### 3.1 Referential integrity checks (REFERENTIAL — all BLOCKING)

All FK relationships that exist in staging must resolve. These are straightforward but must be run in dependency order.

| Code | Check | Table | SQL / pseudo-SQL |
|---|---|---|---|
| REF_01 | sprawa_rola → dluznik | sprawa_rola | `SELECT spr_id FROM sprawa_rola WHERE spr_dl_id NOT IN (SELECT dl_id FROM dluznik)` |
| REF_02 | sprawa_rola → sprawa | sprawa_rola | `... WHERE spr_sp_id NOT IN (SELECT sp_id FROM sprawa)` |
| REF_03 | sprawa_rola → sprawa_rola_typ | sprawa_rola | `... WHERE spr_sprt_id NOT IN (SELECT sprt_id FROM sprawa_rola_typ)` |
| REF_04 | wierzytelnosc_rola → wierzytelnosc | wierzytelnosc_rola | `... WHERE wir_wi_id NOT IN (SELECT wi_id FROM wierzytelnosc)` |
| REF_05 | wierzytelnosc_rola → sprawa | wierzytelnosc_rola | `... WHERE wir_sp_id NOT IN (SELECT sp_id FROM sprawa)` |
| REF_06 | wierzytelnosc → umowa_kontrahent | wierzytelnosc | `... WHERE wi_uko_id IS NOT NULL AND wi_uko_id NOT IN (SELECT uko_id FROM umowa_kontrahent)` |
| REF_07 | dokument → wierzytelnosc | dokument | `... WHERE do_wi_id NOT IN (SELECT wi_id FROM wierzytelnosc)` |
| REF_08 | dokument → dokument_typ | dokument | `... WHERE do_dot_id NOT IN (SELECT dot_id FROM dokument_typ)` |
| REF_09 | adres → dluznik | adres | `... WHERE ad_dl_id NOT IN (SELECT dl_id FROM dluznik)` |
| REF_10 | adres → adres_typ | adres | `... WHERE ad_at_id NOT IN (SELECT at_id FROM adres_typ)` |
| REF_11 | telefon → dluznik | telefon | `... WHERE tn_dl_id NOT IN (SELECT dl_id FROM dluznik)` |
| REF_12 | telefon → telefon_typ | telefon | `... WHERE tn_tt_id NOT IN (SELECT tt_id FROM telefon_typ)` |
| REF_13 | mail → dluznik | mail | `... WHERE ma_dl_id NOT IN (SELECT dl_id FROM dluznik)` |
| REF_14 | akcja → sprawa | akcja | `... WHERE ak_sp_id NOT IN (SELECT sp_id FROM sprawa)` |
| REF_15 | atrybut → atrybut_typ | atrybut | `... WHERE at_att_id NOT IN (SELECT att_id FROM atrybut_typ)` |
| REF_16 | atrybut (atd=1) → dokument | atrybut | `... WHERE at_atd_id = 1 AND at_ob_id NOT IN (SELECT do_id FROM dokument)` |
| REF_17 | atrybut (atd=2) → wierzytelnosc | atrybut | `... WHERE at_atd_id = 2 AND at_ob_id NOT IN (SELECT wi_id FROM wierzytelnosc)` |
| REF_18 | atrybut (atd=3) → dluznik | atrybut | `... WHERE at_atd_id = 3 AND at_ob_id NOT IN (SELECT dl_id FROM dluznik)` |
| REF_19 | atrybut (atd=4) → sprawa | atrybut | `... WHERE at_atd_id = 4 AND at_ob_id NOT IN (SELECT sp_id FROM sprawa)` |
| REF_20 | ksiegowanie_dekret → ksiegowanie | ksiegowanie_dekret | `... WHERE ksd_ks_id NOT IN (SELECT ks_id FROM ksiegowanie)` |
| REF_21 | ksiegowanie_dekret → ksiegowanie_konto | ksiegowanie_dekret | `... WHERE ksd_ksk_id NOT IN (SELECT ksk_id FROM ksiegowanie_konto)` |
| REF_22 | ksiegowanie_dekret → dokument (nullable) | ksiegowanie_dekret | `... WHERE ksd_do_id IS NOT NULL AND ksd_do_id NOT IN (SELECT do_id FROM dokument)` |
| REF_23 | operacja → wierzytelnosc | operacja | `... WHERE oper_wi_id IS NOT NULL AND oper_wi_id NOT IN (SELECT wi_id FROM wierzytelnosc)` |
| REF_24 | sprawa → sprawa_typ | sprawa | `... WHERE sp_spt_id NOT IN (SELECT spt_id FROM sprawa_typ)` |
| REF_25 | sprawa_etap → sprawa_typ | sprawa_etap | `... WHERE spe_spt_id NOT IN (SELECT spt_id FROM sprawa_typ)` |
| REF_26 | dluznik → dluznik_typ | dluznik | `... WHERE dl_dt_id IS NOT NULL AND dl_dt_id NOT IN (SELECT dt_id FROM dluznik_typ)` |
| REF_27 | operacja → waluta (via oper_waluta code) | operacja | `... WHERE oper_waluta IS NOT NULL AND oper_waluta NOT IN (SELECT wa_nazwa_skrocona FROM waluta)` |
| REF_28 | atrybut → atrybut_dziedzina (at_atd_id) | atrybut | `... WHERE at_atd_id NOT IN (SELECT atd_id FROM atrybut_dziedzina)` |
| REF_29 | ksiegowanie → ksiegowanie_typ | ksiegowanie | `... WHERE ks_kst_id NOT IN (SELECT kst_id FROM ksiegowanie_typ)` |
| REF_30 | dluznik.dl_plec → mapowanie.plec | dluznik | `... WHERE dl_plec IS NOT NULL AND dl_plec NOT IN (SELECT plec_kod FROM mapowanie.plec)` |

### 3.2 Technical checks (TECHNICAL)

These verify that staging NULLs won't cause silent failures or unexpected defaults during migration. Severity depends on the resolution strategy.

| Code | Check | Severity | Column | Resolution if NULL |
|---|---|---|---|---|
| TECH_01 | dluznik.dl_plec NULL but in mapowanie.plec | WARNING | dl_plec | maps to NULL dl_pl_id (nullable in prod) — OK |
| TECH_03 | sprawa.sp_numer_rachunku NULL | BLOCKING | sp_numer_rachunku | rb_nr required — record cannot be migrated |
| TECH_04 | wierzytelnosc.wi_uko_id NULL | BLOCKING | wi_uko_id | wi_uko_id NOT NULL in prod — cannot migrate |
| TECH_05 | dokument: do_wi_id NULL | BLOCKING | do_wi_id | cannot derive do_uko_id — cannot migrate. Note: `do_wi_id` is `NOT NULL` in current staging schema — this check is a safeguard only (will always return 0 unless constraint is disabled). |
| TECH_06 | akcja: ak_sp_id NULL | BLOCKING | ak_sp_id | ak_sp_id NOT NULL in prod — cannot migrate |
| TECH_07 | atrybut: at_ob_id NULL | BLOCKING | at_ob_id | entity join impossible — cannot migrate |
| TECH_08 | atrybut: at_wartosc empty string | WARNING | at_wartosc | `at_wartosc` is `NOT NULL` in staging — check for empty string (`= ''`) rather than NULL; atw_wartosc may be nullable in prod — verify |
| TECH_09 | ksiegowanie_dekret: ksd_ks_id NULL | BLOCKING | ksd_ks_id | NOT NULL in prod |
| TECH_10 | operacja: oper_waluta NULL when amount > 0 | WARNING | oper_waluta | ksd_wa_id will be NULL — may violate currency rules |

### 3.3 Format / type checks (FORMAT — proposed statements only)

> **Scope:** These are proposed as candidate validations. Implementation only if customer requests. Listed as SQL statements for reference.
> Threshold values (e.g. minimum phone length) are read from `configuration.threshold_config` — see section 2.5.

| Code | Check | Proposed SQL statement |
|---|---|---|
| FMT_01 | PESEL: 11 digits | `WHERE dl_pesel IS NOT NULL AND (LEN(dl_pesel) <> 11 OR dl_pesel NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')` |
| FMT_02 | NIP: 10 digits | `WHERE dl_nip IS NOT NULL AND LEN(REPLACE(dl_nip,'-','')) <> 10` |
| FMT_03 | REGON: 9 or 14 digits | `WHERE dl_regon IS NOT NULL AND LEN(dl_regon) NOT IN (9,14)` |
| FMT_04 | Postal code: XX-XXX | `WHERE ad_kod IS NOT NULL AND ad_kod NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9]'` |
| FMT_05 | Email contains @ and domain | `WHERE ma_adres_mailowy IS NOT NULL AND ma_adres_mailowy NOT LIKE '%@%.%'` |
| FMT_06 | Phone: min digit count below threshold (hard minimum: 9) | `DECLARE @min INT = (SELECT CAST(cfg_value AS INT) FROM configuration.threshold_config WHERE cfg_key = 'phone_min_digits'); WHERE tn_numer IS NOT NULL AND LEN(REPLACE(REPLACE(REPLACE(tn_numer,' ',''),'-',''),'+','')) < @min` |
| FMT_07 | Phone: country code present (proposed — not all numbers will have one) | `WHERE tn_numer IS NOT NULL AND tn_numer NOT LIKE '+%'` — INFO only, expect many non-Polish numbers |
| FMT_08 | Date: do_data_wymagalnosci >= do_data_wystawienia | `WHERE do_data_wymagalnosci < do_data_wystawienia` |
| FMT_11 | Date: ak_data_zakonczenia not in future | `WHERE ak_data_zakonczenia > GETDATE()` |
| FMT_12 | Date: wi_data_umowy not in future | `WHERE wi_data_umowy > GETDATE()` |

### 3.4 Business rule checks (BUSINESS_RULE)

> Threshold values for anomaly checks are read from `configuration.threshold_config` — see section 2.5.

| Code | Severity | Check | Rationale | SQL / pseudo-SQL |
|---|---|---|---|---|
| BIZ_01 | BLOCKING | Every `sprawa` has at least one `sprawa_rola` | A case with no parties is invalid | `SELECT sp_id FROM sprawa WHERE sp_id NOT IN (SELECT spr_sp_id FROM sprawa_rola)` |
| BIZ_02a | INFO | `sprawa` records with no linked `wierzytelnosc` via `wierzytelnosc_rola` | Allowed — but these cases must have no entries in tables that require wierzytelnosc | `SELECT sp_id FROM sprawa WHERE sp_id NOT IN (SELECT wir_sp_id FROM wierzytelnosc_rola)` |
| BIZ_02b | BLOCKING | `sprawa` with no `wierzytelnosc` but has `dokument`, `ksiegowanie`, or `wplata` records | If no debt claim, these related tables must be empty for that case | `SELECT DISTINCT sp_id FROM sprawa sp WHERE sp_id NOT IN (SELECT wir_sp_id FROM wierzytelnosc_rola) AND (EXISTS (SELECT 1 FROM dbo.ksiegowanie_dekret ksd JOIN dbo.dokument d ON ksd.ksd_do_id = d.do_id JOIN dbo.wierzytelnosc_rola wr ON wr.wir_wi_id = d.do_wi_id WHERE wr.wir_sp_id = sp.sp_id))` |
| BIZ_03 | WARNING | Every `dluznik` is referenced by at least one `sprawa_rola` | Debtor with no case is an orphan — possibly staging artefact | `SELECT dl_id FROM dluznik WHERE dl_id NOT IN (SELECT spr_dl_id FROM sprawa_rola)` |
| BIZ_04 | WARNING | Every `wierzytelnosc` has at least one `dokument` | Debt claim without any document is suspicious | `SELECT wi_id FROM wierzytelnosc WHERE wi_id NOT IN (SELECT do_wi_id FROM dokument)` |
| BIZ_05 | BLOCKING | Every `ksiegowanie` has at least one `ksiegowanie_dekret` | Accounting entry with no posting lines is invalid | `SELECT ks_id FROM ksiegowanie WHERE ks_id NOT IN (SELECT ksd_ks_id FROM ksiegowanie_dekret)` |
| BIZ_06 | BLOCKING | Double-entry balance: SUM(ksd_kwota_wn) = SUM(ksd_kwota_ma) per `ksiegowanie` | Fundamental accounting rule | `SELECT ksd_ks_id, SUM(ksd_kwota) FROM ksiegowanie_dekret GROUP BY ksd_ks_id HAVING SUM(ksd_kwota) <> 0` — exact SQL pending wn/ma split confirmation |
| BIZ_07 | WARNING | Every `sprawa` has at least one `akcja` | A case with no action history is unusual | `SELECT sp_id FROM sprawa WHERE sp_id NOT IN (SELECT ak_sp_id FROM akcja)` |
| BIZ_08 | BLOCKING | Every `akcja` has at least one `rezultat` | At least one rezultat is always required per action | `SELECT ak_id FROM akcja WHERE ak_id NOT IN (SELECT re_ak_id FROM rezultat)` |
| BIZ_09 | WARNING | One-to-many anomaly: dluznik with phone count above threshold | Likely data quality issue | `DECLARE @t INT = (SELECT CAST(cfg_value AS INT) FROM configuration.threshold_config WHERE cfg_key = 'max_phones_per_dluznik'); SELECT tn_dl_id, COUNT(*) AS cnt FROM telefon GROUP BY tn_dl_id HAVING COUNT(*) > @t` |
| BIZ_10 | WARNING | One-to-many anomaly: dluznik with address count above threshold | Same | `DECLARE @t INT = (SELECT CAST(cfg_value AS INT) FROM configuration.threshold_config WHERE cfg_key = 'max_adresy_per_dluznik'); SELECT ad_dl_id, COUNT(*) FROM adres GROUP BY ad_dl_id HAVING COUNT(*) > @t` |
| BIZ_11 | WARNING | One-to-many anomaly: sprawa with akcja count above threshold | May indicate duplication | `DECLARE @t INT = (SELECT CAST(cfg_value AS INT) FROM configuration.threshold_config WHERE cfg_key = 'max_akcje_per_sprawa'); SELECT ak_sp_id, COUNT(*) FROM akcja GROUP BY ak_sp_id HAVING COUNT(*) > @t` |
| BIZ_12 | WARNING | One-to-many anomaly: wierzytelnosc with dokument count above threshold | Verify this is expected | `DECLARE @t INT = (SELECT CAST(cfg_value AS INT) FROM configuration.threshold_config WHERE cfg_key = 'max_dokumenty_per_wierzytelnosc'); SELECT do_wi_id, COUNT(*) FROM dokument GROUP BY do_wi_id HAVING COUNT(*) > @t` |
| BIZ_13 | INFO | dluznik with no personal identifier (no PESEL, NIP, dowod, paszport) | Low data quality — record still migratable | `SELECT dl_id FROM dluznik WHERE dl_pesel IS NULL AND dl_nip IS NULL AND dl_dowod IS NULL AND dl_paszport IS NULL` |
| BIZ_14 | INFO | `wierzytelnosc` with no associated `ksiegowanie` records | Debt claim never posted to accounting | `SELECT wi_id FROM wierzytelnosc wi WHERE NOT EXISTS (SELECT 1 FROM ksiegowanie_dekret ksd JOIN dokument d ON ksd.ksd_do_id=d.do_id WHERE d.do_wi_id=wi.wi_id)` |
| BIZ_15 | WARNING | `harmonogram` records with no matching `wierzytelnosc` | Orphan schedule | TBD once prod table identified |

---

## 4. Pre-migration report

**Purpose:** Human-readable summary of all validation results before migration is approved to run.

**Contents:**
1. Run metadata (date, stage, data extract date)
2. Summary table: checks run / passed / failed / warnings
3. Blocking failures detail (must fix before proceeding)
4. Warning detail (accept or fix)
5. Per-table record counts in staging

**Format:** SQL query run against `dm_staging` after validation completes:

```sql
SELECT
    check_name,
    check_type,
    severity,
    affected_count,
    sample_ids,
    detail
FROM log.validation_result
WHERE run_id = @run_id
ORDER BY
    CASE severity WHEN 'BLOCKING' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
    check_name;
```

**Sample output:**

| check_name | check_type | severity | affected_count | sample_ids | detail |
|---|---|---|---|---|---|
| BIZ_01_sprawa_bez_roli | BUSINESS_RULE | BLOCKING | 2 | 1045,1302 | sprawa records with no sprawa_rola. Count: 2 |
| REF_07_dokument_wierzytelnosc | REFERENTIAL | BLOCKING | 0 | — | — |
| TECH_03_sprawa_numer_rachunku_null | TECHNICAL | BLOCKING | 0 | — | — |
| BIZ_03_dluznik_bez_sprawy | BUSINESS_RULE | WARNING | 5 | 12,34,67,89,103 | dluznik records not referenced by any sprawa_rola. Count: 5 |
| BIZ_04_wierzytelnosc_bez_dokumentu | BUSINESS_RULE | WARNING | 0 | — | — |

**Decision gate:** Migration should NOT proceed if any BLOCKING check has `affected_count > 0`.

---

## 5. Validation spec for Intrum team

**Format:** Table document with:

| Column | Content |
|---|---|
| Code | |
| Category | Referential / Technical / Business Rule |
| Severity | Blocking / Warning |
| Table | staging table name |
| Description | plain language |
| SQL | runnable check query against dm_staging |
| Expected result | "0 rows returned = pass" |

**Scope for external team:** REF_01–REF_34 (all referential), TECH_03–TECH_10 (blocking technical), BIZ_01, BIZ_02b, BIZ_05–BIZ_06, BIZ_08 (hard blocking business rules). Advisory: remaining BIZ_* and FMT_* checks.

**Language:** The final deliverable document will be in **Polish**.

**Status:** Draft — to be generated as a separate .docx after validations are finalized (topic 3).

---

## 6. Migration execution scripts

### 6.1 Script structure

One SQL script per iteration + pre-check + post-report. Scripts live in `scripts/stage{N}/` under the migration directory:

```
scripts/
  stage1/
    00_pre_check.sql          -- validate no BLOCKING errors before proceeding
    01_iter1_lookups.sql      -- all dict/lookup tables (MERGE on UUID)
    02_iter2_dluznik.sql
    03_iter3_adres_mail_telefon.sql
    04_iter4_sprawa.sql
    05_iter5_akcja_rezultat.sql
    06_iter6_wierzytelnosc.sql
    07_iter7_wierzytelnosc_rola_dokument.sql
    08_iter8_financial.sql
    09_iter9_harmonogram.sql
    99_post_report.sql
  stage2/
    ... (same structure)
```

### 6.2 Run tracking

Every execution starts by inserting a row into `log.migration_run` (status = `'RUNNING'`).
- `run_date` = `GETDATE()` at run start — this is the run timestamp, not a magic number
- `run_by` = `SYSTEM_USER` (Windows login or SQL Agent job name)
- `@run_id` (from `SCOPE_IDENTITY()`) flows through all sub-scripts as a parameter/variable
- On clean finish: `UPDATE log.migration_run SET status = 'COMPLETED', duration_seconds = DATEDIFF(s, run_date, GETDATE()) WHERE run_id = @run_id`
- On failure: update to `'FAILED'`

### 6.3 Pre-check guard (`00_pre_check.sql`)

Queries `log.validation_result` for the most recent validation run linked to this migration stage:

```sql
IF EXISTS (
    SELECT 1 FROM log.validation_result
    WHERE run_id = @val_run_id
      AND severity = 'BLOCKING'
      AND affected_count > 0
)
    THROW 50001, 'Pre-migration validation has blocking failures. Migration aborted.', 1;
```

Migration scripts (01–09) trust that this gate was passed; they do not re-validate data.

### 6.4 Idempotency

- **Dict/lookup tables (iter 1):** `MERGE` on UUID column — safe to re-run; existing rows updated, new rows inserted.
- **Entity tables:** `INSERT ... SELECT ... WHERE NOT EXISTS (SELECT 1 FROM prod.tbl WITH (NOLOCK) WHERE tbl_ext_id = stg.id)` — already-migrated rows are silently skipped without performance penalty (ext_id is indexed).
- **FK resolution on re-runs:** `JOIN prod.tbl ON prod.tbl.tbl_ext_id = stg.fk_id` — always resolves correctly regardless of run number.

### 6.5 Staging ID uniqueness (cross-stage constraint)

Each migration stage's staging data **must use non-overlapping PK ranges**. At the start of each new stage, the maximum existing ID in each entity table is checked and the new stage's IDs must start well above that value — with enough headroom to avoid collision. For example:

- Stage 1: IDs in the low range (e.g. 1 – 100k)
- Stage 2: IDs starting at a clearly separated base (e.g. 1M – 2M)
- Stage 3: IDs starting at a further separated base (e.g. 10M – 20M)
- and so on — actual ranges agreed between BAKK and Intrum before each stage

This is a data management requirement enforced on the Intrum team side. Without non-overlapping ranges, the `NOT EXISTS` idempotency check cannot distinguish a "stage 1 already migrated" row from a new "stage 2 row with the same staging ID".

### 6.6 Staging lifecycle per stage

| Step | Action | Responsible |
|---|---|---|
| 1 | Backup current `dm_staging` (copy to `dm_staging_stageN_backup`) | **BAKK** |
| 2 | Truncate / drop staging entity tables | **BAKK** |
| 3 | Populate fresh staging data for new stage | **Intrum** |
| 4 | Run validation scripts, share results report | **BAKK** |
| 5 | Correct blocking issues in source data; repeat steps 4–5 until no BLOCKING failures | **Intrum** |
| 6 | Review and confirm pre-migration report — formal go/no-go | **Intrum** |
| 7 | Run `00_pre_check.sql` gate; abort if any BLOCKING check fails | **BAKK** |
| 8 | Run migration scripts `01_iter1` through `09_iter9` | **BAKK** |
| 9 | Run `99_post_report.sql`, share post-migration report | **BAKK** |
| 10 | Validate post-migration report, formal sign-off | **Intrum** |

### 6.7 Performance rules

| Rule | Detail |
|---|---|
| `SET NOCOUNT ON` | Top of every script — eliminates row count messages |
| Set-based inserts | `INSERT ... SELECT` only — no cursors, no row-by-row |
| `WITH (NOLOCK)` on staging reads | No concurrent writes during migration window |
| `WITH (TABLOCK)` on prod inserts | Enables minimal logging under SIMPLE recovery model |
| `OUTPUT INTO #mapping` | Capture IDENTITY values in-flight — never re-query for generated PKs |
| Indexed temp tables | Every `#mapping` temp table has a PK or covering index on the ext_id lookup column |
| Index disable/rebuild | For the 5 largest tables (`dluznik`, `sprawa`, `wierzytelnosc`, `akcja`, `ksiegowanie_dekret`): disable non-clustered indexes before bulk insert, `ALTER INDEX ALL ... REBUILD` after |
| Single-pass FK resolution | All FK lookups resolved in one JOIN per INSERT — no nested subqueries per row |

### 6.8 Per-script logging pattern

Each migration script follows this structure:

```
1. DECLARE @run_id, @table_name, @attempted, @inserted, @skipped, @failed
2. SET @attempted = (SELECT COUNT(*) FROM staging.tbl)
3. Main INSERT block with OUTPUT INTO #inserted_ids
4. SET @inserted = @@ROWCOUNT (or count of #inserted_ids)
5. TRY/CATCH on individual error cases → INSERT INTO log.migration_error
6. SET @skipped = @attempted - @inserted - @failed
7. INSERT INTO log.migration_table_summary (run_id, table_name, records_attempted,
   records_inserted, records_skipped, records_failed)
```

Error rows written to `log.migration_error` include: `staging_pk`, `error_type` (from taxonomy in section 2), `error_message`, `error_data` (JSON snapshot of staging row).

**Error handling:** Skip failed record/entity, log it, continue — no full rollback per table (decided in section 1).

---

## 7. Post-migration quality checks / KPIs

Checks run against `dm_data_web` after migration completes, comparing with staging baseline.

### 7.1 Record count reconciliation (COUNT)

How pass condition works depends on the migration stage:

- **Stage 1** — production DB is empty before migration. Expected prod count = staging count exactly.
- **Stages 2–5** — production already has data from previous stages. `log.prod_snapshot` captures prod counts at the start of each run (inside `00_pre_check.sql`; DELETE + re-INSERT handles reruns). Expected prod count after migration = snapshot count + staging count.

| KPI code | Check |
|---|---|
| KPI_CNT_01 | COUNT dluznik |
| KPI_CNT_02 | COUNT sprawa |
| KPI_CNT_03 | COUNT wierzytelnosc |
| KPI_CNT_04 | COUNT sprawa_rola |
| KPI_CNT_05 | COUNT wierzytelnosc_rola (including auto-created from wi_sp_id) |
| KPI_CNT_06 | COUNT adres |
| KPI_CNT_07 | COUNT telefon |
| KPI_CNT_08 | COUNT mail |
| KPI_CNT_09 | COUNT akcja |
| KPI_CNT_10 | COUNT dokument |
| KPI_CNT_11 | COUNT ksiegowanie |
| KPI_CNT_12 | COUNT ksiegowanie_dekret (note: operacja also generates rows — TBD once operacja mapping confirmed) |
| KPI_CNT_13 | COUNT log.migration_error = 0 (actual exceptions; lookup skips shown separately in note) |

### 7.2 Financial reconciliation (SUM)

| KPI code | Check | Pass condition |
|---|---|---|
| KPI_SUM_01 | SUM ksd_kwota in staging = SUM(ksd_kwota_wn + ksd_kwota_ma) in prod per ksiegowanie | delta = 0 |
| KPI_SUM_02 | SUM oper_kwota_w_pln per wierzytelnosc in staging ≈ SUM ksd_kwota_wn_bazowa / ksd_kwota_ma_bazowa in prod | tolerance TBD |
| KPI_SUM_03 | SUM oper_kwota_kapitalu_w_pln = SUM prod ksd amounts for capital ksk accounts | delta = 0 |
| KPI_SUM_04 | SUM oper_kwota_odsetek_w_pln = SUM prod ksd amounts for interest ksk accounts | delta = 0 |

### 7.3 Data quality anomalies (ANOMALY — same as BIZ_* but on prod data)

| KPI code | Check | Threshold |
|---|---|---|
| KPI_ANO_01 | wierzytelnosc without any dokument in prod | count = 0 (or matches pre-migration baseline) |
| KPI_ANO_02 | ksiegowanie without any ksiegowanie_dekret in prod | count = 0 |
| KPI_ANO_03 | dluznik with no sprawa_rola in prod | count = 0 |
| KPI_ANO_04 | sprawa with no wierzytelnosc_rola in prod | count = 0 |
| KPI_ANO_05 | One-to-many anomalies — same checks as BIZ_09–12 on prod | count matches pre-migration baseline |
| KPI_ANO_06 | dluznik with no personal identifier in prod | matches pre-migration baseline |
| KPI_ANO_07 | Double-entry balance check in prod ksiegowanie_dekret | SUM(ksd_kwota_wn) = SUM(ksd_kwota_ma) per ks_id |
| KPI_ANO_08 | NEW prod records with ext_id = NULL since last snapshot (missed IDENTITY rule) | count = 0 |
| KPI_ANO_09 | Duplicate ext_id values in prod (any table) | count = 0 |
| KPI_ANO_10 | Prod wierzytelnosc records not linked to any sprawa via wierzytelnosc_rola | count = 0 |

### 7.4 Post-migration summary comparison table

Three-column report: **Indicator | Staging value | Production value**. Populated by querying both DBs after migration. Delta = 0 expected unless explicitly noted.

**Sample output (stage 1 test data):**

| Indicator | Staging | Production | Delta | Status |
|---|---|---|---|---|
| Liczba dłużników | 12 | 12 | 0 | PASS |
| Liczba spraw | 10 | 10 | 0 | PASS |
| Liczba wierzytelności | 10 | 10 | 0 | PASS |
| Liczba dokumentów | 17 | 17 | 0 | PASS |
| Liczba ról na sprawach | 15 | 15 | 0 | PASS |
| Liczba ról na wierzytelnościach | 10 | 10 | 0 | PASS |
| Liczba adresów | 15 | 15 | 0 | PASS |
| Liczba telefonów | 15 | 15 | 0 | PASS |
| Liczba e-maili | 12 | 12 | 0 | PASS |
| Liczba akcji | 20 | 20 | 0 | PASS |
| Liczba księgowań | 15 | 15 | 0 | PASS |
| Liczba dekretów księgowych | 35 | 35 | 0 | PASS |
| Rekordy pominięte (błędy migracji) | — | 0 | — | PASS |
| Rekordy zmigrowane pomyślnie | — | 390 | — | PASS |

| Indicator | Staging SQL | Production SQL |
|---|---|---|
| Liczba dłużników | `SELECT COUNT(*) FROM dm_staging.dbo.dluznik` | `SELECT COUNT(*) FROM dm_data_web.dbo.dluznik` |
| Liczba spraw | `SELECT COUNT(*) FROM dm_staging.dbo.sprawa` | `SELECT COUNT(*) FROM dm_data_web.dbo.sprawa` |
| Liczba wierzytelności | `SELECT COUNT(*) FROM dm_staging.dbo.wierzytelnosc` | `SELECT COUNT(*) FROM dm_data_web.dbo.wierzytelnosc` |
| Liczba dokumentów | `SELECT COUNT(*) FROM dm_staging.dbo.dokument` | `SELECT COUNT(*) FROM dm_data_web.dbo.dokument` |
| Liczba ról na sprawach | `SELECT COUNT(*) FROM dm_staging.dbo.sprawa_rola` | `SELECT COUNT(*) FROM dm_data_web.dbo.sprawa_rola` |
| Liczba ról na wierzytelnościach | `SELECT COUNT(*) FROM dm_staging.dbo.wierzytelnosc_rola` | `SELECT COUNT(*) FROM dm_data_web.dbo.wierzytelnosc_rola` |
| Liczba adresów | `SELECT COUNT(*) FROM dm_staging.dbo.adres` | `SELECT COUNT(*) FROM dm_data_web.dbo.adres` |
| Liczba telefonów | `SELECT COUNT(*) FROM dm_staging.dbo.telefon` | `SELECT COUNT(*) FROM dm_data_web.dbo.telefon` |
| Liczba e-maili | `SELECT COUNT(*) FROM dm_staging.dbo.mail` | `SELECT COUNT(*) FROM dm_data_web.dbo.mail` |
| Liczba akcji | `SELECT COUNT(*) FROM dm_staging.dbo.akcja` | `SELECT COUNT(*) FROM dm_data_web.dbo.akcja` |
| Liczba księgowań | `SELECT COUNT(*) FROM dm_staging.dbo.ksiegowanie` | `SELECT COUNT(*) FROM dm_data_web.dbo.ksiegowanie` |
| Liczba dekretów księgowych | `SELECT COUNT(*) FROM dm_staging.dbo.ksiegowanie_dekret` | `SELECT COUNT(*) FROM dm_data_web.dbo.ksiegowanie_dekret` |
| Łączna kwota kapitału (PLN) | `SELECT SUM(oper_kwota_kapitalu_w_pln) FROM dm_staging.dbo.operacja` | `SELECT SUM(ksd_kwota_wn_bazowa - ksd_kwota_ma_bazowa) FROM dm_data_web.dbo.ksiegowanie_dekret ksd JOIN dm_data_web.dbo.ksiegowanie_konto ksk ON ksd.ksd_ksk_id=ksk.ksk_id WHERE ksk.ksk_nazwa LIKE '%kapital%'` — exact filter TBD per ksk_id mapping |
| Łączna kwota odsetek (PLN) | `SELECT SUM(oper_kwota_odsetek_w_pln) FROM dm_staging.dbo.operacja` | analogicznie dla kont odsetek |
| Łączna kwota odsetek karnych (PLN) | `SELECT SUM(oper_kowta_odsetek_karnych_w_pln) FROM dm_staging.dbo.operacja` | analogicznie |
| Łączna kwota opłat (PLN) | `SELECT SUM(oper_kwota_oplaty_w_pln) FROM dm_staging.dbo.operacja` | analogicznie |
| Łączna kwota prowizji (PLN) | `SELECT SUM(oper_kwota_prowizji_w_pln) FROM dm_staging.dbo.operacja` | analogicznie |
| Łączna kwota operacji (PLN) | `SELECT SUM(oper_kwota_w_pln) FROM dm_staging.dbo.operacja` | `SELECT SUM(ksd_kwota_wn_bazowa) FROM dm_data_web.dbo.ksiegowanie_dekret` |
| Rekordy pominięte (błędy migracji) | — | `SELECT COUNT(*) FROM dm_staging.log.migration_error WHERE run_id = @run_id` |
| Rekordy zmigrowane pomyślnie | — | `SELECT SUM(records_inserted) FROM dm_staging.log.migration_table_summary WHERE run_id = @run_id` |

> **Note:** Financial indicator SQL (ksk account filters) will be finalized once ksk_id → amount type mapping is confirmed with dev team (operacja Q2).

### 7.5 Research needed

Best practices for post-migration data quality in debt management / financial systems — areas to investigate:
- [ ] Ageing analysis: are dates (data_umowy, data_wymagalnosci) distributed sensibly after migration?
- [ ] Currency consistency: all PLN amounts match converted foreign currency amounts within rounding tolerance
- [ ] Duplicate detection: same PESEL / NIP appearing on multiple dluznik records
- [ ] Referential completeness in prod: all FKs resolve (verify no orphans introduced by IDENTITY mapping)
- [ ] NULL ratio comparison: staging vs prod for key fields — sudden increase in NULLs indicates mapping error
