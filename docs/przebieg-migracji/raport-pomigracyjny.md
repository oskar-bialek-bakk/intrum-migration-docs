# Raport pomigracyjny

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
