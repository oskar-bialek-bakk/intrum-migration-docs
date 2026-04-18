---
title: "Migracja ⬝ Walidacje"
---

# Walidacje przed migracją

Po załadowaniu danych do stagingu, zespół BAKK uruchomi poniższe walidacje. Wyniki są zapisywane w tabeli `dm_staging.log.validation_result` i mogą być odpytywane w dowolnym momencie poniższym zapytaniem SQL:

```sql
SELECT
    check_name      AS [Kod],
    severity        AS [Poziom],
    affected_count  AS [Liczba rekordów],
    sample_ids      AS [Przykładowe ID],
    detail          AS [Opis]
FROM dm_staging.log.validation_result
WHERE run_id = <run_id>
  AND affected_count > 0
ORDER BY
    CASE severity WHEN 'BLOCKING' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
    check_name;
```

Przykładowy wynik:

| Kod | Poziom | Liczba rekordów | Przykładowe ID | Opis |
|---|---|---|---|---|
| BIZ_01 | BLOCKING | 3 | 101, 102, 103 | Sprawa nie ma przypisanego dłużnika (brak rekordu w `sprawa_rola`) |
| REF_01 | BLOCKING | 1 | 45 | `sprawa_rola.spr_dl_id` wskazuje na nieistniejącego dłużnika |
| FMT_01 | WARNING | 12 | 10, 22, 38 | PESEL dłużnika nie składa się z dokładnie 11 cyfr |

Wszystkie błędy **blokujące** muszą zostać poprawione przed migracją.

---

### 3.1 Spójność referencyjna (wszystkie BLOKUJĄCE)

Sprawdzają czy wartości w kolumnach FK wskazują na istniejące rekordy.

| Kod | Tabela | Opis |
|---|---|---|
| REF_01 | `sprawa_rola` | Każdy dłużnik w `sprawa_rola` musi istnieć w `dluznik` |
| REF_02 | `sprawa_rola` | Każda sprawa w `sprawa_rola` musi istnieć w `sprawa` |
| REF_03 | `sprawa_rola` | Każdy typ roli w `sprawa_rola` musi istnieć w `sprawa_rola_typ` |
| REF_04 | `wierzytelnosc_rola` | Każda wierzytelność w `wierzytelnosc_rola` musi istnieć w `wierzytelnosc` |
| REF_05 | `wierzytelnosc_rola` | Każda sprawa w `wierzytelnosc_rola` musi istnieć w `sprawa` |
| REF_06 | `wierzytelnosc` | Jeśli `wi_uko_id` jest wypełnione, musi istnieć w `umowa_kontrahent` |
| REF_07 | `dokument` | Każdy dokument musi być powiązany z istniejącą wierzytelnością |
| REF_08 | `dokument` | Typ dokumentu musi istnieć w `dokument_typ` |
| REF_09 | `adres` | Każdy adres musi być powiązany z istniejącym dłużnikiem |
| REF_10 | `adres` | Typ adresu musi istnieć w `adres_typ` |
| REF_11 | `telefon` | Każdy telefon musi być powiązany z istniejącym dłużnikiem |
| REF_12 | `telefon` | Typ telefonu musi istnieć w `telefon_typ` |
| REF_13 | `mail` | Każdy adres e-mail musi być powiązany z istniejącym dłużnikiem |
| REF_14 | `akcja` | Każda akcja musi być powiązana z istniejącą sprawą |
| REF_15 | `atrybut` | Typ atrybutu musi istnieć w `atrybut_typ` |
| REF_16 | `atrybut` | Jeśli `atrybut_typ.att_atd_id=1` (dokument), `at_ob_id` musi istnieć w `dokument` |
| REF_17 | `atrybut` | Jeśli `atrybut_typ.att_atd_id=2` (wierzytelność), `at_ob_id` musi istnieć w `wierzytelnosc` |
| REF_18 | `atrybut` | Jeśli `atrybut_typ.att_atd_id=3` (dłużnik), `at_ob_id` musi istnieć w `dluznik` |
| REF_19 | `atrybut` | Jeśli `atrybut_typ.att_atd_id=4` (sprawa), `at_ob_id` musi istnieć w `sprawa` |
| REF_20 | `ksiegowanie_dekret` | Każdy dekret musi być powiązany z istniejącym księgowaniem |
| REF_21 | `ksiegowanie_dekret` | Konto księgowe musi istnieć w `ksiegowanie_konto` |
| REF_22 | `ksiegowanie_dekret` | Jeśli `ksd_do_id` jest wypełnione, musi istnieć w `dokument` |
| REF_23 | `operacja` | Jeśli `oper_do_id` jest wypełnione, musi istnieć w `dokument` |
| REF_24 | `sprawa` | Typ sprawy musi istnieć w `sprawa_typ` |
| REF_25 | `sprawa_etap` | Typ sprawy w `sprawa_etap` musi istnieć w `sprawa_typ` |
| REF_26 | `dluznik` | Typ dłużnika musi istnieć w `dluznik_typ` |
| REF_27 | `operacja` | Jeśli `oper_waluta` jest wypełnione, musi odpowiadać kodowi waluty w `waluta` |
| REF_28 | `atrybut` | Dziedzina atrybutu musi istnieć w `atrybut_dziedzina` |
| REF_29 | `ksiegowanie` | Typ księgowania musi istnieć w `ksiegowanie_typ` |
| REF_30 | `dluznik` | Wartość `dl_plec` musi odpowiadać kodowi w tabeli mapowania płci |
| REF_31 | `sprawa` | Etap sprawy musi istnieć w `sprawa_etap` |
| REF_32 | `akcja` | Typ akcji musi istnieć w `akcja_typ` |
| REF_33 | `rezultat` | Każdy rezultat musi być powiązany z istniejącą akcją (`re_ak_id → akcja`) |
| REF_34 | `rezultat` | Typ rezultatu musi istnieć w `rezultat_typ` (`re_ret_id → rezultat_typ`) |
| REF_35 | `ksiegowanie_dekret` | Subkonto konta księgowego musi istnieć w `ksiegowanie_konto_subkonto` (`ksd_ksksub_id → ksiegowanie_konto_subkonto`) |

