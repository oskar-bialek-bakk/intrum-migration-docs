---
title: "Migracja ⬝ Wierzytelności"
tags:
  - brq211
---

# Wierzytelności

Iteracja 6 obejmuje wierzytelności — umowy/zobowiązania dłużników — oraz role wierzytelności (powiązania wierzytelność ↔ sprawa) wraz z atrybutami wierzytelności. Dane z tej iteracji można załadować dopiero po Iteracji 4, ponieważ każda wierzytelność i każda rola jest powiązana ze sprawą. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 6</span>
  <span>Zależności: Iteracja 4</span>
  <span>Walidacje: <a href="../../przygotowanie-danych/walidacje/#biz_04">BIZ_04</a>, <a href="../../przygotowanie-danych/walidacje/#biz_14">BIZ_14</a>, <a href="../../przygotowanie-danych/walidacje/#biz_19">BIZ_19</a></span>
  <span>Zakres: wierzytelności, role wierzytelności i ich atrybuty</span>
</div>

## Diagram ER

Diagram pokazuje tabele iteracji 6 (`wierzytelnosc`, `wierzytelnosc_rola`) oraz powiązanie ze `sprawa` (iteracja 4) i `umowa_kontrahent` (iteracja 1). Polimorficzny stos `atrybut` opisany jest w [Tabele generyczne](tabele-generyczne.md#dboatrybut).

```mermaid
erDiagram
    sprawa {
        bigint  sp_id    PK
    }

    umowa_kontrahent {
        int     uko_id    PK
    }

    wierzytelnosc {
        bigint  wi_id           PK
        bigint  wi_sp_id        FK
        int     wi_uko_id       FK
        varchar wi_numer
        varchar wi_tytul
        date    wi_data_umowy
    }

    wierzytelnosc_rola {
        bigint  wir_id          PK
        bigint  wir_sp_id       FK
        bigint  wir_wi_id       FK
    }

    wierzytelnosc       }o--||  sprawa            : "wi_sp_id"
    wierzytelnosc       }o--o|  umowa_kontrahent  : "wi_uko_id"
    wierzytelnosc_rola  }o--||  sprawa            : "wir_sp_id"
    wierzytelnosc_rola  }o--||  wierzytelnosc     : "wir_wi_id"
```

## Tabele

### dbo.wierzytelnosc

<details markdown="1">
<summary><code>dbo.wierzytelnosc</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> nagłówek wierzytelności</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wierzytelnosc</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 sprawa → N wierzytelności)</span>
</div>

Nagłówek wierzytelności — roszczenie finansowe przypisane do sprawy. Jeden wiersz staging odpowiada jednej wierzytelności przypisanej do sprawy z iteracji 4. Powiązania wierzytelności ze sprawą (role: wierzyciel, wierzyciel pierwotny, cesjonariusz, poręczyciel) opisuje osobna tabela [`dbo.wierzytelnosc_rola`](#dbowierzytelnosc_rola) — również migrowana w tej iteracji.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wi_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">Klucz główny wierzytelności w stagingu (BIGINT — 8-bajtowy, dopuszcza identyfikatory źródłowe spoza zakresu INT)</span>
  </li>
  <li>
    <span class="param-name fk required">wi_sp_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">FK do sprawy (BIGINT — kaskada typu z <code>sprawa.sp_id</code>)</span>
  </li>
  <li>
    <span class="param-name fk required">wi_uko_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do <code>dbo.umowa_kontrahent</code> — nullable w stagingu, ale wymagane do migracji. Rekordy z <code>wi_uko_id IS NULL</code> są blokowane przez walidację <a href="../../przygotowanie-danych/walidacje/">TECH_04</a> (BLOCKING) i nie przejdą INNER JOIN w skrypcie iteracji 6.</span>
  </li>
  <li>
    <span class="param-name required">wi_numer</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer wierzytelności nadany w systemie źródłowym</span>
  </li>
  <li>
    <span class="param-name">wi_tytul</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Tytuł wierzytelności</span>
  </li>
  <li>
    <span class="param-name">wi_data_umowy</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zawarcia umowy źródłowej wierzytelności</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

### dbo.wierzytelnosc_rola

<details markdown="1">
<summary><code>dbo.wierzytelnosc_rola</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> powiązanie wierzytelności ze sprawą</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.wierzytelnosc_rola</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 wierzytelność → N ról — wierzyciel, wierzyciel pierwotny, cesjonariusz)</span>
</div>

Staging `wierzytelnosc_rola` zawiera wiersze ról (wierzyciel, wierzyciel pierwotny, cesjonariusz, poręczyciel) przypisujących wierzytelność do sprawy — jedna para (sprawa, wierzytelność) może mieć wiele wpisów roli w zależności od historii cesji. Każdy wiersz stagingu jest migrowany do produkcji; klucze obce są rozwiązywane przez tabele mapowania (`mapowanie.dodane_wierzytelnosci`, `mapowanie.dodane_sprawy`).

<ul class="param-list">
  <li>
    <span class="param-name pk required">wir_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">Klucz główny powiązania wierzytelności ze sprawą w stagingu (IDENTITY)</span>
  </li>
  <li>
    <span class="param-name fk required">wir_sp_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">FK do sprawy</span>
  </li>
  <li>
    <span class="param-name fk required">wir_wi_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">FK do wierzytelności</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `atrybut` (`att_atd_id = 2`) — atrybuty wierzytelności ładuj do wspólnej tabeli `dbo.atrybut`. Definicja: [tabele-generyczne.md#atrybut](tabele-generyczne.md#dboatrybut).

## Powiązania {#powiazania}

- Poprzednia iteracja: [Akcje i rezultaty](akcje.md)
- Następna iteracja: [Dokumenty](role-wierzytelnosci-i-dokumenty.md)
- Słowniki bazowe iteracja 1: [umowa_kontrahent](slowniki.md#dboumowa_kontrahent), [atrybut (struktura polimorficzna)](tabele-generyczne.md#dboatrybut)
- Walidacje referencyjne (wierzytelnosc): [REF_06 (umowa kontrahenta opcjonalna)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (wierzytelnosc_rola): [REF_04 (wierzytelność istnieje)](../przygotowanie-danych/walidacje.md), [REF_05 (sprawa istnieje)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (atrybut polimorficzny): [REF_17 (att_atd_id=2 → wierzytelnosc)](../przygotowanie-danych/walidacje.md)
- Walidacje formatu: [FMT_12 (data umowy nie może być w przyszłości)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe: [BIZ_04 (wierzytelność bez dokumentu), BIZ_14 (bez księgowań), BIZ_19 (data umowy z przyszłości)](../przygotowanie-danych/walidacje.md)
