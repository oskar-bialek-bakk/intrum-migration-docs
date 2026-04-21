---
title: "Migracja ⬝ Dane finansowe"
tags:
  - brq211
---

# Dane finansowe

Iteracja 8 obejmuje księgowania i dekrety — kwoty obciążające/uznanie wierzytelności, rozbite na pozycje rodzajowe (kapitał, odsetki, koszty) zgodnie z zasadą podwójnego zapisu. Dane z tej iteracji można załadować dopiero po Iteracji 7, ponieważ każde księgowanie referuje dokument lub wierzytelność z wcześniejszych iteracji. Zobacz też: [walidacje](../przygotowanie-danych/walidacje.md), [kolejność ładowania](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

<div class="iter-meta">
  <span>Iteracja: 8</span>
  <span>Zależności: Iteracja 7</span>
  <span>Walidacje: <a href="../przygotowanie-danych/walidacje.md#biz_05">BIZ_05</a>, <a href="../przygotowanie-danych/walidacje.md#biz_06">BIZ_06</a>, <a href="../przygotowanie-danych/walidacje.md#biz_17">BIZ_17</a>, <a href="../przygotowanie-danych/walidacje.md#biz_18">BIZ_18</a></span>
  <span>Zakres: księgowania i dekrety</span>
</div>

## Diagram ER

Diagram pokazuje dwie encje finansowe iteracji 8 (`ksiegowanie`, `ksiegowanie_dekret`) oraz minimalne stuby `ksiegowanie_typ`, `ksiegowanie_konto`, `waluta` (iteracja 1) i `dokument` (iteracja 7) jako punkty zaczepienia FK. Słownik typów księgowań — [Słowniki § dbo.ksiegowanie_typ](slowniki.md#dboksiegowanie_typ); słownik kont księgowych — [Słowniki § dbo.ksiegowanie_konto](slowniki.md#dboksiegowanie_konto); słownik walut — [Słowniki § dbo.waluta](slowniki.md); dokumenty — [Role wierzytelności i dokumenty § dbo.dokument](role-wierzytelnosci-i-dokumenty.md#dbodokument). Staging `dbo.operacja` nie ma bezpośredniego odpowiednika w modelu prod — jego kwoty są rozbijane na pozycje rodzajowe (kapitał, odsetki, opłaty, prowizje) i zasilają równocześnie `ksiegowanie` oraz `ksiegowanie_dekret`, dlatego nie pojawia się jako osobna encja na diagramie. Kolumny staging niewykorzystywane przez iterację 8 (`ksd_ksksub_id`, większość kolumn opisowych `operacja`) są wymienione w param-list, ale pominięte na diagramie.

```mermaid
erDiagram
    ksiegowanie_typ {
        int     kst_id    PK
    }

    ksiegowanie_konto {
        int     ksk_id    PK
    }

    waluta {
        int     wa_id     PK
    }

    dokument {
        int     do_id     PK
    }

    ksiegowanie {
        int      ks_id                      PK
        date     ks_data_ksiegowania
        date     ks_data_operacji
        varchar  ks_uwagi
        int      ks_kst_id                  FK
        bit      ks_pierwotne
    }

    ksiegowanie_dekret {
        int      ksd_id                      PK
        int      ksd_ks_id                   FK
        int      ksd_ksk_id                  FK
        int      ksd_do_id                   FK
        int      ksd_wa_id                   FK
        date     ksd_data_wymagalnosci
        date     ksd_data_naliczania_odsetek
    }

    ksiegowanie         }o--||  ksiegowanie_typ    : "ks_kst_id"
    ksiegowanie_dekret  }o--||  ksiegowanie        : "ksd_ks_id"
    ksiegowanie_dekret  }o--||  ksiegowanie_konto  : "ksd_ksk_id"
    ksiegowanie_dekret  }o--||  dokument           : "ksd_do_id"
    ksiegowanie_dekret  }o--||  waluta             : "ksd_wa_id"
```

## Tabele

### dbo.ksiegowanie

<details markdown="1">
<summary><code>dbo.ksiegowanie</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> nagłówki księgowań finansowych</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 wierzytelność → N księgowań)</span>
</div>

Nagłówek księgowania finansowego — data operacji, data zaksięgowania, typ księgowania i powiązanie z wierzytelnością (pośrednio, przez dekrety). Księgowanie grupuje dekrety dwustronne (Winien/Ma) dla jednej operacji gospodarczej.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ks_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny księgowania.</span>
  </li>
  <li>
    <span class="param-name required">ks_data_ksiegowania</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zaksięgowania operacji w systemie źródłowym.</span>
  </li>
  <li>
    <span class="param-name required">ks_data_operacji</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data operacji finansowej (data zdarzenia gospodarczego).</span>
  </li>
  <li>
    <span class="param-name">ks_uwagi</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Uwagi księgowego dotyczące księgowania.</span>
  </li>
  <li>
    <span class="param-name fk required">ks_kst_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika typów księgowań.</span>
  </li>
  <li>
    <span class="param-name">ks_pierwotne</span>
    <span class="param-type">BIT</span>
    <span class="param-desc">Flaga: księgowanie pierwotne (1) vs. korygujące (0).</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna — obsługiwana triggerami insert; nie wypełniać.</span>
  </li>
</ul>

</details>

### dbo.ksiegowanie_dekret

<details markdown="1">
<summary><code>dbo.ksiegowanie_dekret</code> — <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span> dekrety księgowań — pozycje szczegółowe per dokument</summary>

<div class="dict-meta">
  <span>Tabela prod: <code>dm_data_web.ksiegowanie_dekret</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-przeksztalcenie">przekształcenie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 księgowanie → N dekretów — linie Winien/Ma)</span>
</div>

Dekret księgowania — pozycja szczegółowa nagłówka, przypisana do dokumentu lub (w przypadku dekretów wynikających z operacji finansowych) do nagłówka bez dokumentu. Staging `ksd_kwota` koduje stronę dekretu znakiem: wartości dodatnie oznaczają stronę Winien, ujemne — Ma. Dekrety zgrupowane jednym `ksd_ks_id` muszą bilansować się do zera zgodnie z zasadą podwójnego zapisu.

<ul class="param-list">
  <li>
    <span class="param-name pk required">ksd_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny dekretu w stagingu.</span>
  </li>
  <li>
    <span class="param-name fk required">ksd_ks_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do księgowania (nagłówka).</span>
  </li>
  <li>
    <span class="param-name fk">ksd_do_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dokumentu (opcjonalny — dekret może nie być powiązany z dokumentem).</span>
  </li>
  <li>
    <span class="param-name required">ksd_kwota</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota dekretu z zakodowaną stroną: dodatnia → Winien, ujemna → Ma.</span>
  </li>
  <li>
    <span class="param-name">ksd_data_naliczania_odsetek</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data, od której naliczane są odsetki dla dekretu.</span>
  </li>
  <li>
    <span class="param-name fk required">ksd_ksk_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika kont księgowych.</span>
  </li>
  <li>
    <span class="param-name">ksd_uwagi</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opcjonalne pole opisowe dekretu.</span>
  </li>
  <li>
    <span class="param-name fk">ksd_sp_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do sprawy (pomocnicze — służy do wyznaczenia repertorium dekretu).</span>
  </li>
  <li>
    <span class="param-name">ksd_kurs_bazowy</span>
    <span class="param-type">DECIMAL</span>
    <span class="param-desc">Kurs wymiany z waluty dekretu na walutę bazową (PLN).</span>
  </li>
  <li>
    <span class="param-name">ksd_kwota_wn_wyceny</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota Winien w walucie wyceny (pole zarezerwowane — obecnie nie wypełniane).</span>
  </li>
  <li>
    <span class="param-name">ksd_kwota_ma_wyceny</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota Ma w walucie wyceny (pole zarezerwowane — obecnie nie wypełniane).</span>
  </li>
  <li>
    <span class="param-name fk">ksd_wa_id_wyceny</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika walut (waluta wyceny) — pole zarezerwowane, obecnie nie wypełniane.</span>
  </li>
  <li>
    <span class="param-name">ksd_kwota_wn_bazowa</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota Winien w walucie bazowej (PLN).</span>
  </li>
  <li>
    <span class="param-name">ksd_kwota_ma_bazowa</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota Ma w walucie bazowej (PLN).</span>
  </li>
  <li>
    <span class="param-name fk">ksd_wa_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do słownika walut (waluta dekretu).</span>
  </li>
  <li>
    <span class="param-name">ksd_data_wymagalnosci</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data wymagalności dekretu (dziedziczona z powiązanego dokumentu).</span>
  </li>
  <li>
    <span class="param-name fk">ksd_ksksub_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do subkonta konta księgowego (pole schema-only w iteracji 8, REF_35).</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna — obsługiwana triggerami insert; nie wypełniać.</span>
  </li>
</ul>

</details>

### dbo.operacja

<details markdown="1">
<summary><code>dbo.operacja</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> operacje finansowe rozbijane na nagłówek + dekrety rodzajowe</summary>

<div class="dict-meta">
  <span>Tabele prod: <code>dm_data_web.ksiegowanie</code>, <code>dm_data_web.ksiegowanie_dekret</code></span>
  <span>Kształt mapowania: <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span></span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak (1 operacja → 1 nagłówek + 1–5 dekretów)</span>
</div>

Operacja finansowa z systemu źródłowego — wpłaty, umorzenia, korekty, koszty i alokacje. Staging `operacja` nie odpowiada pojedynczej tabeli prod — jej kwoty są rozbijane na pozycje rodzajowe (kapitał, odsetki karne, odsetki umowne, opłaty, prowizje) w momencie ładowania i zasilają jednocześnie nagłówek `ksiegowanie` oraz od jednego do pięciu dekretów `ksiegowanie_dekret`. Strona dekretu (Winien/Ma) wynika z `oper_rejestr_kod` — `wplata` i `umorzenie` trafiają na stronę Winien, pozostałe (korekta, koszt, nadpłata, alokacja) na stronę Ma.

<ul class="param-list">
  <li>
    <span class="param-name pk required">oper_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Klucz główny operacji.</span>
  </li>
  <li>
    <span class="param-name fk">oper_wi_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do wierzytelności (powiązanie wierzytelność ↔ księgowanie jest pośrednie, przez dekret).</span>
  </li>
  <li>
    <span class="param-name">oper_waluta</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kod waluty operacji (SWIFT).</span>
  </li>
  <li>
    <span class="param-name required">oper_rejestr_kod</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Kod rejestru finansowego — determinuje stronę dekretu: wplata/umorzenie → Winien, pozostałe → Ma.</span>
  </li>
  <li>
    <span class="param-name">oper_typ_dekretu</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Typ dekretu operacji.</span>
  </li>
  <li>
    <span class="param-name">oper_opis_dekretu</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opcjonalny opis dekretu.</span>
  </li>
  <li>
    <span class="param-name">oper_dokument_typ_prod_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator typu dokumentu w systemie źródłowym (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_dokument_podtyp_prod_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator podtypu dokumentu w systemie źródłowym (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_dokument_typ_prod_opis</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opis typu dokumentu w systemie źródłowym (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_dokument_podtyp_prod_opis</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opis podtypu dokumentu w systemie źródłowym (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_dokument_prod_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Identyfikator dokumentu w systemie źródłowym (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_opis_slowny</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Słowny opis operacji (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_opis</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Opis techniczny operacji (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_strona</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Strona dekretu w systemie źródłowym (wartość poglądowa — strona prod wyznaczana z oper_rejestr_kod).</span>
  </li>
  <li>
    <span class="param-name">oper_kwota</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota operacji w walucie oryginalnej — suma składników rodzajowych.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_dekretu</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota dekretu (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_kapitalu</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota kapitału — generuje dekret rodzajowy KAP, gdy &gt; 0.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_odsetek</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota odsetek umownych — generuje dekret rodzajowy ODU, gdy &gt; 0.</span>
  </li>
  <li>
    <span class="param-name">oper_kowta_odsetek_karnych</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota odsetek karnych (typo 'kowta' potwierdzony w schemacie źródłowym) — generuje dekret rodzajowy ODK, gdy &gt; 0.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_oplaty</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota opłaty — generuje dekret rodzajowy OPL, gdy &gt; 0.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_prowizji</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota prowizji — generuje dekret rodzajowy PRW, gdy &gt; 0.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota operacji przeliczona na PLN (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_dekretu_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota dekretu w PLN (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_kapitalu_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota kapitału w PLN — kwota bazowa dekretu rodzajowego KAP.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_odsetek_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota odsetek umownych w PLN — kwota bazowa dekretu rodzajowego ODU.</span>
  </li>
  <li>
    <span class="param-name">oper_kowta_odsetek_karnych_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota odsetek karnych w PLN (typo 'kowta' potwierdzony) — kwota bazowa dekretu rodzajowego ODK.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_oplaty_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota opłaty w PLN — kwota bazowa dekretu rodzajowego OPL.</span>
  </li>
  <li>
    <span class="param-name">oper_kwota_prowizji_w_pln</span>
    <span class="param-type">DECIMAL(18,4)</span>
    <span class="param-desc">Kwota prowizji w PLN — kwota bazowa dekretu rodzajowego PRW.</span>
  </li>
  <li>
    <span class="param-name">oper_data_waluty</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data waluty operacji (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_data_danych</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data danych źródłowych (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_data_dekretu</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data dekretu — data zaksięgowania nagłówka (z fallbackiem na oper_data_ksiegowania, gdy NULL).</span>
  </li>
  <li>
    <span class="param-name">oper_data_ksiegowania</span>
    <span class="param-type">DATE</span>
    <span class="param-desc">Data zaksięgowania operacji — data operacji gospodarczej dla nagłówka.</span>
  </li>
  <li>
    <span class="param-name">oper_beneficjent_nazwa</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Nazwa beneficjenta (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_remitter_nazwa</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Nazwa zleceniodawcy (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name">oper_konto</span>
    <span class="param-type">VARCHAR</span>
    <span class="param-desc">Numer konta bankowego operacji (pole informacyjne).</span>
  </li>
  <li>
    <span class="param-name fk">oper_do_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">FK do dokumentu powiązanego z operacją (walidowany przez REF_23; dekrety operacji w prod mają ksd_do_id = NULL).</span>
  </li>
  <li>
    <span class="param-name deprecated">mod_date</span>
    <span class="param-type">DATETIME</span>
    <span class="param-desc">Kolumna techniczna — obsługiwana triggerami insert; nie wypełniać.</span>
  </li>
</ul>

</details>

## Powiązania {#powiazania}

- Poprzednia iteracja: [Role wierzytelności i dokumenty](role-wierzytelnosci-i-dokumenty.md)
- Następna iteracja: [Harmonogram spłat](harmonogram.md)
- Słowniki bazowe iteracja 1: [ksiegowanie_typ](slowniki.md#dboksiegowanie_typ), [ksiegowanie_konto](slowniki.md#dboksiegowanie_konto), [waluta](slowniki.md)
- Dokumenty (iteracja 7): [Role wierzytelności i dokumenty § dbo.dokument](role-wierzytelnosci-i-dokumenty.md#dbodokument)
- Walidacje referencyjne (ksiegowanie_dekret): [REF_20 (dekret → księgowanie)](../przygotowanie-danych/walidacje.md), [REF_21 (ksk_id → ksiegowanie_konto)](../przygotowanie-danych/walidacje.md), [REF_22 (ksd_do_id → dokument)](../przygotowanie-danych/walidacje.md), [REF_35 (ksd_ksksub_id → ksiegowanie_konto_subkonto)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (ksiegowanie): [REF_29 (ks_kst_id → ksiegowanie_typ)](../przygotowanie-danych/walidacje.md)
- Walidacje referencyjne (operacja): [REF_23 (oper_do_id → dokument)](../przygotowanie-danych/walidacje.md), [REF_27 (oper_waluta → waluta)](../przygotowanie-danych/walidacje.md)
- Walidacje techniczne: [TECH_09 (ksd_ks_id wymagane, BLOKUJĄCE)](../przygotowanie-danych/walidacje.md), [TECH_10 (oper_waluta dla kwoty &gt; 0, OSTRZEŻENIE)](../przygotowanie-danych/walidacje.md)
- Walidacje biznesowe: [BIZ_05 (księgowanie bez dekretu, BLOKUJĄCE)](../przygotowanie-danych/walidacje.md#biz_05), [BIZ_06 (suma dekretów ≠ 0, BLOKUJĄCE)](../przygotowanie-danych/walidacje.md#biz_06), [BIZ_17 (ks_data_ksiegowania z przyszłości, INFORMACJA)](../przygotowanie-danych/walidacje.md#biz_17), [BIZ_18 (ks_data_operacji z przyszłości, INFORMACJA)](../przygotowanie-danych/walidacje.md#biz_18)
