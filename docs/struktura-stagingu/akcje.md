---
title: "Migracja ⬝ Akcje i rezultaty"
tags:
  - brq211
---

# Akcje i rezultaty

Iteracja 5 ładuje akcje windykacyjne wraz z ich rezultatami — dwie tabele stagingowe (`dbo.akcja`, `dbo.rezultat`) zasilają trzy tabele produkcyjne: `akcja`, `rezultat` oraz link table `akcja_typ_rezultat_typ` (derywowana z par stagingowych). Wszystkie przejścia są klasy **C**, zależne od słowników z iteracji 1 (`akcja_typ`, `rezultat_typ`) oraz od `mapowanie.dodane_sprawy` zbudowanego w iteracji 4. Iteracja 5 stanowi niezależną gałąź modelu danych — nie jest warunkiem koniecznym dla iteracji 6-9 (wierzytelności, dokumenty, finanse, harmonogram).

Iteracja 5 wprowadza nowy paradygmat rozwiązywania FK — zamiast VARCHAR `ext_id` kolumnowego mostu staging→prod, prod `akcja` przechowuje staging PK bezpośrednio w kolumnie `ak_migracja_id` (INT, indeksowana). Dzięki temu sekcja `rezultat` rozwiązuje FK przez JOIN `prod.akcja.ak_migracja_id = staging.re_ak_id` (INT=INT, bez CAST) — indeks `IX_akcja_ak_migracja_id` rebuildowany jest tuż przed INSERT-em do rezultat. Pozostałe FK do słowników iteracji 1 rozwiązywane są przez pre-zbudowane tabele tymczasowe (`#akt_map`, `#ret_map`) z `CAST(akt_uuid AS VARCHAR(50))` wykonanym raz, a nie per-wiersz. Idempotencja: `akcja` range-based (`WHERE stg.ak_id > @max_mig_id`), `rezultat` NOT EXISTS na composite (`re_ak_id`, `re_ret_id`) — scoping przez JOIN do staging `rezultat` zamiast `@max_mig_id` (po retry akcja high-water mark byłby już na max, co permanentnie pomijałoby rezultat). `akcja_typ_rezultat_typ` — DISTINCT pary wydobyte ze stagingu z WHERE NOT EXISTS po snapshot composite. Ze względu na wydajność, NCI na prod `akcja`+`rezultat` są disablowane przed sekcjami 4-5 i rebuildowane globalnie po zakończeniu pipeline; sekcje 1-2 dodatkowo re-MERGE słowniki `akcja_typ`/`rezultat_typ` (safety przebieg — wyniki iteracji 1 są idempotentne). Szczegóły per prod-tabela w sekcjach `### dbo.<tabela>`; walidacje referencyjne i biznesowe w sekcji [Powiązania](#powiazania) poniżej.

<div class="iter-meta">
  <span>Iteracja: 5</span>
  <span>Zależności: Iteracja 1 (akcja_typ, rezultat_typ) + Iteracja 4 (mapowanie.dodane_sprawy)</span>
</div>

## Diagram ER

Diagram pokazuje tabele iteracji 5 (`akcja`, `rezultat`) wraz z ich słownikami z iteracji 1 oraz minimalnym stubem `sprawa` z iteracji 4 jako punktem zaczepienia FK `ak_sp_id`. Pełna struktura sprawy (`sprawa_typ`, `sprawa_etap`, `sprawa_rola`) — [Sprawy § Diagram ER](sprawy.md#diagram-er). Słowniki `akcja_typ`/`rezultat_typ` — [Tabele słownikowe](slowniki.md). Prod-only link table `akcja_typ_rezultat_typ` opisana w sekcji `<code>dbo.akcja_typ_rezultat_typ</code>` poniżej — derywowana z JOIN staging `rezultat` × `akcja` × `akcja_typ` × `rezultat_typ`.

```mermaid
erDiagram
    sprawa {
        int     sp_id    PK
    }

    akcja_typ {
        int     akt_id    PK
        varchar akt_kod_akcji
        varchar akt_nazwa
        varchar akt_uuid
    }

    rezultat_typ {
        int     ret_id    PK
        varchar ret_kod
        varchar ret_nazwa
        varchar ret_uuid
    }

    akcja {
        int     ak_id                  PK
        int     ak_sp_id               FK
        int     ak_akt_id              FK
        date    ak_data_zakonczenia        "→ ak_zakonczono w prod"
    }

    rezultat {
        int     re_id              PK
        int     re_ak_id           FK
        int     re_ret_id          FK
        date    re_data_wykonania
    }

    akcja    }o--||  sprawa       : "ak_sp_id"
    akcja    }o--o|  akcja_typ    : "ak_akt_id"
    rezultat }o--||  akcja        : "re_ak_id"
    rezultat }o--||  rezultat_typ : "re_ret_id"
```

## Tabele

<details markdown="1">
<summary><code>dbo.akcja</code> — <span class="klasa-badge klasa-c">C</span> akcje windykacyjne wykonane w ramach spraw</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.akcja</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — pełna transformacja (paradygmat `ak_migracja_id`)</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 sprawa → N akcji)</span>
</div>

Akcje windykacyjne wykonane w ramach spraw — operacyjna jednostka pracy na sprawie (telefon, wizyta, list, monit). Staging PK `ak_id` jest typu INT; prod używa IDENTITY i przechowuje pochodzenie staging PK w kolumnie `ak_migracja_id` (INT, nie VARCHAR `ext_id`). Ten paradygmat pozwala sekcji `rezultat` rozwiązać FK `re_ak_id → ak_id` bez CAST — prod `ak_migracja_id` jest indeksowany (`IX_akcja_ak_migracja_id`) i zapewnia szybki INT=INT JOIN. Kolumna `ak_data_zakonczenia` (NULL = akcja niezakończona) mapowana jest na prod `ak_zakonczono`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ak_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny akcji w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">ak_sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do sprawy - rozwiązywany przez mapowanie.dodane_sprawy</span>
  </li>
  <li>
    <span class="param-name fk">ak_akt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów akcji - opcjonalny</span>
  </li>
  <li>
    <span class="param-name">ak_data_zakonczenia</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zakończenia akcji - mapowana na ak_zakonczono w prod</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.akcja
Prod `akcja` generuje własny IDENTITY `ak_id` — staging PK trafia do kolumny `ak_migracja_id` (INT). Idempotencja realizowana jest range-based: `WHERE stg.ak_id > @max_mig_id` (gdzie `@max_mig_id = MAX(ak_migracja_id)` w prod, domyślnie `-2147483648` dla stagingu pustego). FK `ak_sp_id` rozwiązywany przez INNER JOIN na `mapowanie.dodane_sprawy` (staging `sp_id` → prod `sp_id`; tabela budowana przez iteracja 4). FK `ak_akt_id` rozwiązywany przez pre-zbudowaną tabelę tymczasową `#akt_map` (staging `akt_id` → prod `akt_id` przez `akt_uuid`, `CAST(akt_uuid AS VARCHAR(50))` wykonany raz podczas budowy mapy). Przy INSERT stosowana jest jedna przemianowana kolumna: staging `ak_data_zakonczenia` trafia do prod `ak_zakonczono` (NULL = akcja niezakończona). Kolumny hardkodowane: `ak_kolejnosc = 0` i `ak_interwal = 0` (brak odpowiedników w stagingu — prod wymaga wartości domyślnych). Performance: przed INSERT-em NCIs na prod `akcja` + `rezultat` są DISABLE (proc `usp_manage_prod_ncis 'akcja,rezultat', 'DISABLE'`), a sam INSERT wykorzystuje hint `WITH (TABLOCK)` — w połączeniu z disabled NCIs daje minimalnie-logowany bulk insert. Indeks `IX_akcja_ak_migracja_id` rebuildowany jest natychmiast po INSERT do `akcja` (przed sekcją `rezultat`), pozostałe NCIs rebuildowane globalnie po zakończeniu pipeline. Pominięte przy INSERT: IDENTITY `ak_id`. Kolumny `aud_data`/`aud_login` wypełniane są explicite (odpowiednio `COALESCE(stg.mod_date, @aud_now)` i `@aud_login`), z pominięciem UDF-a obliczającego defaulty.

</details>

<details markdown="1">
<summary><code>dbo.rezultat</code> — <span class="klasa-badge klasa-c">C</span> rezultaty akcji windykacyjnych (rozszerza prod: `rezultat` + `akcja_typ_rezultat_typ`)</summary>

<div class="dict-meta">
  <span>Tabele prod: <code>dm_data_web.rezultat</code>, <code>dm_data_web.akcja_typ_rezultat_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — pełna transformacja (link table derywowany)</span>
  <span>Obowiązkowa: tak (BIZ_08: każda akcja musi mieć ≥1 rezultat)</span>
  <span>Multi-row: tak (1 akcja → N rezultatów, ale typowo 1:1)</span>
</div>

Rezultaty akcji windykacyjnych — wynik wykonania akcji (kontakt osiągnięty, brak odbioru, odmowa płatności, zobowiązanie do zapłaty itp.). Staging PK `re_id` istnieje, ale nie trafia do prod — prod używa IDENTITY `re_id`, a **nie posiada** kolumny `re_ext_id` (w przeciwieństwie do tabel iteracja 3, gdzie ext_id jest kotwicą idempotencji). Tabela jest materializacją wymogu BIZ_08 (akcja bez rezultatu jest nieprawidłowa) i walidowana jest przez REF_33 (FK do akcji) i REF_34 (FK do typu rezultatu). Dodatkowo iteracja 5 wykorzystuje staging `rezultat` × `akcja` jako źródło derywacji link-table `akcja_typ_rezultat_typ` (distinct pary `akt_id` × `ret_id`).

<ul class="param-list">
  <li>
    <span class="param-name pk required">re_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny rezultatu akcji w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">re_ak_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do akcji - rozwiązywany przez prod.akcja.ak_migracja_id</span>
  </li>
  <li>
    <span class="param-name fk required">re_ret_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów rezultatów</span>
  </li>
  <li>
    <span class="param-name">re_data_wykonania</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data wykonania rezultatu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.rezultat
Prod `rezultat` generuje własny IDENTITY `re_id` — staging PK nie trafia do prod (brak kolumny `re_ext_id` w prod `rezultat`). FK `re_ak_id` rozwiązywany przez INNER JOIN na `prod.akcja.ak_migracja_id = stg.re_ak_id` (INT=INT, bez CAST — wykorzystuje indeks `IX_akcja_ak_migracja_id` rebuildowany w poprzednim kroku). FK `re_ret_id` rozwiązywany przez pre-zbudowaną tabelę tymczasową `#ret_map` (staging `ret_id` → prod `ret_id` przez `ret_uuid`, `CAST(ret_uuid AS VARCHAR(50))` wykonany raz). Idempotencja nie może być range-based — na retry po udanym INSERT do `akcja` wartość `@max_mig_id` byłaby już na maksimum, co permanentnie pomijałoby wiersze rezultat — dlatego scoping realizowany jest przez JOIN do staging `dbo.rezultat` (naturalny zakres bieżących danych stagingu) plus `NOT EXISTS` na composite key (`re_ak_id`, `re_ret_id`) w prod. Kolumna `re_data_wykonania` kopiowana jest 1:1. Brak kolumn hardkodowanych. INSERT korzysta z hint `WITH (TABLOCK)` i disabled NCIs (patrz sekcja `### dbo.akcja` powyżej) — minimalnie-logowany bulk insert. Pominięte przy INSERT: IDENTITY `re_id` w prod, staging `re_id` (nie używany — prod nie ma odpowiednika ext_id). Kolumny `aud_data`/`aud_login` wypełniane są explicite (odpowiednio `COALESCE(stg.mod_date, @aud_now)` i `@aud_login`), z pominięciem UDF-a.

### dbo.akcja_typ_rezultat_typ
Link table typu N:M — pary `(akt_id, ret_id)` dopuszczalne w modelu produkcyjnym. W iteracji 5 derywowana ze stagingu: `FROM dbo.rezultat JOIN dbo.akcja ON ak_id = re_ak_id JOIN dbo.akcja_typ ON akt_id = ak_akt_id JOIN dbo.rezultat_typ ON ret_id = re_ret_id` — następnie JOIN-y do prod `akcja_typ`/`rezultat_typ` po `akt_uuid`/`ret_uuid` rozwiązują prod IDs. `SELECT DISTINCT` deduplikuje (ta sama para `akt_id` × `ret_id` może wystąpić wielokrotnie w stagingu przy różnych sprawach). Idempotencja: snapshot istniejących par prod trafia do indeksowanej `#existing_akrt` (UNIQUE INDEX na composite), a `LEFT JOIN ... WHERE ex.aktret_akt_id IS NULL` pomija pary już obecne. Brak kolumn hardkodowanych. Tabela ładowana jest **przed** sekcjami `### dbo.akcja` i `### dbo.rezultat` (SECTION 3 w SQL), ponieważ jej zawartość zależy wyłącznie od stagingu — nie od prod-owych FK rozwiązywanych w sekcjach 4-5.

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Sprawy i role](sprawy.md)
- Następna iteracja: [Wierzytelności](wierzytelnosci.md)
- Klasyfikacja mapowania: [Mapowanie staging → prod](mapowanie-tabel.md)
- Słowniki bazowe iteracja 1: [akcja_typ](slowniki.md#dboakcja_typ), [rezultat_typ](slowniki.md#dborezultat_typ)
- Walidacje referencyjne (akcja): [REF_14 (sprawa), REF_32 (typ akcji)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (rezultat): [REF_33 (akcja), REF_34 (typ rezultatu)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe: [BIZ_08 (akcja musi mieć ≥1 rezultat, BLOKUJĄCE)](../przygotowanie-danych/walidacje.md)
