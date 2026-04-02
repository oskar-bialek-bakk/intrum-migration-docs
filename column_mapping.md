# Intrum — Column Mapping: Staging → Production

Per-table column mapping details for all 41 migration items (sections 1-30 core, 31-41 wlasciwosc feature).
For planning overview, table index, and decisions log see [plan.md](plan.md).

---

### 1. `adres_typ` → `adres_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `at_id` | `at_id` | PK |
| `at_nazwa` | `at_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `at_uuid` | `at_uuid` | MERGE key for stages 2-5 |

**ext_id mapping:** none (no natural ext_id candidate)
**ext_id backfill:** UUID-keyed tables (adres_typ, dluznik_typ, telefon_typ, atrybut_typ, sprawa_etap_typ) require cross-DB backfill after MERGE to set `*_ext_id` for rows matched-but-not-inserted (already in prod). Pattern: `UPDATE stg SET ext_id = prod.pk FROM stg JOIN prod ON uuid WHERE ext_id IS NULL`. Added 2026-04-01 (QW6). dokument_typ, ksiegowanie_konto, ksiegowanie_typ use simple `SET ext_id = pk` because they merge on PK directly.

---

### 2. `dluznik_typ` → `dluznik_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `dt_id` | `dt_id` | PK |
| `dt_nazwa` | `dt_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `dt_uuid` | `dt_uuid` | MERGE key for stages 2-5 |

**ext_id mapping:** none

---

### 3. `dokument_typ` → `dokument_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `dot_id` | `dot_id` | PK |
| `dot_nazwa` | `dot_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `dot_uuid` | `dot_uuid` | MERGE key for stages 2-5 |
| — | `dot_przedawnienie` | NULL |
| — | `dot_odsetki` | NULL |
| — | `dot_kolejnosc_rozksiegowania NOT NULL` | constant `1` |
| — | `dot_kod` | NULL |

**✓ MERGE key:** iter1 now merges on `dot_uuid` (fixed from `dot_id` per review H1). Seed scripts updated to copy `dot_uuid` from prod. Works for all stages.


---

### 4. `ksiegowanie_konto` → `ksiegowanie_konto` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `ksk_id` | `ksk_id` | PK |
| `ksk_nazwa` | `ksk_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `ksk_uuid` | `ksk_uuid` | MERGE key for stages 2-5 |
| — | `ksk_ksk_id_nadrzedne` | NULL |
| — | `ksk_kolejnosc_rozksiegowania NOT NULL` | `99` |
| — | `ksk_czy_techniczne bit NOT NULL` | `0` — **TBD: verify per account after migration** |


---

### 5. `ksiegowanie_typ` → `ksiegowanie_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `kst_id` | `kst_id` | PK |
| `kst_nazwa` | `kst_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `kst_uuid` | `kst_uuid` | MERGE key for stages 2-5 |


---

### 6. `sprawa_rola_typ` → `sprawa_rola_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `sprt_id` | `sprt_id` | PK |
| `sprt_nazwa` | `sprt_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `sprt_uuid` | `sprt_uuid` | MERGE key for stages 2-5 |


---

### 7. `atrybut_dziedzina` → `atrybut_dziedzina` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `atd_id` | `atd_id` | PK |
| `atd_nazwa` | `atd_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `atd_uuid` | `atd_uuid` | MERGE key for stages 2-5 |


---

### 8. `atrybut_rodzaj` → `atrybut_rodzaj` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `atr_id` | `atr_id` | PK |
| `atr_nazwa` | `atr_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `atr_uuid` | `atr_uuid` | MERGE key for stages 2-5 |


---

### 9. `atrybut_typ` → `atrybut_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `att_id` | `att_id` | PK |
| `att_nazwa` | `att_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `att_uuid` | `att_uuid` | MERGE key for stages 2-5 |
| `att_atd_id` | `att_atd_id NOT NULL → atrybut_dziedzina` | direct — staging atrybut_typ now carries correct domain |
| `att_atr_id` | `att_atr_id NOT NULL → atrybut_rodzaj` | direct — staging atrybut_typ now carries correct data-type |
| — | `att_required bit NOT NULL` | `0` |
| — | `att_zrodlo_danych` | NULL |

**atrybut_dziedzina mapping (atd_id):** 1=dokument, 2=wierzytelnosc, 3=dluznik, 4=sprawa
**atrybut_rodzaj mapping (atr_id):** 1=text, 2=date, 3=number, 4-7=dictionary


---

### 10. `sprawa_etap` → `sprawa_etap_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `spe_id` | `spet_id` | PK renamed |
| `spe_nazwa` | `spet_nazwa` | renamed |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `spe_uuid` | `spet_uuid` | MERGE key for stages 2-5 |
| `spe_spt_id` | `spet_spt_id NOT NULL → sprawa_typ` | direct (added `spe_spt_id` to staging `sprawa_etap`) |
| — | `spet_akt_id NOT NULL → akcja_typ` | derived — see transformation logic below |
| — | `spet_kolorR` | `51` |
| — | `spet_kolorG` | `153` |
| — | `spet_kolorB` | `255` |
| — | `spet_kolejnosc` | `1` |

**sprawa_typ values in prod:** 1=Windykacyjna, 2=Handlowa, 3=Kontrahenta, 5=Dluznik, 6=Umowa-Wszyscy dluznicy
**staging change:** `spe_spt_id INT NOT NULL` added to `dbo.sprawa_etap` + `dbo.sprawa_typ` lookup table added to staging.sql

**Transformation logic (etap migration creates akcja_typ records):**
1. Add one row to staging `akcja_typ` for each `sprawa_etap` row (`akt_nazwa = spe_nazwa`, defaults for other cols — see table 16); `akt_uuid = NEWID()`
2. MERGE staging `akcja_typ` → prod `akcja_typ` ON `akt_uuid` (same as table 16 step 4)
3. MERGE staging `sprawa_etap` → prod `sprawa_etap_typ` ON `spe_uuid`: insert `spet_nazwa = spe_nazwa`, `spet_spt_id = spe_spt_id`, `spet_akt_id` = prod `akt_id` (join via `akt_uuid`), colours, `spet_kolejnosc = 1`

**How current etap is tracked in prod:**
No `sp_spe_id` column on prod `sprawa`. Instead: current etap = last `akcja` (ordered by `ak_zakonczono` DESC) whose `ak_akt_id` matches a `sprawa_etap_typ.spet_akt_id`. This is handled automatically by the regular `akcja` migration (table 16) — staging `akcja.ak_data_zakonczenia` maps to prod `ak_zakonczono`, so no separate akcja inserts are needed here.

**Note:** must run after `akcja_typ` is populated; etap tracking akcja records come from table 16

---

