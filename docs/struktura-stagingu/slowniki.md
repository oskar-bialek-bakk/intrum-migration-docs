---
title: "Migracja ⬝ Tabele słownikowe"
tags:
  - brq211
---

# Tabele słownikowe

Iteracja 1 obejmuje tabele słownikowe i referencyjne — waluty, kursy, kontrahenci, typy adresów/telefonów/dokumentów, dziedziny i typy atrybutów oraz właściwości, typy księgowań i konta księgowe. Jest to pierwsza fala dostawy — słowniki muszą być załadowane przed jakimikolwiek danymi transakcyjnymi, bo praktycznie każda kolejna iteracja referuje kody z tych tabel. Zobacz też: [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 1</span>
  <span>Zakres: słowniki i tabele referencyjne</span>
</div>

## Tabele

### dbo.waluta

<details markdown="1">
<summary><code>dbo.waluta</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> kopia referencyjna walut</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.waluta</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Tabela referencyjna walut wykorzystywanych w systemie. Stanowi punkt odniesienia dla tabel księgowań i kursów — każda operacja finansowa wskazuje kod waluty z tego słownika.

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

</details>

### dbo.kurs_walut

<details markdown="1">
<summary><code>dbo.kurs_walut</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> kursy walut referencyjne</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.kurs_walut</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Kursy walut referencyjne używane przy przeliczaniu wierzytelności i księgowań. Para `(kw_kod, kw_data)` stanowi klucz naturalny — kod ISO waluty i data łącznie jednoznacznie identyfikują wiersz.

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

</details>

### dbo.kontrahent

<details markdown="1">
<summary><code>dbo.kontrahent</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> kontrahenci i wierzyciele</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.kontrahent</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Kontrahenci — wierzyciele pierwotni i pośrednicy — powiązani z umowami cesji i zarządzaniem portfelami wierzytelności. Każdy kontrahent może występować jako wierzyciel pierwotny, wtórny lub cesjonariusz w [umowach kontrahenta](#dboumowa_kontrahent).

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

</details>

### dbo.umowa_kontrahent

<details markdown="1">
<summary><code>dbo.umowa_kontrahent</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> umowy z kontrahentami</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.umowa_kontrahent</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Umowy z kontrahentami określające cesje wierzytelności i warunki współpracy. Każda umowa wskazuje aktualnego cesjonariusza (`uko_ko_id`) oraz — opcjonalnie — wierzyciela pierwotnego i wtórnego, tworząc łańcuch cesji portfela.

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

</details>

### dbo.adres_typ

<details markdown="1">
<summary><code>dbo.adres_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów adresów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.adres_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów adresów (np. zameldowania, korespondencyjny). Tabela referencyjna dla adresów dłużników i kontrahentów — kod typu pozwala rozróżnić charakter adresu.

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

</details>

### dbo.dluznik_typ

<details markdown="1">
<summary><code>dbo.dluznik_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów dłużników</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dluznik_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów dłużników (np. osoba fizyczna, firma). Referencjonowany przez tabelę dłużników (`dluznik.dl_dt_id`) — wartość pola pozwala dostosować logikę obsługi sprawy do charakteru podmiotu.

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

</details>

### dbo.dokument_typ

<details markdown="1">
<summary><code>dbo.dokument_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów dokumentów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dokument_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów dokumentów powiązanych z wierzytelnością (np. faktura, nota, umowa). Używany w tabelach dokumentów przypisanych do spraw — kod typu określa rodzaj dokumentu wystawianego w procesie windykacyjnym.

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

</details>

### dbo.ksiegowanie_konto

<details markdown="1">
<summary><code>dbo.ksiegowanie_konto</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik kont księgowych</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie_konto</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik kont księgowych używanych przy dekretacji operacji finansowych (np. kapitał, odsetki, prowizje). Każde konto ma unikalną nazwę i kod umożliwiający rozksięgowanie wpłat i korekt na właściwe pozycje bilansowe.

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

</details>

### dbo.ksiegowanie_typ

<details markdown="1">
<summary><code>dbo.ksiegowanie_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów księgowań</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów księgowań (np. wpłata, korekta). Używany w rozksięgowaniach operacji finansowych — kod typu określa charakter zapisu księgowego.

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

</details>

### dbo.sprawa_rola_typ

<details markdown="1">
<summary><code>dbo.sprawa_rola_typ</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik typów ról uczestników sprawy</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_rola_typ</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów ról uczestników sprawy (np. dłużnik główny, poręczyciel). Określa charakter przypisania osoby lub firmy do sprawy windykacyjnej.

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

</details>

### dbo.sprawa_typ

<details markdown="1">
<summary><code>dbo.sprawa_typ</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik typów spraw</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_typ</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów spraw (np. windykacyjna, handlowa). Określa charakter sprawy i rzutuje na dostępne dla niej etapy (patrz [`sprawa_etap`](#dbosprawa_etap)).

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

</details>

### dbo.telefon_typ

<details markdown="1">
<summary><code>dbo.telefon_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów numerów telefonów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.telefon_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów numerów telefonów (stacjonarny, komórkowy, fax). Używany przy kontaktach telefonicznych z dłużnikami — kod typu pozwala rozróżnić kanał kontaktu.

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

</details>

### dbo.atrybut_dziedzina

<details markdown="1">
<summary><code>dbo.atrybut_dziedzina</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik dziedzin atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_dziedzina</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik dziedzin atrybutów — określa typ encji, do której przypisywany jest atrybut (np. dłużnik, sprawa, wierzytelność). Referencjonowany przez [`atrybut_typ`](#dboatrybut_typ).

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

</details>

### dbo.atrybut_rodzaj

<details markdown="1">
<summary><code>dbo.atrybut_rodzaj</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik rodzajów atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_rodzaj</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik rodzajów atrybutów — określa typ danych wartości atrybutu (np. tekst, liczba, data). Referencjonowany przez [`atrybut_typ`](#dboatrybut_typ).

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

</details>

### dbo.akcja_typ

<details markdown="1">
<summary><code>dbo.akcja_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów akcji windykacyjnych</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.akcja_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów akcji windykacyjnych możliwych do wykonania w ramach sprawy (np. kontakt telefoniczny, wysłanie wezwania, zlecenie egzekucyjne). Każda akcja ma kod, nazwę i konfigurację wpływającą na sposób jej wykonania.

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

!!! note "Uwaga — fixup w iteracji 5"
    Ta tabela jest ponownie zasilana w [iteracji 5](akcje.md) — MERGE
    wymusza wartości domyślne dla kolumn <code>akt_akk_id</code>,
    <code>akt_koszt</code>, <code>akt_wielokrotna</code>.
    Iteracja 1 ładuje bazowe dane ze stagingu,
    iteracja 5 nadpisuje domyślnymi wartościami.

</details>

### dbo.rezultat_typ

<details markdown="1">
<summary><code>dbo.rezultat_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów rezultatów akcji</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.rezultat_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów rezultatów akcji — możliwe wyniki wykonania akcji windykacyjnej (np. „otrzymano wpłatę", „kontakt zakończony"). Flaga `ret_konczy` wskazuje czy rezultat oznacza finalizację akcji.

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

!!! note "Uwaga — fixup w iteracji 5"
    Ta tabela jest ponownie zasilana w [iteracji 5](akcje.md) — MERGE
    wymusza wartość domyślną dla kolumny <code>ret_systemowy=0</code>.
    Iteracja 1 ładuje bazowe dane ze stagingu,
    iteracja 5 nadpisuje domyślnymi wartościami.

</details>

### dbo.atrybut_typ

<details markdown="1">
<summary><code>dbo.atrybut_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów atrybutów</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.atrybut_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów atrybutów definiujący dostępne pola dodatkowe dla encji (dłużnik, sprawa, wierzytelność). Każdy typ atrybutu odwołuje się do dziedziny (encji docelowej) oraz rodzaju (typu danych przechowywanej wartości).

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

</details>

### dbo.sprawa_etap

<details markdown="1">
<summary><code>dbo.sprawa_etap</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik etapów sprawy</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_etap_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik etapów sprawy (np. sądowy, egzekucyjny, polubowny). Każdy etap przypisany jest do konkretnego [typu sprawy](#dbosprawa_typ) i opcjonalnie wskazuje domyślną [akcję](#dboakcja_typ) wykonywaną przy przejściu do tego etapu.

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

</details>

### dbo.zrodlo_pochodzenia_informacji

<details markdown="1">
<summary><code>dbo.zrodlo_pochodzenia_informacji</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik źródeł informacji</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.zrodlo_pochodzenia_informacji</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik źródeł pochodzenia informacji o dłużnikach i wierzytelnościach — określa skąd pozyskano dane (np. wewnętrzny system, zewnętrzne bazy).

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

</details>

### dbo.wlasciwosc_typ_walidacji

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ_walidacji</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik typów walidacji właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ_walidacji</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów walidacji właściwości — reguły kontroli poprawności wartości pola (np. walidacja numeru NIP, formatu e-mail, zakresu liczb). Referencjonowany przez [`wlasciwosc_typ`](#dbowlasciwosc_typ).

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

</details>

### dbo.wlasciwosc_dziedzina

<details markdown="1">
<summary><code>dbo.wlasciwosc_dziedzina</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik dziedzin właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_dziedzina</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik dziedzin właściwości — określa typ encji, do której przypisywana jest właściwość. Używany w tabeli konfiguracyjnej [`wlasciwosc_typ_podtyp_dziedzina`](#dbowlasciwosc_typ_podtyp_dziedzina).

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

</details>

### dbo.wlasciwosc_podtyp

<details markdown="1">
<summary><code>dbo.wlasciwosc_podtyp</code> — <span class="ksztalt-badge ksztalt-11">1:1</span> słownik podtypów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_podtyp</code></span>
  <span>Kształt mapowania: 1:1</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik podtypów właściwości — klasyfikacja uszczegółowiająca typ właściwości. Wykorzystywany razem z typem i dziedziną w tabeli konfiguracyjnej [`wlasciwosc_typ_podtyp_dziedzina`](#dbowlasciwosc_typ_podtyp_dziedzina).

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

</details>

### dbo.wlasciwosc_typ

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> słownik typów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Słownik typów właściwości — definiuje dostępne pola dodatkowe z przypisaną regułą walidacji (poprzez `wt_wtw_id` do [`wlasciwosc_typ_walidacji`](#dbowlasciwosc_typ_walidacji)). Pozwala opisywać właściwości z kontrolą poprawności wartości.

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

</details>

### dbo.wlasciwosc_typ_podtyp_dziedzina

<details markdown="1">
<summary><code>dbo.wlasciwosc_typ_podtyp_dziedzina</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> konfiguracja dziedzin i podtypów właściwości</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wlasciwosc_typ_podtyp_dziedzina</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Tabela konfiguracyjna łącząca typ właściwości z jej dziedziną i podtypem — definiuje dostępne kombinacje dla aplikacji ([`wlasciwosc_typ`](#dbowlasciwosc_typ), [`wlasciwosc_dziedzina`](#dbowlasciwosc_dziedzina), [`wlasciwosc_podtyp`](#dbowlasciwosc_podtyp)).

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

</details>

## Powiązania {#powiazania}

- Następna iteracja: [Dłużnicy i atrybuty dłużników](dluznicy.md)
- Walidacje referencyjne ogólne (dotyczą wszystkich typów słownikowych):
  [REF_03, REF_08, REF_10, REF_12, REF_15, REF_21, REF_26, REF_29, REF_30, REF_32, REF_34](../przygotowanie-danych/walidacje.md)
