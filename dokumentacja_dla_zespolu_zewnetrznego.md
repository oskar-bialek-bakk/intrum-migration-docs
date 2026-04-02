# Dokumentacja migracji danych — przewodnik dla zespołu Intrum

**Baza docelowa stagingu:** `dm_staging`
**Baza produkcyjna:** `dm_data_web`

---

## 1. Wstęp

Niniejszy dokument opisuje proces zasilania bazy stagingowej danymi oraz zasady walidacji, które zostaną uruchomione przed migracją do bazy produkcyjnej.

Dane dostarczane przez zespół Intrum muszą zostać załadowane do bazy `dm_staging` w określonej kolejności. Po załadowaniu, zespół BAKK uruchomi zestaw skryptów walidacyjnych sprawdzających jakość i spójność danych. Wyniki walidacji będą przekazane zwrotnie — błędy **blokujące** muszą zostać poprawione przed migracją.

### Poziomy ważności walidacji

| Poziom | Opis |
|---|---|
| **BLOKUJĄCE** | Dane nie mogą zostać zmigrowane — wymagana korekta przed uruchomieniem migracji |
| **OSTRZEŻENIE** | Dane zostaną zmigrowane, ale wymagają weryfikacji — mogą wskazywać na problemy jakościowe |
| **INFORMACJA** | Dane zostaną zmigrowane — komunikat wyłącznie informacyjny, brak wymaganej akcji |

---

## 2. Kolejność zasilania tabel stagingowych

### Zasady ogólne

1. **Wartości FK** muszą odnosić się do identyfikatorów ze stagingu, nie z bazy produkcyjnej.
2. Tabele w obrębie tej samej iteracji nie mają zależności między sobą i mogą być ładowane równolegle (chyba że zaznaczono inaczej).

---

### Iteracja 1 — Wszystkie tabele słownikowe i referencyjne

Iteracja 1 składa się z dwóch kroków:

**Krok 1A — wykonywany jednorazowo przez zespół BAKK** (przed przekazaniem stagingu zespołowi Intrum):
Skopiowanie istniejących danych produkcyjnych do tabel słownikowych w stagingu.

**Krok 1B — wykonywany przez zespół Intrum:**
1. Dodaj nowe wartości wymagane przez dane źródłowe (wartości nieistniejące jeszcze w bazie produkcyjnej).
2. Używaj identyfikatorów ze stagingu wypełniając kolumny FK w późniejszych iteracjach.
3. Podczas migracji skrypty BAKK automatycznie uzupełnią bazę produkcyjną o nowe wartości (operacja MERGE).

> **Uwaga:** Nie wszystkie słowniki muszą być zasilone przed pierwszą iteracją encji. Wystarczy zasilić tylko te słowniki, które są faktycznie wymagane przez tabele encji w danej iteracji. Przykład: przed Iteracją 2 (dłużnicy) konieczne jest zasilenie `dluznik_typ` oraz słowników atrybutów (`atrybut_dziedzina`, `atrybut_rodzaj`, `atrybut_typ`). Szczegółowe zależności per tabela opisuje kolumna „Zależności FK" w tabelach iteracji 2–9.

