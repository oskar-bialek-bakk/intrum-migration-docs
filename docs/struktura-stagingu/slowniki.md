---
title: "Migracja ⬝ Tabele słownikowe"
tags:
  - brq211
---

# Tabele słownikowe

Iteracja 1 ładuje 24 tabele słownikowe i referencyjne — typy, statusy, katalogi i tabele konfiguracyjne — które stanowią fundament całego procesu migracji. Każda kolejna iteracja (2–9) zakłada ich obecność w produkcji: klucze obce ze sprawy, dłużnika, wierzytelności, akcji i właściwości wskazują bezpośrednio na rekordy załadowane w tej iteracji. Brak kompletności tabel słownikowych blokuje uruchomienie wszystkich dalszych kroków.

Tabele dzielą się na trzy klasy mapowania. Klasa A to czyste kopie referencyjne — identyfikatory stagingowe są tożsame z produkcyjnymi, MERGE odbywa się po UUID lub kluczu naturalnym, a kolumny biznesowe kopiowane są bez transformacji. Klasa B obejmuje słowniki, w których produkcja generuje własny klucz główny (IDENTITY lub z backfillem) albo nadaje UUID przez trigger — wartości `_id` ze stagingu trafiają do kolumny `*_ext_id` w tabeli prod dla późniejszego rozwiązania FK; jedyne pominięte kolumny to audyt (`aud_data`, `aud_login`) i klucz IDENTITY, bo są wypełniane automatycznie. Klasa C zawiera tabele z pełnymi transformacjami: zmiany nazw kolumn lub tabel, rozwiązywanie kluczy obcych przez JOIN na `ext_id`, a także wartości domyślne hardkodowane dla kolumn nieistniejących w stagingu. Szczegóły klasyfikacji każdej tabeli widoczne są w sekcji `### dbo.<tabela>` (klasa B i C) lub w nagłówku bloku (klasa A); tabele klasy A są w pełni 1:1 i nie wymagają dodatkowego opisu mapowania. Walidacje referencyjne dotyczące wszystkich tabel słownikowych opisane są w sekcji [Powiązania](#powiazania) poniżej.

<div class="iter-meta">
  <span>Iteracja: 1</span>
  <span>Zależności: brak (fundament)</span>
</div>

## Tabele

<details markdown="1">
<summary><code>dbo.waluta</code> — <span class="klasa-badge klasa-a">A</span> kopia referencyjna walut</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.waluta</code></span>
  <span>Klasa: <span class="klasa-badge klasa-a">A</span> — kopia referencyjna</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Kopia referencyjna tabeli walut z produkcji, wypełniana przed uruchomieniem migracji. Identyfikatory stagingowe (`wa_id`) są tożsame z produkcyjnymi; MERGE odbywa się po `wa_uuid` (z fallbackiem po `wa_id` dla wierszy bez UUID). Na tej tabeli opierają się FK z tabel księgowań.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wa_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator waluty (PK, zgodny z produkcją)</span>
  </li>
  <li>
    <span class="param-name required">wa_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Pełna nazwa waluty (np. Polski Złoty, Euro)</span>
  </li>
  <li>
    <span class="param-name required">wa_nazwa_skrocona</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Skrócona nazwa waluty (kod ISO, np. PLN, EUR)</span>
  </li>
  <li>
    <span class="param-name deprecated">wa_uuid</span>
    <span class="param-type">VARCHAR(50)</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.waluta
Kopiowana bez zmian do `dm_data_web.waluta` — klasa A, tożsamość `wa_id` zachowana. MERGE po `wa_uuid` (z fallbackiem po `wa_id` dla wierszy bez UUID). Pominięte przy INSERT: `aud_data`, `aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.kurs_walut</code> — <span class="klasa-badge klasa-a">A</span> kursy walut referencyjne</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.kurs_walut</code></span>
  <span>Klasa: <span class="klasa-badge klasa-a">A</span> — kopia referencyjna</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Kopia referencyjna kursów walut z produkcji, wypełniana przed uruchomieniem migracji. MERGE odbywa się po kluczu naturalnym `(kw_kod, kw_data)` — para kod ISO waluty i data jest unikalna. Brak kolumny UUID i ext_id; klucze stagingowe są równe produkcyjnym.

<ul class="param-list">
  <li>
    <span class="param-name pk required">kw_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator kursu walutowego (PK)</span>
  </li>
  <li>
    <span class="param-name required">kw_tabela</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Oznaczenie tabeli kursów NBP</span>
  </li>
  <li>
    <span class="param-name required">kw_waluta</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Pełna nazwa waluty</span>
  </li>
  <li>
    <span class="param-name required">kw_kod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kod ISO waluty</span>
  </li>
  <li>
    <span class="param-name required">kw_numer</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer tabeli kursów NBP</span>
  </li>
  <li>
    <span class="param-name required">kw_data</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data obowiązywania kursu</span>
  </li>
  <li>
    <span class="param-name required">kw_wartosc</span>
    <span class="param-type">DECIMAL</span>
    <span class="param-desc">Wartość kursu waluty względem PLN</span>
  </li>
  <li>
    <span class="param-name required">kw_typ</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Typ kursu</span>
  </li>
  <li>
    <span class="param-name fk required">kw_wa_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do tabeli waluta</span>
  </li>
</ul>

### dbo.kurs_walut
Kopiowana bez zmian do `dm_data_web.kurs_walut` — klasa A, klucze stagingowe równe produkcyjnym. MERGE po kluczu naturalnym `(kw_kod, kw_data)`. Pominięte przy INSERT: `aud_data`, `aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.kontrahent</code> — <span class="klasa-badge klasa-b">B</span> kontrahenci i wierzyciele</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.kontrahent</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — kopia referencyjna z pominięciem kolumn</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Kontrahenci — wierzyciele pierwotni i pośrednicy — powiązani z umowami. Tabela jest kopią referencyjną: `ko_id` ze stagingu trafia bezpośrednio jako `ko_id` w produkcji (INSERT explicit, nie IDENTITY w tym kontekście). Po MERGE staging `ko_id` zapisywany jest do `ko_id_migracja` dla celów śledzenia migracji i rozwiązywania FK w downstream.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ko_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator kontrahenta (PK)</span>
  </li>
  <li>
    <span class="param-name required">ko_firma</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa firmy kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_nip</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer NIP kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_regon</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer REGON kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_krs</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer KRS kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_nr_rachunku</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer rachunku bankowego kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_numer</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Wewnętrzny numer ewidencyjny kontrahenta</span>
  </li>
  <li>
    <span class="param-name">ko_id_migracja</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator z systemu źródłowego - używany do śledzenia migracji</span>
  </li>
  <li>
    <span class="param-name">ko_numer_klienta</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer klienta nadany przez kontrahenta</span>
  </li>
</ul>

### dbo.kontrahent
Kolumny pominięte przy INSERT: `ko_id_migracja` (zapisywane post-MERGE jako odwzorowanie PK stagingowego), `aud_data` i `aud_login` (wypełniane systemowo z wartości pre-computed `@aud_now` / `@aud_login`). Wszystkie pozostałe kolumny biznesowe kopiowane 1:1 bez transformacji wartości.

</details>

<details markdown="1">
<summary><code>dbo.umowa_kontrahent</code> — <span class="klasa-badge klasa-c">C</span> umowy z kontrahentami</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.umowa_kontrahent</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — transformacja FK</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Umowy z kontrahentami określające cesje wierzytelności i warunki współpracy. FK `uko_ko_id` nie może być kopiowany bezpośrednio, ponieważ wymaga rozwiązania przez zmapowany klucz kontrahenta. Staging `uko_id` trafia do `uko_id_migracja` w produkcji dla celów śledzenia.

<ul class="param-list">
  <li>
    <span class="param-name pk required">uko_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny umowy kontrahenta</span>
  </li>
  <li>
    <span class="param-name fk required">uko_ko_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do tabeli kontrahent - aktualny cesjonariusz wierzytelności</span>
  </li>
  <li>
    <span class="param-name">uko_data_cesji</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data cesji wierzytelności na aktualnego cesjonariusza</span>
  </li>
  <li>
    <span class="param-name">uko_data_naliczania_odsetek</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data od której naliczane są odsetki</span>
  </li>
  <li>
    <span class="param-name">uko_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa umowy kontrahenta</span>
  </li>
  <li>
    <span class="param-name">uko_data_zawarcia</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zawarcia umowy</span>
  </li>
  <li>
    <span class="param-name fk">uko_ko_id_wierzyciel_pierwotny</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do tabeli kontrahent - wierzyciel pierwotny</span>
  </li>
  <li>
    <span class="param-name">uko_ko_id_migracja</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator umowy z systemu źródłowego - używany do śledzenia migracji</span>
  </li>
  <li>
    <span class="param-name">uko_data_ppraw</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data przejścia praw</span>
  </li>
  <li>
    <span class="param-name fk">uko_ko_id_wierzyciel_wtorny</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do tabeli kontrahent - wierzyciel wtórny</span>
  </li>
  <li>
    <span class="param-name fk">uko_ukot_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów umów kontrahenta</span>
  </li>
</ul>

### dbo.umowa_kontrahent
Klucz obcy `uko_ko_id` rozwiązywany przez dwustopniowy JOIN: staging `kontrahent.ko_id` → staging `ko_id_migracja` → prod `kontrahent.ko_id`. Użyty jest `ISNULL(..., src.uko_ko_id)` jako fallback dla wierszy będących kopią referencyjną (gdzie staging PK = prod PK bezpośrednio). Staging `uko_id` trafia do prod kolumny `uko_id_migracja` (zapisywane post-MERGE). Wszystkie pozostałe kolumny biznesowe kopiowane 1:1. Pominięte: `aud_data`, `aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.adres_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów adresów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.adres_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via UUID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów adresów (np. zameldowania, korespondencyjny). MERGE odbywa się po `at_uuid`; produkcyjny `at_id` jest generowany przez IDENTITY — staging `at_id` nigdy nie trafia do produkcji jako PK. Po MERGE produkcyjny `at_id` zapisywany jest do `staging.adres_typ.at_ext_id` dla rozwiązywania FK w tabelach adresów.

<ul class="param-list">
  <li>
    <span class="param-name pk required">at_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu adresu (PK)</span>
  </li>
  <li>
    <span class="param-name required">at_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu adresu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">at_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.adres_typ
Kolumny pominięte przy INSERT do produkcji: `at_id` (IDENTITY w prod — generowany automatycznie), `aud_data` i `aud_login` (systemowe). Produkowany `at_id` trafia do `staging.adres_typ.at_ext_id` przez backfill po UUID. Jedyną kolumną biznesową jest `at_nazwa`.

</details>

<details markdown="1">
<summary><code>dbo.dluznik_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów dłużników</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dluznik_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via UUID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów dłużników (np. osoba fizyczna, firma). MERGE odbywa się po `dt_uuid`; produkcyjny `dt_id` jest IDENTITY. Po MERGE produkcyjny `dt_id` zapisywany jest do `staging.dluznik_typ.dt_ext_id`. Referencjonowany przez tabelę `dluznik.dl_dt_id`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">dt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu dłużnika (PK)</span>
  </li>
  <li>
    <span class="param-name required">dt_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu dłużnika</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">dt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.dluznik_typ
Kolumny pominięte przy INSERT: `dt_id` (IDENTITY), `aud_data`/`aud_login` (systemowe). Prod `dt_id` backfillowany do `staging.dluznik_typ.dt_ext_id` przez JOIN na `dt_uuid`. Jedyną kolumną biznesową jest `dt_nazwa`.

</details>

<details markdown="1">
<summary><code>dbo.dokument_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów dokumentów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dokument_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID z explicit PK</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów dokumentów powiązanych z wierzytelnością. MERGE odbywa się po `dot_uuid`; w odróżnieniu od typowych słowników klasy B, prod `dot_id` jest wstawiany explicit (nie jest IDENTITY w tym kontekście). Po MERGE staging `dot_id` zapisywany jest do `staging.dokument_typ.dot_ext_id`; przy backfillu `dot_ext_id = dot_id` (dla istniejących wierszy staging PK = prod PK).

<ul class="param-list">
  <li>
    <span class="param-name pk required">dot_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu dokumentu (PK)</span>
  </li>
  <li>
    <span class="param-name required">dot_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu dokumentu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">dot_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.dokument_typ
Kolumna `dot_kolejnosc_rozksiegowania` w produkcji ustawiana na stałą wartość `1` (nie istnieje w stagingu). Pominięte: `aud_data`/`aud_login` (systemowe). Staging `dot_id` = prod `dot_id` po backfillu `dot_ext_id`.

</details>

<details markdown="1">
<summary><code>dbo.ksiegowanie_konto</code> — <span class="klasa-badge klasa-c">C</span> słownik kont księgowych</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie_konto</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — hardkodowane wartości prod</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik kont księgowych używanych przy dekretacji (np. kapitał, odsetki). MERGE odbywa się po `ksk_id`. Trzy kolumny produkcyjne nie mają odpowiedników w stagingu — ich wartości są hardkodowane zgodnie z planem migracji.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ksk_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator konta księgowego (PK)</span>
  </li>
  <li>
    <span class="param-name required">ksk_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa konta księgowego</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">ksk_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.ksiegowanie_konto
Kolumny nieistniejące w stagingu, wstawiane z hardkodowanymi wartościami podczas INSERT: `ksk_kolejnosc_rozksiegowania = 99`, `ksk_czy_techniczne = 0`, `ksk_ksk_id_nadrzedne = NULL`. Wartości określone w planie migracji — brak danych źródłowych w stagingu dla tych pól. Staging `ksk_id` = prod `ksk_id` (merge po ID); `ksk_ext_id` backfillowany jako `ksk_id`.

</details>

<details markdown="1">
<summary><code>dbo.ksiegowanie_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów księgowań</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via ID (SELF backfill)</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów księgowań (np. wpłata, korekta). MERGE odbywa się po `kst_id` (tryb ID, nie UUID). Staging `kst_id` = prod `kst_id` — kopia referencyjna; po MERGE `kst_ext_id` backfillowany jako `kst_id` (SELF).

<ul class="param-list">
  <li>
    <span class="param-name pk required">kst_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu księgowania (PK)</span>
  </li>
  <li>
    <span class="param-name required">kst_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu księgowania</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">kst_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.ksiegowanie_typ
Pominięte przy INSERT: `aud_data`/`aud_login` (systemowe). Jedyna kolumna biznesowa: `kst_nazwa`. `kst_ext_id` backfillowany jako `kst_id` (SELF — staging PK = prod PK).

</details>

<details markdown="1">
<summary><code>dbo.sprawa_rola_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów ról uczestników sprawy</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_rola_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via ID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów ról uczestników sprawy (np. dłużnik główny, poręczyciel). MERGE po `sprt_id` (tryb ID); kopia referencyjna — staging PK = prod PK. Backfill NONE (ext_id nie jest używany w downstream przy prostym ID-mode).

<ul class="param-list">
  <li>
    <span class="param-name pk required">sprt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu roli (PK)</span>
  </li>
  <li>
    <span class="param-name required">sprt_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu roli uczestnika sprawy</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">sprt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.sprawa_rola_typ
Pominięte przy INSERT: `aud_data`/`aud_login` (systemowe). Kolumna biznesowa: `sprt_nazwa`. Brak backfillu ext_id — downstream FK rozwiązywane bezpośrednio przez `sprt_id`.

</details>

<details markdown="1">
<summary><code>dbo.sprawa_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów spraw</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via ID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów spraw (np. windykacyjna, handlowa). MERGE po `spt_id` (tryb ID); kopia referencyjna. Referencjonowany przez `sprawa_etap.spe_spt_id` w tej samej iteracji (iteracja 2). Backfill NONE.

<ul class="param-list">
  <li>
    <span class="param-name pk required">spt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu sprawy (PK)</span>
  </li>
  <li>
    <span class="param-name required">spt_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu sprawy</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">spt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.sprawa_typ
Pominięte przy INSERT: `aud_data`/`aud_login` (systemowe). Kolumna biznesowa: `spt_nazwa`. Brak backfillu ext_id — downstream FK (np. `sprawa_etap.spe_spt_id`) rozwiązywane przez JOIN na `spt_ext_id` aktualizowanym przez generic proc.

</details>

<details markdown="1">
<summary><code>dbo.telefon_typ</code> — <span class="klasa-badge klasa-b">B</span> słownik typów numerów telefonów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.telefon_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID, rename PK kolumny</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów numerów telefonów (stacjonarny, komórkowy, fax). Staging PK to `tt_id`, prod PK to `tnt_id` (IDENTITY) — zmiana nazwy kolumny między schematami. MERGE po `tt_uuid` (staging) vs `tnt_uuid` (prod). Staging `tt_id` zapisywany do `staging.telefon_typ.tt_ext_id` dla rozwiązywania FK.

<ul class="param-list">
  <li>
    <span class="param-name pk required">tt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu telefonu (PK; w produkcji kolumna nosi nazwę tnt_id)</span>
  </li>
  <li>
    <span class="param-name required">tt_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu telefonu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">tt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.telefon_typ
Staging `tt_id` → prod `tnt_id` (IDENTITY — nie wstawiamy explicit); staging `tt_nazwa` → prod `tnt_nazwa`; staging `tt_uuid` → prod `tnt_uuid`. Prod `tnt_id` przechwytywany przez OUTPUT i zapisywany do `staging.telefon_typ.tt_ext_id`. Pominięte: `tnt_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.atrybut_dziedzina</code> — <span class="klasa-badge klasa-b">B</span> słownik dziedzin atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_dziedzina</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via ID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik dziedzin atrybutów — określa typ encji, do której przypisywany jest atrybut. MERGE po `atd_id` (tryb ID); kopia referencyjna. Referencjonowany przez `atrybut_typ.att_atd_id` w iteracji 2.

<ul class="param-list">
  <li>
    <span class="param-name pk required">atd_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny dziedziny atrybutu</span>
  </li>
  <li>
    <span class="param-name required">atd_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa dziedziny - określa typ encji, do której należy atrybut</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">atd_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.atrybut_dziedzina
Pominięte przy INSERT: `aud_data`/`aud_login` (systemowe). Kolumna biznesowa: `atd_nazwa`. Backfill NONE — downstream `atrybut_typ` rozwiązuje FK przez JOIN na `atd_ext_id`.

</details>

<details markdown="1">
<summary><code>dbo.atrybut_rodzaj</code> — <span class="klasa-badge klasa-b">B</span> słownik rodzajów atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_rodzaj</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — lookup MERGE via ID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik rodzajów atrybutów — określa typ danych wartości atrybutu. MERGE po `atr_id` (tryb ID); kopia referencyjna. Referencjonowany przez `atrybut_typ.att_atr_id` w iteracji 2.

<ul class="param-list">
  <li>
    <span class="param-name pk required">atr_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny rodzaju atrybutu</span>
  </li>
  <li>
    <span class="param-name required">atr_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa rodzaju - określa typ danych wartości atrybutu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">atr_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.atrybut_rodzaj
Pominięte przy INSERT: `aud_data`/`aud_login` (systemowe). Kolumna biznesowa: `atr_nazwa`. Backfill NONE — downstream `atrybut_typ` rozwiązuje FK przez JOIN na `atr_ext_id`.

</details>

<details markdown="1">
<summary><code>dbo.akcja_typ</code> — <span class="klasa-badge klasa-c">C</span> słownik typów akcji windykacyjnych</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.akcja_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — IDENTITY PK, MERGE via UUID</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów akcji możliwych do wykonania w ramach sprawy. Prod ma IDENTITY PK — staging `akt_id` nigdy nie trafia do produkcji jako klucz główny. MERGE odbywa się po `akt_uuid`. Po MERGE produkcyjny `akt_id` zapisywany jest do `staging.akcja_typ.akt_ext_id`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">akt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu akcji (PK, IDENTITY)</span>
  </li>
  <li>
    <span class="param-name required">akt_kod_akcji</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kod akcji</span>
  </li>
  <li>
    <span class="param-name required">akt_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Wyświetlana nazwa typu akcji</span>
  </li>
  <li>
    <span class="param-name required">akt_rodzaj</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Rodzaj kontrolki akcji, do wyboru z listy z dokumentacji</span>
  </li>
  <li>
    <span class="param-name">akt_ikona</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Ikonka kontrolki akcji</span>
  </li>
  <li>
    <span class="param-name deprecated">akt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">akt_akk_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name">akt_koszt</span>
    <span class="param-type">DECIMAL</span>
    <span class="param-desc">Koszt jednostkowy wykonania akcji; domyślnie 1.00</span>
  </li>
  <li>
    <span class="param-name">akt_wielokrotna</span>
    <span class="param-type">BIT</span>
    <span class="param-desc">Flaga określająca czy akcja może być wykonana wielokrotnie (1=tak, 0=nie)</span>
  </li>
</ul>

### dbo.akcja_typ
Prod PK `akt_id` jest IDENTITY — staging `akt_id` nie jest wstawiany jako PK produkcji. MERGE po `akt_uuid`; prod `akt_id` przechwytywany przez OUTPUT i zapisywany do `staging.akcja_typ.akt_ext_id`. Wszystkie kolumny biznesowe (`akt_kod_akcji`, `akt_nazwa`, `akt_rodzaj`, `akt_ikona`, `akt_koszt`, `akt_wielokrotna`, `akt_akk_id`) kopiowane ze stagingu. Pominięte: prod `akt_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

!!! note "Uwaga — fixup w iteracji 5"
    Ta tabela jest ponownie zasilana w [iteracji 5](akcje.md) — MERGE
    wymusza wartości domyślne dla kolumn <code>akt_akk_id</code>,
    <code>akt_koszt</code>, <code>akt_wielokrotna</code>.
    Iteracja 1 ładuje bazowe dane ze stagingu,
    iteracja 5 nadpisuje domyślnymi wartościami.

</details>

<details markdown="1">
<summary><code>dbo.rezultat_typ</code> — <span class="klasa-badge klasa-c">C</span> słownik typów rezultatów akcji</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.rezultat_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — IDENTITY PK, hardkodowany ret_systemowy</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów rezultatów akcji — możliwe wyniki wykonania akcji. Prod ma IDENTITY PK — staging `ret_id` nie trafia do produkcji jako PK. MERGE po `ret_uuid`. `ret_systemowy` hardkodowany jako `0` (kolumna nie istnieje w stagingu).

<ul class="param-list">
  <li>
    <span class="param-name pk required">ret_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu rezultatu (PK, IDENTITY)</span>
  </li>
  <li>
    <span class="param-name required">ret_kod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Krótki kod rezultatu (np. OTR, KZM, WYS)</span>
  </li>
  <li>
    <span class="param-name required">ret_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Wyświetlana nazwa rezultatu</span>
  </li>
  <li>
    <span class="param-name required">ret_konczy</span>
    <span class="param-type">BIT</span>
    <span class="param-desc">Flaga określająca czy rezultat kończy akcję (1=tak, 0=nie)</span>
  </li>
  <li>
    <span class="param-name deprecated">ret_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.rezultat_typ
Prod PK `ret_id` jest IDENTITY — staging `ret_id` zapisywany do `staging.rezultat_typ.ret_ext_id` przez OUTPUT. Kolumna prod `ret_systemowy` (nieistniejąca w stagingu) hardkodowana jako `0`. Kolumny `ret_kod`, `ret_nazwa`, `ret_konczy` kopiowane ze stagingu. Pominięte: prod `ret_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

!!! note "Uwaga — fixup w iteracji 5"
    Ta tabela jest ponownie zasilana w [iteracji 5](akcje.md) — MERGE
    wymusza wartość domyślną dla kolumny <code>ret_systemowy=0</code>.
    Iteracja 1 ładuje bazowe dane ze stagingu,
    iteracja 5 nadpisuje domyślnymi wartościami.

</details>

<details markdown="1">
<summary><code>dbo.atrybut_typ</code> — <span class="klasa-badge klasa-c">C</span> słownik typów atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — FK via ext_id, hardkodowane wartości</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów atrybutów definiujący dostępne pola dodatkowe dla encji. Iteracja 2 — ładowany po zasileniu `atrybut_dziedzina` i `atrybut_rodzaj`. MERGE po `att_uuid`. Dwa FK rozwiązywane przez JOIN na `ext_id` poprzednich tabel.

<ul class="param-list">
  <li>
    <span class="param-name pk required">att_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny typu atrybutu</span>
  </li>
  <li>
    <span class="param-name required">att_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa typu atrybutu</span>
  </li>
  <li>
    <span class="param-name fk required">att_atd_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do atrybut_dziedzina (atd_id) - dziedzina (encja docelowa) atrybutu</span>
  </li>
  <li>
    <span class="param-name fk required">att_atr_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do atrybut_rodzaj (atr_id) - rodzaj (typ danych) atrybutu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">att_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.atrybut_typ
FK `att_atd_id` rozwiązywany przez JOIN: `staging.atrybut_dziedzina.atd_id` → `atd_ext_id` → `prod.atrybut_dziedzina.atd_id`. Analogicznie `att_atr_id` przez `staging.atrybut_rodzaj.atr_ext_id`. Kolumny prod nieistniejące w stagingu: `att_required = 0` (hardkodowane), `att_zrodlo_danych = NULL` (hardkodowane). Po MERGE prod `att_id` zapisywany do `staging.atrybut_typ.att_ext_id`. Pominięte: `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.sprawa_etap</code> — <span class="klasa-badge klasa-c">C</span> słownik etapów sprawy</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_etap_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — rename tabeli i kolumn, FK via ext_id, hardkodowane kolory</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik etapów sprawy (np. sądowy, egzekucyjny, polubowny). Staging `sprawa_etap` mapuje do prod `sprawa_etap_typ` — zmiana nazwy tabeli. Iteracja 2 — ładowany po `sprawa_typ` i `akcja_typ`. MERGE po `spe_uuid` (staging) vs `spet_uuid` (prod).

<ul class="param-list">
  <li>
    <span class="param-name pk required">spe_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator etapu sprawy (PK)</span>
  </li>
  <li>
    <span class="param-name required">spe_nazwa</span>
    <span class="param-type">NVARCHAR</span>
    <span class="param-desc">Nazwa etapu sprawy</span>
  </li>
  <li>
    <span class="param-name fk required">spe_spt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do typu sprawy (sprawa_typ.spt_id) - określa do jakiego typu sprawy należy etap</span>
  </li>
  <li>
    <span class="param-name fk">spe_akt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do akcja_typ (akt_id) - opcjonalny typ akcji domyślnie powiązany z etapem sprawy</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
  <li>
    <span class="param-name deprecated">spe_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.sprawa_etap
Zmiana nazwy tabeli: staging `sprawa_etap` → prod `sprawa_etap_typ`. Zmiana nazwy kolumn: prefiks `spe_*` → `spet_*`. FK `spet_spt_id` rozwiązywany przez JOIN na `staging.sprawa_typ.spt_ext_id` → prod `sprawa_typ.spt_id`. FK `spet_akt_id` rozwiązywany przez LEFT JOIN na `staging.akcja_typ.akt_uuid` → prod `akcja_typ.akt_uuid` (opcjonalny, stąd LEFT JOIN). Kolumny prod nieistniejące w stagingu hardkodowane: `spet_kolorR = 51`, `spet_kolorG = 153`, `spet_kolorB = 255`, `spet_kolejnosc = 1`. Staging `spe_id` zapisywany do prod `spet_ext_id`. Pominięte: `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.zrodlo_pochodzenia_informacji</code> — <span class="klasa-badge klasa-b">B</span> słownik źródeł informacji</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.zrodlo_pochodzenia_informacji</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID z explicit PK</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik źródeł pochodzenia informacji o dłużnikach i wierzytelnościach. MERGE po `zpi_uuid`; prod `zpi_id` nie jest IDENTITY — wstawiany explicit ze stagingu. Iteracja 3.

<ul class="param-list">
  <li>
    <span class="param-name pk required">zpi_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator źródła informacji (PK)</span>
  </li>
  <li>
    <span class="param-name required">zpi_nazwa</span>
    <span class="param-type">NVARCHAR(255) NOT NULL</span>
    <span class="param-desc">Nazwa źródła pochodzenia informacji</span>
  </li>
  <li>
    <span class="param-name">zpi_opis</span>
    <span class="param-type">NVARCHAR(2000) NULL</span>
    <span class="param-desc">Opis źródła pochodzenia informacji (opcjonalny)</span>
  </li>
  <li>
    <span class="param-name deprecated">zpi_uuid</span>
    <span class="param-type">VARCHAR(50) NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.zrodlo_pochodzenia_informacji
MERGE po `zpi_uuid`; `zpi_id` wstawiany explicit (prod `zpi_id` nie jest IDENTITY). Kolumny biznesowe: `zpi_nazwa`, `zpi_opis` kopiowane 1:1. Po MERGE prod `zpi_id` zapisywany do `staging.zrodlo_pochodzenia_informacji.zpi_ext_id`. Pominięte: `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ_walidacji</code> — <span class="klasa-badge klasa-b">B</span> słownik typów walidacji właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ_walidacji</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID, IDENTITY w prod</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów walidacji właściwości (reguły walidacji wartości pola). MERGE po `wtw_uuid`; prod `wtw_id` jest IDENTITY. Iteracja 3. Referencjonowany przez `wlasciwosc_typ.wt_wtw_id` w iteracji 4.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wtw_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator typu walidacji (PK)</span>
  </li>
  <li>
    <span class="param-name required">wtw_nazwa</span>
    <span class="param-type">VARCHAR(50) NOT NULL</span>
    <span class="param-desc">Nazwa typu walidacji właściwości</span>
  </li>
  <li>
    <span class="param-name deprecated">wtw_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.wlasciwosc_typ_walidacji
MERGE po `wtw_uuid`; prod `wtw_id` IDENTITY — staging `wtw_id` → `staging.wlasciwosc_typ_walidacji.wtw_ext_id`. Kolumna biznesowa: `wtw_nazwa`. Pominięte: prod `wtw_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.wlasciwosc_dziedzina</code> — <span class="klasa-badge klasa-b">B</span> słownik dziedzin właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_dziedzina</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID, IDENTITY w prod</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik dziedzin właściwości — określa typ encji, do której przypisywana jest właściwość. MERGE po `wdzi_uuid`; prod `wdzi_id` jest IDENTITY. Iteracja 3. Referencjonowany przez `wlasciwosc_typ_podtyp_dziedzina` w iteracji 4.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wdzi_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator dziedziny właściwości (PK)</span>
  </li>
  <li>
    <span class="param-name required">wdzi_nazwa</span>
    <span class="param-type">VARCHAR(100) NOT NULL</span>
    <span class="param-desc">Nazwa dziedziny właściwości</span>
  </li>
  <li>
    <span class="param-name deprecated">wdzi_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.wlasciwosc_dziedzina
MERGE po `wdzi_uuid`; prod `wdzi_id` IDENTITY — staging `wdzi_id` → `staging.wlasciwosc_dziedzina.wdzi_ext_id`. Kolumna biznesowa: `wdzi_nazwa`. Pominięte: prod `wdzi_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.wlasciwosc_podtyp</code> — <span class="klasa-badge klasa-b">B</span> słownik podtypów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_podtyp</code></span>
  <span>Klasa: <span class="klasa-badge klasa-b">B</span> — MERGE via UUID, IDENTITY w prod</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik podtypów właściwości — klasyfikacja uszczegółowiająca typ właściwości. MERGE po `wpt_uuid`; prod `wpt_id` jest IDENTITY. Iteracja 3. Referencjonowany przez `wlasciwosc_typ_podtyp_dziedzina` w iteracji 4.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wpt_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator podtypu właściwości (PK)</span>
  </li>
  <li>
    <span class="param-name required">wpt_nazwa</span>
    <span class="param-type">VARCHAR(255) NOT NULL</span>
    <span class="param-desc">Nazwa podtypu właściwości</span>
  </li>
  <li>
    <span class="param-name deprecated">wpt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.wlasciwosc_podtyp
MERGE po `wpt_uuid`; prod `wpt_id` IDENTITY — staging `wpt_id` → `staging.wlasciwosc_podtyp.wpt_ext_id`. Kolumna biznesowa: `wpt_nazwa`. Pominięte: prod `wpt_id` (IDENTITY), `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ</code> — <span class="klasa-badge klasa-c">C</span> słownik typów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — FK via ext_id</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów właściwości — definiuje dostępne pola dodatkowe z przypisaną regułą walidacji. MERGE po `wt_uuid`. Iteracja 4 — zależny od `wlasciwosc_typ_walidacji`. FK `wt_wtw_id` rozwiązywany przez `ext_id`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wt_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator typu właściwości (PK)</span>
  </li>
  <li>
    <span class="param-name required">wt_nazwa</span>
    <span class="param-type">VARCHAR(255) NOT NULL</span>
    <span class="param-desc">Nazwa typu właściwości</span>
  </li>
  <li>
    <span class="param-name fk required">wt_wtw_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">FK do wlasciwosc_typ_walidacji (wtw_id) - typ walidacji stosowanej dla tej właściwości</span>
  </li>
  <li>
    <span class="param-name deprecated">wt_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.wlasciwosc_typ
FK `wt_wtw_id` rozwiązywany przez JOIN: `staging.wlasciwosc_typ_walidacji.wtw_id` → `wtw_ext_id` (prod `wlasciwosc_typ_walidacji.wtw_id`). MERGE po `wt_uuid`; prod `wt_id` zapisywany do `staging.wlasciwosc_typ.wt_ext_id`. Kolumna biznesowa: `wt_nazwa`. Pominięte: `aud_data`/`aud_login` (systemowe).

</details>

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ_podtyp_dziedzina</code> — <span class="klasa-badge klasa-c">C</span> konfiguracja dziedzin i podtypów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ_podtyp_dziedzina</code></span>
  <span>Klasa: <span class="klasa-badge klasa-c">C</span> — trzy FK via ext_id</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Tabela łącząca typ właściwości z jej dziedziną i podtypem — konfiguruje dostępne kombinacje w systemie. MERGE po `wtpd_uuid`. Iteracja 4 — zależna od `wlasciwosc_typ`, `wlasciwosc_dziedzina` i `wlasciwosc_podtyp`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wtpd_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">Identyfikator konfiguracji (PK)</span>
  </li>
  <li>
    <span class="param-name fk required">wtpd_wt_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">FK do wlasciwosc_typ (wt_id) - typ właściwości</span>
  </li>
  <li>
    <span class="param-name fk required">wtpd_dzi_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">FK do wlasciwosc_dziedzina (wdzi_id) - dziedzina, w której właściwość występuje</span>
  </li>
  <li>
    <span class="param-name fk required">wtpd_wpt_id</span>
    <span class="param-type">INT NOT NULL</span>
    <span class="param-desc">FK do wlasciwosc_podtyp (wpt_id) - podtyp doprecyzowujący właściwość</span>
  </li>
  <li>
    <span class="param-name deprecated">wtpd_uuid</span>
    <span class="param-type">UNIQUEIDENTIFIER NOT NULL</span>
    <span class="param-desc">Klucz naturalny UUID używany do MERGE między stagingiem a produkcją</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME NOT NULL</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

### dbo.wlasciwosc_typ_podtyp_dziedzina
Trzy FK rozwiązywane przez JOIN na `ext_id`: `wtpd_wt_id` via `staging.wlasciwosc_typ.wt_ext_id`, `wtpd_dzi_id` via `staging.wlasciwosc_dziedzina.wdzi_ext_id`, `wtpd_wpt_id` via `staging.wlasciwosc_podtyp.wpt_ext_id`. MERGE po `wtpd_uuid`; prod `wtpd_id` zapisywany do `staging.wlasciwosc_typ_podtyp_dziedzina.wtpd_ext_id`. Pominięte: `aud_data`/`aud_login` (systemowe).

</details>

## Powiązania {#powiazania}

- Następna iteracja: [Dłużnicy i atrybuty dłużników](dluznicy.md)
- Klasyfikacja mapowania: [Mapowanie staging → prod](mapowanie-tabel.md)
- Walidacje referencyjne ogólne (dotyczą wszystkich typów słownikowych):
  [REF_03, REF_08, REF_10, REF_12, REF_15, REF_21, REF_26, REF_29, REF_30, REF_32, REF_34](../przygotowanie-danych/walidacje.md)
