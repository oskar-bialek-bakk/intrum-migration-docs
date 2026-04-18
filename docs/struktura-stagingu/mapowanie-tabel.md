---
title: "Migracja ⬝ Mapowanie staging → prod"
tags:
  - brq211
  - brq212
  - brq214
---

# Mapowanie staging → prod

Każda tabela stagingowa należy do jednej z trzech klas odwzorowania na bazę
produkcyjną `dm_data_web`. Klasa decyduje o tym, ile opisu mapowania znajdziesz
na stronie iteracji, do której należy tabela.

## Klasyfikacja

<div class="api-section">
  <div class="api-section-title">Klasy odwzorowania</div>

  <ul class="param-list">
    <li>
      <span class="param-name"><span class="klasa-badge klasa-a">A</span> 1:1</span>
      <span class="param-desc">
        Tabela stagingowa i produkcyjna mają ten sam zestaw kolumn i typów.
        Migracja kopiuje wiersze bez transformacji.
        Na stronie iteracji widzisz definicje kolumn i krótką notkę
        „kopiowana bez zmian do <code>dm_data_web.&lt;tabela&gt;</code>".
      </span>
    </li>
    <li>
      <span class="param-name"><span class="klasa-badge klasa-b">B</span> Simplified</span>
      <span class="param-desc">
        Tabela stagingowa ma mniej kolumn niż produkcyjna —
        pominięte są kolumny nullable lub generowane przez triggery / IDENTITY.
        Na stronie iteracji jest lista pominiętych kolumn z uzasadnieniem.
      </span>
    </li>
    <li>
      <span class="param-name"><span class="klasa-badge klasa-c">C</span> Fanned-out</span>
      <span class="param-desc">
        Wiersz stagingu rozlewa się na wiele tabel produkcyjnych
        lub przechodzi przez logikę biznesową
        (CASE, JOIN-y, ekstrakcja pól). Na stronie iteracji jest pełne
        mapowanie kolumn: skąd bierze się wartość, jakie są warunki,
        do jakiej tabeli produkcyjnej trafia.
      </span>
    </li>
  </ul>
</div>

!!! note "Tabele z wieloma źródłami"
    Niektóre tabele produkcyjne są zasilane z kilku tabel stagingowych w różnych
    iteracjach. Najważniejszy przypadek to `dm_data_web.ksiegowanie`, które
    otrzymuje wiersze z trzech źródeł: bezpośredni MERGE `dbo.ksiegowanie`
    (iter 8), fan-out z `dbo.operacja` (iter 8) oraz fan-out z
    `dbo.harmonogram` (iter 9). Podobnie `dm_data_web.wlasciwosc` jest
    zasilana z czterech par iteracji (dłużnik / adres / mail / telefon)
    przez wspólną procedurę `usp_migrate_wlasciwosc_domain`.

## Mapowanie wszystkich tabel

Każdy wiersz linkuje do strony iteracji, na której znajdziesz szczegóły kolumn
i notatki mapowania.