---

### 3.2 Walidacje techniczne

| Kod | Poziom | Opis |
|---|---|---|
| TECH_01 | OSTRZEŻENIE | Dłużnik ma pustą kolumnę `dl_plec` — płeć nie zostanie przeniesiona do bazy produkcyjnej (pole opcjonalne) |
| TECH_03 | **BLOKUJĄCE** | Sprawa ma pustą kolumnę `sp_numer_rachunku` — numer rachunku jest wymagany, rekord nie może zostać zmigrowany |
| TECH_04 | **BLOKUJĄCE** | Wierzytelność ma pustą kolumnę `wi_uko_id` — powiązanie z umową kontrahenta jest wymagane |
| TECH_05 | **BLOKUJĄCE** | Dokument ma pustą kolumnę `do_wi_id` — powiązanie z wierzytelnością jest wymagane |
| TECH_06 | **BLOKUJĄCE** | Akcja ma pustą kolumnę `ak_sp_id` — powiązanie ze sprawą jest wymagane |
| TECH_07 | **BLOKUJĄCE** | Atrybut ma pustą kolumnę `at_ob_id` — brak wskazania encji docelowej, rekord nie może zostać zmigrowany |
| TECH_08 | OSTRZEŻENIE | Atrybut ma pustą wartość (`at_wartosc = ''`) — wartość może być pusta w bazie produkcyjnej, wymaga weryfikacji |
| TECH_09 | **BLOKUJĄCE** | Dekret księgowania ma pustą kolumnę `ksd_ks_id` — powiązanie z nagłówkiem księgowania jest wymagane |
| TECH_10 | OSTRZEŻENIE | Operacja finansowa ma kwotę większą od zera, ale pustą walutę (`oper_waluta`) — waluta zostanie ustawiona jako NULL na produkcji |

---

### 3.3 Walidacje formatów

Wszystkie poniższe walidacje mają poziom **OSTRZEŻENIE** z wyjątkiem FMT_07 (INFORMACJA).

Poniższy zestaw walidacji stanowi propozycję bazową. Zakres i progi poszczególnych sprawdzeń mogą zostać dostosowane do specyficznych wymagań Intrum podczas warsztatów analitycznych.

