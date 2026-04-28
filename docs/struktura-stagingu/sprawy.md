---
title: "Migracja ⬝ Sprawy i role"
tags:
  - brq211
---

# Sprawy i role

Iteracja 4 obejmuje sprawy — kontekst zadłużenia klienta, wraz z rolami sprawy (kto bierze udział w sprawie — dłużnik główny, poręczyciel, pełnomocnik) oraz atrybutami sprawy. Dane z tej iteracji można załadować dopiero po Iteracji 2, ponieważ każda rola sprawy wskazuje na istniejącego dłużnika. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 4</span>
  <span>Zależności: Iteracja 2</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#str_01">STR_01</a>, <a href="../przygotowanie-danych/walidacje.md#str_02">STR_02</a>, <a href="../przygotowanie-danych/walidacje.md#str_03">STR_03</a>, <a href="../przygotowanie-danych/walidacje.md#biz_07">BIZ_07</a>, <a href="../przygotowanie-danych/walidacje.md#str_10">STR_10</a></span>
  <span>Zakres: sprawy, role spraw i atrybuty</span>
</div>

## Diagram ER

Diagram pokazuje tabele iteracji 4 (sprawa + sprawa_rola wraz z ich słownikami) oraz powiązanie z `dluznik` (iteracja 2). Polimorficzny stos `atrybut` opisany jest w [Tabele generyczne](tabele-generyczne.md#dboatrybut).

```mermaid
erDiagram
    dluznik {
        int     dl_id    PK
    }

    sprawa_typ {
        int     spt_id    PK
        varchar spt_nazwa
    }

    sprawa_etap {
        int     spe_id     PK
        varchar spe_nazwa
        int     spe_spt_id FK
    }

    sprawa_rola_typ {
        int     sprt_id    PK
        varchar sprt_nazwa
    }

    sprawa {
        int     sp_id             PK
        int     sp_spe_id         FK
        int     sp_spt_id         FK
        varchar sp_numer_sprawy
        varchar sp_pracownik          "→ GE_USER.US_LOGIN w prod"
        varchar sp_numer_rachunku
    }

    sprawa_rola {
        int     spr_id      PK
        int     spr_sp_id   FK
        int     spr_dl_id   FK
        int     spr_sprt_id FK
    }

    sprawa       }o--||  sprawa_etap     : "sp_spe_id"
    sprawa       }o--||  sprawa_typ      : "sp_spt_id"
    sprawa_etap  }o--||  sprawa_typ      : "spe_spt_id"
    sprawa_rola  }o--||  sprawa          : "spr_sp_id"
    sprawa_rola  }o--||  dluznik         : "spr_dl_id"
    sprawa_rola  }o--||  sprawa_rola_typ : "spr_sprt_id"
```

## Tabele

### dbo.sprawa

<details markdown="1">
<summary><code>dbo.sprawa</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> rekord sprawy (rozgałęzienie: `rachunek_bankowy` + `sprawa` + `operator`)</summary>

<div class="dict-meta">
  <span>Tabele prod: <code>dm_data_web.rachunek_bankowy</code>, <code>dm_data_web.sprawa</code>, <code>dm_data_web.operator</code></span>
  <span>Kształt mapowania: rozbicie</span>
  <span>Obowiązkowa: tak</span>
  <span>Multi-row: tak (1 dłużnik → N spraw)</span>
</div>

Rekord sprawy — jednostka pracy systemu DEBT Manager, powiązana z dłużnikiem przez `sprawa_rola`. Jeden wiersz staging rozchodzi się do trzech tabel prod: `rachunek_bankowy` (distinct po numerze rachunku), `sprawa` (rekord główny) oraz `operator` (gdy `sp_pracownik` jest wypełniony). Kolumna `sp_numer_rachunku` jest wymagana. Opcjonalne okno obsługi: `sp_data_obslugi_od`/`sp_data_obslugi_do`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny sprawy w stagingu</span>
  </li>
  <li>
    <span class="param-name required">sp_numer_sprawy</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer sprawy nadany w systemie źródłowym</span>
  </li>
  <li>
    <span class="param-name required">sp_numer_rachunku</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer rachunku bankowego sprawy - migrowany do tabeli rachunek_bankowy</span>
  </li>
  <li>
    <span class="param-name">sp_pracownik</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Login pracownika przypisanego do sprawy, opcjonalny</span>
  </li>
  <li>
    <span class="param-name fk required">sp_spe_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do etapu sprawy</span>
  </li>
  <li>
    <span class="param-name fk required">sp_spt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów spraw</span>
  </li>
  <li>
    <span class="param-name">sp_import_info</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Identyfikator paczki importu, z której pochodzi rekord</span>
  </li>
  <li>
    <span class="param-name">sp_data_obslugi_od</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data obsługi od (start date)</span>
  </li>
  <li>
    <span class="param-name">sp_data_obslugi_do</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data obsługi do (end date)</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `atrybut` (`att_atd_id = 4`) — atrybuty sprawy ładuj do wspólnej tabeli `dbo.atrybut`. Definicja: [tabele-generyczne.md#atrybut](tabele-generyczne.md#dboatrybut).

### dbo.sprawa_rola

<details markdown="1">
<summary><code>dbo.sprawa_rola</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> tabela łącząca sprawę z dłużnikiem (rola dłużnika na sprawie)</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.sprawa_rola</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: tak (STR_01: każda sprawa musi mieć ≥1 dłużnika)</span>
  <span>Multi-row: tak (1 sprawa → N dłużników w różnych rolach)</span>
</div>

Tabela łącząca (junction) — każdy wiersz wiąże sprawę z dłużnikiem wraz z rolami w jakiej dłużnik (lub powiązana ze sprawą osoba) występuje w sprawie (np. dłużnik główny, poręczyciel, pełnomocnik). Jedna sprawa może mieć wielu dłużników w różnych rolach. Tabela jest materializacją wymogu STR_01 (sprawa bez dłużnika jest nieprawidłowa). Opcjonalne okno obowiązywania roli: `spr_data_od`/`spr_data_do` (puste = rola otwarta bezterminowo).

<ul class="param-list">
  <li>
    <span class="param-name pk required">spr_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny powiązania sprawy z dłużnikiem</span>
  </li>
  <li>
    <span class="param-name fk required">spr_sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do sprawy</span>
  </li>
  <li>
    <span class="param-name fk required">spr_dl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dłużnika</span>
  </li>
  <li>
    <span class="param-name fk required">spr_sprt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika ról w sprawie</span>
  </li>
  <li>
    <span class="param-name">spr_data_od</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data początku obowiązywania roli dłużnika w sprawie. Pole opcjonalne - jeśli puste, podstawiana jest data wczytania wiersza do staging</span>
  </li>
  <li>
    <span class="param-name">spr_data_do</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zakończenia obowiązywania roli dłużnika w sprawie. Pole opcjonalne - jeśli puste, podstawiana jest data sentinel 9999-12-31 (rola otwarta bezterminowo)</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Dane kontaktowe (adres, mail, telefon)](kontakty.md)
- Następna iteracja: [Akcje i rezultaty](akcje.md)
- Walidacje referencyjne (sprawa): [REF_24 (typ sprawy), REF_31 (etap sprawy), REF_25 (etap-typ)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (sprawa_rola): [REF_01 (dłużnik), REF_02 (sprawa), REF_03 (typ roli)](../przygotowanie-danych/walidacje.md)
- Walidacje techniczne: [TECH_03 (sp_numer_rachunku wymagane)](../przygotowanie-danych/walidacje.md)
- Walidacje integralności strukturalnej: [STR_01 (sprawa musi mieć ≥1 dłużnika)](../przygotowanie-danych/walidacje.md#str_01)