### 11. `telefon_typ` → `telefon_typ` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `tt_id` | `tnt_id` | PK renamed |
| `tt_nazwa` | `tnt_nazwa` | renamed |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `tt_uuid` | `tnt_uuid` | MERGE key for stages 2-5 |


---

### 12. `dluznik` → `dluznik` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `dl_id` | `dl_id` | PK |
| `dl_plec VARCHAR(1)` | `dl_pl_id INT → plec` | via `plec_mapping` table in staging ('K'→1,'M'→2,'B'→4); NULL→NULL |
| `dl_imie` | `dl_imie` | direct |
| `dl_nazwisko` | `dl_nazwisko` | direct |
| `dl_dowod` | `dl_numer_dowodu` | renamed |
| `dl_paszport` | `dl_numer_paszportu` | renamed |
| `dl_dluznik` | `dl_numer` | renamed |
| `dl_pesel` | `dl_pesel` | direct |
| `dl_dt_id` | `dl_dt_id` | direct |
| `dl_uwagi` | `dl_opis` | renamed |
| `dl_firma` | `dl_firma` | direct |
| `dl_import_info INT` | `dl_import_info VARCHAR` | ⚠️ CAST(dl_import_info AS VARCHAR) |
| `dl_nip` | `dl_nip` | direct |
| `dl_regon` | `dl_regon` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| — | `dl_ext_id` | store staging `dl_id` |
| staging `dl_id` | **NOT mapped to prod `dl_id`** | prod `dl_id` is IDENTITY — auto-generated; staging `dl_id` → `dl_ext_id` only |


---

### 13. `sprawa` → `sprawa` + `operator` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `sp_id` | `sp_ext_id` | staging PK → ext_id (IDENTITY rule) |
| `sp_numer_sprawy` | `sp_numer` | renamed |
| `sp_import_info` | `sp_import_info` | direct — format: `yyyy-mm-dd hh:mm:ss.zzz` |
| `sp_data_obslugi_od` | `sp_data_obslugi_od` | direct |
| `sp_data_obslugi_do` | `sp_data_obslugi_do` | direct |
| `sp_spt_id` | `sp_spt_id` | direct — added to staging |
| `mod_date` | `aud_data` | trigger |
| `sp_numer_rachunku` | `rachunek_bankowy.rb_nr` → `sp_rb_id` | see transformation logic below |
| `sp_pracownik` | `sp_pr_id` = `GE_USER.US_ID` WHERE `US_LOGIN = sp_pracownik` | GE_USER must be pre-populated in prod |
| `sp_pracownik` | → also insert into `operator` | one operator record per sprawa (see transformation logic) |
| `sp_spe_id` | via `akcja` (etap mechanism) | handled — see table 10 |

**staging change:** `sp_spt_id INT NOT NULL` added to `dbo.sprawa` with FK to `dbo.sprawa_typ`

**Transformation logic — rachunek_bankowy must be inserted before sprawa:**

`rachunek_bankowy` relevant columns: `rb_id` (IDENTITY), `rb_nr VARCHAR(50) NOT NULL`, `rb_bank VARCHAR(50) NOT NULL`

1. INSERT distinct `sp_numer_rachunku` values into prod `rachunek_bankowy` (`rb_nr = sp_numer_rachunku`, `rb_bank = ''`). Capture `OUTPUT inserted.rb_id, inserted.rb_nr` into temp table `#rb_mapping`.
2. INSERT into prod `sprawa`: JOIN staging `sprawa` → `#rb_mapping` on `sp_numer_rachunku = rb_nr` to get `sp_rb_id`; `sp_pr_id = GE_USER.US_ID WHERE US_LOGIN = sp_pracownik`.
3. UPDATE `rachunek_bankowy SET rb_sp_id = prod_sp_id` after sprawa insert (optional — `rb_sp_id` is nullable).
4. INSERT into prod `operator` **only when `sp_pracownik IS NOT NULL`**: `op_sp_id = prod_sp_id`, `op_us_id = GE_USER.US_ID WHERE US_LOGIN = sp_pracownik`, `op_data_od = mod_date`, `op_zastepstwo = 0`, `op_opt_id = 1`

**prod operator table columns (for reference):** `op_id` (PK), `op_sp_id` (NOT NULL), `op_us_id` (NOT NULL), `op_opt_id` (NOT NULL), `op_data_od` (NOT NULL), `op_data_do` (NULL), `op_zastepstwo bit` (NOT NULL)


---

### 14. `wierzytelnosc` → `wierzytelnosc` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `wi_id` | `wi_ext_id` | staging PK → ext_id (IDENTITY rule) |
| `wi_numer` | `wi_numer` | direct |
| `wi_tytul` | `wi_tytul` | direct |
| `wi_data_umowy` | `wi_data_umowy` | direct |
| `wi_uko_id` | `wi_uko_id NOT NULL → umowa_kontrahent` | direct (staging `wi_uko_id` FK → staging `dbo.umowa_kontrahent`) |
| `wi_sp_id` | ❌ not on prod `wierzytelnosc` | ⚠️ **structural** — create `wierzytelnosc_rola` record (see transformation logic) |
| `mod_date` | `aud_data` | trigger |
| — | `wi_wt_id NOT NULL → wierzytelnosc_typ` | `1` |
| — | `wi_uuid` | `NEWID()` |

**staging change:** `wi_uko_id INT NULL` added to `dbo.wierzytelnosc` with FK to staging `dbo.umowa_kontrahent(uko_id)`. Tables `dbo.kontrahent` and `dbo.umowa_kontrahent` added to staging.sql (populated from prod reference data before migration runs).

**Transformation logic:**
1. INSERT into prod `wierzytelnosc` (`wi_numer`, `wi_tytul`, `wi_data_umowy`, `wi_wt_id = 1`, `wi_uko_id = staging wi_uko_id`, `wi_ext_id = staging wi_id`, `wi_uuid = NEWID()`) → capture prod `wi_id` via `OUTPUT inserted.wi_id, inserted.wi_ext_id` into `#wi_mapping`
2. INSERT into prod `wierzytelnosc_rola` for each row: `wir_wi_id` = prod wi_id (from `#wi_mapping WHERE wi_ext_id = staging wi_id`), `wir_sp_id` = prod sp_id (`WHERE sp_ext_id = staging wi_sp_id`), `wir_wirt_id = 1`, plus defaults from table 26


---