| Iter | Tabela stagingowa | Tabela produkcyjna | Klasa |
|------|-------------------|---------------------|:-----:|
| [1](slowniki.md) | `dbo.waluta` | `dm_data_web.waluta` | <span class="klasa-badge klasa-a">A</span> |
| [1](slowniki.md) | `dbo.kurs_walut` | `dm_data_web.kurs_walut` | <span class="klasa-badge klasa-a">A</span> |
| [1](slowniki.md) | `dbo.kontrahent` | `dm_data_web.kontrahent` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.umowa_kontrahent` | `dm_data_web.umowa_kontrahent` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.adres_typ` | `dm_data_web.adres_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.dluznik_typ` | `dm_data_web.dluznik_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.dokument_typ` | `dm_data_web.dokument_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.ksiegowanie_konto` | `dm_data_web.ksiegowanie_konto` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.ksiegowanie_typ` | `dm_data_web.ksiegowanie_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.sprawa_rola_typ` | `dm_data_web.sprawa_rola_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.sprawa_typ` | `dm_data_web.sprawa_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.telefon_typ` | `dm_data_web.telefon_typ` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.atrybut_dziedzina` | `dm_data_web.atrybut_dziedzina` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.atrybut_rodzaj` | `dm_data_web.atrybut_rodzaj` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.akcja_typ` | `dm_data_web.akcja_typ` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.rezultat_typ` | `dm_data_web.rezultat_typ` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.atrybut_typ` | `dm_data_web.atrybut_typ` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.sprawa_etap` | `dm_data_web.sprawa_etap_typ` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.zrodlo_pochodzenia_informacji` | `dm_data_web.zrodlo_pochodzenia_informacji` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.wlasciwosc_typ_walidacji` | `dm_data_web.wlasciwosc_typ_walidacji` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.wlasciwosc_dziedzina` | `dm_data_web.wlasciwosc_dziedzina` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.wlasciwosc_podtyp` | `dm_data_web.wlasciwosc_podtyp` | <span class="klasa-badge klasa-b">B</span> |
| [1](slowniki.md) | `dbo.wlasciwosc_typ` | `dm_data_web.wlasciwosc_typ` | <span class="klasa-badge klasa-c">C</span> |
| [1](slowniki.md) | `dbo.wlasciwosc_typ_podtyp_dziedzina` | `dm_data_web.wlasciwosc_typ_podtyp_dziedzina` | <span class="klasa-badge klasa-c">C</span> |
| [2](dluznicy.md) | `dbo.dluznik` | `dm_data_web.dluznik` | <span class="klasa-badge klasa-c">C</span> |
| [2](dluznicy.md) | `dbo.atrybut` (`att_atd_id=3`) | `dm_data_web.atrybut_wartosc`<br>`dm_data_web.atrybut_dluznik` | <span class="klasa-badge klasa-c">C</span> |
| [2](dluznicy.md) | `dbo.wlasciwosc` + `dbo.wlasciwosc_dluznik` (`wdzi_id=4`) | `dm_data_web.wlasciwosc`<br>`dm_data_web.wlasciwosc_dluznik` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.adres` | `dm_data_web.adres` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.mail` | `dm_data_web.mail` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.telefon` | `dm_data_web.telefon` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.wlasciwosc` + `dbo.wlasciwosc_adres` (`wdzi_id=2`) | `dm_data_web.wlasciwosc`<br>`dm_data_web.wlasciwosc_adres` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.wlasciwosc` + `dbo.wlasciwosc_email` (`wdzi_id=3`) | `dm_data_web.wlasciwosc`<br>`dm_data_web.wlasciwosc_email` | <span class="klasa-badge klasa-c">C</span> |
| [3](kontakty.md) | `dbo.wlasciwosc` + `dbo.wlasciwosc_telefon` (`wdzi_id=1`) | `dm_data_web.wlasciwosc`<br>`dm_data_web.wlasciwosc_telefon` | <span class="klasa-badge klasa-c">C</span> |
| [4](sprawy.md) | `dbo.sprawa` | `dm_data_web.rachunek_bankowy`<br>`dm_data_web.sprawa`<br>`dm_data_web.operator` | <span class="klasa-badge klasa-c">C</span> |
| [4](sprawy.md) | `dbo.sprawa_rola` | `dm_data_web.sprawa_rola` | <span class="klasa-badge klasa-c">C</span> |
| [4](sprawy.md) | `dbo.atrybut` (`att_atd_id=4`) | `dm_data_web.atrybut_wartosc`<br>`dm_data_web.atrybut_sprawa` | <span class="klasa-badge klasa-c">C</span> |
| [5](akcje.md) | `dbo.akcja_typ` (re-MERGE fixup) | `dm_data_web.akcja_typ` | <span class="klasa-badge klasa-c">C</span> |
| [5](akcje.md) | `dbo.rezultat_typ` (re-MERGE fixup) | `dm_data_web.rezultat_typ` | <span class="klasa-badge klasa-c">C</span> |
| [5](akcje.md) | `dbo.akcja` | `dm_data_web.akcja` | <span class="klasa-badge klasa-c">C</span> |
| [5](akcje.md) | `dbo.rezultat` | `dm_data_web.rezultat` | <span class="klasa-badge klasa-c">C</span> |
| [6](wierzytelnosci.md) | `dbo.wierzytelnosc` | `dm_data_web.wierzytelnosc`<br>`dm_data_web.wierzytelnosc_rola` | <span class="klasa-badge klasa-c">C</span> |
| [6](wierzytelnosci.md) | `dbo.atrybut` (`att_atd_id=2`) | `dm_data_web.atrybut_wartosc`<br>`dm_data_web.atrybut_wierzytelnosc` | <span class="klasa-badge klasa-c">C</span> |
| [7](role-wierzytelnosci-i-dokumenty.md) | `dbo.wierzytelnosc_rola` | `dm_data_web.wierzytelnosc_rola` | <span class="klasa-badge klasa-c">C</span> |
| [7](role-wierzytelnosci-i-dokumenty.md) | `dbo.dokument` | `dm_data_web.dokument` | <span class="klasa-badge klasa-c">C</span> |
| [7](role-wierzytelnosci-i-dokumenty.md) | `dbo.atrybut` (`att_atd_id=1`) | `dm_data_web.atrybut_wartosc`<br>`dm_data_web.atrybut_dokument` | <span class="klasa-badge klasa-c">C</span> |
| [8](finanse.md) | `dbo.ksiegowanie` | `dm_data_web.ksiegowanie` | <span class="klasa-badge klasa-c">C</span> |
| [8](finanse.md) | `dbo.ksiegowanie_dekret` | `dm_data_web.ksiegowanie_dekret` | <span class="klasa-badge klasa-c">C</span> |
| [8](finanse.md) | `dbo.operacja` | `dm_data_web.ksiegowanie`<br>`dm_data_web.ksiegowanie_dekret` | <span class="klasa-badge klasa-c">C</span> |
| [9](harmonogram.md) | `dbo.harmonogram` | `dm_data_web.dokument`<br>`dm_data_web.ksiegowanie`<br>`dm_data_web.ksiegowanie_dekret` | <span class="klasa-badge klasa-c">C</span> |

Razem: **49 mapowań** (2 × A, 14 × B, 33 × C) z 9 iteracji. Niektóre tabele stagingowe pojawiają się w kilku wierszach — np. `atrybut` (4 różne `att_atd_id`), `akcja_typ` / `rezultat_typ` (iter 1 + iter 5 re-MERGE).
