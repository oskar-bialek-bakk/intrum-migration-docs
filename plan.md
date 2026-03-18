# Intrum — Staging → Production Migration Plan

## Project overview

- **Source DB:** `dm_staging`
- **Target DB:** `dm_data_web`
- **Staging schema file:** `migration/scripts/staging.sql`
- **Migration stages:** 5 stages over ~2-3 years
  - Stage 1: production DB is empty
  - Stages 2-5: production already has data — inserts only, no updates; existence checks needed for lookup/dictionary tables to avoid duplicates

---

## Global conventions (decided)

| Topic | Decision |
|---|---|
| `mod_date` (staging) | Maps to `aud_data` (prod) — **handled by triggers, do not insert** |
| `aud_login` (prod only) | **Handled by triggers, do not insert** |
| `*_uuid` columns (prod only) | Insert `NEWID()` |
| `*_ext_id` columns (prod only) | Store staging PK — mapped per table (see individual tables) |
| `*_tworzacy_us_id` columns | Use `@system_admin_user_id` variable — set actual value when scripting migration |
| Schema | All prod tables are `dbo.*` |
| Existence checks (stages 2-5) | Required for all lookup/dictionary tables before insert |
| **IDENTITY PKs (global)** | **All 13 main entity tables in prod have IDENTITY PKs — never insert staging PK as prod PK. Let DB engine generate. Store staging PK in `*_ext_id`. When migrating child tables, resolve prod FK by: `WHERE *_ext_id = staging_id`** |
| **UUID merge for lookup tables (stages 2-5)** | **All staging lookup/dictionary tables have a `*_uuid UNIQUEIDENTIFIER` column (generated once at staging setup). On stages 2-5, MERGE into prod ON `uuid` match — insert if not exists, never update. Applies to: `adres_typ`, `dluznik_typ`, `dokument_typ`, `ksiegowanie_konto`, `ksiegowanie_typ`, `sprawa_rola_typ`, `sprawa_typ`, `sprawa_etap` (→ `sprawa_etap_typ`), `telefon_typ`, `atrybut_dziedzina`, `atrybut_rodzaj`, `atrybut_typ`, `akcja_typ`, `rezultat_typ`** |
| `plec` mapping | Staging uses letter codes ('K'=kobieta, 'M'=mezczyzna, 'B'=brak danych) in `mapowanie.plec` table → maps to prod `plec.pl_id` (1,2,4). `dl_plec NULL` → `dl_pl_id NULL` (nullable in prod) |
| **Mapping tables convention** | All value-mapping tables live in schema `mapowanie` with Polish names (e.g. `mapowanie.plec`). Staging has a `mapowanie` schema created at setup. |

---

## Table mapping index

| # | Staging table | Prod table(s) | Status |
|---|---|---|---|
| 1 | `adres_typ` | `adres_typ` | ✅ Ready to script |
| 2 | `dluznik_typ` | `dluznik_typ` | ✅ Ready to script |
| 3 | `dokument_typ` | `dokument_typ` | ✅ Ready to script |
| 4 | `ksiegowanie_konto` | `ksiegowanie_konto` | ✅ Ready to script |
| 5 | `ksiegowanie_typ` | `ksiegowanie_typ` | ✅ Ready to script |
| 6 | `sprawa_rola_typ` | `sprawa_rola_typ` | ✅ Ready to script |
| 7 | `atrybut_dziedzina` | `atrybut_dziedzina` | ✅ Ready to script |
| 8 | `atrybut_rodzaj` | `atrybut_rodzaj` | ✅ Ready to script |
| 9 | `atrybut_typ` | `atrybut_typ` | ✅ Ready to script |
| 10 | `sprawa_etap` | `sprawa_etap_typ` | ✅ Ready to script |
| 11 | `telefon_typ` | `telefon_typ` | ✅ Ready to script (PK renamed: tt_id→tnt_id) |
| 12 | `dluznik` | `dluznik` | ✅ Ready to script |
| 13 | `sprawa` | `sprawa` + `operator` | ✅ Ready to script |
| 14 | `wierzytelnosc` | `wierzytelnosc` | ✅ Ready to script |
| 15 | `adres` | `adres` | ✅ Ready to script |
| 16 | `akcja` | `akcja` + `akcja_typ` + `rezultat` + `rezultat_typ` | ✅ Ready to script |
| 17 | `atrybut` | `atrybut_wartosc` + `atrybut_dluznik` / `atrybut_sprawa` / `atrybut_wierzytelnosc` | ✅ Ready to script |
| 18 | `dokument` | `dokument` | ✅ Ready to script |
| 19 | `harmonogram` | `dokument` + `ksiegowanie` + `ksiegowanie_dekret` chain | 🔴 Open questions |
| 20 | `ksiegowanie` | `ksiegowanie` | 🔴 Open questions |
| 21 | `ksiegowanie_dekret` | `ksiegowanie_dekret` | 🔴 Open questions |
| 22 | `mail` | `mail` | ✅ Ready to script |
| 23 | `operacja` | `ksiegowanie_dekret` + `wplata` / `korekta` | 🔴 Open questions |
| 24 | `sprawa_rola` | `sprawa_rola` | ✅ Ready to script |
| 25 | `telefon` | `telefon` | ✅ Ready to script |
| 26 | `wierzytelnosc_rola` | `wierzytelnosc_rola` | ✅ Ready to script |
| 27 | `zabezpieczenie` | ❓ No prod table found | 🔵 Stage 2+ only |
| 28 | — | Multi-currency infrastructure | 🔴 Schema changes needed |

