---
title: "Migracja ⬝ Dane kontaktowe (adres, mail, telefon)"
tags:
  - brq211
---

# Dane kontaktowe (adres, mail, telefon)

Iteracja 3 obejmuje dane kontaktowe dłużników — adresy pocztowe, adresy e-mail oraz numery telefonów. Dane z tej iteracji można załadować dopiero po Iteracji 2, ponieważ każdy kontakt musi być powiązany z istniejącym dłużnikiem. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

!!! warning "Dane osobowe"
    Tabele w tej iteracji zawierają dane osobowe (PII) — adresy pocztowe, adresy e-mail oraz numery telefonów. Kolumny zawierające dane osobowe są oznaczone znacznikiem PII.

<div class="iter-meta">
  <span>Iteracja: 3</span>
  <span>Zależności: Iteracja 2</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#str_08">STR_08</a>, <a href="../przygotowanie-danych/walidacje.md#str_09">STR_09</a></span>
  <span>Zakres: dane kontaktowe dłużników</span>
</div>

## Diagram ER

Diagram pokazuje tabele kontaktowe iteracja 3 oraz ich powiązanie z `dluznik` (iteracja 2). Pełna struktura dłużnika (`dluznik_typ`, `mapowanie_plec`, atrybuty) — [Dłużnicy § Diagram ER](dluznicy.md#diagram-er).

```mermaid
erDiagram
    dluznik {
        int     dl_id    PK
    }

    adres_typ {
        int     at_id    PK
        varchar at_nazwa
    }

    telefon_typ {
        int     tt_id    PK
        varchar tt_nazwa
    }

    adres {
        int     ad_id          PK
        int     ad_dl_id       FK
        int     ad_at_id       FK
        varchar ad_ulica
        varchar ad_nr_domu
        varchar ad_nr_lokalu
        varchar ad_kod
        varchar ad_miejscowosc
        varchar ad_poczta
        varchar ad_panstwo
        varchar ad_uwagi
    }

    mail {
        int     ma_id            PK
        int     ma_dl_id         FK
        varchar ma_adres_mailowy
    }

    telefon {
        int     tn_id    PK
        int     tn_dl_id FK
        int     tn_tt_id FK
        varchar tn_numer
    }

    adres       }o--||  dluznik     : "ad_dl_id"
    adres       }o--||  adres_typ   : "ad_at_id"
    mail        }o--||  dluznik     : "ma_dl_id"
    telefon     }o--||  dluznik     : "tn_dl_id"
    telefon     }o--||  telefon_typ : "tn_tt_id"
```

## Tabele

### dbo.adres

<details markdown="1">
<summary><code>dbo.adres</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> adresy dłużnika (zameldowania, korespondencyjny, pobytu)</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.adres</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak</span>
</div>

Adresy przypisane do dłużnika, z typem określonym przez `ad_at_id` (FK do słownika `adres_typ`). Okres obowiązywania adresu opisują kolumny `ad_data_od`/`ad_data_do` — `NULL` w `ad_data_do` oznacza adres aktywny.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ad_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny adresu w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">ad_dl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dłużnika (dluznik.dl_id)</span>
  </li>
  <li>
    <span class="param-name fk required">ad_at_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów adresów (adres_typ.at_id)</span>
  </li>
  <li>
    <span class="param-name pii">ad_ulica</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Nazwa ulicy</span>
  </li>
  <li>
    <span class="param-name pii">ad_nr_domu</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer domu</span>
  </li>
  <li>
    <span class="param-name pii">ad_nr_lokalu</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer lokalu</span>
  </li>
  <li>
    <span class="param-name pii">ad_kod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kod pocztowy w formacie XX-XXX</span>
  </li>
  <li>
    <span class="param-name pii">ad_miejscowosc</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Miejscowość</span>
  </li>
  <li>
    <span class="param-name">ad_poczta</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Poczta</span>
  </li>
  <li>
    <span class="param-name">ad_panstwo</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kraj</span>
  </li>
  <li>
    <span class="param-name">ad_uwagi</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Uwagi dotyczące adresu</span>
  </li>
  <li>
    <span class="param-name">ad_data_od</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data początku obowiązywania adresu</span>
  </li>
  <li>
    <span class="param-name">ad_data_do</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data końca obowiązywania adresu - NULL oznacza adres aktywny</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `wlasciwosc` + `wlasciwosc_adres` (`wdzi_id = 2`) — właściwości adresu. Definicja: [tabele-generyczne.md#dbowlasciwosc](tabele-generyczne.md#dbowlasciwosc).

### dbo.mail

<details markdown="1">
<summary><code>dbo.mail</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> adresy e-mail dłużnika</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.mail</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak</span>
</div>

Adresy e-mail przypisane do dłużnika. Okres obowiązywania opisują kolumny `ma_data_od`/`ma_data_do` — `NULL` w `ma_data_do` oznacza adres aktywny. Treść adresu e-mail znajduje się w kolumnie `ma_adres_mailowy`.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ma_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny adresu e-mail w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">ma_dl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dłużnika (dluznik.dl_id)</span>
  </li>
  <li>
    <span class="param-name required pii">ma_adres_mailowy</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Adres e-mail dłużnika</span>
  </li>
  <li>
    <span class="param-name">ma_data_od</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data początku obowiązywania adresu e-mail</span>
  </li>
  <li>
    <span class="param-name">ma_data_do</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data końca obowiązywania adresu e-mail - NULL oznacza adres aktywny</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `wlasciwosc` + `wlasciwosc_email` (`wdzi_id = 3`) — właściwości adresu e-mail. Definicja: [tabele-generyczne.md#dbowlasciwosc](tabele-generyczne.md#dbowlasciwosc).

### dbo.telefon

<details markdown="1">
<summary><code>dbo.telefon</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> numery telefonów dłużnika</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.telefon</code></span>
  <span>Kształt mapowania: przekształcenie</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak</span>
</div>

Numery telefonów przypisane do dłużnika, z typem określonym przez `tn_tt_id` (FK do słownika `telefon_typ`). Okres obowiązywania opisują kolumny `tn_data_od`/`tn_data_do` — `NULL` w `tn_data_do` oznacza numer aktywny.

<ul class="param-list">
  <li>
    <span class="param-name pk required">tn_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny numeru telefonu w stagingu</span>
  </li>
  <li>
    <span class="param-name fk required">tn_dl_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dłużnika (dluznik.dl_id)</span>
  </li>
  <li>
    <span class="param-name required pii">tn_numer</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer telefonu</span>
  </li>
  <li>
    <span class="param-name fk required">tn_tt_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów telefonów (telefon_typ.tt_id)</span>
  </li>
  <li>
    <span class="param-name">tn_data_od</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data początku obowiązywania numeru telefonu</span>
  </li>
  <li>
    <span class="param-name">tn_data_do</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Data końca obowiązywania numeru telefonu - NULL oznacza numer aktywny</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać</span>
  </li>
</ul>

</details>

- `wlasciwosc` + `wlasciwosc_telefon` (`wdzi_id = 1`) — właściwości telefonu. Definicja: [tabele-generyczne.md#dbowlasciwosc](tabele-generyczne.md#dbowlasciwosc).

## Powiązania {#powiazania}

- Poprzednia iteracja: [Dłużnicy i atrybuty dłużników](dluznicy.md)
- Następna iteracja: [Sprawy i role](sprawy.md)
- Walidacje referencyjne (adres): [REF_09, REF_10](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (mail): [REF_13](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (telefon): [REF_11, REF_12](../przygotowanie-danych/walidacje.md)
- Walidacje formatu: [FMT_04 (kod pocztowy), FMT_05 (e-mail), FMT_06, FMT_07 (telefon)](../przygotowanie-danych/walidacje.md)
- Walidacje integralności strukturalnej: [STR_08 (limit telefonów)](../przygotowanie-danych/walidacje.md#str_08), [STR_09 (limit adresów)](../przygotowanie-danych/walidacje.md#str_09)