### 15. `adres` → `adres` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `ad_id` | `ad_ext_id` | staging PK → ext_id (IDENTITY rule) |
| `ad_dl_id` | `ad_dl_id` | direct (resolve via `dl_ext_id`) |
| `ad_at_id` | `ad_at_id` | direct |
| `ad_ulica` | `ad_ulica` | direct |
| `ad_nr_domu` | `ad_nr_domu` | direct |
| `ad_nr_lokalu` | `ad_nr_lokalu` | direct |
| `ad_kod` | `ad_kod` | direct |
| `ad_miejscowosc` | `ad_miejscowosc` | direct |
| `ad_poczta` | `ad_poczta` | direct |
| `ad_panstwo` | `ad_panstwo` | direct |
| `ad_uwagi` | `ad_uwagi` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `ad_data_od NOT NULL` | staging `mod_date` |
| — | `ad_zpi_id NOT NULL → zrodlo_pochodzenia_informacji` | `2` (external system) |
| — | `ad_tworzacy_us_id NOT NULL` | `@system_admin_user_id` (variable — see global conventions) |

**Active address limit:** The maximum number of simultaneously active addresses per dluznik per `ad_at_id` is controlled by `dm_data_web_pipeline.dbo.adres_typ_podmiot_konfiguracja.atpk_il` (filtered by `atp_id=2` for dluznik). Exceeding this limit is a BLOCKING validation error (BIZ_20).


---

### 16. `akcja` → `akcja` + `akcja_typ` + `rezultat` + `rezultat_typ` ✅

Staging row contains merged action+result data. Dedicated staging tables `akcja_typ`, `rezultat_typ`, `rezultat` added to support the migration chain and UUID-based prod MERGE.

**Staging tables added:** `dbo.akcja_typ`, `dbo.rezultat_typ`, `dbo.rezultat`

**UUID merge strategy (stages 2-5):** staging `akcja_typ.akt_uuid` and `rezultat_typ.ret_uuid` are generated once and used to match records against prod on re-runs — avoids reliance on integer IDs that may diverge.

| Staging source | Prod table.column | Note |
|---|---|---|
| `staging.akcja_typ.akt_kod_akcji` | `akcja_typ.akt_kod_akcji` | pre-populated from DISTINCT staging `akcja` |
| `staging.akcja_typ.akt_nazwa` | `akcja_typ.akt_nazwa` | pre-populated from DISTINCT staging `akcja` |
| `staging.akcja_typ.akt_rodzaj` | `akcja_typ.akt_rodzaj NOT NULL` | ⚠️ set manually per row in staging |
| `staging.akcja_typ.akt_ikona` | `akcja_typ.akt_ikona` | ⚠️ set manually per row in staging |
| `staging.akcja_typ.akt_uuid` | merge key on `akcja_typ` | — |
| — | `akcja_typ.akt_akk_id NOT NULL` | `1` |
| — | `akcja_typ.akt_koszt NOT NULL` | `1.00` |
| — | `akcja_typ.akt_wielokrotna NOT NULL` | `1` |
| `staging.rezultat_typ.ret_kod` | `rezultat_typ.ret_kod` | pre-populated from DISTINCT staging `akcja` |
| `staging.rezultat_typ.ret_nazwa` | `rezultat_typ.ret_nazwa` | pre-populated from DISTINCT staging `akcja` |
| `staging.rezultat_typ.ret_konczy` | `rezultat_typ.ret_konczy NOT NULL` | ⚠️ set manually per row in staging |
| `staging.rezultat_typ.ret_uuid` | merge key on `rezultat_typ` | — |
| `akcja.ak_id` | `akcja.ak_ext_id` | staging PK → ext_id (IDENTITY confirmed via DB) |
| `akcja.ak_sp_id` | `akcja.ak_sp_id` | resolve via prod `sp_ext_id` |
| — | `akcja.ak_akt_id NOT NULL` | from prod `akcja_typ` after MERGE (join on `akt_uuid`) |
| — | `akcja.ak_kolejnosc NOT NULL` | `0` |
| — | `akcja.ak_interwal NOT NULL` | `0` |
| `akcja.ak_data_zakonczenia` | `akcja.ak_zakonczono` | direct — also used for current etap determination (see table 10) |
| `staging.rezultat.re_ak_id` | `rezultat.re_ak_id` | prod `ak_id` after akcja insert |
| `staging.rezultat.re_ret_id` | `rezultat.re_ret_id` | from prod `rezultat_typ` after MERGE (join on `ret_uuid`) |
| `staging.rezultat.re_data_wykonania` | `rezultat.re_data_wykonania` | direct |

**Transformation logic:**
1. Populate staging `akcja_typ` manually (one row per distinct action type); `akt_uuid = NEWID()`; **manually set `akt_rodzaj` + `akt_ikona` per row**
2. Populate staging `rezultat_typ` manually (one row per distinct result type); `ret_uuid = NEWID()`; **manually set `ret_konczy` per row**
3. Populate staging `akcja` with `ak_akt_id` FK to staging `akcja_typ`
4. Populate staging `rezultat` — TBD by customer; `re_ak_id` FK to staging `akcja`
4. MERGE staging `akcja_typ` → prod `akcja_typ` ON `akt_uuid` (INSERT if not exists)
5. MERGE staging `rezultat_typ` → prod `rezultat_typ` ON `ret_uuid` (INSERT if not exists)
6. INSERT prod `akcja_typ_rezultat_typ` for each distinct `(akt_uuid, ret_uuid)` combo in staging (resolve prod IDs via UUID joins)
7. INSERT prod `akcja` — resolve `ak_akt_id` by joining staging `akcja_typ` → prod `akcja_typ` ON `akt_uuid`; `ak_kolejnosc = 0`, `ak_interwal = 0`, `ak_ext_id = staging ak_id`
8. INSERT prod `rezultat` from staging `rezultat` — resolve `re_ak_id` via `ak_ext_id`, resolve `re_ret_id` by joining staging `rezultat_typ` → prod `rezultat_typ` ON `ret_uuid`

**Notes:**
- `akt_rodzaj` + `akt_ikona`: set manually per row in staging `akcja_typ` before migration
- `rezultat`: migrate all rows from staging `rezultat` regardless of count per `akcja` (1:1 or many both handled by the join)

---

### 17. `atrybut` → `atrybut_wartosc` + entity join table ✅

Staging `at_ob_id` is an object reference — could be a dluznik, sprawa, or wierzytelnosc ID.

**Transformation logic:**
1. Insert `atrybut_wartosc` (`atw_att_id = at_att_id`, `atw_wartosc = at_wartosc`) → get `atw_id`
2. Based on object type → insert into `atrybut_dluznik`, `atrybut_sprawa`, or `atrybut_wierzytelnosc`

| Staging column | Prod table.column | Note |
|---|---|---|
| `at_id` | staging PK only | no direct prod PK — `atw_id` is new |
| `at_ob_id` | entity join table FK (`atdl_dl_id` / `atsp_sp_id` / `atwi_wi_id` / `atdo_do_id`) | domain determined by `atrybut_typ.att_atd_id` (see below) |
| `at_wartosc` | `atrybut_wartosc.atw_wartosc` | direct |
| `at_att_id` | `atrybut_wartosc.atw_att_id` | direct — also provides domain via `atrybut_typ.att_atd_id` |