| Tabela | Uwagi |
|---|---|
| `dbo.waluta` | Słownik walut |
| `dbo.kurs_walut` | Kursy walut |
| `dbo.kontrahent` | Wierzyciele i kontrahenci |
| `dbo.umowa_kontrahent` | Umowy z kontrahentami — załadować po `kontrahent` |
| `dbo.adres_typ` | Słownik typów adresów |
| `dbo.dluznik_typ` | Słownik typów dłużników |
| `dbo.dokument_typ` | Słownik typów dokumentów |
| `dbo.ksiegowanie_konto` | Słownik kont księgowych |
| `dbo.ksiegowanie_typ` | Słownik typów księgowań |
| `dbo.sprawa_rola_typ` | Słownik ról w sprawie |
| `dbo.sprawa_typ` | Słownik typów spraw |
| `dbo.telefon_typ` | Słownik typów telefonów |
| `dbo.atrybut_dziedzina` | Słownik dziedzin atrybutów |
| `dbo.atrybut_rodzaj` | Słownik rodzajów atrybutów |
| `dbo.akcja_typ` | Słownik typów akcji. **Kolumny `akt_rodzaj` i `akt_ikona` muszą być uzupełnione dla każdego wiersza** — skonsultuj z zespołem BAKK dozwolone wartości z dokumentacji aplikacji. |
| `dbo.rezultat_typ` | Słownik typów rezultatów. **Kolumna `ret_konczy` (BIT) musi być uzupełniona dla każdego wiersza** — określa czy dany rezultat zamyka akcję. |
| `dbo.atrybut_typ` | Słownik typów atrybutów. **Wymaga uprzedniego zasilenia `atrybut_dziedzina` i `atrybut_rodzaj`.** |
| `dbo.sprawa_etap` | Słownik etapów spraw. **Wymaga uprzedniego zasilenia `sprawa_typ` i `akcja_typ`. Każdy wiersz `sprawa_etap` wymaga odpowiadającego wiersza w `akcja_typ`.** |
| `dbo.zrodlo_pochodzenia_informacji` | Słownik źródeł pochodzenia informacji |
| `dbo.wlasciwosc_typ_walidacji` | Słownik typów walidacji właściwości |
| `dbo.wlasciwosc_dziedzina` | Słownik dziedzin właściwości |
| `dbo.wlasciwosc_podtyp` | Słownik podtypów właściwości |
| `dbo.wlasciwosc_typ` | Słownik typów właściwości. **Wymaga uprzedniego zasilenia `wlasciwosc_typ_walidacji`.** |
| `dbo.wlasciwosc_typ_podtyp_dziedzina` | Powiązania typ-podtyp-dziedzina właściwości. **Wymaga uprzedniego zasilenia `wlasciwosc_typ`, `wlasciwosc_dziedzina`, `wlasciwosc_podtyp`.** |

---

### Iteracja 2 — Dłużnicy i ich atrybuty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.dluznik` | `dl_dt_id → dluznik_typ` | Reguła biznesowa: `dl_dt_id` równe (1,2) → wymagane `dl_imie`, `dl_nazwisko`, `dl_pesel`. `dl_dt_id` równe (3,4) → wymagane `dl_firma`, `dl_nip`. |
| `dbo.atrybut` *(att_atd_id = 3)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → dluznik.dl_id` | Wyłącznie atrybuty dłużników (`atrybut_typ.att_atd_id = 3`). Załadować po `dluznik`. |
| `dbo.wlasciwosc` *(dziedzina=4)* | `wl_wtpd_id → wlasciwosc_typ_podtyp_dziedzina` | Główna tabela właściwości — załadować wiersze powiązane z dłużnikami (dziedzina=4). Załadować razem z `wlasciwosc_dluznik`. |
| `dbo.wlasciwosc_dluznik` | `wd_wl_id → wlasciwosc`, `wd_dl_id → dluznik` | Właściwości dłużników. Załadować po `dluznik`. Wymaga zasilenia tabel słownikowych `wlasciwosc_*` w Iteracji 1. |

---

### Iteracja 3 — Dane kontaktowe dłużników

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.adres` | `ad_dl_id → dluznik`, `ad_at_id → adres_typ` | Dozwolonych wiele adresów na dłużnika. Maksymalna liczba jednocześnie aktywnych adresów danego typu (`ad_at_id`) jest konfigurowana w prod: `adres_typ_podmiot_konfiguracja.atpk_il` (dla `atp_id=2` — dłużnik). Aktywny = `ad_data_do IS NULL` lub `ad_data_do > GETDATE()`. Przekroczenie limitu jest **blokujące** (BIZ_20). |
| `dbo.mail` | `ma_dl_id → dluznik` | |
| `dbo.telefon` | `tn_dl_id → dluznik`, `tn_tt_id → telefon_typ` | Dozwolonych wiele numerów telefonu na dłużnika, jednak dla każdego typu telefonu (`tn_tt_id`) tylko jeden rekord może być jednocześnie aktywny (brak daty zakończenia lub `tn_data_do > GETDATE()`). |
| `dbo.wlasciwosc` *(dziedzina=1,2,3)* | `wl_wtpd_id → wlasciwosc_typ_podtyp_dziedzina` | Wiersze właściwości powiązane z adresami (dziedzina=2), e-mailami (dziedzina=3) i telefonami (dziedzina=1). Załadować razem z `wlasciwosc_adres`, `wlasciwosc_email`, `wlasciwosc_telefon`. |
| `dbo.wlasciwosc_adres` | `wa_wl_id → wlasciwosc`, `wa_ad_id → adres` | Właściwości adresów. Załadować po `adres`. |
| `dbo.wlasciwosc_email` | `we_wl_id → wlasciwosc`, `we_ma_id → mail` | Właściwości adresów e-mail. Załadować po `mail`. |
| `dbo.wlasciwosc_telefon` | `wt_wl_id → wlasciwosc`, `wt_tn_id → telefon` | Właściwości telefonów. Załadować po `telefon`. |

