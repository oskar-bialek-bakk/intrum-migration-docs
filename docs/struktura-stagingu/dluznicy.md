---
title: "Migracja ⬝ Dłużnicy i atrybuty dłużników"
tags:
  - brq211
---

# Dłużnicy i atrybuty dłużników

Iteracja 2 obejmuje dane głównych dłużników — osoby fizyczne i osoby prawne wraz z atrybutami identyfikującymi. Dane z tej iteracji można załadować dopiero po Iteracji 1, ponieważ każdy dłużnik referuje typy ze słowników (typ dłużnika, dziedziny i typy atrybutów). Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

!!! warning "Dane osobowe"
    Tabele w tej iteracji zawierają dane osobowe (PII) — imię, nazwisko, PESEL, NIP, REGON, numer dowodu osobistego, numer paszportu, nazwa firmy. Kolumny zawierające dane osobowe są oznaczone znacznikiem PII.

<div class="iter-meta">
  <span>Iteracja: 2</span>
  <span>Zależności: Iteracja 1</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#biz_03">BIZ_03</a>, <a href="../przygotowanie-danych/walidacje.md#biz_13">BIZ_13</a></span>
  <span>Zakres: dłużnicy główni i ich atrybuty</span>
</div>

## Diagram ER

!!! info "mapowanie.plec"
    W diagramie węzeł `mapowanie.plec` reprezentowany jest jako `mapowanie_plec` (podkreślenie zamiast kropki) — składnia mermaid `erDiagram` nie dopuszcza kropek w nazwach encji.

```mermaid
erDiagram
    dluznik_typ {
        int     dt_id    PK
        varchar dt_nazwa
    }

    mapowanie_plec {
        varchar pm_kod    PK  "'K'=kobieta, 'M'=mezczyzna, 'B'=brak"
        int     pm_pl_id      "prod plec.pl_id"
        varchar pm_nazwa
    }

    dluznik {
        int     dl_id         PK
        int     dl_dt_id      FK
        varchar dl_plec       FK  "→ mapowanie_plec"
        varchar dl_imie
        varchar dl_nazwisko
        varchar dl_pesel
        varchar dl_nip
        varchar dl_regon
        varchar dl_dowod
        varchar dl_paszport
        varchar dl_firma
        varchar dl_uwagi
    }

    atrybut_dziedzina {
        int     atd_id    PK   "1=dok, 2=wi, 3=dl"
        varchar atd_nazwa
    }

    atrybut_rodzaj {
        int     atr_id    PK
        varchar atr_nazwa
    }

    atrybut_typ {
        int     att_id     PK
        varchar att_nazwa
        int     att_atd_id FK
        int     att_atr_id FK
    }

    atrybut {
        int     at_id     PK
        int     at_ob_id       "polymorficzny: dl_id / sp_id / wi_id / do_id"
        int     at_att_id FK   "dziedzina i rodzaj dziedziczone z atrybut_typ"
        varchar at_wartosc
    }

    dluznik     }o--||  dluznik_typ       : "dl_dt_id"
    dluznik     }o--o|  mapowanie_plec    : "dl_plec"
    atrybut     }o--||  atrybut_typ       : "at_att_id"
    atrybut_typ }o--||  atrybut_dziedzina : "att_atd_id"
    atrybut_typ }o--||  atrybut_rodzaj    : "att_atr_id"
```

## Tabele

### dbo.dluznik

<details markdown="1">
<summary><code>dbo.dluznik</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> rekord główny dłużnika (osoba fizyczna lub podmiot gospodarczy)</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.dluznik</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak</span>
</div>

Główny rekord dłużnika — obejmuje zarówno osoby fizyczne (`dl_dt_id` ∈ {1,2}), jak i podmioty gospodarcze (`dl_dt_id` ∈ {3,4}). Wypełniane pola zależą od typu dłużnika (`dl_dt_id`): dla osób fizycznych obowiązkowe są imię, nazwisko i PESEL; dla podmiotów gospodarczych — nazwa firmy i NIP.