**Transformation logic (per row):**
1. INSERT into `atrybut_wartosc` (`atw_att_id = at_att_id`, `atw_wartosc = at_wartosc`) → capture `atw_id`
2. Based on `atrybut_typ.att_atd_id` (derived from `at_att_id`) — `at_ob_id` is the staging entity PK; resolve to prod IDENTITY PK via `ext_id`:
   - 1 → INSERT into `atrybut_dokument` (`atdo_atw_id = atw_id`, `atdo_do_id = prod.do_id WHERE do_ext_id = at_ob_id`)
   - 2 → INSERT into `atrybut_wierzytelnosc` (`atwi_atw_id = atw_id`, `atwi_wi_id = prod.wi_id WHERE wi_ext_id = at_ob_id`)
   - 3 → INSERT into `atrybut_dluznik` (`atdl_atw_id = atw_id`, `atdl_dl_id = prod.dl_id WHERE dl_ext_id = at_ob_id`)
   - 4 → INSERT into `atrybut_sprawa` (`atsp_atw_id = atw_id`, `atsp_sp_id = prod.sp_id WHERE sp_ext_id = at_ob_id`)


---

### 18. `dokument` → `dokument` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `do_id` | `do_ext_id` | staging PK → ext_id (IDENTITY rule). **⚠️ Mixed format:** iter7 writes numeric `do_ext_id` (staging `do_id`); iter9 writes `HR_<hr_id>` prefixed strings. Idempotency checks must use `TRY_CAST` or filter `NOT LIKE '%[^0-9-]%'` when reading numeric ext_ids. (Fixed 2026-04-01 QW2) |
| `do_wi_id` | `do_wi_id` | direct |
| `do_dot_id` | `do_dot_id` | direct |
| `do_data_wystawienia` | `do_data_wystawienia` | direct |
| `do_numer_dokumentu` | `do_numer` | renamed |
| `do_tytul_dokumentu` | `do_tytul` | renamed |
| `do_data_wymagalnosci` | ❌ not on prod `dokument` | ⚠️ feeds `ksiegowanie_dekret.ksd_data_wymagalnosci` — only for rows where `ks_pierwotne = 1` (resolved at table 21). **Note:** iter9 sets `do_data_wystawienia = hr_data_raty` on its dokument rows. |
| `mod_date` | `aud_data` | trigger |
| — | `do_uko_id NOT NULL → umowa_kontrahent` | JOIN `wierzytelnosc` via `do_wi_id`: `do_uko_id = wi_uko_id WHERE wi_id = do_wi_id` |


---

### 19. `harmonogram` → `dokument` + `ksiegowanie` + `ksiegowanie_dekret` 🔴

Each staging `harmonogram` row represents one instalment. Migration creates a chain of records per row.

| Staging column | Prod target | Note |
|---|---|---|
| `hr_wi_id` | `dokument.do_wi_id` | FK to wierzytelnosc |
| `hr_data_raty` | `dokument.do_data_wystawienia` + `do_data_wymagalnosci` | both = `hr_data_raty` |
| `hr_typ` | `dokument.do_numer` / `do_tytul` | ⚠️ confirm usage — see Q3 |
| `hr_kwota_kapitalu` | `ksd_kwota_wn`, `ksd_ksk_id = 2` | WN dekret, only if > 0 |
| `hr_kwota_odsetek` | `ksd_kwota_wn`, `ksd_ksk_id = 6` | WN dekret, only if > 0 — ⚠️ confirm interest type Q4 |
| — | `ksd_kwota_ma`, `ksd_ksk_id = 1` | balancing MA dekret = SUM of non-zero WN amounts |

**Transformation logic per harmonogram row:**
1. INSERT `dokument` (`do_wi_id`, `do_data_wystawienia = hr_data_raty`, `do_data_wymagalnosci = hr_data_raty`, `do_dot_id = 20` (Kapital), `do_uko_id` via wierzytelnosc join, `do_ext_id = hr_id`) → capture `do_id`
2. INSERT `ksiegowanie` (`ks_data_ksiegowania = hr_data_raty`, `ks_data_operacji = hr_data_raty`, `ks_kst_id = 2` (wplata), `ks_pierwotne = 1`, `ks_zamkniete = 1`, `ks_na_rachunek_kontrahenta = 0`, `ks_od_komornika = 0`) → capture `ks_id`
3. If `hr_kwota_kapitalu > 0`: INSERT `ksiegowanie_dekret` (`ksd_ksk_id = 2`, `ksd_kwota_wn = hr_kwota_kapitalu`, `ksd_kwota_ma = 0`, `ksd_data_wymagalnosci = hr_data_raty`)
4. If `hr_kwota_odsetek > 0`: INSERT `ksiegowanie_dekret` (`ksd_ksk_id = 6`, `ksd_kwota_wn = hr_kwota_odsetek`, `ksd_kwota_ma = 0`, `ksd_data_wymagalnosci = hr_data_raty`)
5. Always INSERT balancing dekret: `ksd_ksk_id = 1`, `ksd_kwota_wn = 0`, `ksd_kwota_ma = SUM of non-zero WN amounts`

**Open questions:**
- [ ] Q3: Is `hr_typ` used for `do_numer`/`do_tytul`, or is a fixed string sufficient?
- [ ] Q4: Is `hr_kwota_odsetek` always umowne (ksk_id=6), or can it be ustawowe (8) or karne (5)?

---

### 20. `ksiegowanie` → `ksiegowanie`

| Staging column | Prod column | Note |
|---|---|---|
| `ks_id` | `ks_id` | PK |
| `ks_data_ksiegowania` | `ks_data_ksiegowania` | direct |
| `ks_data_operacji` | `ks_data_operacji` | direct |
| `ks_uwagi` | `ks_uwagi` | direct |
| `ks_kst_id` | `ks_kst_id` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `ks_zamkniete bit NOT NULL` | `1` default; `0` for unposted payments — ⚠️ see open question |
| — | `ks_pierwotne bit NOT NULL` | `1` for initial document values (initial import); `0` for others — ⚠️ see open question |
| — | `ks_na_rachunek_kontrahenta bit NOT NULL` | `0` always ✅ |
| — | `ks_od_komornika bit NOT NULL` | `CASE WHEN oper_typ_dekretu = 1 THEN 1 ELSE 0 END` for operacja-generated ksiegowanie; `0` for direct staging.ksiegowanie |