---

### Iteracja 4 — Sprawy, role i atrybuty spraw

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.sprawa` | `sp_spt_id → sprawa_typ`, `sp_spe_id → sprawa_etap` | `sp_numer_rachunku` — numer rachunku bankowego jako tekst. `sp_pracownik` — opcjonalny. `sp_data_obslugi_od` / `sp_data_obslugi_do` — opcjonalne daty obsługi. `sp_import_info` — data importu w formacie `yyyy-mm-dd hh:mm:ss.zzz`. |
| `dbo.sprawa_rola` | `spr_sp_id → sprawa`, `spr_dl_id → dluznik`, `spr_sprt_id → sprawa_rola_typ` | Przypisanie dłużników do spraw wraz z rolą. Załadować po `sprawa`. |
| `dbo.atrybut` *(att_atd_id = 4)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → sprawa.sp_id` | Wyłącznie atrybuty spraw (`atrybut_typ.att_atd_id = 4`). Załadować po `sprawa`. |

---

### Iteracja 5 — Akcje i rezultaty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.akcja` | `ak_sp_id → sprawa`, `ak_akt_id → akcja_typ` | Akcje windykacyjne. `ak_data_zakonczenia` — akcja zamknięta: uzupełnić, jeśli do akcji nie będą dodawane więcej rezultatów. |
| `dbo.rezultat` | `re_ak_id → akcja`, `re_ret_id → rezultat_typ` | Załadować po `akcja`. Wymagany przynajmniej jeden rezultat każdej akcji. |

---

### Iteracja 6 — Wierzytelności i ich atrybuty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.wierzytelnosc` | `wi_sp_id → sprawa`, `wi_uko_id → umowa_kontrahent` | Wierzytelności powiązane ze sprawami |
| `dbo.atrybut` *(att_atd_id = 2)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → wierzytelnosc.wi_id` | Wyłącznie atrybuty wierzytelności (`atrybut_typ.att_atd_id = 2`). Załadować po `wierzytelnosc`. |

---

### Iteracja 7 — Dokumenty, role wierzytelności i atrybuty dokumentów

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.wierzytelnosc_rola` | `wir_wi_id → wierzytelnosc`, `wir_sp_id → sprawa` | Powiązania wierzytelności ze sprawami |
| `dbo.dokument` | `do_wi_id → wierzytelnosc`, `do_dot_id → dokument_typ` | Dokumenty finansowe |
| `dbo.atrybut` *(att_atd_id = 1)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → dokument.do_id` | Wyłącznie atrybuty dokumentów (`atrybut_typ.att_atd_id = 1`). Załadować po `dokument`. |

---

### Iteracja 8 — Dane finansowe

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.ksiegowanie` | `ks_kst_id → ksiegowanie_typ` | Nagłówki księgowań |
| `dbo.operacja` | `oper_wi_id → wierzytelnosc` | Surowe operacje finansowe z systemu źródłowego |
| `dbo.ksiegowanie_dekret` | `ksd_ks_id → ksiegowanie`, `ksd_do_id → dokument`, `ksd_ksk_id → ksiegowanie_konto`, `ksd_sp_id → sprawa`, `ksd_wa_id → waluta` | Załadować po `ksiegowanie`. Kolumny wielowalutowe (`ksd_kurs_bazowy`, `ksd_kwota_wn/ma_*`) są opcjonalne — wypełnić jeśli system źródłowy dostarcza dane wyceny. |

---

### Iteracja 9 — Ostatnia

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.harmonogram` | `hr_wi_id → wierzytelnosc` | Harmonogram spłat |
| `dbo.zabezpieczenie` | `zab_wi_id → wierzytelnosc`, `zab_dl_id → dluznik` | **Tylko od etapu 2 migracji** — nie jest wymagane dla etapu 1. |

---

### Podsumowanie kolejności

```
Iteracja 1  → waluta, kurs_walut, kontrahent, umowa_kontrahent,
               adres_typ, dluznik_typ, dokument_typ, ksiegowanie_konto,
               ksiegowanie_typ, sprawa_rola_typ, sprawa_typ, telefon_typ,
               atrybut_dziedzina, atrybut_rodzaj, akcja_typ, rezultat_typ,
               atrybut_typ*, sprawa_etap*, zrodlo_pochodzenia_informacji,
               wlasciwosc_typ_walidacji, wlasciwosc_dziedzina, wlasciwosc_podtyp,
               wlasciwosc_typ*, wlasciwosc_typ_podtyp_dziedzina*          (* po spełnieniu zależności)
