---
title: "Migracja ⬝ Raport pomigracyjny"
---

# Raport pomigracyjny

Po zakończeniu migracji zespół BAKK uruchamia skrypt `99_post_report.sql`, który przeprowadza automatyczną weryfikację jakości danych bezpośrednio na bazie produkcyjnej `dm_data_web`. Wyniki zapisywane są w tabeli `dm_staging.log.postmigration_check` i obejmują łącznie 30 wskaźników KPI podzielonych na trzy kategorie.

Raport jest przekazywany zespołowi Intrum jako podstawa formalnego odbioru. Warunek zaliczenia dla wskaźników COUNT: liczba rekordów w produkcji równa się sumie stanu sprzed migracji (snapshot) i liczby rekordów zasilonych w stagingu. Dla etapu 1, gdzie baza produkcyjna była pusta przed migracją, snapshot = 0, więc wymagana liczba produkcyjna = liczba stagingowa.

<div class="api-section" markdown>
<div class="api-section-title">Kategorie KPI</div>

<div class="kategoria-grid">

<div class="kategoria-card kategoria-count">
  <div class="kategoria-header">
    <span class="kategoria-code">COUNT</span>
    <span class="kategoria-meta">13 KPI</span>
  </div>
  <p class="kategoria-desc">Uzgodnienie liczebności — czy liczba rekordów w każdej tabeli produkcyjnej odpowiada oczekiwanej (snapshot + staging).</p>
</div>

<div class="kategoria-card kategoria-sum">
  <div class="kategoria-header">
    <span class="kategoria-code">SUM</span>
    <span class="kategoria-meta">4 KPI</span>
  </div>
  <p class="kategoria-desc">Uzgodnienie finansowe — czy sumy kwot kluczowych kolumn finansowych (wierzytelności, dekrety) zgadzają się ze stagingiem.</p>
</div>

<div class="kategoria-card kategoria-anomaly">
  <div class="kategoria-header">
    <span class="kategoria-code">ANOMALY</span>
    <span class="kategoria-meta">13 KPI</span>
  </div>
  <p class="kategoria-desc">Jakość danych — rekordy bez wymaganego identyfikatora zewnętrznego, naruszenia zasady podwójnego zapisu, niespójności typologiczne i inne odchylenia.</p>
</div>

</div>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Zapytanie diagnostyczne</div>

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

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Przykładowy wynik</div>

Scenariusz testowy etapu 0: N = 250 000 spraw.

<div class="kpi-summary-strip">
  <div class="kpi-summary-tile kpi-summary-total">
    <span class="kpi-summary-num">21</span>
    <span class="kpi-summary-label">Wskaźniki</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-pass">
    <span class="kpi-summary-num">15</span>
    <span class="kpi-summary-label">PASS</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-fail">
    <span class="kpi-summary-num">4</span>
    <span class="kpi-summary-label">FAIL</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-warn">
    <span class="kpi-summary-num">2</span>
    <span class="kpi-summary-label">WARN</span>
  </div>
</div>

<div class="report-dashboard">
<table class="report-table">
  <thead>
    <tr>
      <th class="col-kpi">KPI</th>
      <th class="col-typ">Typ</th>
      <th class="col-num">Oczekiwana (staging)</th>
      <th class="col-num">Rzeczywista (prod)</th>
      <th class="col-num">Delta</th>
      <th class="col-status">Status</th>
      <th class="col-uwaga">Uwaga</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>KPI_CNT_01 dluznik</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_02 sprawa</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_03 wierzytelnosc</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_04 sprawa_rola</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_06 adres</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_07 telefon</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_CNT_09 akcja</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">500 000</td>
      <td class="num">498 312</td>
      <td class="num delta-neg">-1 688</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Część rekordów akcji odrzucona z powodu brakującego <code>ak_akt_id</code> — wymaga korekty w danych źródłowych</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_10 dokument</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 250 000</td>
      <td class="num">500 000</td>
      <td class="num delta-pos">250 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Iteracja 9 generuje dodatkowe rekordy dokumentów z harmonogramów</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_11 ksiegowanie</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 250 000</td>
      <td class="num">750 000</td>
      <td class="num delta-pos">500 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Iteracja 8 i iteracja 9 generują dodatkowe rekordy z operacji i harmonogramów</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_12 ksiegowanie_dekret</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 500 000</td>
      <td class="num">1 750 000</td>
      <td class="num delta-pos">1 250 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Operacje i harmonogramy generują dodatkowe dekrety</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_13 błędy migracji</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_01 suma ksd_kwota</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">0,00</td>
      <td class="num">1 125 000 000,00</td>
      <td class="num delta-pos">1 125 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note"><code>ksd_kwota</code> nie zasilona w stagingu — znany brak w danych testowych</span></td>
    </tr>
    <tr>
      <td><code>KPI_SUM_02 kwota operacji vs ksd_wn</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">375 000 000,00</td>
      <td class="num">375 000 000,00</td>
      <td class="num">0,00</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_03 kapitał PLN</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">300 000 000,00</td>
      <td class="num">375 000 000,00</td>
      <td class="num delta-pos">75 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Identyfikatory kont kapitałowych (<code>ksk_id</code>) do potwierdzenia z zespołem deweloperskim</span></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_04 odsetki PLN</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">75 000 000,00</td>
      <td class="num">0,00</td>
      <td class="num delta-neg">75 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Identyfikatory kont odsetkowych (<code>ksk_id</code>) do potwierdzenia z zespołem deweloperskim</span></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_01 wi bez dokumentu</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_02 ks bez dekretu</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-warn">
      <td><code>KPI_ANO_06 dluznik bez identyfikatora</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">43</td>
      <td class="num delta-pos">43</td>
      <td><span class="status-pill status-warn">WARN</span></td>
      <td><span class="kpi-note">43 dłużników bez PESEL, NIP, dowodu ani paszportu — wymaga weryfikacji jakości danych</span></td>
    </tr>
    <tr class="row-warn">
      <td><code>KPI_ANO_07 niezbilansowane dekrety</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">250 000</td>
      <td class="num delta-pos">250 000</td>
      <td><span class="status-pill status-warn">WARN</span></td>
      <td><span class="kpi-note">Dekrety generowane przez harmonogramy — zachowanie oczekiwane</span></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_08 ext_id NULL</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_09 ext_id duplikaty</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>

</div>