**Flag resolution:**
- `ks_zamkniete`: `1` when allocation to documents exists (has ksiegowanie_dekret rows linked to dokument); `0` for unallocated payments
- `ks_pierwotne`: `1` for initial document values (harmonogram + primary operacja entries); `0` for payment allocations (alokacje wpłat)
- `ks_na_rachunek_kontrahenta`: always `0` ✅
- `ks_od_komornika`: `oper_typ_dekretu = 0` → `ks_od_komornika = 0`; `oper_typ_dekretu = 1` → `ks_od_komornika = 1` (operacja path only; direct ksiegowanie defaults to `0`)


---

### 21. `ksiegowanie_dekret` → `ksiegowanie_dekret`

| Staging column | Prod column | Note |
|---|---|---|
| `ksd_id` | `ksd_ext_id` | staging PK → ext_id (`ksd_ext_id VARCHAR(255)` already in prod) |
| `ksd_ks_id` | `ksd_ks_id` | direct |
| `ksd_ksk_id` | `ksd_ksk_id` | direct |
| `ksd_do_id` | `ksd_do_id` | direct (resolve via `do_ext_id`) |
| `ksd_data_naliczania_odsetek` | `ksd_data_naliczania_odsetek` | direct |
| `ksd_kwota DECIMAL(18,2)` | `ksd_kwota_wn` / `ksd_kwota_ma` | sign: `ksd_kwota > 0` → WN, `ksd_kwota < 0` → MA (for operacja path: per `oper_rejestr_kod` — see table 23) |
| `ksd_uwagi` | ❌ not in prod | dropped |
| `ksd_sp_id` | `ksd_rb_id` | resolved via prod `sprawa.sp_rb_id` (JOIN prod `sprawa` ON `sp_ext_id = ksd_sp_id`; staging.sprawa has no `sp_rb_id`) |
| `mod_date` | `aud_data` | trigger |
| — | `ksd_data_wymagalnosci NOT NULL` | `do_data_wymagalnosci` via `ksd_do_id` JOIN `dokument`, **only for `ks_pierwotne = 1`** rows; fallback for `ks_pierwotne = 0` or `ksd_do_id IS NULL`: `2100-01-01`. **⚠️ Review finding (M4):** iter8 operacja path currently hardcodes `2100-01-01` for ALL rows, even those with a resolved `do_id` — should pull `do_data_wystawienia` from linked dokument when available. |

**Multi-currency columns (partially already in prod):**

| Prod column | Status | Source |
|---|---|---|
| `ksd_kwota_wn_bazowa DECIMAL(18,2)` | ✅ already in prod | debit amount in payment currency (bazowa) |
| `ksd_kwota_ma_bazowa DECIMAL(18,2)` | ✅ already in prod | credit amount in payment currency (bazowa) |
| `ksd_wa_id INT` | ✅ already in prod | original currency FK → `dbo.waluta` |
| `ksd_kurs_bazowy DECIMAL(18,4)` | ✅ already in prod | exchange rate |
| `ksd_kwota_wn_wyceny DECIMAL(18,2)` | ❌ needs adding to staging | debit amount in valuation currency |
| `ksd_kwota_ma_wyceny DECIMAL(18,2)` | ❌ needs adding to staging | credit amount in valuation currency |
| `ksd_wa_id_wyceny INT` | ❌ needs adding to staging | valuation currency FK → `dbo.waluta` |

**Business rule:** exactly one of ksd_kwota_wn / ksd_kwota_ma must be non-zero per row.
- ksd_kwota_wn increases debt balance; ksd_kwota_ma decreases it
- WN/MA determination: for direct staging.ksiegowanie_dekret rows — `ksd_kwota` sign; for operacja-path rows — per `oper_rejestr_kod` (see table 23)


---

### 22. `mail` → `mail` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `ma_id` | `ma_ext_id` | staging PK → ext_id (IDENTITY confirmed via DB) |
| `ma_dl_id` | `ma_dl_id` | direct (resolve via `dl_ext_id`) |
| `ma_adres_mailowy VARCHAR(50)` | `ma_nazwa VARCHAR(50)` | renamed; staging column changed to VARCHAR(50) |
| `mod_date` | `aud_data` | trigger |
| — | `ma_mat_id NOT NULL → mail_typ` | `1` |
| — | `ma_data_od NOT NULL` | staging `mod_date` |
| — | `ma_tworzacy_us_id NOT NULL` | `@system_admin_user_id` (variable) |
| — | `ma_uuid` | `NEWID()` |


---

### 23. `operacja` → `ksiegowanie_dekret` + `wplata` / `korekta`

Staging `operacja` is bank transaction / financial operation data. It maps to:
1. **Always** → `ksiegowanie_dekret` (one row per account/currency split)
2. **Depending on operation type** → `wplata` OR `korekta`

**Staging operacja columns (key ones):**

| Staging column | Note |
|---|---|
| `oper_id` | PK |
| `oper_grupa_id INT` | grouping operation in one transaction |
| `oper_waluta VARCHAR(3)` | currency code → resolve to `wa_id` via staging `waluta` |
| `oper_strona VARCHAR(10)` | determines wn vs ma, based on `oper_rejestr_kod` |
| `oper_rejestr_kod VARCHAR(20)` | register code — determines is it wpłata/korekta/koszt/alokacja/nadpłata |
| `oper_typ_dekretu VARCHAR(20)` | booking type — determines subkonto for `ksiegowanie_dekret` |
| `oper_kwota` | total amount |
| `oper_kwota_dekretu` | posting amount |
| `oper_kwota_kapitalu` | capital portion → maps to capital ksk account |
| `oper_kwota_odsetek` | interest portion → maps to interest ksk account |
| `oper_kowta_odsetek_karnych` | penalty interest → maps to penalty ksk account |
| `oper_kwota_oplaty` | fees portion → maps to fees ksk account |
| `oper_kwota_prowizji` | commissions → maps to commissions ksk account |
| `oper_kwota_*_w_pln` | PLN equivalents for each of the above → `ksd_kwota_wn_bazowa` / `ksd_kwota_ma_bazowa` |
| `oper_data_dekretu` | booking date → `ks_data_ksiegowania` |
| `oper_data_ksiegowania` | posting date → `ks_data_operacji` |
| `oper_beneficjent_nazwa` | → `wpl_nazwa_wplacajacego` |
| `oper_konto VARCHAR(50)` | account number → `wpl_rachunek_nadawcy` |
| `oper_opis` | → `wpl_tytul` |