Iteracja 2  → dluznik, atrybut (att_atd_id=3), wlasciwosc (dziedzina=4), wlasciwosc_dluznik
Iteracja 3  → adres, mail, telefon, wlasciwosc (dziedzina=1,2,3), wlasciwosc_adres, wlasciwosc_email, wlasciwosc_telefon
Iteracja 4  → sprawa, sprawa_rola, atrybut (att_atd_id=4)
Iteracja 5  → akcja, rezultat
Iteracja 6  → wierzytelnosc, atrybut (att_atd_id=2)
Iteracja 7  → wierzytelnosc_rola, dokument, atrybut (att_atd_id=1)
Iteracja 8  → ksiegowanie, operacja, ksiegowanie_dekret       (dane finansowe)
Iteracja 9  → harmonogram, zabezpieczenie                     (ostatnie)
```

---

## 3. Walidacje przed migracją

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

---

## 4. Postępowanie po wykryciu błędów

Po uruchomieniu walidacji zespół BAKK przekaże raport w formie wyniku zapytania SQL (patrz sekcja 3). Raport zawiera:
- identyfikatory rekordów z błędami
- kod i opis walidacji
- liczbę rekordów objętych błędem

Przykładowy raport z błędami blokującymi do korekty:

| Kod | Poziom | Liczba rekordów | Przykładowe ID | Opis |
|---|---|---|---|---|
| BIZ_08 | BLOCKING | 5 | 201, 202, 203, 204, 205 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| REF_14 | BLOCKING | 2 | 310, 311 | `akcja.ak_sp_id` wskazuje na nieistniejącą sprawę |
| TECH_03 | BLOCKING | 1 | 88 | `sprawa.sp_numer_rachunku` ma wartość NULL — pole wymagane |

**Błędy blokujące** — wymagają korekty w danych źródłowych i ponownego załadowania do stagingu przed migracją.

**Ostrzeżenia** — można poprawić przed migracją lub pisemnie potwierdzić akceptację odchyleń.

**Informacje** — nie wymagają akcji.

Po każdej poprawce walidacje zostaną uruchomione ponownie aż do uzyskania braku błędów blokujących.

---

## 5. Migracja danych

Po uzyskaniu braku błędów blokujących zespół BAKK przystąpi do migracji danych ze stagingu do bazy produkcyjnej. Migracja zostanie przeprowadzona zgodnie z ustalonym harmonogramem i obejmie przeniesienie wszystkich zasilonych tabel stagingowych do odpowiadających im tabel w `dm_data_web`.

Po zakończeniu migracji zespół BAKK przekaże potwierdzenie wykonania wraz z podsumowaniem liczby zmigrowanych rekordów per tabela.

---

## 6. Raport pomigracyjny

Po zakończeniu migracji zespół BAKK uruchamia skrypt `99_post_report.sql`, który przeprowadza automatyczną weryfikację jakości danych bezpośrednio na bazie produkcyjnej `dm_data_web`. Wyniki zapisywane są w tabeli `dm_staging.log.postmigration_check` i obejmują łącznie 30 wskaźników KPI podzielonych na trzy kategorie.

Raport jest przekazywany zespołowi Intrum jako podstawa formalnego odbioru (sekcja 7). Warunek zaliczenia dla wskaźników COUNT: liczba rekordów w produkcji równa się sumie stanu sprzed migracji (snapshot) i liczby rekordów zasilonych w stagingu. Dla etapu 1, gdzie baza produkcyjna była pusta przed migracją, snapshot = 0, więc wymagana liczba produkcyjna = liczba stagingowa.

| Kategoria | Liczba KPI | Co sprawdzają |
|---|---|---|
| COUNT — uzgodnienie liczebności | 13 | Czy liczba rekordów w każdej tabeli produkcyjnej odpowiada oczekiwanej (snapshot + staging) |
| SUM — uzgodnienie finansowe | 4 | Czy sumy kwot kluczowych kolumn finansowych (wierzytelności, dekrety) zgadzają się ze stagingiem |
| ANOMALY — jakość danych | 13 | Rekordy bez wymaganego identyfikatora zewnętrznego, naruszenia zasady podwójnego zapisu, niespójności typologiczne i inne odchylenia jakościowe |

Raport dostępny jest w formie wyniku zapytania SQL:

```sql
SELECT
    kpi_name            AS [KPI],
    kpi_type            AS [Typ],
    expected_value      AS [Oczekiwana (staging)],
    actual_value        AS [Rzeczywista (prod)],
    delta               AS [Delta],
    CASE WHEN pass = 1 THEN 'PASS'
         WHEN kpi_type = 'ANOMALY' THEN 'WARN'
         ELSE 'FAIL' END AS [Status],
    ISNULL(note, '')    AS [Uwaga]