| Kod | Poziom | Tabela | Opis |
|---|---|---|---|
| FMT_01 | OSTRZEŻENIE | `dluznik` | PESEL musi składać się z dokładnie 11 cyfr |
| FMT_02 | OSTRZEŻENIE | `dluznik` | NIP musi składać się z 10 cyfr (myślniki są ignorowane) |
| FMT_03 | OSTRZEŻENIE | `dluznik` | REGON musi składać się z 9 lub 14 cyfr |
| FMT_04 | OSTRZEŻENIE | `adres` | Kod pocztowy musi być w formacie XX-XXX |
| FMT_05 | OSTRZEŻENIE | `mail` | Adres e-mail musi zawierać znak `@` i domenę |
| FMT_06 | OSTRZEŻENIE | `telefon` | Numer telefonu musi zawierać co najmniej 9 cyfr (po usunięciu spacji, myślników i znaku +) |
| FMT_07 | INFORMACJA | `telefon` | Numer telefonu nie zaczyna się od `+` — brak kodu kraju |
| FMT_08 | OSTRZEŻENIE | `dokument` | Data wymagalności dokumentu (`do_data_wymagalnosci`) nie może być wcześniejsza niż data wystawienia (`do_data_wystawienia`) |
| FMT_11 | OSTRZEŻENIE | `akcja` | Data zakończenia akcji (`ak_data_zakonczenia`) nie może być w przyszłości |
| FMT_12 | OSTRZEŻENIE | `wierzytelnosc` | Data umowy wierzytelności (`wi_data_umowy`) nie może być w przyszłości |

---

### 3.4 Reguły biznesowe

| Kod | Poziom | Opis |
|---|---|---|
| BIZ_01 | **BLOKUJĄCE** | Każda sprawa musi mieć co najmniej jeden rekord w `sprawa_rola` — sprawa bez przypisanego dłużnika jest nieprawidłowa |
| BIZ_02a | INFORMACJA | Sprawa bez powiązanej wierzytelności — dozwolone, ale taka sprawa nie może mieć powiązanych dokumentów ani księgowań |
| BIZ_02b | **BLOKUJĄCE** | Sprawa bez wierzytelności ma powiązane dokumenty lub dekrety księgowania — niedozwolone, dane muszą zostać poprawione |
| BIZ_03 | OSTRZEŻENIE | Dłużnik nie jest powiązany z żadną sprawą — możliwy błąd zasilania danych |
| BIZ_04 | OSTRZEŻENIE | Wierzytelność nie ma żadnego powiązanego dokumentu — sytuacja podejrzana, wymaga weryfikacji |
| BIZ_05 | **BLOKUJĄCE** | Księgowanie nie ma żadnego dekretu — zapis księgowy bez linii szczegółowych jest nieprawidłowy |
| BIZ_06 | **BLOKUJĄCE** | Suma kwot dekretów na jednym księgowaniu nie wynosi zero — naruszenie zasady podwójnego zapisu |
| BIZ_07 | OSTRZEŻENIE | Sprawa nie ma żadnej akcji — przypadek bez historii działań jest nietypowy |
| BIZ_08 | **BLOKUJĄCE** | Akcja nie ma żadnego rezultatu — każda akcja musi mieć co najmniej jeden rezultat |
| BIZ_09 | OSTRZEŻENIE | Dłużnik ma nadmierną liczbę numerów telefonu — próg konfigurowalny w `dm_staging.configuration.threshold_config` (klucz: `max_phones_per_dluznik`) |
| BIZ_10 | OSTRZEŻENIE | Dłużnik ma nadmierną liczbę adresów — próg konfigurowalny w `dm_staging.configuration.threshold_config` (klucz: `max_adresy_per_dluznik`) |
| BIZ_11 | OSTRZEŻENIE | Sprawa ma nadmierną liczbę akcji — próg konfigurowalny w `dm_staging.configuration.threshold_config` (klucz: `max_akcje_per_sprawa`) |
| BIZ_12 | OSTRZEŻENIE | Wierzytelność ma nadmierną liczbę dokumentów — próg konfigurowalny w `dm_staging.configuration.threshold_config` (klucz: `max_dokumenty_per_wierzytelnosc`) |
| BIZ_13 | INFORMACJA | Dłużnik nie ma żadnego identyfikatora (brak PESEL, NIP, numeru dowodu i paszportu) — rekord zostanie zmigrowany, ale niska jakość danych |
| BIZ_14 | INFORMACJA | Wierzytelność nie ma żadnych powiązanych księgowań — wierzytelność nigdy nie trafiła do księgowości |
| BIZ_15 | OSTRZEŻENIE | Harmonogram spłat powiązany z nieistniejącą wierzytelnością — rekord osierocony |
| BIZ_16 | **BLOKUJĄCE** | Dokument nie ma daty wymagalności na podstawowym dekrecie księgowania — każdy dokument musi mieć datę wymagalności |
| BIZ_17 | INFORMACJA | Księgowanie ma datę księgowania z przyszłości — data księgowania nie może być przyszła |
| BIZ_18 | INFORMACJA | Księgowanie ma datę operacji z przyszłości — data operacji nie może być przyszła |
| BIZ_19 | INFORMACJA | Wierzytelność ma datę umowy z przyszłości — data zawarcia umowy nie może być przyszła |
