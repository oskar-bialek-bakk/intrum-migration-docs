---
title: "Migracja ⬝ Akcje i rezultaty"
tags:
  - brq211
---

# Akcje i rezultaty

Iteracja 5 obejmuje akcje prowadzone w ramach spraw oraz ich rezultaty — kontakt telefoniczny, wizyta, wysłane pismo, itp. Dane z tej iteracji można załadować dopiero po Iteracji 4, ponieważ każda akcja musi być powiązana z istniejącą sprawą. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 5</span>
  <span>Zależności: Iteracja 4</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#biz_08">BIZ_08</a></span>
  <span>Zakres: akcje prowadzone w sprawach oraz ich rezultaty</span>
</div>

## Diagram ER

Diagram pokazuje tabele iteracji 5 (`akcja`, `rezultat`) wraz ze słownikami typów akcji i rezultatów z iteracji 1 oraz powiązaniem do sprawy z iteracji 4. Pełna struktura sprawy — [Sprawy i role § Diagram ER](sprawy.md#diagram-er). Słowniki `akcja_typ`/`rezultat_typ` — [Tabele słownikowe](slowniki.md).

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

### dbo.akcja

<details markdown="1">
<summary><code>dbo.akcja</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> akcje wykonane w ramach spraw</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.akcja</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 sprawa → N akcji)</span>
</div>

Akcje wykonane w ramach spraw — operacyjna jednostka pracy na sprawie (telefon, wizyta, list, monit). Każda akcja wskazuje sprawę, w ramach której była prowadzona, oraz opcjonalnie typ akcji ze słownika `akcja_typ`. Kolumna `ak_data_zakonczenia` (NULL = akcja niezakończona) mapowana jest na prod `ak_zakonczono`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ak_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny akcji w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">ak_sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do sprawy</span>
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

</details>

### dbo.rezultat

<details markdown="1">
<summary><code>dbo.rezultat</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> rezultaty akcji</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.rezultat</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: tak (BIZ_08: każda akcja musi mieć ≥1 rezultat)</span>
  <span>Multi-row: tak (1 akcja → N rezultatów, ale typowo 1:1)</span>
</div>

Rezultaty akcji — wynik wykonania akcji (kontakt osiągnięty, brak odbioru, odmowa płatności, zobowiązanie do zapłaty itp.). Tabela materializuje wymóg BIZ_08: akcja bez rezultatu jest nieprawidłowa. Każdy rezultat wskazuje akcję, której dotyczy, oraz typ rezultatu ze słownika `rezultat_typ`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">re_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny rezultatu akcji w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">re_ak_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do akcji</span>
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

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Sprawy i role](sprawy.md)
- Następna iteracja: [Wierzytelności](wierzytelnosci.md)
- Słowniki bazowe iteracja 1: [akcja_typ](slowniki.md#dboakcja_typ), [rezultat_typ](slowniki.md#dborezultat_typ)
- Walidacje referencyjne (akcja): [REF_14 (sprawa), REF_32 (typ akcji)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (rezultat): [REF_33 (akcja), REF_34 (typ rezultatu)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe: [BIZ_08 (akcja musi mieć ≥1 rezultat, BLOKUJĄCE)](../przygotowanie-danych/walidacje.md#biz_08)
