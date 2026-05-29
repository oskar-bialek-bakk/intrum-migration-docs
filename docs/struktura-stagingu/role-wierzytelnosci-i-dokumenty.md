---
title: "Migracja ⬝ Dokumenty"
tags:
  - brq211
---

# Dokumenty

Iteracja 7 obejmuje dokumenty powiązane z wierzytelnościami (faktury, noty, wezwania) oraz ich atrybuty. Dane z tej iteracji można załadować dopiero po Iteracji 6, ponieważ każdy dokument odnosi się do konkretnej wierzytelności. Role wierzytelności (powiązania wierzytelność ↔ sprawa) są migrowane wcześniej, w [Iteracji 6](wierzytelnosci.md#dbowierzytelnosc_rola). Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 7</span>
  <span>Zależności: Iteracja 6</span>
  <span>Walidacje: <a href="../../przygotowanie-danych/walidacje/#str_11">STR_11</a>, <a href="../../przygotowanie-danych/walidacje/#biz_16">BIZ_16</a></span>
  <span>Zakres: dokumenty i ich atrybuty</span>
</div>

## Diagram ER

Diagram pokazuje tabelę iteracji 7 (`dokument`) oraz minimalne stuby `wierzytelnosc` (iteracja 6) i `dokument_typ` (iteracja 1) jako punkty zaczepienia FK. Pełny słownik wierzytelności — [Wierzytelności § Diagram ER](wierzytelnosci.md#diagram-er); słownik typów dokumentów — [Słowniki § dbo.dokument_typ](slowniki.md#dbodokument_typ). Polimorficzny stos `atrybut` opisany jest w [Tabele generyczne](tabele-generyczne.md#dboatrybut); w iteracji 7 wiersze `att_atd_id = 1` dotyczą atrybutów dokumentu.

```mermaid
erDiagram
    wierzytelnosc {
        bigint  wi_id    PK
    }

    dokument_typ {
        int     dot_id   PK
    }

    dokument {
        bigint  do_id                   PK
        bigint  do_wi_id                FK
        int     do_dot_id               FK
        varchar do_numer_dokumentu
        varchar do_tytul_dokumentu
        date    do_data_wystawienia
    }

    dokument            }o--||  wierzytelnosc  : "do_wi_id"
    dokument            }o--||  dokument_typ   : "do_dot_id"
```

## Tabele

### dbo.dokument

- `atrybut` (`att_atd_id = 1`) — atrybuty dokumentu ładuj do wspólnej tabeli `dbo.atrybut`. Definicja: [tabele-generyczne.md#atrybut](tabele-generyczne.md#dboatrybut).

<details markdown="1">
<summary><code>dbo.dokument</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> nagłówki dokumentów finansowych (faktury, noty, wezwania)</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dokument</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 wierzytelność → N dokumentów)</span>
</div>

Nagłówek dokumentu finansowego powiązanego z wierzytelnością — faktury, noty księgowe, wezwania do zapłaty, potwierdzenia salda. Każdy dokument wiąże się z dokładnie jedną wierzytelnością z iteracji 6 i jednym typem dokumentu ze słowników iteracji 1.

<ul class="param-list">
  <li>
    <span class="param-name pk required">do_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">Klucz główny dokumentu w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">do_wi_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">FK do wierzytelności</span>
  </li>
  <li>
    <span class="param-name required">do_numer_dokumentu</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer dokumentu nadany w systemie źródłowym</span>
  </li>
  <li>
    <span class="param-name">do_data_wystawienia</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data wystawienia dokumentu</span>
  </li>
  <li>
    <span class="param-name fk required">do_dot_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów dokumentów</span>
  </li>
  <li>
    <span class="param-name">do_tytul_dokumentu</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Tytuł dokumentu</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Wierzytelności](wierzytelnosci.md)
- Następna iteracja: [Dane finansowe](finanse.md)
- Słowniki bazowe iteracja 1: [dokument_typ](slowniki.md#dbodokument_typ), [atrybut (struktura polimorficzna)](tabele-generyczne.md#dboatrybut)
- Walidacje referencyjne (dokument): [REF_07 (wierzytelność istnieje)](../przygotowanie-danych/walidacje.md), [REF_08 (dokument_typ istnieje)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (atrybut polimorficzny): [REF_15 (atrybut_typ istnieje)](../przygotowanie-danych/walidacje.md), [REF_16 (att_atd_id=1 → dokument)](../przygotowanie-danych/walidacje.md)
- Walidacje techniczne: [TECH_05 (do_wi_id wymagane)](../przygotowanie-danych/walidacje.md), [TECH_07 (at_ob_id wymagane)](../przygotowanie-danych/walidacje.md)
- Walidacje integralności strukturalnej: [STR_11 (nadmierna liczba dokumentów per wierzytelność)](../przygotowanie-danych/walidacje.md#str_11)
- Walidacje biznesowe: [BIZ_16 (dokument bez daty wymagalności — BLOKUJĄCE)](../przygotowanie-danych/walidacje.md#biz_16)