**Transformation logic:**
1. Each `operacja` row with `oper_rejestr_kod` IN (`'wplata'`, `'korekta'`, `'umorzenie'`, `'koszt'`) creates one `ksiegowanie` header (if not already existing) and one `ksiegowanie_dekret` with amount from `oper_kwota_dekretu`
2. Per amount breakdown in scope of one `dokument` and `oper_rejestr_kod = 'alokacja'` (kapital, odsetki, odsetki_karne, oplaty, prowizje) → one `ksiegowanie_dekret` row per non-zero amount, each with the appropriate `ksk_id` and `ksksub_id` for that account type
3. If `oper_rejestr_kod = 'nadplata'` → one `ksiegowanie_dekret` with amount from `oper_kwota_dekretu`
4. Based on `oper_rejestr_kod` (or `oper_typ_dekretu`) → insert into `wplata`, `korekta`, or `koszt`

**wplata column mapping:**

| Prod column | Source |
|---|---|
| `wpl_sp_id` | via `wierzytelnosc_rola` or `sprawa` join |
| `wpl_data_operacji` | `oper_data_operacji` |
| `wpl_kwota` | `oper_kwota` |
| `wpl_tytul` | `oper_opis` |
| `wpl_nazwa_wplacajacego` | `oper_beneficjent_nazwa` |
| `wpl_rachunek_nadawcy` | `oper_konto` |
| `wpl_wa_id` | resolve from `oper_waluta` via `waluta` |
| `wpl_ext_id` | `oper_id` |
| `wpl_kwota_bazowa` | `oper_kwota_w_pln` |
| `wpl_kurs_bazowy` | derived from `kurs_walut` |
| `wpl_ks_id` | prod `ks_id` after `ksiegowanie` insert |

**ksk_id mapping per amount type (resolved):**

| Amount type | ksd_ksk_id | ksd_ksksub_id |
|---|---|---|
| Kapitał | 2 | NULL |
| Odsetki karne | 5 | NULL |
| Odsetki umowne | 6 | NULL |
| Odsetki ustawowe | 8 | NULL |
| Opłaty | 10 | NULL |
| Prowizje | 10 | 22 |

**wn/ma per oper_rejestr_kod:**

| oper_rejestr_kod | wn/ma |
|---|---|
| wplata | wn |
| umorzenie | wn |
| koszt | ma |
| korekta | ma |
| alokacja | always opposite to the technical operacja in the same `oper_grupa_id` |
| nadplata | ma |


---

### 24. `sprawa_rola` → `sprawa_rola` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `spr_id` | — | staging has IDENTITY — prod generates its own; staging `spr_id` → `spr_ext_id` |
| — | `spr_ext_id` | store staging `spr_id` |
| `spr_sp_id` | `spr_sp_id` | direct |
| `spr_dl_id` | `spr_dl_id` | direct |
| `spr_sprt_id` | `spr_sprt_id` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `spr_kwota_poreczenia_do money NOT NULL` | `0` |
| — | `spr_data_od datetime NOT NULL` | staging `mod_date` |
| — | `spr_data_do datetime NOT NULL` | `9999-12-31` |


---

### 25. `telefon` → `telefon` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `tn_id` | `tn_ext_id` | staging PK → ext_id (prod generates IDENTITY) |
| `tn_dl_id` | `tn_dl_id` | direct |
| `tn_numer` | `tn_numer` | direct |
| `tn_tt_id` | `tn_tnt_id` | FK column renamed (consistent with telefon_typ PK rename) |
| `mod_date` | `aud_data` | trigger |
| — | `tn_data_od NOT NULL` | staging `mod_date` |
| — | `tn_zpi_id NOT NULL → zrodlo_pochodzenia_informacji` | `2` (external system) |
| — | `tn_tworzacy_us_id NOT NULL` | `@system_admin_user_id` (variable) |


---

### 26. `wierzytelnosc_rola` → `wierzytelnosc_rola` ✅

| Staging column | Prod column | Note |
|---|---|---|
| `wir_id` | — | staging has IDENTITY — prod generates its own; staging `wir_id` → `wir_ext_id` |
| — | `wir_ext_id` | store staging `wir_id` |
| `wir_sp_id` | `wir_sp_id` | direct |
| `wir_wi_id` | `wir_wi_id` | direct |
| `wir_rl_id` | `wir_wirt_id` | `NULL` |
| `mod_date` | `aud_data` | trigger |
| — | `wir_kwota_poreczenia_do money NOT NULL` | `0` |
| — | `wir_data_od datetime NOT NULL` | staging `mod_date` |
| — | `wir_data_do datetime NOT NULL` | `9999-12-31` |

**Note:** This table will also receive auto-generated records from migrating `wierzytelnosc.wi_sp_id` (see table 14).


---

### 27. `zabezpieczenie` → ❓ NO PROD TABLE 🔵

Staging `zabezpieczenie` stores collateral/security data (type, value, dates, KW entries, etc.) linked to `wierzytelnosc` and `dluznik`.
No matching table found in production DB. Deferred to Stage 2+.

**Open questions:**
- [ ] Q1: Where does collateral/security data live in production? Is there a prod table under a different name, or is this data not migrated?

---

### 28. Multi-currency infrastructure ✅

New task: extend `ksiegowanie_dekret` with full multi-currency support and add `waluta` / `kurs_walut` to staging.

**A. Columns to ADD to staging `dbo.ksiegowanie_dekret`** (already in prod):

| Column | Type | Note |
|---|---|---|
| `ksd_kwota_wn_wyceny` | `DECIMAL(18,2) NULL` | debit amount in valuation currency |
| `ksd_kwota_ma_wyceny` | `DECIMAL(18,2) NULL` | credit amount in valuation currency |
| `ksd_wa_id_wyceny` | `INT NULL` | valuation currency FK → `dbo.waluta` |

**Already present in prod** (no action needed): `ksd_kwota_wn_bazowa`, `ksd_kwota_ma_bazowa`, `ksd_wa_id`, `ksd_kurs_bazowy`
**Not adding** `ksd_kurs` — same as existing `ksd_kurs_bazowy`

**B. Add `dbo.waluta` to staging** (copy structure + data from prod):

Prod `waluta` columns: `wa_id INT NOT NULL` (PK), `wa_nazwa VARCHAR(100)`, `wa_nazwa_skrocona VARCHAR(50)`, `wa_uuid VARCHAR(50)`, `aud_data` (trigger), `aud_login` (trigger)

**C. Add `dbo.kurs_walut` to staging** (copy structure + data from prod):

Prod `kurs_walut` columns: `kw_id INT NOT NULL` (PK), `kw_tabela VARCHAR(5)`, `kw_waluta VARCHAR(MAX) NOT NULL`, `kw_kod VARCHAR(5) NOT NULL`, `kw_numer VARCHAR(MAX) NOT NULL`, `kw_data DATETIME NOT NULL`, `kw_wartosc DECIMAL(18,4) NOT NULL`, `kw_typ VARCHAR(1)`, `kw_wa_id INT` (FK → waluta)

