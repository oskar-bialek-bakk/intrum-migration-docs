---
title: "Migracja ⬝ Harmonogram"
tags:
  - brq211
---

# Harmonogram

Iteracja 9 obejmuje harmonogramy spłat — raty powiązane z wierzytelnościami, z rozbiciem na część kapitałową i odsetkową. Dane z tej iteracji można załadować dopiero po Iteracji 6, ponieważ każda rata harmonogramu musi być powiązana z istniejącą wierzytelnością. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 9</span>
  <span>Zależności: Iteracja 6</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#str_07">STR_07</a></span>
  <span>Zakres: harmonogramy spłat i przypomnienia</span>
</div>

## Diagram ER

Diagram pokazuje tabele docelowe iteracji 9 (`dokument`, `ksiegowanie`, `ksiegowanie_dekret`) oraz minimalne stuby `dokument_typ`, `ksiegowanie_typ`, `ksiegowanie_konto` (iteracja 1) i `wierzytelnosc` (iteracja 6) jako punkty zaczepienia FK. Słownik typów dokumentów — [Słowniki § dbo.dokument_typ](slowniki.md#dbodokument_typ); słownik typów księgowań — [Słowniki § dbo.ksiegowanie_typ](slowniki.md#dboksiegowanie_typ); słownik kont księgowych — [Słowniki § dbo.ksiegowanie_konto](slowniki.md#dboksiegowanie_konto); wierzytelność — [Wierzytelności § dbo.wierzytelnosc](wierzytelnosci.md#dbowierzytelnosc).

```mermaid
erDiagram
    dokument_typ {
        int     dot_id    PK
    }

    ksiegowanie_typ {
        int     kst_id    PK
    }

    ksiegowanie_konto {
        int     ksk_id    PK
    }

    wierzytelnosc {
        int     wi_id     PK
    }

    dokument {
        int      do_id                 PK
        int      do_wi_id              FK
        int      do_dot_id             FK
        date     do_data_wystawienia
        varchar  do_numer_dokumentu
        varchar  do_tytul_dokumentu
    }

    ksiegowanie {
        int      ks_id                      PK
        date     ks_data_ksiegowania
        date     ks_data_operacji
        int      ks_kst_id                  FK
        bit      ks_pierwotne
    }

    ksiegowanie_dekret {
        int      ksd_id                   PK
        int      ksd_ks_id                FK
        int      ksd_ksk_id               FK
        int      ksd_do_id                FK
        date     ksd_data_wymagalnosci
    }

    dokument            }o--||  wierzytelnosc       : "do_wi_id"
    dokument            }o--||  dokument_typ        : "do_dot_id"
    ksiegowanie         }o--||  ksiegowanie_typ     : "ks_kst_id"
    ksiegowanie_dekret  }o--||  ksiegowanie         : "ksd_ks_id"
    ksiegowanie_dekret  }o--||  ksiegowanie_konto   : "ksd_ksk_id"
    ksiegowanie_dekret  }o--||  dokument            : "ksd_do_id"
```

## Tabele

### dbo.harmonogram

<details markdown="1">
<summary><code>dbo.harmonogram</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> raty harmonogramu spłat</summary>

<div class="dict-meta">
  <span>Tabele prod: <code>dm_data_web.dokument</code>, <code>dm_data_web.ksiegowanie</code>, <code>dm_data_web.ksiegowanie_dekret</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span></span>
  <span>Obowiązkowa: nie (harmonogram opcjonalny per wierzytelność)</span>
  <span>Multi-row: tak (1 rata → 1 dokument + 1 ksiegowanie + 1–3 dekrety)</span>
</div>

Rata harmonogramu spłat powiązana z wierzytelnością — data płatności, numer kolejny raty, łączna kwota wraz z rozbiciem na część kapitałową i odsetkową. Każdy wiersz staging `harmonogram` generuje trójkę rekordów prod: nagłówek `dokument`, nagłówek `ksiegowanie` oraz od jednego do trzech dekretów `ksiegowanie_dekret` bilansujących kwotę raty.

<ul class="param-list">
  <li>
    <span class="param-name pk required">hr_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny raty harmonogramu.</span>
  </li>
  <li>
    <span class="param-name fk required">hr_wi_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do wierzytelności (iteracja 6).</span>
  </li>
  <li>
    <span class="param-name required">hr_typ</span>
    <span class="param-type">VARCHAR(50)</span>
    <span class="param-desc">Typ harmonogramu (np. umowny, sądowy).</span>
  </li>
  <li>
    <span class="param-name required">hr_data_raty</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data płatności raty.</span>
  </li>
  <li>
    <span class="param-name required">hr_numer_raty</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Numer kolejny raty w harmonogramie.</span>
  </li>
  <li>
    <span class="param-name required">hr_kwota_raty</span>
    <span class="param-type">DECIMAL(18,2)</span>
    <span class="param-desc">Łączna kwota raty (suma kapitału + odsetek).</span>
  </li>
  <li>
    <span class="param-name required">hr_kwota_kapitalu</span>
    <span class="param-type">DECIMAL(18,2)</span>
    <span class="param-desc">Część kapitałowa raty.</span>
  </li>
  <li>
    <span class="param-name required">hr_kwota_odsetek</span>
    <span class="param-type">DECIMAL(18,2)</span>
    <span class="param-desc">Część odsetkowa raty.</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna — nie wypełniać.</span>
  </li>
</ul>

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Dane finansowe](finanse.md)
- Źródłowe wierzytelności: [Wierzytelności](wierzytelnosci.md)
- Słowniki bazowe iteracja 1: [dokument_typ](slowniki.md#dbodokument_typ), [ksiegowanie_typ](slowniki.md#dboksiegowanie_typ), [ksiegowanie_konto](slowniki.md#dboksiegowanie_konto)
- Walidacje integralności strukturalnej: [STR_07 (harmonogram bez wierzytelności, OSTRZEŻENIE)](../przygotowanie-danych/walidacje.md#str_07)
- Koniec migracji etap 1 — [Kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md)