For column-by-column mapping details see [column_mapping.md](column_mapping.md).

---

## Decisions log

| Date | Decision |
|---|---|
| 2026-03-02 | `aud_data` / `aud_login` handled by prod triggers — do not insert |
| 2026-03-02 | `*_uuid` columns — insert `NEWID()` |
| 2026-03-02 | `*_ext_id` columns — mapped per table individually |
| 2026-03-02 | Migration is insert-only (no updates); stages 2-5 need existence checks on lookup tables |
| 2026-03-03 | `rachunek_bankowy.rb_bank` default = `''` (empty string) |
| 2026-03-03 | `sp_pracownik` → `operator` mapping deferred; `sp_pr_id = NULL` for now |
| 2026-03-03 | `wierzytelnosc.wi_wt_id` default = `1` |
| 2026-03-03 | `wierzytelnosc_rola.wir_wirt_id` default = `1` for records auto-created from `wi_sp_id` |
| 2026-03-03 | `wi_uko_id` required in prod; staging `dbo.kontrahent` + `dbo.umowa_kontrahent` added to staging.sql |
| 2026-03-03 | staging `wi_id` → prod `wi_ext_id` (IDENTITY rule applies to wierzytelnosc) |
| 2026-03-03 | `*_tworzacy_us_id` → `@system_admin_user_id` variable across all tables (adres, mail, telefon) |
| 2026-03-03 | `ad_data_od` = staging `mod_date`; `ad_zpi_id` = `2` (external system) |
| 2026-03-03 | prod `adres.ad_id` confirmed IDENTITY; staging `ad_id` → `ad_ext_id` |
| 2026-03-03 | prod `akcja.ak_id` confirmed IDENTITY; staging `ak_id` → `ak_ext_id` |
| 2026-03-03 | `ak_kolejnosc = 0`, `ak_interwal = 0` for all migrated `akcja` rows |
| 2026-03-03 | `akt_akk_id = 1`, `akt_koszt = 1.00`, `akt_wielokrotna = 1` for migrated `akcja_typ` rows |
| 2026-03-03 | staging `akcja_typ` + `rezultat_typ` + `rezultat` tables added; UUID-based MERGE strategy for stages 2-5 |
| 2026-03-03 | `ret_konczy` belongs on `rezultat_typ` (not per `akcja` row); set manually per type in staging |
| 2026-03-03 | prod `mail.ma_id` confirmed IDENTITY; staging `ma_id` → `ma_ext_id` |
| 2026-03-03 | `ma_mat_id = 1`; `ma_data_od = mod_date`; staging `ma_adres_mailowy` changed to `VARCHAR(50)` |
| 2026-03-03 | `tn_data_od = mod_date` (telefon) |
| 2026-03-03 | `spr_kwota_poreczenia_do = 0`, `spr_data_od = mod_date`, `spr_data_do = 9999-12-31` (sprawa_rola + wierzytelnosc_rola) |
| 2026-03-03 | `tn_zpi_id = 2`; `wir_wirt_id = NULL` for migrated rows |
| 2026-03-03 | `tn_id` → `tn_ext_id` (IDENTITY rule applies to telefon) |
| 2026-03-03 | `spr_id` → `spr_ext_id`; `wir_id` → `wir_ext_id` (IDENTITY rule applies to sprawa_rola + wierzytelnosc_rola) |
| 2026-03-03 | `akcja.ak_data_wykonania` → `ak_zakonczono` in prod; etap tracking (table 10) handled automatically by regular akcja migration |
| 2026-03-03 | UUID merge strategy extended to all staging lookup tables (adres_typ, dluznik_typ, dokument_typ, ksiegowanie_konto, ksiegowanie_typ, sprawa_rola_typ, sprawa_typ, sprawa_etap, telefon_typ, atrybut_dziedzina, atrybut_rodzaj, atrybut_typ) |
| 2026-03-03 | `atrybut.at_ob_id` → entity FK resolved via `*_ext_id` lookup (atdl_dl_id, atwi_wi_id, atsp_sp_id, atdo_do_id) |
| 2026-03-05 | `dokument.do_uko_id` = `wierzytelnosc.wi_uko_id` JOIN via `do_wi_id` |
| 2026-03-05 | `dokument.do_data_wymagalnosci` does NOT go on prod `dokument` — feeds `ksiegowanie_dekret.ksd_data_wymagalnosci` for `ks_pierwotne = 1` rows only |
| 2026-03-05 | `dokument.do_id` → `do_ext_id` (IDENTITY rule applies to dokument) |
| 2026-03-05 | `sprawa.sp_pr_id` = `GE_USER.US_ID` WHERE `US_LOGIN = sp_pracownik`; GE_USER must be pre-populated in prod |
| 2026-03-05 | `sprawa` migration also creates `operator` records: `op_sp_id=prod_sp_id`, `op_us_id=GE_USER.US_ID`, `op_data_od=mod_date`, `op_zastepstwo=0`; `op_opt_id` TBD |
| 2026-03-05 | `ksiegowanie.ks_na_rachunek_kontrahenta = 0` always |
| 2026-03-05 | `ksiegowanie.ks_zamkniete = 1` default (0 for unposted — logic TBD); `ks_pierwotne = 1` for initial values (logic TBD); `ks_od_komornika = 1` if bailiff (detection TBD) |
| 2026-03-05 | `ksiegowanie_dekret.ksd_data_wymagalnosci` = `dokument.do_data_wymagalnosci` via `ksd_do_id`, only for `ks_pierwotne = 1`; fallback TBD |
| 2026-03-05 | `ksiegowanie_dekret.ksd_ext_id` (VARCHAR(255)) already exists in prod — store staging `ksd_id` there |
| 2026-03-05 | Multi-currency: `ksd_kwota_wn_bazowa`, `ksd_kwota_ma_bazowa`, `ksd_wa_id`, `ksd_kurs_bazowy` already in prod; add `ksd_kwota_wn_wyceny`, `ksd_kwota_ma_wyceny`, `ksd_wa_id_wyceny`, `ksd_kurs` |
| 2026-03-05 | `waluta` + `kurs_walut` tables already exist in prod; need to add to staging and populate from prod |
| 2026-03-05 | `operacja` maps to `ksiegowanie_dekret` (always) + `wplata` or `korekta` depending on operation type; split by capital/interest/fees/commissions accounts |
| 2026-03-05 | `harmonogram` has no direct prod data table (raport_harmonogram is reporting only); prod table TBD |
| 2026-03-07 | staging `akcja` table restructured: removed `ak_kod_akcji`, `ak_nazwa_akcji`, `ak_kod_rezultatu_akcji`, `ak_nazwa_rezultatu_akcji`, `ak_data_wykonania`; added `ak_akt_id` (FK to staging `akcja_typ`) + `ak_data_zakonczenia` (maps to prod `ak_zakonczono`) |
| 2026-03-07 | sprawa/operator: op_opt_id=1; create operator record only when sp_pracownik IS NOT NULL |
| 2026-03-07 | harmonogram maps to dokument+ksiegowanie+ksiegowanie_dekret; kapital WN ksk=2, odsetki WN ksk=6, balancing MA ksk=1 |
| 2026-03-07 | ksiegowanie: ks_zamkniete=0 for unallocated payments; ks_pierwotne=0 for payment allocations |
| 2026-03-07 | ksiegowanie_dekret: ksd_data_wymagalnosci fallback = 2100-01-01 |
| 2026-03-07 | ksd_kurs: do NOT add — same as ksd_kurs_bazowy |
| 2026-03-07 | multi-currency wyceny columns go to STAGING (already in prod) |
| 2026-03-07 | operacja ksk_id: kapital=2, odsetki karne=5, umowne=6, ustawowe=8, oplaty=10, prowizje=10 (subkonto TBD) |

---

## Open questions summary (pending dev team input)

| Table | Status | Remaining questions |
|---|---|---|
| `harmonogram` | ⚠️ open | Maps to dokument+ksiegowanie+ksd chain; Q1-4: dot_id, kst_id, hr_typ, interest type |
| `ksiegowanie` | ⚠️ open | Q3 bailiff detection TBD (`ks_od_komornika`) |
| `ksiegowanie_dekret` | ⚠️ open | Q1 WN/MA indicator TBD (`oper_strona` unconfirmed) |
| `operacja` | ⚠️ open | wplata/korekta type TBD; oplaty/prowizje subkonto TBD |
| `zabezpieczenie` | 🔵 Stage 2+ only | Q1: which prod table (if any)? |
| Multi-currency (28) | ⚠️ open | wyceny columns need adding to staging.sql |