**Currency resolution for operacja migration:**
`oper_waluta VARCHAR(3)` (ISO code) → look up `waluta.wa_id` WHERE `wa_nazwa_skrocona = oper_waluta`

**Resolved:** `waluta` / `kurs_walut` in staging are read-only reference copies — populated directly from prod before migration run, no UUID MERGE needed.

---

### 29. `ksiegowanie_konto_subkonto` → `ksiegowanie_konto_subkonto` ✅

Reference copy table — staging populated from prod before migration run. No IDENTITY on PK.

| Staging column | Prod column | Note |
|---|---|---|
| `ksksub_id` | `ksksub_id` | PK |
| `ksksub_ksk_id` | `ksksub_ksk_id` | direct → FK to `ksiegowanie_konto` |
| `ksksub_nazwa` | `ksksub_nazwa` | direct |
| `ksksub_etap` | `ksksub_etap` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `ksksub_uuid` | `ksksub_uuid` | MERGE key for stages 2-5 |


---

### 30. `dokument_odsetki_przerwy` → `dokument_odsetki_przerwy` ✅

Entity table. `dop_id` is IDENTITY in prod. Requires `dokument_odsetki_przerwy_typ` as reference copy in staging (populated from prod before migration run).

| Staging column | Prod column | Note |
|---|---|---|
| `dop_id` | `dop_id` | PK (IDENTITY in prod) |
| `dop_do_id` | `dop_do_id` | direct — resolve via `do_ext_id` |
| `dop_data_od` | `dop_data_od` | direct |
| `dop_data_do` | `dop_data_do` | direct |
| `dop_dopt_id` | `dop_dopt_id` | direct → FK to `dokument_odsetki_przerwy_typ` |
| `dop_licz_od_niewymagalnych` | `dop_licz_od_niewymagalnych bit NOT NULL` | direct; staging default `0` |
| `dop_ak_id` | `dop_ak_id` | direct (nullable) |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |

---

## Wlasciwosc Feature Tables (Sections 31-41)

Per [project_wlasciwosc_feature.md](project_wlasciwosc_feature.md) — adding 11 property/attribute tables to migration pipeline.
- **Sections 31-36:** Lookup/reference tables (INT PK, not IDENTITY). MERGE keyed on `*_uuid` (CAST to VARCHAR(50) in MERGE ON). Require cross-DB backfill of `*_ext_id` after MERGE for all rows.
- **Sections 37-41:** Entity tables (IDENTITY PKs or FK-resolved IDs). Idempotency via parent ext_ids or composite keys.

---

### 31. `zrodlo_pochodzenia_informacji` → `zrodlo_pochodzenia_informacji` ✅

Lookup table. No IDENTITY on PK.

| Staging column | Prod column | Note |
|---|---|---|
| `zpi_id` | `zpi_id` | PK |
| `zpi_nazwa` | `zpi_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `zpi_uuid` | `zpi_uuid` | MERGE key for stages 2-5; `CAST(zpi_uuid AS VARCHAR(50))` |

**ext_id mapping:** `zpi_ext_id` — backfill after MERGE (UUID-keyed cross-DB update)

---

### 32. `wlasciwosc_typ_walidacji` → `wlasciwosc_typ_walidacji` ✅

Lookup table. No IDENTITY on PK.

| Staging column | Prod column | Note |
|---|---|---|
| `wtw_id` | `wtw_id` | PK |
| `wtw_nazwa` | `wtw_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `wtw_uuid` | `wtw_uuid` | MERGE key for stages 2-5; `CAST(wtw_uuid AS VARCHAR(50))` |

**ext_id mapping:** `wtw_ext_id` — backfill after MERGE (UUID-keyed cross-DB update)

---

### 33. `wlasciwosc_dziedzina` → `wlasciwosc_dziedzina` ✅

Lookup table. No IDENTITY on PK.