<ul class="param-list">
  <li>
    <span class="param-name pk required">dl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny dłużnika w stagingu</span>
  </li>
  <li>
    <span class="param-name">dl_plec</span>
    <span class="param-type">VARCHAR(1)</span>
    <span class="param-desc">Kod płci dłużnika - wartość tekstowa mapowana na prod przez słownik kodów płci</span>
  </li>
  <li>
    <span class="param-name required pii">dl_imie</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Imię dłużnika - wymagane dla wartości dl_dt_id równych (1,2)</span>
  </li>
  <li>
    <span class="param-name required pii">dl_nazwisko</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Nazwisko dłużnika - wymagane dla wartości dl_dt_id równych (1,2)</span>
  </li>
  <li>
    <span class="param-name pii">dl_dowod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer dowodu osobistego dłużnika</span>
  </li>
  <li>
    <span class="param-name pii">dl_paszport</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer paszportu dłużnika</span>
  </li>
  <li>
    <span class="param-name">dl_dluznik</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Wewnętrzny numer ewidencyjny dłużnika</span>
  </li>
  <li>
    <span class="param-name pii">dl_pesel</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer PESEL dłużnika - wymagany dla wartości dl_dt_id równych (1,2)</span>
  </li>
  <li>
    <span class="param-name fk required">dl_dt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów dłużnika - determinuje wymagane pola: (1,2) osoba fizyczna, (3,4) podmiot gospodarczy</span>
  </li>
  <li>
    <span class="param-name">dl_uwagi</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Uwagi dotyczące dłużnika</span>
  </li>
  <li>
    <span class="param-name pii">dl_firma</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Nazwa firmy dłużnika - wymagana dla wartości dl_dt_id równych (3,4)</span>
  </li>
  <li>
    <span class="param-name">dl_import_info</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator paczki importu, z której pochodzi rekord</span>
  </li>
  <li>
    <span class="param-name pii">dl_nip</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer NIP dłużnika - wymagany dla wartości dl_dt_id równych (3,4)</span>
  </li>
  <li>
    <span class="param-name pii">dl_regon</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer REGON dłużnika</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `atrybut` (`att_atd_id = 3`) — atrybuty dłużnika ładuj do wspólnej tabeli `dbo.atrybut`. Definicja: [tabele-generyczne.md#atrybut](tabele-generyczne.md#dboatrybut).
- `wlasciwosc` + `wlasciwosc_dluznik` (`wdzi_id = 4`) — właściwości dłużnika. Definicja: [tabele-generyczne.md#dbowlasciwosc](tabele-generyczne.md#dbowlasciwosc).

<details markdown="1">
<summary><code>mapowanie.plec</code> — słownik kodu płci (K/M/B) dla FK do prod plec</summary>

<div class="dict-meta">
  <span>Kształt mapowania: słownik pomocniczy (nie migruje do prod)</span>
  <span>Obowiązkowa: tak (dla dłużników z niepustym `dl_plec`)</span>
  <span>Multi-row: tak</span>
</div>

Tabela pomocnicza — nie podlega migracji do prod. Zawiera słownik mapowania jednoliterowych kodów płci (`'K'`, `'M'`, `'B'`) występujących w kolumnie `dbo.dluznik.dl_plec` na identyfikatory produkcyjnej tabeli `plec` (`pm_pl_id`). Wiersz musi być wypełniony przed uruchomieniem Iteracji 2; brak odpowiedniego mapowania skutkuje pustą płcią dla dłużników z niepustym `dl_plec`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">pm_kod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Jednoliterowy kod płci</span>
  </li>
  <li>
    <span class="param-name fk required">pm_pl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do tabeli plec</span>
  </li>
  <li>
    <span class="param-name">pm_nazwa</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opis przekazanego kodu</span>
  </li>
</ul>

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Tabele słownikowe](slowniki.md)
- Następna iteracja: [Dane kontaktowe (adres, mail, telefon)](kontakty.md)
- Walidacje referencyjne (dluznik): [REF_26, REF_30](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (atrybut): [REF_15, REF_16, REF_17, REF_18, REF_19, REF_28](../przygotowanie-danych/walidacje.md)
- Walidacje formatu (dluznik): [FMT_01 (PESEL), FMT_02 (NIP), FMT_03 (REGON)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe (dluznik): [BIZ_13 (brak identyfikatora)](../przygotowanie-danych/walidacje.md)