FROM dm_staging.log.postmigration_check
WHERE run_id = <run_id>
ORDER BY check_id;
```

Przykładowy wynik (scenariusz testowy etapu 0: N = 250 000 spraw):

| KPI | Typ | Oczekiwana (staging) | Rzeczywista (prod) | Delta | Status | Uwaga |
|---|---|---|---|---|---|---|
| KPI_CNT_01 dluznik | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_02 sprawa | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_03 wierzytelnosc | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_04 sprawa_rola | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_06 adres | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_07 telefon | COUNT | 250 000 | 250 000 | 0 | PASS | |
| KPI_CNT_09 akcja | COUNT | 500 000 | 498 312 | -1 688 | FAIL | Część rekordów akcji odrzucona z powodu brakującego `ak_akt_id` — wymaga korekty w danych źródłowych |
| KPI_CNT_10 dokument | COUNT | ≥ 250 000 | 500 000 | 250 000 | PASS | Iter9 generuje dodatkowe rekordy dokumentów z harmonogramów |
| KPI_CNT_11 ksiegowanie | COUNT | ≥ 250 000 | 750 000 | 500 000 | PASS | Iter8 i iter9 generują dodatkowe rekordy z operacji i harmonogramów |
| KPI_CNT_12 ksiegowanie_dekret | COUNT | ≥ 500 000 | 1 750 000 | 1 250 000 | PASS | Operacje i harmonogramy generują dodatkowe dekrety |
| KPI_CNT_13 błędy migracji | COUNT | 0 | 0 | 0 | PASS | |
| KPI_SUM_01 suma ksd_kwota | SUM | 0,00 | 1 125 000 000,00 | 1 125 000 000,00 | FAIL | `ksd_kwota` nie zasilona w stagingu — znany brak w danych testowych |
| KPI_SUM_02 kwota operacji vs ksd_wn | SUM | 375 000 000,00 | 375 000 000,00 | 0,00 | PASS | |
| KPI_SUM_03 kapitał PLN | SUM | 300 000 000,00 | 375 000 000,00 | 75 000 000,00 | FAIL | Identyfikatory kont kapitałowych (`ksk_id`) do potwierdzenia z zespołem deweloperskim |
| KPI_SUM_04 odsetki PLN | SUM | 75 000 000,00 | 0,00 | 75 000 000,00 | FAIL | Identyfikatory kont odsetkowych (`ksk_id`) do potwierdzenia z zespołem deweloperskim |
| KPI_ANO_01 wi bez dokumentu | ANOMALY | 0 | 0 | 0 | PASS | |
| KPI_ANO_02 ks bez dekretu | ANOMALY | 0 | 0 | 0 | PASS | |
| KPI_ANO_06 dluznik bez identyfikatora | ANOMALY | 0 | 43 | 43 | WARN | 43 dłużników bez PESEL, NIP, dowodu ani paszportu — wymaga weryfikacji jakości danych |
| KPI_ANO_07 niezbilansowane dekrety | ANOMALY | 0 | 250 000 | 250 000 | WARN | Dekrety generowane przez harmonogramy — zachowanie oczekiwane |
| KPI_ANO_08 ext_id NULL | ANOMALY | 0 | 0 | 0 | PASS | |
| KPI_ANO_09 ext_id duplikaty | ANOMALY | 0 | 0 | 0 | PASS | |

---

## 7. Odbiór procesu migracji

Na podstawie danych zawartych w raporcie pomigracyjnym zespół Intrum dokonuje formalnego odbioru procesu migracji. Odbiór potwierdza poprawność i kompletność przeniesionych danych.

W przypadku stwierdzenia istotnych rozbieżności lub błędów uniemożliwiających prawidłowe funkcjonowanie systemu, zespół Intrum podejmuje decyzję o wycofaniu zmian z bazy produkcyjnej (rollback). Decyzja o rollbacku musi zostać podjęta i przekazana zespołowi BAKK niezwłocznie po zakończeniu analizy raportu pomigracyjnego.

*Szczegółowe kryteria odbioru oraz procedura rollbacku — TBD.*