| Staging column | Prod column | Note |
|---|---|---|
| `wdzi_id` | `wdzi_id` | PK |
| `wdzi_nazwa` | `wdzi_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `wdzi_uuid` | `wdzi_uuid` | MERGE key for stages 2-5; `CAST(wdzi_uuid AS VARCHAR(50))` |

**ext_id mapping:** `wdzi_ext_id` — backfill after MERGE (UUID-keyed cross-DB update)

---

### 34. `wlasciwosc_podtyp` → `wlasciwosc_podtyp` ✅

Lookup table. No IDENTITY on PK.

| Staging column | Prod column | Note |
|---|---|---|
| `wpt_id` | `wpt_id` | PK |
| `wpt_nazwa` | `wpt_nazwa` | direct |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `wpt_uuid` | `wpt_uuid` | MERGE key for stages 2-5; `CAST(wpt_uuid AS VARCHAR(50))` |

**ext_id mapping:** `wpt_ext_id` — backfill after MERGE (UUID-keyed cross-DB update)

---

### 35. `wlasciwosc_typ` → `wlasciwosc_typ` ✅

Lookup table. No IDENTITY on PK. Has FK: `wt_wtw_id → wlasciwosc_typ_walidacji`.

| Staging column | Prod column | Note |
|---|---|---|
| `wt_id` | `wt_id` | PK |
| `wt_nazwa` | `wt_nazwa` | direct |
| `wt_wtw_id` | `wt_wtw_id` | FK → `wlasciwosc_typ_walidacji` |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `wt_uuid` | `wt_uuid` | MERGE key for stages 2-5; `CAST(wt_uuid AS VARCHAR(50))` |

**ext_id mapping:** `wt_ext_id` — backfill after MERGE (UUID-keyed cross-DB update)

---

### 36. `wlasciwosc_typ_podtyp_dziedzina` → `wlasciwosc_typ_podtyp_dziedzina` ✅

Lookup table junction. No IDENTITY on PK. Has 3 FKs:
- `wtpd_wt_id → wlasciwosc_typ`
- `wtpd_dzi_id → wlasciwosc_dziedzina`
- `wtpd_wpt_id → wlasciwosc_podtyp`

| Staging column | Prod column | Note |
|---|---|---|
| `wtpd_id` | `wtpd_id` | PK |
| `wtpd_wt_id` | `wtpd_wt_id` | FK → `wlasciwosc_typ` |
| `wtpd_dzi_id` | `wtpd_dzi_id` | FK → `wlasciwosc_dziedzina` |
| `wtpd_wpt_id` | `wtpd_wpt_id` | FK → `wlasciwosc_podtyp` |
| `mod_date` | `aud_data` | trigger |
| — | `aud_login` | trigger |
| `wtpd_uuid` | `wtpd_uuid` | MERGE key for stages 2-5 |
| — | `wtpd_ext_id` | set after MERGE for stages 2-5 idempotency |

**ext_id mapping:** For stages 2-5, populate `wtpd_ext_id` = `wtpd_id` after MERGE to enable foreign key resolution in child tables.

---

### 37. `wlasciwosc` → `wlasciwosc` ✅

Entity table. `wl_id` is IDENTITY in prod. Idempotency via parent ext_ids (stage 1 only, no UUID MERGE).

**Key FK:** `wl_wtpd_id` → resolve via `wlasciwosc_typ_podtyp_dziedzina.wtpd_ext_id`

| Staging column | Prod column | Note |
|---|---|---|
| `wl_id` | — | staging PK (IDENTITY) — dropped in stage 2+ |
| — | `wl_id` | prod IDENTITY (generated) |
| `wl_wtpd_id` | `wl_wtpd_id` | resolve from staging `wl_wtpd_id` via `wtpd_ext_id` JOIN |
| `wl_aktywny_od` | `wl_aktywny_od` | direct |
| `wl_aktywny_do` | `wl_aktywny_do` | direct |
| — | `wl_tworzacy_us_id NOT NULL` | `@system_admin_user_id` |
| — | `wl_dezaktywujacy_us_id` | `NULL` |
| — | `wl_zpi_id NOT NULL` | `2` (always) |
| — | `wl_uuid` | `NEWID()` (prod generates) |
| — | `aud_data` | `GETUTCDATE()` (explicit, not trigger) |
| — | `aud_login` | `'admin'` (explicit, not trigger) |

**Idempotency:** Stage 1 only (no ext_id backfill). Stages 2+ use parent (`dluznik`, `adres`, `mail`, `telefon`) ext_ids to determine if row already linked.

---

### 38. `wlasciwosc_dluznik` → `wlasciwosc_dluznik` ✅

Entity bridge table. `wd_id` is IDENTITY in prod. Idempotency via composite key `(wd_dl_id, wd_wl_id)`.

**FKs:**
- `wd_wl_id → wlasciwosc` (resolve via staging `wl_id` → prod `wl_id` after wlasciwosc insert)
- `wd_dl_id → dluznik` (resolve via `dl_ext_id`)

| Staging column | Prod column | Note |
|---|---|---|
| `wd_id` | — | staging PK (IDENTITY) — dropped in stage 2+ |
| — | `wd_id` | prod IDENTITY (generated) |
| `wd_wl_id` | `wd_wl_id` | resolve to prod `wl_id` after wlasciwosc insert |
| `wd_dl_id` | `wd_dl_id` | resolve from staging `wd_dl_id` via `dl_ext_id` JOIN |
| — | `aud_data` | `GETUTCDATE()` (explicit) |
| — | `aud_login` | `'admin'` (explicit) |

**Idempotency:** Composite key `(wd_dl_id, wd_wl_id)`. Check-before-insert or MERGE with ON clause: `ON (prod.wd_dl_id = src.wd_dl_id AND prod.wd_wl_id = src.wd_wl_id)`.

---

### 39. `wlasciwosc_adres` → `wlasciwosc_adres` ✅

Entity bridge table. `wa_id` is IDENTITY in prod. Idempotency via composite key `(wa_ad_id, wa_wl_id)`.

**FKs:**
- `wa_wl_id → wlasciwosc` (resolve via staging `wl_id` → prod `wl_id` after wlasciwosc insert)
- `wa_ad_id → adres` (resolve via `ad_ext_id`)

| Staging column | Prod column | Note |
|---|---|---|
| `wa_id` | — | staging PK (IDENTITY) — dropped in stage 2+ |
| — | `wa_id` | prod IDENTITY (generated) |
| `wa_wl_id` | `wa_wl_id` | resolve to prod `wl_id` after wlasciwosc insert |
| `wa_ad_id` | `wa_ad_id` | resolve from staging `wa_ad_id` via `ad_ext_id` JOIN |
| — | `aud_data` | `GETUTCDATE()` (explicit) |
| — | `aud_login` | `'admin'` (explicit) |

**Idempotency:** Composite key `(wa_ad_id, wa_wl_id)`. Check-before-insert or MERGE with ON clause: `ON (prod.wa_ad_id = src.wa_ad_id AND prod.wa_wl_id = src.wa_wl_id)`.

---

### 40. `wlasciwosc_email` → `wlasciwosc_email` ✅

Entity bridge table. `we_id` is IDENTITY in prod. Idempotency via composite key `(we_ma_id, we_wl_id)`.

**FKs:**
- `we_wl_id → wlasciwosc` (resolve via staging `wl_id` → prod `wl_id` after wlasciwosc insert)
- `we_ma_id → mail` (resolve via `ma_ext_id`)

| Staging column | Prod column | Note |
|---|---|---|
| `we_id` | — | staging PK (IDENTITY) — dropped in stage 2+ |
| — | `we_id` | prod IDENTITY (generated) |
| `we_wl_id` | `we_wl_id` | resolve to prod `wl_id` after wlasciwosc insert |
| `we_ma_id` | `we_ma_id` | resolve from staging `we_ma_id` via `ma_ext_id` JOIN |
| — | `aud_data` | `GETUTCDATE()` (explicit) |
| — | `aud_login` | `'admin'` (explicit) |

**Idempotency:** Composite key `(we_ma_id, we_wl_id)`. Check-before-insert or MERGE with ON clause: `ON (prod.we_ma_id = src.we_ma_id AND prod.we_wl_id = src.we_wl_id)`.

---

### 41. `wlasciwosc_telefon` → `wlasciwosc_telefon` ✅

Entity bridge table. `wt_id` is IDENTITY in prod. Idempotency via composite key `(wt_tn_id, wt_wl_id)`.

**Note:** Prod table prefix is `wt_*` (naming collision with `wlasciwosc_typ`, but prod table structure is preserved).

**FKs:**
- `wt_wl_id → wlasciwosc` (resolve via staging `wl_id` → prod `wl_id` after wlasciwosc insert)
- `wt_tn_id → telefon` (resolve via `tn_ext_id`)

| Staging column | Prod column | Note |
|---|---|---|
| `wt_id` | — | staging PK (IDENTITY) — dropped in stage 2+ |
| — | `wt_id` | prod IDENTITY (generated) |
| `wt_wl_id` | `wt_wl_id` | resolve to prod `wl_id` after wlasciwosc insert |
| `wt_tn_id` | `wt_tn_id` | resolve from staging `wt_tn_id` via `tn_ext_id` JOIN |
| — | `aud_data` | `GETUTCDATE()` (explicit) |
| — | `aud_login` | `'admin'` (explicit) |

**Idempotency:** Composite key `(wt_tn_id, wt_wl_id)`. Check-before-insert or MERGE with ON clause: `ON (prod.wt_tn_id = src.wt_tn_id AND prod.wt_wl_id = src.wt_wl_id)`.
