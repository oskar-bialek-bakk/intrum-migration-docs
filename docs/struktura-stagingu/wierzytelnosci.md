---
title: "Migracja ⬝ Wierzytelności"
tags:
  - brq211
---

# Wierzytelności

Iteracja 6 obejmuje wierzytelności — umowy/zobowiązania dłużników wraz z atrybutami wierzytelności. Dane z tej iteracji można załadować dopiero po Iteracji 4, ponieważ każda wierzytelność jest powiązana ze sprawą. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 6</span>
  <span>Zależności: Iteracja 4</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#biz_04">BIZ_04</a>, <a href="../przygotowanie-danych/walidacje.md#biz_14">BIZ_14</a>, <a href="../przygotowanie-danych/walidacje.md#biz_19">BIZ_19</a></span>
  <span>Zakres: wierzytelności i ich atrybuty</span>
</div>

## Diagram ER

Diagram pokazuje tabelę iteracji 6 (`wierzytelnosc`) oraz powiązanie ze `sprawa` (iteracja 4) i `umowa_kontrahent` (iteracja 1). Polimorficzny stos `atrybut` opisany jest w [Tabele generyczne](tabele-generyczne.md#dboatrybut).

```mermaid
erDiagram
    sprawa {
        int     sp_id    PK
    }

    umowa_kontrahent {
        int     uko_id    PK
    }

    wierzytelnosc {
        int     wi_id           PK
        int     wi_sp_id        FK
        int     wi_uko_id       FK
        varchar wi_numer
        varchar wi_tytul
        date    wi_data_umowy
    }

    wierzytelnosc  }o--||  sprawa            : "wi_sp_id"
    wierzytelnosc  }o--o|  umowa_kontrahent  : "wi_uko_id"
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

Nagłówek wierzytelności — roszczenie finansowe przypisane do sprawy. Jeden wiersz staging odpowiada jednej wierzytelności przypisanej do sprawy z iteracji 4; rola wierzyciela domyślnego jest materializowana automatycznie po stronie prod na podstawie nagłówka — nie wymaga osobnego wiersza w stagingu. Dodatkowe role (poręczyciel, cesjonariusz) są tematem iteracji 7.

<ul class="param-list">
  <li>
    <span class="param-name pk required">wi_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny wierzytelności w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">wi_sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do sprawy</span>
  </li>
  <li>
    <span class="param-name fk required">wi_uko_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do <code>dbo.umowa_kontrahent</code> — nullable w stagingu, ale wymagane do migracji. Rekordy z <code>wi_uko_id IS NULL</code> są blokowane przez walidację <a href="../przygotowanie-danych/walidacje.md">TECH_04</a> (BLOCKING) i nie przejdą INNER JOIN w skrypcie iteracji 6.</span>
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

- `atrybut` (`att_atd_id = 2`) — atrybuty wierzytelności ładuj do wspólnej tabeli `dbo.atrybut`. Definicja: [tabele-generyczne.md#atrybut](tabele-generyczne.md#dboatrybut).

## Powiązania {#powiazania}

- Poprzednia iteracja: [Akcje i rezultaty](akcje.md)
- Następna iteracja: [Role wierzytelności i dokumenty](role-wierzytelnosci-i-dokumenty.md)
- Słowniki bazowe iteracja 1: [umowa_kontrahent](slowniki.md#dboumowa_kontrahent), [atrybut (struktura polimorficzna)](tabele-generyczne.md#dboatrybut)
- Walidacje referencyjne (wierzytelnosc): [REF_06 (umowa kontrahenta opcjonalna)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (atrybut polimorficzny): [REF_17 (att_atd_id=2 → wierzytelnosc)](../przygotowanie-danych/walidacje.md)
- Walidacje formatu: [FMT_12 (data umowy nie może być w przyszłości)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe: [BIZ_04 (wierzytelność bez dokumentu), BIZ_14 (bez księgowań), BIZ_19 (data umowy z przyszłości)](../przygotowanie-danych/walidacje.md)
